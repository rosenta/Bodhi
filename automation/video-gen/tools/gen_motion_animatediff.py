#!/usr/bin/env python3
"""gen_motion_animatediff.py — Short motion clip via AnimateDiff on Apple Silicon MPS.

Text-to-video using SD 1.5 base + AnimateDiff motion adapter. No Conv3D issue
(AnimateDiff's motion module is 1D temporal attention over SD's 2D VAE, not
SVD's 3D VAE). Runs on MPS natively; ~4GB total download first time.

Usage:
    python3 gen_motion_animatediff.py <prompt> <output_mp4> [options]

Example:
    python3 gen_motion_animatediff.py \\
        "A sage sitting by the ganges river at golden hour, gentle breeze moving his white robes, soft particles in sunlight, cinematic" \\
        samples/motion/smoke-animdiff.mp4 \\
        --frames 16 --fps 8 --steps 20

Env:
    HF_HUB_DISABLE_XET=1 — avoids xethub CDN SSL issues (set automatically)
"""
from __future__ import annotations

import argparse
import logging
import os
import sys
import time
from pathlib import Path

os.environ.setdefault("PYTORCH_ENABLE_MPS_FALLBACK", "1")
os.environ.setdefault("HF_HUB_DISABLE_XET", "1")

import torch
from diffusers import AnimateDiffPipeline, MotionAdapter, DDIMScheduler
from diffusers.utils import export_to_video

logging.basicConfig(
    format="[%(asctime)s] %(levelname)s %(message)s",
    datefmt="%H:%M:%S",
    level=logging.INFO,
)
log = logging.getLogger("animatediff")

# Stable choices on MPS 16GB:
MOTION_ADAPTER_ID = os.environ.get(
    "ANIMDIFF_ADAPTER", "guoyww/animatediff-motion-adapter-v1-5-2"
)
SD_BASE_ID = os.environ.get(
    "ANIMDIFF_BASE", "SG161222/Realistic_Vision_V5.1_noVAE"
)


def pick_device(requested: str) -> torch.device:
    if requested == "mps":
        if not (torch.backends.mps.is_available() and torch.backends.mps.is_built()):
            log.warning("MPS unavailable; falling back to cpu")
            return torch.device("cpu")
        return torch.device("mps")
    return torch.device(requested)


def build_pipeline(device: torch.device) -> AnimateDiffPipeline:
    dtype = torch.float16 if device.type == "mps" else torch.float32
    log.info("loading motion adapter %s", MOTION_ADAPTER_ID)
    t0 = time.time()
    adapter = MotionAdapter.from_pretrained(
        MOTION_ADAPTER_ID, torch_dtype=dtype, use_safetensors=True,
    )
    log.info("adapter load wall=%.1fs", time.time() - t0)

    log.info("loading sd base %s", SD_BASE_ID)
    t0 = time.time()
    pipe = AnimateDiffPipeline.from_pretrained(
        SD_BASE_ID, motion_adapter=adapter, torch_dtype=dtype,
        use_safetensors=True,
    )
    log.info("base load wall=%.1fs", time.time() - t0)

    pipe.scheduler = DDIMScheduler.from_config(
        pipe.scheduler.config,
        beta_schedule="linear",
        clip_sample=False,
        timestep_spacing="linspace",
        steps_offset=1,
    )

    pipe.to(device)

    # MPS workaround: fp16 VAE decoder produces NaN → green/black frames.
    # Diffusers' `force_upcast` flag doesn't take effect in this version, so
    # we monkey-patch the VAE's decode path: cast latents to fp32, run the
    # decoder in fp32, cast the result back to the original dtype.
    if device.type == "mps":
        pipe.vae.to(dtype=torch.float32)
        _orig_decode = pipe.vae.decode

        def _safe_decode(z, *args, **kwargs):
            in_dtype = z.dtype
            result = _orig_decode(z.to(torch.float32), *args, **kwargs)
            # result may be a DecoderOutput namedtuple-like object
            if hasattr(result, "sample"):
                result.sample = result.sample.to(in_dtype)
            return result

        pipe.vae.decode = _safe_decode
        log.info("vae fp32 decode monkey-patch applied (MPS NaN workaround)")

    try:
        pipe.enable_attention_slicing(slice_size=1)
        log.info("enabled attention slicing")
    except Exception as e:
        log.warning("attention slicing unavailable: %s", e)
    try:
        pipe.enable_vae_slicing()
        log.info("enabled vae slicing")
    except Exception as e:
        log.debug("vae slicing unavailable: %s", e)

    return pipe


def generate(
    pipe: AnimateDiffPipeline,
    prompt: str,
    *,
    negative: str,
    frames: int,
    steps: int,
    guidance: float,
    seed: int,
    width: int,
    height: int,
) -> list:
    generator = torch.manual_seed(seed)
    log.info(
        "prompting frames=%d steps=%d guidance=%.1f size=%dx%d seed=%d",
        frames, steps, guidance, width, height, seed,
    )
    t0 = time.time()
    out = pipe(
        prompt=prompt,
        negative_prompt=negative,
        num_frames=frames,
        num_inference_steps=steps,
        guidance_scale=guidance,
        width=width,
        height=height,
        generator=generator,
    )
    log.info("generation wall=%.1fs", time.time() - t0)
    return out.frames[0]


def parse_args(argv: list[str]) -> argparse.Namespace:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("prompt")
    p.add_argument("output_mp4")
    p.add_argument("--negative", default="bad quality, worse quality, blurry, distorted, watermark, text")
    p.add_argument("--frames", type=int, default=16, help="num_frames (AnimateDiff sweet spot 8-24)")
    p.add_argument("--steps", type=int, default=20)
    p.add_argument("--guidance", type=float, default=7.5)
    p.add_argument("--seed", type=int, default=42)
    p.add_argument("--fps", type=int, default=8)
    p.add_argument("--width", type=int, default=512)
    p.add_argument("--height", type=int, default=512)
    p.add_argument("--device", default="mps", choices=["mps", "cpu"])
    return p.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    device = pick_device(args.device)
    log.info("device=%s", device)

    pipe = build_pipeline(device)
    frames = generate(
        pipe, args.prompt,
        negative=args.negative,
        frames=args.frames,
        steps=args.steps,
        guidance=args.guidance,
        seed=args.seed,
        width=args.width,
        height=args.height,
    )

    out_path = Path(args.output_mp4).resolve()
    out_path.parent.mkdir(parents=True, exist_ok=True)
    export_to_video(frames, str(out_path), fps=args.fps)
    size_mb = out_path.stat().st_size / (1024 * 1024)
    log.info("wrote %s size=%.2fMB duration=%.1fs", out_path, size_mb, args.frames / args.fps)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
