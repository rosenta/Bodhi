"""Replace Vivekachudamani verse-explainer audio with ElevenLabs Brian renders.

Reads `data/top-30-verses.json`, synthesizes the `hindi_explanation` field for
each verse via ElevenLabs `eleven_multilingual_v2` (Brian voice — same settings
as the approved Gate-1 sample), and overwrites
`website/public/audio/vivekachudamani/<verse_number>.mp3` in place.

The original MMS-TTS audio is backed up to
`automation/video-gen/cache/elevenlabs-migration/backup-mms/` once per run.

Resumability: a sidecar marker `.elevenlabs.json` in the output dir records
which verse_numbers have been migrated. Re-running the script will skip them
unless `--force` is given.

Failure handling: stop on the first synthesis failure; the partial backup is
preserved so a re-run can resume.

Usage:
    python automation/video-gen/tools/elevenlabs_verse_batch.py            # all 30 verses
    python automation/video-gen/tools/elevenlabs_verse_batch.py --limit 3  # first 3 only (dry-run-ish, real spend)
    python automation/video-gen/tools/elevenlabs_verse_batch.py --force    # re-do already-migrated
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[3]
VERSES_JSON = PROJECT_ROOT / "data" / "top-30-verses.json"
PUBLIC_AUDIO_DIR = PROJECT_ROOT / "website" / "public" / "audio" / "vivekachudamani"
BACKUP_DIR = (
    PROJECT_ROOT / "automation" / "video-gen" / "cache" / "elevenlabs-migration" / "backup-mms"
)
MARKER_PATH = PUBLIC_AUDIO_DIR / ".elevenlabs.json"
KEY_PATH = Path("~/.config/elevenlabs/key").expanduser()

VOICE_ID_BRIAN = "nPczCjzI2devNBz1zQrb"
MODEL_ID = "eleven_multilingual_v2"
VOICE_SETTINGS = {
    "stability": 0.55,
    "similarity_boost": 0.75,
    "style": 0.30,
    "use_speaker_boost": True,
}


def load_api_key() -> str:
    if not KEY_PATH.is_file():
        sys.exit(f"[err] ElevenLabs key not found at {KEY_PATH}")
    return KEY_PATH.read_text().strip()


def load_marker() -> dict:
    if MARKER_PATH.is_file():
        return json.loads(MARKER_PATH.read_text())
    return {"migrated": {}, "voice": "Brian", "voice_id": VOICE_ID_BRIAN, "model": MODEL_ID}


def save_marker(marker: dict) -> None:
    MARKER_PATH.write_text(json.dumps(marker, ensure_ascii=False, indent=2))


def synthesize(api_key: str, text: str) -> bytes:
    url = f"https://api.elevenlabs.io/v1/text-to-speech/{VOICE_ID_BRIAN}"
    payload = json.dumps(
        {
            "text": text,
            "model_id": MODEL_ID,
            "voice_settings": VOICE_SETTINGS,
        }
    ).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=payload,
        method="POST",
        headers={
            "xi-api-key": api_key,
            "Content-Type": "application/json",
            "Accept": "audio/mpeg",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            return resp.read()
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")[:500]
        raise RuntimeError(f"HTTP {e.code} — {body}") from e


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--limit", type=int, default=0, help="Synth only first N verses (0 = all)")
    parser.add_argument("--force", action="store_true", help="Re-synth already-migrated verses")
    parser.add_argument("--dry-run", action="store_true", help="List planned spend, do nothing")
    args = parser.parse_args()

    if not VERSES_JSON.is_file():
        sys.exit(f"[err] missing {VERSES_JSON}")

    verses = json.loads(VERSES_JSON.read_text())
    if not isinstance(verses, list):
        sys.exit("[err] expected list shape in top-30-verses.json")

    BACKUP_DIR.mkdir(parents=True, exist_ok=True)
    PUBLIC_AUDIO_DIR.mkdir(parents=True, exist_ok=True)

    marker = load_marker()
    migrated = marker.setdefault("migrated", {})

    plan: list[tuple[int, str, str]] = []  # (verse_number, hindi_text, public_mp3_path)
    for v in verses:
        vnum = v.get("verse_number")
        text = (v.get("hindi_explanation") or "").strip()
        if not vnum or not text:
            continue
        plan.append((vnum, text, str(PUBLIC_AUDIO_DIR / f"{vnum}.mp3")))

    if args.limit > 0:
        plan = plan[: args.limit]

    if not args.force:
        plan = [p for p in plan if str(p[0]) not in migrated]

    total_chars = sum(len(t) for _, t, _ in plan)
    print(f"[plan] {len(plan)} verses to synth, {total_chars:,} chars total")
    if args.dry_run:
        for vnum, text, path in plan:
            print(f"  - verse {vnum}: {len(text)} chars -> {path}")
        return 0

    if not plan:
        print("[done] nothing to do (use --force to re-synth)")
        return 0

    api_key = load_api_key()
    t0 = time.time()
    spent_chars = 0

    for i, (vnum, text, public_path) in enumerate(plan, start=1):
        print(f"[{i}/{len(plan)}] verse {vnum}: {len(text)} chars ...", end="", flush=True)

        public = Path(public_path)
        # one-time backup of the original MMS-TTS file
        backup = BACKUP_DIR / public.name
        if public.is_file() and not backup.is_file():
            shutil.copy2(public, backup)

        try:
            audio_bytes = synthesize(api_key, text)
        except Exception as e:
            print(f"  FAILED: {e}")
            print(f"[stop] spent ~{spent_chars:,} chars before failure. Run again to resume.")
            save_marker(marker)
            return 1

        public.write_bytes(audio_bytes)
        spent_chars += len(text)

        migrated[str(vnum)] = {
            "chars": len(text),
            "bytes": len(audio_bytes),
            "voice": "Brian",
            "model": MODEL_ID,
            "synthed_at": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
        }
        # save marker after every successful synth so partial runs are resumable
        save_marker(marker)

        size_kb = len(audio_bytes) / 1024
        print(f"  ok ({size_kb:.0f} KB)")

    elapsed = time.time() - t0
    print(
        f"\n[done] {len(plan)} verses, {spent_chars:,} chars, {elapsed:.1f}s wall, "
        f"backups in {BACKUP_DIR.relative_to(PROJECT_ROOT)}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
