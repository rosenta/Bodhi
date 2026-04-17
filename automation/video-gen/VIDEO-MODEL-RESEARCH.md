# Video Model Research — Project Bodhi Media Pipeline

**Author:** Video Model Engineer
**Date:** 2026-04-18
**Status:** Research only. No install, no generation performed.
**Target machine:** Apple Silicon MacBook (M-series, unified memory)
**Goal:** Replace/augment current Unsplash-stills + Ken Burns approach with a local AI video model.

---

## 1. Seedance status (the headline answer)

**Seedance 1.0 / 2.0 is NOT open-source.**

- ByteDance's Seedance video family (Seedance-1.0, Seedance-1.0-Mini, Seedance-2.0) is a **proprietary, hosted-API-only** product. It sits alongside Sora / Veo / Kling in the closed-source tier.
- The paper is public (arXiv / HF Papers: `huggingface.co/papers/2506.09113`), but **no weights have been released**. There is no `ByteDance-Seed/Seedance-1.0-Mini` weights repo on HuggingFace — the user's assumption that a HF weights drop exists is incorrect as of April 2026.
- ByteDance-Seed's only open-source releases are the **Seed-OSS-36B LLMs** (text, not video) and a few research artifacts like `bytedance-research/HuMo` (human motion, narrow). Nothing runs text/image-to-video locally.
- Access to Seedance today = **hosted API only** (via fal.ai, WaveSpeed, volcengine, and similar). That is a paid API, which violates the project's zero-paid-API constraint.

**Consequence:** Running Seedance locally on Apple Silicon is not possible today. We must pick an alternative.

---

## 2. Candidate comparison — open-source video models on Apple Silicon

| Model | Release | License | Params | Min unified RAM | Apple Silicon | img2vid | Quality tier | Install ease |
|---|---|---|---|---|---|---|---|---|
| **LTX-Video 2.3 (Distilled Q4)** via `james-see/ltx-video-mac` | Mar 2026 | OpenRAIL-M (LTX) | 22B (Q4 quantized ~19.4GB) | 32 GB (64 GB rec.) | **Native MLX port** (Metal, first-class) | **Yes** | High (4K, 50fps native; fastest open model) | **Easy** — native macOS app, one-click installer |
| **Stable Video Diffusion (SVD-XT 1.1)** via ComfyUI-MPS | 2024 | Stability AI Community | 1.5B | 16 GB | PyTorch MPS (works, slow) | **Yes** (image-first by design) | Medium (2-4s clips, 576×1024) | Medium — ComfyUI + workflow JSON |
| **AnimateDiff** (SD1.5 motion module) via ComfyUI | 2023-24 | Apache 2.0 | ~1.3B motion + SD base | 16 GB (13 GB min for AnimateDiff alone) | PyTorch MPS (works, memory-touchy) | Partial (img-init via IP-Adapter) | Medium (stylized, short, subtle motion) | Medium — ComfyUI-AnimateDiff-Evolved nodes |
| **Wan 2.1 (1.3B)** via ComfyUI | Feb 2025 | Apache 2.0 | 1.3B | 16 GB | PyTorch MPS (works on M2 Studio per community reports) | **Yes** | Medium-High | Medium — community Mac workflow tweaks required |
| **Wan 2.2 I2V (14B MoE)** via ComfyUI | 2025 | Apache 2.0 | 14B MoE | 48+ GB realistically | PyTorch MPS (runs on M2 Mac Studio community-reported; slow) | **Yes** | High (SOTA open, beats HunyuanVideo) | Medium-Hard — needs GGUF quants for Mac |
| **Mochi-1** (Genmo) | 2024 | Apache 2.0 | 10B | **40+ GB VRAM** (H100-class) | No practical Apple Silicon path | Limited | High | **Hard / infeasible on MacBook** |
| **CogVideoX-2B** | 2024 | CogVideoX License | 2B | 16-24 GB | Undocumented/unoptimized for MPS | Yes (I2V variant exists) | Medium | Hard — no native Mac path |
| **Seedance 1.0 / 2.0** | 2025 | **Proprietary** | N/A | N/A | **Not available locally** | Via API only | Top-tier | **N/A — hosted only** |

