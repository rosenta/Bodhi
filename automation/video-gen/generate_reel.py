#!/usr/bin/env python3
"""
generate_reel.py — Build a 9:16 1080x1920 MP4 from a reel JSON script.

Fully local. Zero paid APIs.
- TTS via Piper (if PIPER_BIN set) or macOS `say` fallback.
- Visuals: source.unsplash.com stock image + FFmpeg Ken Burns, gradient on fail.
- Ollama for query rewriting of scene descriptions (optional).
- FFmpeg concat + drawtext + optional music bed mix.

Usage:
    python3 generate_reel.py <path/to/reel.json> [output.mp4]

Env knobs:
    TTS_ENGINE    piper | say | auto (default auto)
    USE_STOCK     1 | 0 (default 1)
    USE_OLLAMA    1 | 0 (default 1)
    OLLAMA_MODEL  default llama3.2:3b
    MUSIC_BED     path to mp3 (default music/bed.mp3 if present)
    FONT_FILE     default /System/Library/Fonts/Supplemental/Arial.ttf
"""

from __future__ import annotations

import json
import os
import re
import shlex
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parent
TOOLS = ROOT / "tools"
CACHE = ROOT / "cache"
OUTPUT = ROOT / "output"
MUSIC = ROOT / "music"

WIDTH, HEIGHT, FPS = 1080, 1920, 30

DEFAULT_FONT = os.environ.get(
    "FONT_FILE",
    "/System/Library/Fonts/Supplemental/Arial.ttf",
)
if not Path(DEFAULT_FONT).exists():
    # common macOS fallbacks
    for alt in (
        "/System/Library/Fonts/Helvetica.ttc",
        "/Library/Fonts/Arial.ttf",
        "/System/Library/Fonts/HelveticaNeue.ttc",
    ):
        if Path(alt).exists():
            DEFAULT_FONT = alt
            break


@dataclass(frozen=True)
class Scene:
    idx: int
    target_duration: float
    visual: str
    voiceover: str
    text_overlay: str


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def run(cmd: list[str], *, check: bool = True, capture: bool = False) -> subprocess.CompletedProcess:
    """Run a subprocess. Raise on non-zero unless check=False."""
    kwargs: dict = {"text": True}
    if capture:
        kwargs["stdout"] = subprocess.PIPE
        kwargs["stderr"] = subprocess.PIPE
    res = subprocess.run(cmd, **kwargs)
    if check and res.returncode != 0:
        err = res.stderr if capture else ""
        raise RuntimeError(f"command failed ({res.returncode}): {' '.join(shlex.quote(c) for c in cmd)}\n{err}")
    return res


def ffprobe_duration(path: Path) -> float:
    res = run(
        [
            "ffprobe", "-v", "error",
            "-show_entries", "format=duration",
            "-of", "default=noprint_wrappers=1:nokey=1",
            str(path),
        ],
        capture=True,
    )
    return float(res.stdout.strip())


def parse_time_window(s: str) -> float:
    """Turn '0-6s' or '6-15s' into target duration (seconds)."""
    m = re.match(r"\s*(\d+(?:\.\d+)?)\s*-\s*(\d+(?:\.\d+)?)\s*s?\s*$", s)
    if not m:
        return 6.0
    a, b = float(m.group(1)), float(m.group(2))
    return max(1.0, b - a)


def load_scenes(path: Path) -> tuple[dict, list[Scene]]:
    data = json.loads(path.read_text())
    scenes = []
    for i, s in enumerate(data.get("script", []), start=1):
        scenes.append(
            Scene(
                idx=i,
                target_duration=parse_time_window(s.get("time", "0-6s")),
                visual=s.get("visual", "").strip(),
                voiceover=s.get("voiceover", "").strip(),
                text_overlay=s.get("text_overlay", "").strip(),
            )
        )
    return data, scenes


# ---------------------------------------------------------------------------
# Voiceover
# ---------------------------------------------------------------------------

def synthesise_voice(text: str, out_wav: Path) -> None:
    engine = os.environ.get("TTS_ENGINE", "auto")
    script = TOOLS / "synthesize_voice.sh"
    if not text.strip():
        # produce a silent placeholder so downstream duration logic still works
        run([
            "ffmpeg", "-y", "-loglevel", "error",
            "-f", "lavfi", "-i", "anullsrc=r=44100:cl=mono",
            "-t", "0.5", str(out_wav),
        ])
        return
    run(["bash", str(script), text, str(out_wav), engine])


# ---------------------------------------------------------------------------
# Visual asset
# ---------------------------------------------------------------------------

