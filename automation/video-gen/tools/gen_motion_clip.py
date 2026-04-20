#!/usr/bin/env python3
"""
gen_motion_clip.py — Generate a short motion video from a still image using
Stable Video Diffusion (SVD-XT 1.1) on Apple Silicon MPS.

Reads an input JPG/PNG, writes an MP4 of ~2-4 seconds of motion.

Usage:
    python3 gen_motion_clip.py <input_image> <output_mp4>
        [--motion N] [--seed N] [--frames N] [--fps N] [--device mps|cpu]

Env:
    HF_HOME                  HuggingFace cache root (defaults to ~/.cache/huggingface)
    SVD_MODEL_ID             HF model id (default stabilityai/stable-video-diffusion-img2vid-xt)
    SVD_DECODE_CHUNK         decode_chunk_size for VAE (default 2; lower = less RAM, slower)
    SVD_NUM_INFERENCE_STEPS  denoise steps (default 20; lower = faster, worse quality)

Memory strategy (16 GB Apple Silicon):
    - float16 weights for UNet/image encoder
    - VAE upcast to float32 to avoid known MPS NaN/black-frame bug
    - enable_model_cpu_offload() — components swap in/out of GPU
    - decode_chunk_size=2 — VAE decodes 2 frames at a time
    - enable_forward_chunking() on UNet
"""
from __future__ import annotations

import argparse
import logging
import os
import sys
import time
from pathlib import Path

# MPS Conv3D fallback — SVD's VAE uses 3D convolutions that PyTorch's MPS
# backend does not implement. Setting this env var lets those ops transparently
# fall back to CPU while UNet/image_encoder stay on MPS. Must be set BEFORE
# torch is imported. (In practice SVD still fails in other ways on MPS — this
# script auto-falls-back to CPU; see pick_device/build_pipeline.)
os.environ.setdefault("PYTORCH_ENABLE_MPS_FALLBACK", "1")
# HuggingFace's new xethub CDN (cas-bridge.xethub.hf.co) has intermittent SSL
# cert issues on some macOS Python installs. Disabling it falls back to the
# classic LFS download path, which is reliable.
os.environ.setdefault("HF_HUB_DISABLE_XET", "1")

import torch
from PIL import Image

logging.basicConfig(
    format="[%(asctime)s] %(levelname)s %(message)s",
    datefmt="%H:%M:%S",
    level=logging.INFO,
)
log = logging.getLogger("gen_motion_clip")

MODEL_ID = os.environ.get("SVD_MODEL_ID", "stabilityai/stable-video-diffusion-img2vid-xt")
DECODE_CHUNK = int(os.environ.get("SVD_DECODE_CHUNK", "2"))
NUM_INFERENCE_STEPS = int(os.environ.get("SVD_NUM_INFERENCE_STEPS", "20"))

# SVD was trained on 1024x576 (landscape). Running at native resolution on
# Apple Silicon 16GB unified memory hits OOM on the attention layer (tried
# 44GB then 25GB buffer with attention slicing). We downscale to half to
# fit, accepting lower quality. Caller can upscale with ffmpeg if needed.
# Dimensions must be divisible by 8 for the VAE.
SVD_WIDTH = int(os.environ.get("SVD_WIDTH", "512"))
SVD_HEIGHT = int(os.environ.get("SVD_HEIGHT", "288"))


def pick_device(requested: str) -> torch.device:
    if requested == "mps":
        if not (torch.backends.mps.is_available() and torch.backends.mps.is_built()):
            log.warning("MPS requested but unavailable; falling back to cpu")
            return torch.device("cpu")
        return torch.device("mps")
    return torch.device(requested)


def load_and_fit_image(path: Path, target_w: int, target_h: int) -> Image.Image:
    """Load image, resize+crop to target dims preserving aspect. Returns RGB."""
    img = Image.open(path).convert("RGB")
    src_ratio = img.width / img.height
    tgt_ratio = target_w / target_h
    if src_ratio > tgt_ratio:
        # too wide — crop horizontally after fitting height
        new_h = target_h
        new_w = int(round(target_h * src_ratio))
    else:
        new_w = target_w
        new_h = int(round(target_w / src_ratio))
    img = img.resize((new_w, new_h), Image.LANCZOS)
    # center crop
    left = (new_w - target_w) // 2
    top = (new_h - target_h) // 2
    return img.crop((left, top, left + target_w, top + target_h))


