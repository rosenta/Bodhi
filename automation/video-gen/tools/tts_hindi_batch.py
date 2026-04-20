"""Hindi TTS batch generator for Project Bodhi.

Reads ``hindi_explanation`` fields from a JSON source file (either the flat
``top-30-verses.json`` or the nested ``yoga-sutras-complete.json``) and
renders one MP3 per item using the approved **v2-winner** recipe:

  * ``facebook/mms-tts-hin`` VITS synthesis
  * Sentence-chunked rendering with real silences
  * FFmpeg warm-EQ + gentle compression + subtle verb + loudnorm

The output MP3 filename is the item identifier: ``<verse_number>.mp3`` for
verses (e.g. ``2.mp3``) or ``<sutra_number>.mp3`` for sutras (e.g.
``1.33.mp3``).

Usage
-----

Render five verses::

    python tts_hindi_batch.py \\
        --source data/top-30-verses.json \\
        --out-dir website/public/audio/vivekachudamani \\
        --keys 2,6,11,20,32

Render five sutras::

    python tts_hindi_batch.py \\
        --source data/yoga-sutras-complete.json \\
        --out-dir website/public/audio/yoga-sutras \\
        --keys 1.1,1.2,1.33,2.3,2.16

Omit ``--keys`` to render every item that has a ``hindi_explanation`` field.

WAV intermediates are cached in ``--wav-cache`` (default
``automation/video-gen/cache/tts-wave1``) so future runs can reuse them
without re-synthesizing.

A per-file summary is appended to ``--log`` (default
``automation/video-gen/logs/tts-wave1.log``).

Constraints
-----------
* Fully local; no network calls beyond the one-time HuggingFace model pull.
* MPS preferred, CPU fallback on error (``PYTORCH_ENABLE_MPS_FALLBACK=1``).
* Never mutates the source JSON.
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

# Must be set before importing torch/transformers for the MPS fallback paths
# the v2-winner recipe relies on.
os.environ.setdefault("PYTORCH_ENABLE_MPS_FALLBACK", "1")
os.environ.setdefault("HF_HUB_DISABLE_XET", "1")

import warnings

warnings.filterwarnings("ignore")

import numpy as np  # noqa: E402
import scipy.io.wavfile  # noqa: E402
import torch  # noqa: E402
import transformers  # noqa: E402
from transformers import AutoTokenizer, VitsModel  # noqa: E402

transformers.logging.set_verbosity_error()

TARGET_SR = 22_050
MODEL_ID = "facebook/mms-tts-hin"
SENTENCE_GAP = 0.35  # seconds between non-terminal chunks
TERMINAL_GAP = 0.70  # seconds after '।' terminated sentences
QUESTION_GAP = 0.80  # seconds after question mark

# Winner FFmpeg chain (see samples/hindi-voice/_build/gen_mms_v2.py step 5).
WINNER_CHAIN = (
    "asoftclip=type=tanh:param=0.7,"
    "equalizer=f=200:t=h:w=150:g=1.5,"
    "equalizer=f=4000:t=h:w=2000:g=-1.5,"
    "acompressor=threshold=-18dB:ratio=2:attack=20:release=250,"
    "aecho=0.8:0.9:40:0.15"
)


@dataclass(frozen=True)
class Item:
    """A single piece of Hindi text to synthesize."""

    key: str
    text: str


# ---------------------------------------------------------------------------
# Data extraction
# ---------------------------------------------------------------------------


def load_items(source: Path, keys: list[str] | None) -> list[Item]:
    """Load items from either the verses JSON (flat) or the sutras JSON (nested)."""
    with source.open("r", encoding="utf-8") as fh:
        data = json.load(fh)

    items: list[Item] = []

    if isinstance(data, list):
        # top-30-verses.json shape: list of {verse_number, hindi_explanation, ...}
        for v in data:
            if not isinstance(v, dict):
                continue
            key = str(v.get("verse_number"))
            text = v.get("hindi_explanation")
            if not text:
                continue
            items.append(Item(key=key, text=text))
    elif isinstance(data, dict) and "padas" in data:
        # yoga-sutras-complete.json shape: {padas: [{sutras: [{sutra_number, hindi_explanation, ...}]}]}
        for pada in data.get("padas", []):
            for s in pada.get("sutras", []):
                key = str(s.get("sutra_number"))
                text = s.get("hindi_explanation")
                if not text:
                    continue
                items.append(Item(key=key, text=text))
    else:
        raise ValueError(f"Unrecognized JSON shape in {source}")

    if keys is not None:
        wanted = set(keys)
        kept = [it for it in items if it.key in wanted]
        missing = wanted - {it.key for it in kept}
        if missing:
            raise KeyError(f"Keys not found with hindi_explanation: {sorted(missing)}")
        return kept
    return items


# ---------------------------------------------------------------------------
# Synthesis
# ---------------------------------------------------------------------------


def pick_device() -> torch.device:
    """Return preferred torch device for VITS synthesis.

    MMS-TTS-Hindi VITS produces broken (dramatically stretched) output on MPS
    because the stochastic duration predictor does not round-trip correctly on
    Apple Silicon. The approved v2-winner baseline was generated on CPU, so we
    stick with CPU here. Callers can override by setting
    ``BODHI_TTS_DEVICE=mps`` or ``cuda``.
    """
    override = os.environ.get("BODHI_TTS_DEVICE", "").strip().lower()
    if override in {"mps", "cuda", "cpu"}:
        return torch.device(override)
    return torch.device("cpu")


def load_model(device: torch.device) -> tuple[VitsModel, AutoTokenizer, int]:
    print(f"[load] {MODEL_ID} on {device}", flush=True)
    model = VitsModel.from_pretrained(MODEL_ID).to(device)
    tokenizer = AutoTokenizer.from_pretrained(MODEL_ID)
    model.eval()
    return model, tokenizer, int(model.config.sampling_rate)


def split_sentences(text: str) -> list[tuple[str, float]]:
    """Split Hindi text into chunks with trailing-silence durations.

    Strategy:
      * Normalize em-dashes and collapse newlines.
      * Split on Devanagari full-stop ``।``, ``?``, ``.`` while keeping the
        delimiter attached to each chunk.
      * Within each sentence, further split on commas for chunked synthesis,
        since MMS-TTS-hin prosody degrades on very long utterances.
    """
    cleaned = text.replace("—", " — ").replace("\n", " ")
    # Split into sentences preserving terminators
    sentences: list[str] = []
    buf: list[str] = []
    for ch in cleaned:
        buf.append(ch)
        if ch in "।?.":
            sent = "".join(buf).strip()
            if sent:
                sentences.append(sent)
            buf = []
    tail = "".join(buf).strip()
    if tail:
        # no terminator; treat as sentence ending in ।
        sentences.append(tail + "।")

    out: list[tuple[str, float]] = []
    for sent in sentences:
        terminator = sent[-1] if sent[-1] in "।?." else "।"
        if terminator == "?":
            end_gap = QUESTION_GAP
        elif terminator == "।":
            end_gap = TERMINAL_GAP
        else:  # '.'
            end_gap = TERMINAL_GAP
        body = sent[:-1].strip() if sent[-1] in "।?." else sent
        parts = [p.strip(" ,।") for p in body.split(",") if p.strip(" ,।")]
        if not parts:
            continue
        for i, part in enumerate(parts):
            last = i == len(parts) - 1
            if last:
                chunk = part + terminator
                gap = end_gap
            else:
                chunk = part + "।"  # brief terminator hint for the model
                gap = SENTENCE_GAP
            out.append((chunk, gap))
    return out


def synth_chunk(
    model: VitsModel,
    tokenizer: AutoTokenizer,
    device: torch.device,
    text: str,
    *,
    speaking_rate: float,
    noise_scale: float,
    noise_scale_duration: float,
    seed: int,
) -> np.ndarray:
    """Synthesize a single chunk; returns empty array if the chunk is all non-Devanagari."""
    torch.manual_seed(seed)
    model.speaking_rate = speaking_rate
    model.noise_scale = noise_scale
    model.noise_scale_duration = noise_scale_duration
    inputs = tokenizer(text, return_tensors="pt")
    # MMS-TTS-Hindi tokenizer drops all non-Devanagari characters. If the chunk
    # contains only ASCII (e.g. "bank balance।"), token count drops to zero and
    # the model raises a dtype error. Skip such chunks cleanly.
    if inputs.input_ids.shape[-1] == 0:
        return np.zeros(0, dtype=np.float32)
    inputs = inputs.to(device)
    with torch.no_grad():
        wav = model(**inputs).waveform.squeeze().detach().to("cpu").numpy().astype(np.float32)
    thresh = 0.005
    idx = np.where(np.abs(wav) > thresh)[0]
    if len(idx) > 10:
        wav = wav[max(0, idx[0] - 500) : min(len(wav), idx[-1] + 2000)]
    return wav


def silence(sr: int, seconds: float) -> np.ndarray:
    return np.zeros(int(seconds * sr), dtype=np.float32)


def synth_item(
    model: VitsModel,
    tokenizer: AutoTokenizer,
    device: torch.device,
    sr: int,
    text: str,
    *,
    speaking_rate: float = 0.9,
    noise_scale_pair: tuple[float, float] = (0.55, 0.72),
    noise_scale_duration: float = 0.88,
) -> np.ndarray:
    """Render a full item with the v2-winner ensemble + chunked recipe."""
    chunks = split_sentences(text)
    buf: list[np.ndarray] = []
    for i, (chunk, gap) in enumerate(chunks):
        a = synth_chunk(
            model,
            tokenizer,
            device,
            chunk,
            speaking_rate=speaking_rate,
            noise_scale=noise_scale_pair[0],
            noise_scale_duration=noise_scale_duration,
            seed=11 + i,
        )
        b = synth_chunk(
            model,
            tokenizer,
            device,
            chunk,
            speaking_rate=speaking_rate,
            noise_scale=noise_scale_pair[1],
            noise_scale_duration=noise_scale_duration,
            seed=101 + i,
        )
        if a.size == 0 or b.size == 0:
            # Chunk had no Devanagari characters after tokenization; preserve
            # pacing with a short silence only.
            buf.append(silence(sr, gap))
            continue
        n = min(len(a), len(b))
        mixed = 0.5 * a[:n] + 0.5 * b[:n]
        buf.append(mixed.astype(np.float32))
        buf.append(silence(sr, gap))
    if not buf:
        return np.zeros(0, dtype=np.float32)
    return np.concatenate(buf)


def save_wav(wav: np.ndarray, path: Path, sr: int) -> None:
    peak = float(np.max(np.abs(wav)) + 1e-9)
    if peak > 0.98:
        wav = wav / peak * 0.97
    pcm = (wav * 32767.0).astype(np.int16)
    path.parent.mkdir(parents=True, exist_ok=True)
    scipy.io.wavfile.write(str(path), sr, pcm)


# ---------------------------------------------------------------------------
# FFmpeg post-processing
# ---------------------------------------------------------------------------


def ff(cmd: list[str]) -> None:
    result = subprocess.run(cmd, check=False, capture_output=True)
    if result.returncode != 0:
        raise RuntimeError(
            f"ffmpeg failed:\n{' '.join(cmd)}\nSTDERR:\n{result.stderr.decode('utf-8', errors='replace')}"
        )


def ffprobe_duration(path: Path) -> float:
    result = subprocess.run(
        [
            "ffprobe",
            "-v",
            "error",
            "-show_entries",
            "format=duration",
            "-of",
            "default=noprint_wrappers=1:nokey=1",
            str(path),
        ],
        check=True,
        capture_output=True,
    )
    return float(result.stdout.decode().strip())


def render_mp3(src_wav: Path, out_mp3: Path) -> None:
    """Apply winner chain + loudnorm, write 22.05kHz mono 128kbps MP3."""
    out_mp3.parent.mkdir(parents=True, exist_ok=True)
    af = f"aresample={TARGET_SR},{WINNER_CHAIN},loudnorm=I=-16:TP=-1.5:LRA=11"
    ff(
        [
            "ffmpeg",
            "-y",
            "-i",
            str(src_wav),
            "-af",
            af,
            "-ar",
            str(TARGET_SR),
            "-ac",
            "1",
            "-c:a",
            "libmp3lame",
            "-b:a",
            "128k",
            str(out_mp3),
        ]
    )


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------


@dataclass
class Result:
    key: str
    mp3_path: Path | None
    duration_sec: float
    size_bytes: int
    wall_sec: float
    status: str
    note: str = ""


def process_item(
    item: Item,
    out_dir: Path,
    wav_cache: Path,
    model: VitsModel,
    tokenizer: AutoTokenizer,
    device: torch.device,
    sr: int,
) -> Result:
    started = time.time()
    try:
        wav = synth_item(model, tokenizer, device, sr, item.text)
    except Exception as exc:
        if device.type != "cpu":
            print(f"[warn] {device.type} synthesis failed for {item.key}: {exc}; falling back to CPU", flush=True)
            try:
                model.to("cpu")
                wav = synth_item(model, tokenizer, torch.device("cpu"), sr, item.text)
                model.to(device)  # restore original device for next item
            except Exception as exc2:  # pragma: no cover - defensive
                return Result(
                    key=item.key,
                    mp3_path=None,
                    duration_sec=0.0,
                    size_bytes=0,
                    wall_sec=time.time() - started,
                    status="failed",
                    note=f"{device.type}+CPU failure: {exc2}",
                )
        else:
            return Result(
                key=item.key,
                mp3_path=None,
                duration_sec=0.0,
                size_bytes=0,
                wall_sec=time.time() - started,
                status="failed",
                note=f"synthesis failure: {exc}",
            )

    if wav.size == 0:
        return Result(
            key=item.key,
            mp3_path=None,
            duration_sec=0.0,
            size_bytes=0,
            wall_sec=time.time() - started,
            status="failed",
            note="empty waveform",
        )

    wav_path = wav_cache / f"{item.key}.wav"
    save_wav(wav, wav_path, sr)

    mp3_path = out_dir / f"{item.key}.mp3"
    render_mp3(wav_path, mp3_path)

    duration = ffprobe_duration(mp3_path)
    size = mp3_path.stat().st_size

    if size < 30_000 or size > 2_000_000:
        return Result(
            key=item.key,
            mp3_path=mp3_path,
            duration_sec=duration,
            size_bytes=size,
            wall_sec=time.time() - started,
            status="suspect",
            note=f"size {size} outside [30KB, 2MB]",
        )
    if duration < 5 or duration > 120:
        return Result(
            key=item.key,
            mp3_path=mp3_path,
            duration_sec=duration,
            size_bytes=size,
            wall_sec=time.time() - started,
            status="suspect",
            note=f"duration {duration:.1f}s outside [5, 120]",
        )

    return Result(
        key=item.key,
        mp3_path=mp3_path,
        duration_sec=duration,
        size_bytes=size,
        wall_sec=time.time() - started,
        status="ok",
    )


def log_result(log_path: Path, source: Path, r: Result) -> None:
    log_path.parent.mkdir(parents=True, exist_ok=True)
    ts = time.strftime("%Y-%m-%d %H:%M:%S")
    path_str = str(r.mp3_path) if r.mp3_path else "-"
    line = (
        f"{ts}\t{source.name}\tkey={r.key}\tstatus={r.status}\t"
        f"dur={r.duration_sec:.2f}s\tsize={r.size_bytes}B\twall={r.wall_sec:.1f}s\t"
        f"path={path_str}\tnote={r.note}\n"
    )
    with log_path.open("a", encoding="utf-8") as fh:
        fh.write(line)


def parse_keys(raw: str | None) -> list[str] | None:
    if not raw:
        return None
    return [k.strip() for k in raw.split(",") if k.strip()]


def build_arg_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--source", type=Path, required=True, help="Path to source JSON file")
    p.add_argument("--out-dir", type=Path, required=True, help="Directory to write MP3 files")
    p.add_argument(
        "--keys",
        type=str,
        default=None,
        help="Comma-separated identifiers to render (e.g. 2,6,11 or 1.1,1.33). Omit for all items.",
    )
    p.add_argument(
        "--wav-cache",
        type=Path,
        default=Path("automation/video-gen/cache/tts-wave1"),
        help="Directory for WAV intermediates",
    )
    p.add_argument(
        "--log",
        type=Path,
        default=Path("automation/video-gen/logs/tts-wave1.log"),
        help="Per-item log file (appended)",
    )
    return p


def main(argv: Iterable[str] | None = None) -> int:
    args = build_arg_parser().parse_args(list(argv) if argv is not None else None)

    keys = parse_keys(args.keys)
    items = load_items(args.source, keys)
    print(f"[plan] {len(items)} item(s) from {args.source}", flush=True)

    device = pick_device()
    model, tokenizer, sr = load_model(device)

    args.out_dir.mkdir(parents=True, exist_ok=True)
    args.wav_cache.mkdir(parents=True, exist_ok=True)

    results: list[Result] = []
    total_start = time.time()
    for i, item in enumerate(items, 1):
        print(f"\n[{i}/{len(items)}] key={item.key} chars={len(item.text)}", flush=True)
        r = process_item(item, args.out_dir, args.wav_cache, model, tokenizer, device, sr)
        log_result(args.log, args.source, r)
        results.append(r)
        if r.status == "ok":
            print(
                f"  ok  -> {r.mp3_path} dur={r.duration_sec:.2f}s size={r.size_bytes}B wall={r.wall_sec:.1f}s",
                flush=True,
            )
        else:
            print(f"  {r.status.upper()} -> {r.note}", flush=True)

    total_wall = time.time() - total_start
    oks = sum(1 for r in results if r.status == "ok")
    print(f"\n[done] {oks}/{len(results)} ok, total wall={total_wall:.1f}s", flush=True)
    return 0 if oks == len(results) else 1


if __name__ == "__main__":
    sys.exit(main())