def rewrite_query(visual: str) -> str:
    if os.environ.get("USE_OLLAMA", "1") != "1":
        return " ".join(visual.split()[:4])
    script = TOOLS / "ollama_visual_query.sh"
    try:
        res = run(["bash", str(script), visual], capture=True, check=False)
        q = res.stdout.strip().splitlines()[0].strip() if res.stdout else ""
        return q or " ".join(visual.split()[:4])
    except Exception:
        return " ".join(visual.split()[:4])


def fetch_stock_image(query: str, out_jpg: Path) -> bool:
    if os.environ.get("USE_STOCK", "1") != "1":
        return False
    script = TOOLS / "fetch_stock_image.sh"
    res = run(["bash", str(script), query, str(out_jpg)], check=False, capture=True)
    return res.returncode == 0 and out_jpg.exists() and out_jpg.stat().st_size > 10_000


def palette_for(idx: int) -> tuple[str, str]:
    """Deterministic palette per scene (hex colors without '#')."""
    palettes = [
        ("1a1a2e", "0f3460"),
        ("2c3e50", "4ca1af"),
        ("373B44", "4286f4"),
        ("141E30", "243B55"),
        ("232526", "414345"),
        ("000000", "434343"),
        ("3e5151", "decba4"),
    ]
    return palettes[(idx - 1) % len(palettes)]


def make_gradient_image(idx: int, out_jpg: Path) -> None:
    c1, c2 = palette_for(idx)
    # Two-color vertical gradient via ffmpeg gradients filter
    run([
        "ffmpeg", "-y", "-loglevel", "error",
        "-f", "lavfi",
        "-i", f"gradients=s={WIDTH}x{HEIGHT}:c0=0x{c1}:c1=0x{c2}:duration=1:speed=0",
        "-frames:v", "1",
        str(out_jpg),
    ])


# ---------------------------------------------------------------------------
# Scene clip (Ken Burns + overlay text + VO)
# ---------------------------------------------------------------------------

def _ffmpeg_escape_text(s: str) -> str:
    # For drawtext: escape \, ', :, %
    return (
        s.replace("\\", "\\\\")
         .replace("'", "\u2019")   # curly apostrophe — safer than escaping
         .replace(":", "\\:")
         .replace("%", "\\%")
    )


def build_scene_clip(scene: Scene, img: Path, vo: Path, out_mp4: Path) -> None:
    vo_dur = ffprobe_duration(vo)
    # Real duration: max of target-from-JSON and measured VO (so VO never clips).
    dur = max(scene.target_duration, vo_dur + 0.25)
    total_frames = int(round(dur * FPS))

    # Ken Burns: gently zoom from 1.0 → 1.08 over the duration, drifting center.
    # Direction alternates per scene for variety.
    zoom_in = scene.idx % 2 == 1
    if zoom_in:
        zoom_expr = "min(zoom+0.0008,1.12)"
        x_expr = "iw/2-(iw/zoom/2)"
        y_expr = "ih/2-(ih/zoom/2)"
    else:
        # Zoom from 1.12 -> 1.0 (slow pull-out)
        zoom_expr = "if(lte(zoom,1.0),1.12,max(1.0,zoom-0.0008))"
        x_expr = "iw/2-(iw/zoom/2)"
        y_expr = "ih/2-(ih/zoom/2)"

    # Build video filter graph
    vf_parts = [
        # Pre-scale big so zoompan has resolution to crop from without blur.
        f"scale={WIDTH*2}:{HEIGHT*2}:force_original_aspect_ratio=increase",
        f"crop={WIDTH*2}:{HEIGHT*2}",
        f"zoompan=z='{zoom_expr}':x='{x_expr}':y='{y_expr}':d={total_frames}:s={WIDTH}x{HEIGHT}:fps={FPS}",
        "format=yuv420p",
    ]

    # Text overlay (drawtext) — either the explicit text_overlay, or the VO
    # as a subtitle-like caption (wrapped). We show only text_overlay if set.
    overlay_text = scene.text_overlay
    if overlay_text:
        safe = _ffmpeg_escape_text(overlay_text)
        font = DEFAULT_FONT
        vf_parts.append(
            f"drawtext=fontfile='{font}':text='{safe}':"
            f"fontcolor=white:fontsize=72:"
            f"box=1:boxcolor=black@0.55:boxborderw=24:"
            f"x=(w-text_w)/2:y=h-th-220"
        )

    vf = ",".join(vf_parts)

    # Create a looped-image source of the right duration, attach VO audio
    # padded with trailing silence so it matches dur exactly. No -shortest.
    af = f"apad=whole_dur={dur:.3f},aresample=async=1"
    run([
        "ffmpeg", "-y", "-loglevel", "error",
        "-loop", "1", "-t", f"{dur:.3f}", "-i", str(img),
        "-i", str(vo),
        "-vf", vf,
        "-af", af,
        "-c:v", "libx264", "-preset", "medium", "-crf", "20",
        "-r", str(FPS),
        "-c:a", "aac", "-b:a", "192k",
        "-t", f"{dur:.3f}",
        "-movflags", "+faststart",
        str(out_mp4),
    ])