def build_pipeline(device: torch.device):
    """Create StableVideoDiffusionPipeline with MPS-safe settings.

    Note: on MPS we load in fp16 but upcast the VAE to fp32 because fp16
    VAE on MPS emits NaNs (known pytorch/pytorch#78168 pattern).
    """
    from diffusers import StableVideoDiffusionPipeline

    log.info("loading pipeline %s (this is a ~9.6GB first-time download)", MODEL_ID)
    t0 = time.time()
    pipe = StableVideoDiffusionPipeline.from_pretrained(
        MODEL_ID,
        torch_dtype=torch.float16 if device.type != "cpu" else torch.float32,
        variant="fp16" if device.type != "cpu" else None,
    )
    log.info("pipeline load wall=%.1fs", time.time() - t0)

    # SVD on Apple Silicon MPS is blocked by two issues:
    #   1. VAE uses Conv3D — not implemented in PyTorch MPS backend.
    #   2. Mixing MPS and CPU components causes cross-device tensor errors
    #      inside the pipeline's internal shuttle logic.
    # The only reliable path on this machine is to run the full pipeline on
    # CPU in fp32. This is slower (~15-25 min for 14 frames at 512x288) but
    # produces correct output. Set --device cpu explicitly or let MPS-requested
    # runs auto-fall back here.
    if device.type == "mps":
        log.warning("SVD-XT has unresolved MPS issues (Conv3D + cross-device); falling back to CPU fp32")
        device = torch.device("cpu")
        # Also reload weights in fp32 if we were in fp16 — fp16 on CPU is slower than fp32.
        pipe = pipe.to(dtype=torch.float32)

    pipe.to(device)
    log.info("pipeline on %s (dtype=%s)", device, next(pipe.unet.parameters()).dtype)

    try:
        pipe.unet.enable_forward_chunking()
        log.info("enabled unet forward chunking")
    except Exception as e:
        log.warning("forward chunking unavailable: %s", e)

    # Attention slicing is critical on 16GB: prevents a 44GB scaled-dot-product
    # allocation on MPS for 1024x576 inputs. slice_size=1 minimises memory.
    try:
        pipe.enable_attention_slicing(slice_size=1)
        log.info("enabled attention slicing (slice_size=1)")
    except Exception as e:
        log.warning("attention slicing unavailable: %s", e)

    # VAE slicing reduces peak memory during decode.
    try:
        pipe.enable_vae_slicing()
        log.info("enabled vae slicing")
    except Exception as e:
        log.warning("vae slicing unavailable: %s", e)

    return pipe


def generate(
    image: Image.Image,
    pipe,
    *,
    frames: int,
    motion_bucket_id: int,
    noise_aug_strength: float,
    seed: int,
    fps: int,
) -> list[Image.Image]:
    generator = torch.manual_seed(seed)
    log.info(
        "generating %d frames motion=%d noise=%.2f steps=%d decode_chunk=%d",
        frames, motion_bucket_id, noise_aug_strength, NUM_INFERENCE_STEPS, DECODE_CHUNK,
    )
    t0 = time.time()
    out = pipe(
        image,
        height=image.height,
        width=image.width,
        num_frames=frames,
        num_inference_steps=NUM_INFERENCE_STEPS,
        decode_chunk_size=DECODE_CHUNK,
        motion_bucket_id=motion_bucket_id,
        noise_aug_strength=noise_aug_strength,
        fps=fps,
        generator=generator,
    )
    log.info("generation wall=%.1fs", time.time() - t0)
    return out.frames[0]


def frames_to_mp4(frames: list[Image.Image], out_mp4: Path, fps: int) -> None:
    from diffusers.utils import export_to_video

    out_mp4.parent.mkdir(parents=True, exist_ok=True)
    export_to_video(frames, str(out_mp4), fps=fps)
    log.info("wrote %s size=%.2fMB", out_mp4, out_mp4.stat().st_size / (1024 * 1024))


def parse_args(argv: list[str]) -> argparse.Namespace:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("input_image")
    p.add_argument("output_mp4")
    p.add_argument("--motion", type=int, default=127,
                   help="motion_bucket_id; 1-255, higher = more motion (default 127)")
    p.add_argument("--noise", type=float, default=0.02,
                   help="noise_aug_strength 0.0-1.0 (default 0.02)")
    p.add_argument("--seed", type=int, default=42)
    p.add_argument("--frames", type=int, default=14,
                   help="num_frames (SVD-XT supports up to 25; default 14 for speed)")
    p.add_argument("--fps", type=int, default=7, help="output fps (SVD trained at 6-8)")
    p.add_argument("--device", default="mps", choices=["mps", "cpu"])
    return p.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    in_path = Path(args.input_image).resolve()
    out_path = Path(args.output_mp4).resolve()
    if not in_path.exists():
        log.error("input not found: %s", in_path)
        return 2

    device = pick_device(args.device)
    log.info("device=%s frames=%d fps=%d motion=%d seed=%d",
             device, args.frames, args.fps, args.motion, args.seed)

    image = load_and_fit_image(in_path, SVD_WIDTH, SVD_HEIGHT)
    log.info("fitted input image to %dx%d", image.width, image.height)

    pipe = build_pipeline(device)

    frames = generate(
        image, pipe,
        frames=args.frames,
        motion_bucket_id=args.motion,
        noise_aug_strength=args.noise,
        seed=args.seed,
        fps=args.fps,
    )
    frames_to_mp4(frames, out_path, args.fps)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