### Key source findings

- **LTX-Video-Mac** (`james-see/ltx-video-mac`): explicit M1/M2/M3/M4 support, MLX framework (not MPS — native Apple Metal), 32 GB RAM minimum, img2vid first-class, one-time model download 20–42 GB.
- **LTX on HF discussion #26**: M3 MacBook Pro users report **~5 min per clip**; M1 16GB ~15 min. PyTorch 2.5+ causes artifacts — must pin **PyTorch 2.4.1**. Quality best at 4–6 second clips.
- **Wan 2.2** community report: "works comfortably on Mac Studio M2" (Facebook ComfyUI group) — but no hard per-clip timing numbers on MacBooks. Requires GGUF quant workflows (Kijai / comfyanonymous variants).
- **Mochi-1**: Genmo's own docs recommend H100, cites "several minutes per clip on H100." Not a MacBook target.
- **SVD-XT**: Well-tested on Mac via ComfyUI, but outputs are short (2-4 s, 25 frames) and quality is behind LTX/Wan in 2026.
- **AnimateDiff**: Reliable for stylized short motion on Mac but intrinsically limited to SD1.5-grade quality + subtle camera motion. Good fit for "mild animation of a still," i.e. a fancier Ken Burns.

---

## 3. Recommendation — **LTX-Video 2.3 Distilled (Q4) via `james-see/ltx-video-mac`**

### Why it wins

1. **Only model with a native Apple Silicon port** (MLX, not PyTorch-MPS shim). Translation: real Metal performance, not the 30–50% MPS tax.
2. **Purpose-built img2vid** — matches the pipeline: generate a still (Nano Banana / SDXL), feed in, get motion. Cleaner than text-to-video which would redo the composition.
3. **Q4 distilled variant is 19.4 GB on disk, fits a 32 GB MacBook** — realistic for a developer laptop.
4. **Quality ceiling is highest** of the MacBook-viable options (4K-capable, 22B params).
5. **Install is one-click** — native `.app`, no ComfyUI graph wrangling.
6. **Known-good inference time: ~5 min/clip on M3 MacBook Pro** per community reports (4–6 s clip length recommended).

### Fallback pick — **Wan 2.1 (1.3B) via ComfyUI**
If the 32 GB RAM floor or the ~5-min/clip budget proves unworkable, drop to Wan 2.1 1.3B. Runs in ~16 GB, slower per-token but much lighter footprint. Quality is a notch below LTX but clearly above SVD-XT.

### Second fallback — **SVD-XT via ComfyUI**
Battle-tested, smallest install, but output length (2–4 s) and quality are weakest. Keep in back pocket.

---

## 4. Step-by-step install plan (LTX-Video-Mac)

**Do NOT execute yet — this is the plan.**