# ---------------------------------------------------------------------------
# Concat + music mix
# ---------------------------------------------------------------------------

def concat_scenes(clips: list[Path], out_mp4: Path) -> None:
    list_file = CACHE / "_concat_list.txt"
    list_file.write_text("\n".join(f"file '{c.resolve()}'" for c in clips) + "\n")
    run([
        "ffmpeg", "-y", "-loglevel", "error",
        "-f", "concat", "-safe", "0", "-i", str(list_file),
        "-c", "copy",
        str(out_mp4),
    ])


def mix_music(base_mp4: Path, music: Path, out_mp4: Path) -> None:
    run([
        "ffmpeg", "-y", "-loglevel", "error",
        "-i", str(base_mp4),
        "-stream_loop", "-1", "-i", str(music),
        "-filter_complex",
        "[1:a]volume=0.10[bed];[0:a][bed]amix=inputs=2:duration=first:dropout_transition=0[a]",
        "-map", "0:v", "-map", "[a]",
        "-c:v", "copy",
        "-c:a", "aac", "-b:a", "192k",
        "-shortest",
        "-movflags", "+faststart",
        str(out_mp4),
    ])


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def main() -> int:
    if len(sys.argv) < 2:
        print(__doc__)
        return 2

    reel_path = Path(sys.argv[1]).resolve()
    if not reel_path.exists():
        print(f"reel json not found: {reel_path}", file=sys.stderr)
        return 2

    CACHE.mkdir(parents=True, exist_ok=True)
    OUTPUT.mkdir(parents=True, exist_ok=True)

    data, scenes = load_scenes(reel_path)
    reel_id = data.get("id", reel_path.stem)
    slug = re.sub(r"[^A-Za-z0-9_-]+", "-", str(reel_path.stem))
    print(f"[reel] {reel_path.name} — {data.get('title', '(untitled)')} — {len(scenes)} scenes")

    # Dedicated per-reel cache to avoid cross-contamination
    scache = CACHE / slug
    scache.mkdir(parents=True, exist_ok=True)

    scene_clips: list[Path] = []
    for scene in scenes:
        print(f"[scene {scene.idx}] target={scene.target_duration:.1f}s — "
              f"VO='{scene.voiceover[:60]}{'…' if len(scene.voiceover) > 60 else ''}'")
        vo_wav = scache / f"vo_{scene.idx:02d}.wav"
        img_jpg = scache / f"img_{scene.idx:02d}.jpg"
        clip_mp4 = scache / f"scene_{scene.idx:02d}.mp4"

        synthesise_voice(scene.voiceover, vo_wav)

        query = rewrite_query(scene.visual) if scene.visual else f"abstract scene {scene.idx}"
        print(f"[scene {scene.idx}] query='{query}'")
        got_stock = fetch_stock_image(query, img_jpg)
        if not got_stock:
            print(f"[scene {scene.idx}] stock fetch failed — using gradient")
            make_gradient_image(scene.idx, img_jpg)

        build_scene_clip(scene, img_jpg, vo_wav, clip_mp4)
        scene_clips.append(clip_mp4)

    # Concat
    concat_mp4 = scache / "_concat.mp4"
    concat_scenes(scene_clips, concat_mp4)

    # Output name
    out_name = sys.argv[2] if len(sys.argv) > 2 else f"reel-{reel_id}.mp4"
    final_mp4 = OUTPUT / out_name
    final_mp4.parent.mkdir(parents=True, exist_ok=True)

    music_path = Path(os.environ.get("MUSIC_BED", str(MUSIC / "bed.mp3")))
    if music_path.exists():
        print(f"[mix] mixing music bed: {music_path}")
        mix_music(concat_mp4, music_path, final_mp4)
    else:
        shutil.copy2(concat_mp4, final_mp4)

    dur = ffprobe_duration(final_mp4)
    size_mb = final_mp4.stat().st_size / (1024 * 1024)
    print(f"[done] {final_mp4}  duration={dur:.2f}s  size={size_mb:.2f}MB")
    return 0


if __name__ == "__main__":
    sys.exit(main())
