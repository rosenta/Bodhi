#!/usr/bin/env python3
"""gen_motion_cloud.py — cloud-inference fallback for motion video generation.

Uses Replicate's pay-per-second API to run open-source video models
(AnimateDiff, SVD-XT, Zeroscope, LTX-Video, ToonCrafter) when local MPS
inference is blocked by hardware limits (e.g. MacBook M4 16GB — SVD-XT
Conv3D fails, AnimateDiff VAE NaN on MPS).

Still open-source MODELS — just not running locally. ~$0.05-0.15 per clip.

Usage:
    export REPLICATE_API_TOKEN=r8_xxx   # https://replicate.com/account/api-tokens
    python3 gen_motion_cloud.py "<prompt>" <output_mp4> \\
        [--model animatediff|svd|zeroscope|ltx|tooncrafter] \\
        [--frames N] [--steps N] [--seed N] [--image URL] [--image2 URL]

Model notes:
    animatediff : text-to-video, ~$0.08/clip, 16 frames, stylized
    svd         : image-to-video, pass --image URL
    zeroscope   : text-to-video, older, cheap & reliable
    ltx         : LTX-Video (Lightricks) — text or image-to-video,
                  ~$0.065/clip on Replicate, best open-source quality
    tooncrafter : cartoon interpolation between two illustrated frames,
                  ~$0.068/clip, pass --image and --image2

Env:
    REPLICATE_API_TOKEN (required)
"""
from __future__ import annotations

import argparse
import logging
import os
import sys
import time
from pathlib import Path

try:
    import replicate
except ImportError:
    sys.stderr.write("pip install replicate\n")
    sys.exit(2)

import requests

logging.basicConfig(
    format="[%(asctime)s] %(levelname)s %(message)s",
    datefmt="%H:%M:%S",
    level=logging.INFO,
)
log = logging.getLogger("gen_cloud")


MODELS = {
    # Open-source AnimateDiff — runs on Replicate GPU; ~$0.08/clip @ 16 frames
    "animatediff": {
        "slug": "lucataco/animate-diff:beecf59c4aee8d81bf04f0381033dfa10dc16e845b4ae00d281e2fa377e48a9f",
        "input_fn": lambda prompt, frames, steps, seed, image, image2: {
            "prompt": prompt,
            "n_prompt": "bad quality, worse quality, blurry, distorted, text, watermark",
            "seed": seed,
            "steps": steps,
            "guidance_scale": 7.5,
            "motion_module": "mm_sd_v15_v2",
        },
    },
    # Open-source Stable Video Diffusion — image-to-video.
    # Pass --image <url> (or prompt slot as fallback).
    "svd": {
        "slug": "stability-ai/stable-video-diffusion:3f0457e4619daac51203dedb472816fd4af51f3149fa7a9e0b5ffcf1b8172438",
        "input_fn": lambda prompt, frames, steps, seed, image, image2: {
            "input_image": image or prompt,
            "sizing_strategy": "maintain_aspect_ratio",
            "frames_per_second": 6,
            "motion_bucket_id": 127,
            "cond_aug": 0.02,
        },
    },
    # Open-source Zeroscope — older but cheap and reliable
    "zeroscope": {
        "slug": "anotherjesse/zeroscope-v2-xl:9f747673945c62801b13b84701c783929c0ee784e4748ec062204894dda1a351",
        "input_fn": lambda prompt, frames, steps, seed, image, image2: {
            "prompt": prompt,
            "num_frames": frames,
            "num_inference_steps": steps,
            "seed": seed,
            "width": 576,
            "height": 320,
            "fps": 8,
        },
    },
    # LTX-Video by Lightricks — best open-source quality, ~$0.065/clip.
    # Supports text-to-video and image-to-video. License: OpenRAIL-M.
    # Slug uses floating "latest" tag; resolve pinned version with
    #   `replicate model versions get lightricks/ltx-video` if determinism needed.
    "ltx": {
        "slug": "lightricks/ltx-video",
        "input_fn": lambda prompt, frames, steps, seed, image, image2: {
            k: v for k, v in {
                "prompt": prompt,
                "image": image,  # None means pure txt2vid
                "seed": seed,
                "num_inference_steps": steps,
                "aspect_ratio": "9:16",  # vertical reels default
                "length": 97,  # 97 frames @ 24fps ≈ 4s (must be N*8+1)
            }.items() if v is not None
        },
    },
    # ToonCrafter — cartoon interpolation between two key frames.
    # Ideal for "animated initially OK" per user constraint. ~$0.068/clip, ~2s output.
    # Requires --image (start frame URL) and --image2 (end frame URL).
    "tooncrafter": {
        "slug": "fofr/tooncrafter",
        "input_fn": lambda prompt, frames, steps, seed, image, image2: {
            "image_1": image,
            "image_2": image2,
            "prompt": prompt,
            "seed": seed,
            "loop": False,
            "color_correction": True,
            "interpolation_steps": 50,
        },
    },
}


def parse_args(argv: list[str]) -> argparse.Namespace:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("prompt")
    p.add_argument("output_mp4")
    p.add_argument("--model", default="animatediff", choices=list(MODELS))
    p.add_argument("--frames", type=int, default=16)
    p.add_argument("--steps", type=int, default=25)
    p.add_argument("--seed", type=int, default=42)
    p.add_argument("--image", default=None, help="start image URL (svd, ltx, tooncrafter)")
    p.add_argument("--image2", default=None, help="end image URL (tooncrafter)")
    return p.parse_args(argv)


def run(model_key: str, **kwargs) -> str:
    """Submit a prediction to Replicate and return the output video URL."""
    spec = MODELS[model_key]
    inputs = spec["input_fn"](**kwargs)
    log.info("submitting to replicate model=%s inputs=%s", model_key, list(inputs))
    t0 = time.time()
    output = replicate.run(spec["slug"], input=inputs)
    log.info("replicate prediction wall=%.1fs", time.time() - t0)
    # Replicate returns a URL (or list of URLs depending on model)
    if isinstance(output, list):
        return output[0] if output else ""
    return str(output)


def download(url: str, out_path: Path) -> None:
    log.info("downloading %s → %s", url, out_path)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    r = requests.get(url, stream=True, timeout=120)
    r.raise_for_status()
    with out_path.open("wb") as f:
        for chunk in r.iter_content(chunk_size=1 << 20):
            f.write(chunk)
    log.info("wrote %s size=%.2fMB", out_path,
             out_path.stat().st_size / (1024 * 1024))


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    if not os.environ.get("REPLICATE_API_TOKEN"):
        log.error("REPLICATE_API_TOKEN not set; get one at https://replicate.com/account/api-tokens")
        return 2
    try:
        url = run(
            args.model,
            prompt=args.prompt,
            frames=args.frames,
            steps=args.steps,
            seed=args.seed,
            image=args.image,
            image2=args.image2,
        )
    except Exception as e:
        log.error("replicate run failed: %s", e)
        return 3
    if not url:
        log.error("no video URL in response")
        return 4
    try:
        download(url, Path(args.output_mp4).resolve())
    except Exception as e:
        log.error("download failed: %s", e)
        return 5
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
