"""Generate a music bed for a Project Bodhi reel using MusicGen.

Run via the SVD venv (has transformers + audiocraft deps already):
    automation/video-gen/.venv-svd/bin/python automation/video-gen/tools/gen_music_bed.py \
        --prompt "..." --duration 32 --out path.wav

Local-only, no paid APIs. CPU/MPS on Apple Silicon.
"""
from __future__ import annotations

import argparse
import sys
import wave
from pathlib import Path

import numpy as np
import torch
from transformers import AutoProcessor, MusicgenForConditionalGeneration


def write_wav_int16_mono(path: Path, sample_rate: int, samples_int16: np.ndarray) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "wb") as f:
        f.setnchannels(1)
        f.setsampwidth(2)  # 16-bit
        f.setframerate(sample_rate)
        f.writeframes(samples_int16.tobytes())


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("--prompt", required=True, help="Mood/style prompt for the music")
    p.add_argument("--duration", type=float, default=30.0, help="Seconds of audio")
    p.add_argument("--out", required=True, help="Output WAV path")
    p.add_argument(
        "--model",
        default="facebook/musicgen-small",
        help="MusicGen variant (small/medium/melody)",
    )
    p.add_argument(
        "--device",
        default="cpu",
        choices=["cpu", "mps"],
        help="Inference device. Default cpu — MPS spikes memory and gets OOM-killed on 16GB Macs.",
    )
    return p.parse_args()


def main() -> int:
    args = parse_args()

    # CPU is more memory-stable than MPS for MusicGen on Apple Silicon (MPS spikes during generation).
    # Override with --device mps if you have headroom.
    device = args.device
    print(f"[music] device={device} model={args.model}")

    processor = AutoProcessor.from_pretrained(args.model)
    model = MusicgenForConditionalGeneration.from_pretrained(args.model)
    model.to(device)

    inputs = processor(text=[args.prompt], padding=True, return_tensors="pt").to(device)

    # MusicGen samples ~50 tokens/sec at 32 kHz. Default sampling rate = 32000.
    sr = model.config.audio_encoder.sampling_rate
    tokens_per_second = model.config.audio_encoder.frame_rate
    max_new_tokens = int(args.duration * tokens_per_second) + 1
    print(f"[music] sr={sr} tokens={max_new_tokens} ({args.duration}s)")

    with torch.inference_mode():
        audio_values = model.generate(
            **inputs,
            do_sample=True,
            guidance_scale=3.0,
            max_new_tokens=max_new_tokens,
            temperature=1.0,
        )

    # audio_values shape: (batch, channels, samples)
    audio = audio_values[0, 0].detach().cpu().numpy()
    audio = np.clip(audio, -1.0, 1.0)
    audio_int16 = (audio * 32767).astype(np.int16)

    out_path = Path(args.out)
    write_wav_int16_mono(out_path, sr, audio_int16)
    print(f"[music] wrote {out_path} ({len(audio)/sr:.1f}s, {sr} Hz)")

    return 0


if __name__ == "__main__":
    sys.exit(main())