### Prerequisites
- macOS 14.0+ (user has Darwin 25.4.0 = macOS 15+, fine)
- Python 3.10 or 3.11 (NOT 3.12+; MLX compatibility)
- **PyTorch 2.4.1 pinned** (2.5+ causes artifacts on Apple Silicon per HF discussion #26)
- 32 GB unified memory minimum, 64 GB recommended
- ~50 GB free disk (model + cache + outputs)

### Steps (estimated wall-clock)
1. Clone / download app from `github.com/james-see/ltx-video-mac` releases — **2 min**
2. Configure Python path in the app's Preferences; let it install missing packages (pins torch 2.4.1, mlx, diffusers) — **5-10 min**
3. First-run model download: LTX-2.3 Distilled Q4 (~19.4 GB) — **15-30 min** on typical home broadband
4. Smoke test: img2vid on one Bodhi still, 5 s @ 768×1344 (vertical 9:16 proxy) — **~5 min generate time**
5. Verify output is usable and deterministic enough for a batch pipeline — **10 min eyeballing**

**Total first-run setup:** ~45-60 min wall-clock, mostly passive downloads.

### Per-clip inference estimate (M3 MacBook Pro class)

| Clip spec | Time | Notes |
|---|---|---|
| 4 s, 768×1344, 24 fps | ~4 min | Sweet spot |
| 5 s, 768×1344, 24 fps | ~5 min | Recommended default |
| 6 s, 1080×1920, 24 fps | ~7-9 min | Full vertical, watch memory |
| 10 s, 1080×1920 | ~12-15 min | Often flickers/drifts — avoid |

M1 16 GB would be ~3× slower; M3/M4 Max with 64 GB will be 1.3-1.5× faster.

---

## 5. Brutally honest ROI analysis

**A typical Bodhi reel is ~60 s → ~12 scenes of 5 s each.**

| Pipeline | Per-reel render time | Cost | Quality |
|---|---|---|---|
| Current (Unsplash + Ken Burns + FFmpeg) | **~30-90 s** | $0 | Low-medium. Static, obvious. |
| LTX-Video for **every** clip | **12 × 5 min = 60 min** | $0 | High, cinematic motion |
| **Hybrid: LTX for hero shots only** (2-3 per reel) + Ken Burns for fill | **~15-20 min** | $0 | Medium-high, high perceived quality jump |
| All Seedance (API) | ~5 min | ~$0.10-0.40/clip × 12 = **$1.20-5/reel** | Top-tier |

A 60-minute render per 60-second reel is a **60× real-time ratio**. For a daily-verse cadence (7 reels/week), that's 7 hours of local GPU-wall-clock per week. Feasible overnight, painful interactively.

### Middle-path recommendation (my honest pick)

**Keep Ken Burns as the default. Use LTX-Video selectively for hero moments.**

- 2–3 "hero" scenes per reel get LTX motion (opener, climactic verse, closer). These are the shots viewers actually remember.
- The other 9–10 scenes stay on the current Unsplash + Ken Burns path. They're fine as B-roll.
- Render budget per reel stays under 20 min, which is overnight-batchable for the full week in 2 hours.
- Quality jump is 80% of the "go full AI video" benefit at 20% of the cost.

This hybrid also de-risks LTX flakiness: if img2vid fails on a scene, we fall back to Ken Burns for that scene and keep shipping.

---

## 6. Fallback plan if LTX-Video-Mac fails

1. **If install fails or first-run crashes** → switch to ComfyUI + Wan 2.1 (1.3B). More setup friction but a well-trodden Mac path.
2. **If quality disappoints at Q4** → download LTX-2 Unified (42 GB) and require a 64 GB machine.
3. **If inference time is >10 min/clip** → drop to Wan 2.1 1.3B or SVD-XT; smaller, faster, lower quality but workable.
4. **If nothing local is good enough** → revisit the no-paid-APIs constraint for hero shots only (fal.ai Seedance at ~$0.20/clip × 3 hero clips/reel × 7 reels/week ≈ **$4-5/week**). Document the escape hatch; do not ship with it on by default.

---

## 7. Sources

- [Seedance 1.0 paper (HF Papers)](https://huggingface.co/papers/2506.09113)
- [Is Seedance 2.0 Open Source? (GLB GPT 2026)](https://www.glbgpt.com/hub/is-seedance-2-0-open-source-truth-about-bytedances-new-video-ai-2026/)
- [LTX-Video-Mac native app (james-see)](https://github.com/james-see/ltx-video-mac)
- [LTX-Video HF discussion #26 — M3/M4 reports](https://huggingface.co/Lightricks/LTX-Video/discussions/26)
- [LTX-Video official repo](https://github.com/Lightricks/LTX-Video)
- [Wan-Video/Wan2.1](https://github.com/Wan-Video/Wan2.1)
- [Wan-Video/Wan2.2](https://github.com/Wan-Video/Wan2.2)
- [ComfyUI-AnimateDiff-Evolved (Kosinkadink)](https://github.com/Kosinkadink/ComfyUI-AnimateDiff-Evolved)
- [HF diffusers MPS docs](https://huggingface.co/docs/diffusers/optimization/mps)
- [Mochi-1 local guide (Codersera)](https://codersera.com/blog/run-mochi-1-on-macos-step-by-step-guide)
