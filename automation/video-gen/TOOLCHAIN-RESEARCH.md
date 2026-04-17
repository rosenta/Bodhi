# Toolchain Research — Local Video Generation on 16 GB M4 MacBook Pro

**Author:** Tooling Research + Install Engineer
**Date:** 2026-04-18
**Machine:** MacBook Pro M4, 16 GB unified memory, macOS 26.4.1, 68 GB free disk, Python 3.12.2, torch 2.2.2 (MPS available), ffmpeg 7.1.1
**Mandate:** Pick ONE local open-source video tool that produces real motion (not a pan on a still). Install it. Smoke test. Honest report.

---

## 1. The 16 GB reality check

The previous research doc (`VIDEO-MODEL-RESEARCH.md`) picked **LTX-Video-Mac** as winner, but its floor is **32 GB unified memory** (Q4 distilled weights are 19.4 GB on disk before PyTorch overhead). **This machine has 16 GB.** That pick is therefore disqualified by hardware.

Every candidate must be re-evaluated against a 16 GB ceiling, minus ~2 GB for macOS = **~14 GB usable**. With CPU offload tricks we can push weights to unified-memory-as-swap but inference is punishingly slow.

## 2. Candidate matrix (re-scored for 16 GB M4)

| Tool | Weights on disk | Live RAM footprint | Apple path | img2vid | Install ease | Verdict on this machine |
|---|---|---|---|---|---|---|
| **SVD-XT 1.1 (diffusers + MPS)** | ~9.6 GB fp16 | <8 GB with `enable_model_cpu_offload` + `decode_chunk_size=2` + `enable_forward_chunking` (per HF docs) | PyTorch MPS | **Yes (native)** | `pip install diffusers transformers accelerate` — trivial | **VIABLE — primary pick** |
| **AnimateDiff v3 (diffusers + MPS)** | ~4 GB motion adapter + ~4 GB SD1.5 base | ~6-8 GB with attention slicing | PyTorch MPS | Weak (needs IP-Adapter workflow) | `pip install diffusers` + motion adapter | Viable but lower quality ceiling (SD1.5) and weak img2vid; fallback |
| **LTX-Video 2.3 Distilled (MLX)** | 19.4 GB Q4 | Author-declared 32 GB min | MLX native | Yes | Easy (native app) | **BLOCKED — 16 GB too small** |
| **Wan 2.1 1.3B (ComfyUI)** | ~5 GB | ~10-12 GB est. | PyTorch MPS via ComfyUI | Yes | Medium (ComfyUI graph setup) | Possibly viable but no Mac 16 GB benchmark exists; ComfyUI overhead; deferred |
| **Wan 2.2 14B MoE (GGUF)** | 14+ GB quantized | 48+ GB realistic | MPS/ComfyUI | Yes | Hard | BLOCKED |
| **Mochi-1 (Genmo)** | ~40 GB | 40+ GB VRAM, H100-class | None practical | Limited | Hard | BLOCKED |
| **CogVideoX-2B** | ~10 GB | 16-24 GB | No native MPS | Yes | Hard | Untested on Mac; deferred |
| **HunyuanVideo** | ~30 GB | 60+ GB | None practical | Yes | Hard | BLOCKED |
| **Pyramid-Flow** | ~14 GB | ~16 GB claimed | No native MPS path | Yes | Medium | Unclear Mac fit; not worth risk |

### Why SVD-XT wins here

1. **Only option with a publicly documented path to <8 GB memory** on a consumer machine (HF diffusers docs: "Using all these tricks together should lower the memory requirement to less than 8GB VRAM.")
2. **Trivial install** — three pip packages, zero ComfyUI.
3. **Image-to-video native** — matches our existing pipeline: Unsplash/SDXL still → SVD-XT → 2-4 s motion clip.
4. **25-frame output @ 576×1024** — 3.5 s at 7 fps, which is playable real motion, not a pan.
5. **Known MPS bugs are float32-related, not blockers** — well-documented workarounds (force fp32 VAE upcast).
6. **Community license permits** non-commercial use + commercial under agreement — we're non-commercial for the smoke test; revisit for production distribution.

### Known SVD-XT limitations on MPS (honest)

- Slow: expect **5–15 minutes per clip** on M4 16 GB with CPU offload + chunking. No community benchmark for exactly this config exists; will measure empirically.
- Output is 2-4 s, not 10 s. A reel made entirely of SVD clips would need ~12-15 clips × 10 min = 2-3 hours/reel render.
- Motion intensity is controllable via `motion_bucket_id` but can be subtle. Need to experiment per scene.
- fp16 on MPS has known NaN/black-frame issues — must handle gracefully (force fp32 VAE).

## 3. Text animation / on-screen Hindi — decision

### Candidates

| Tool | Devanagari | Install | Programmability | Verdict |
|---|---|---|---|---|
| **FFmpeg drawtext** + Noto Sans Devanagari | Yes (with proper font file) | Already installed | `enable='between(t,a,b)'` expressions for timing | **Good enough for v1 — ship it** |
| **Remotion** | Yes (Chromium renders any web font) | `npm create video` — requires Node toolchain; headless Chromium | React/TSX components | Better for complex kinetic typography; bigger architectural commitment |
| **Motion Canvas** | Weak (Canvas 2D text shaping is fragile for complex scripts) | `npm init` | TS imperative | **NO** for Devanagari |
| **Manim** | Yes (with TexLive Full, 5-7 GB) | Heavy LaTeX stack | Python | Overkill for one-line overlays |

### Pick — **FFmpeg drawtext (v1)** with Remotion as a later upgrade path

- v1: drawtext + Noto Sans Devanagari TTF, fade-in/slide-in via `alpha='if(lt(t,0.3), t/0.3, 1)'` and `x='...'` expressions.
- v2 (when motion graphics budget exceeds what drawtext can express): port to Remotion.
- This keeps the current `generate_reel.py` path simple and avoids adding a Node.js build step to the pipeline right now.

## 4. Disk budget

Available: **68 GB**. SVD-XT fp16 weights: **~9.6 GB**. diffusers/transformers/accelerate packages: **~2 GB**. HF cache overhead: ~1 GB. **Total install = ~12-13 GB.** Comfortably within budget.

## 5. Decision

- **Video model:** SVD-XT 1.1 via `diffusers` + MPS (with CPU offload, VAE slicing, forward chunking, `decode_chunk_size=2`).
- **Text animation:** FFmpeg drawtext with Noto Sans Devanagari.
- **Fallback if SVD-XT OOMs or hangs:** AnimateDiff v3 motion adapter on SD1.5 base (ship as partial motion rather than no motion).

Next — Phase 2 install.

---

## Sources

- [diffusers SVD docs — memory optimization](https://huggingface.co/docs/diffusers/en/using-diffusers/svd)
- [diffusers AnimateDiff pipeline docs](https://github.com/huggingface/diffusers/blob/main/docs/source/en/api/pipelines/animatediff.md)
- [diffusers MPS optimization](https://huggingface.co/docs/diffusers/optimization/mps)
- [stabilityai/stable-video-diffusion-img2vid-xt HF](https://huggingface.co/stabilityai/stable-video-diffusion-img2vid-xt)
- [LTX-Video-Mac repo](https://github.com/james-see/ltx-video-mac) — documented 32 GB minimum, disqualifies on 16 GB
- [Remotion vs Motion Canvas](https://www.remotion.dev/docs/compare/motion-canvas)
- [MPS float16 NaN known issue](https://github.com/pytorch/pytorch/issues/78168)
