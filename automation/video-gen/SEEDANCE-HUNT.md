# Seedance Open-Source Hunt — Phase 1 Findings

**Date:** 2026-04-18
**Specialist:** Seedance Specialist (rerun after previous rate-limit kills)
**Time-box:** 20 min

## TL;DR

**Seedance is NOT open-source.** No weights published as of April 2026. Hosted-API only (fal.ai, WaveSpeed, volcengine — all paid). This confirms prior research in `VIDEO-MODEL-RESEARCH.md`; nothing has changed since.

Pivot: use an open-source-weights video model **hosted on Replicate** (cloud inference, open model, pay-per-run).

## Evidence — ByteDance-Seed public catalog

Enumerated public repos. All video-adjacent items checked:

| Repo | Type | Weights? |
|---|---|---|
| `ByteDance-Seed/Seed-OSS-36B-Instruct` | LLM (text) | Yes — Apache-2.0 |
| `ByteDance-Seed/Seed-OSS-36B-Base` | LLM (text) | Yes — Apache-2.0 |
| `bytedance-research/HuMo` | Human motion (narrow research) | Yes — research-only |
| **Seedance 1.0 / 2.0** | **Video gen** | **No weights, API-only** |
| Magi | Rumored txt2vid | No public weights found |
| SeedVR2 | Rumored upscaler | No public weights found |

Community quantizations / MLX ports / Mac forks of Seedance: **none found**. Searched `seedance + (mlx | mac | apple-silicon | ggml | quantized | fork)` — zero hits on HF, GitHub, or Replicate. `fofr/seedance-1-lite` does not exist.

## Replicate open-source video models (April 2026)

Confirmed hosted, running open-source weights, no subscription required:

| Slug | Model | License | ~Cost/run | Use |
|---|---|---|---|---|
| `lightricks/ltx-video` | LTX-Video | OpenRAIL-M | ~$0.065 | **Best quality**, txt2vid + img2vid, 9:16 capable |
| `fofr/tooncrafter` | ToonCrafter | Apache-2.0 wrapper, SVD base | ~$0.068 | Cartoon interpolation between 2 frames (~2s) — user said "animated OK" |
| `lucataco/animate-diff` | AnimateDiff SD1.5 | Apache-2.0 | ~$0.08 | Stylized txt2vid, 16 frames |
| `stability-ai/stable-video-diffusion` | SVD-XT | Stability community | ~$0.06 | img2vid, 2–4s |
| `anotherjesse/zeroscope-v2-xl` | Zeroscope | CC-BY-NC | ~$0.04 | Older fallback |

Wan 2.1/2.2, Mochi-1, Pyramid-Flow exist on Replicate too but are pricier ($0.15–$0.40/clip) and overkill for the reels use case.

## Verdict

- **Is open-source Seedance runnable anywhere?** **No.** Closed weights. Not on HF, not on Replicate, no community port.
- **Best runnable alternative for this project:** **`lightricks/ltx-video`** on Replicate — OpenRAIL-M weights, ~$0.065/clip, img2vid-capable, best quality of the hosted-open-source options.
- **If "animated/cartoon initially" is the explicit preference:** `fofr/tooncrafter` (~$0.068) — it interpolates between two stylized keyframes. Great for a Vivekachudamani-style hand-drawn reel aesthetic.

## Sources

- https://huggingface.co/ByteDance-Seed
- https://huggingface.co/ByteDance
- https://huggingface.co/papers/2506.09113 (Seedance 1.0 paper — weights not released)
- https://www.glbgpt.com/hub/is-seedance-2-0-open-source-truth-about-bytedances-new-video-ai-2026/
- https://replicate.com/lightricks/ltx-video
- https://replicate.com/fofr/tooncrafter
- https://replicate.com/collections/text-to-video
- https://github.com/Doubiiu/ToonCrafter
