# Seedance Decision — Project Bodhi Motion Video

**Date:** 2026-04-18
**Status:** Recommendation only — no paid requests fired.

## Seedance open-source status

**Debunked.** ByteDance has published only LLM weights (Seed-OSS-36B). Seedance 1.0 / 2.0 / Magi / SeedVR2 video weights remain unreleased as of April 2026. No community port, no MLX fork, no GGUF quant. Evidence in `SEEDANCE-HUNT.md`.

## Recommendation

**Primary: `lightricks/ltx-video` on Replicate.**
- License: OpenRAIL-M (true open-source weights; Replicate is just hosting)
- Cost: ~$0.065/run, ~67s wall time
- Supports txt2vid and img2vid (pair with existing Unsplash/Nano-Banana stills)
- Vertical 9:16 native

**Stylized alternative: `fofr/tooncrafter`.**
- Use when a hand-drawn / animated aesthetic is desired (user: "animated initially OK")
- Needs two keyframes (start + end) — perfect fit for Ken-Burns-style shot pairs
- ~$0.068/run

## One-liners (after setting token)

```bash
export REPLICATE_API_TOKEN=r8_xxx   # https://replicate.com/account/api-tokens

# LTX-Video txt2vid (4s vertical)
python3 automation/video-gen/tools/gen_motion_cloud.py \
  "cinematic sunrise over Himalayan peaks, slow push-in, devotional mood" \
  automation/video-gen/samples/motion/smoke-ltx.mp4 \
  --model ltx --seed 42

# LTX-Video img2vid (feed an existing Bodhi still)
python3 automation/video-gen/tools/gen_motion_cloud.py \
  "subtle breeze, gentle camera drift, contemplative" \
  automation/video-gen/samples/motion/smoke-ltx-i2v.mp4 \
  --model ltx --image https://example.com/bodhi-still.jpg --seed 42

# ToonCrafter cartoon interpolation
python3 automation/video-gen/tools/gen_motion_cloud.py \
  "meditating sage, soft painterly motion" \
  automation/video-gen/samples/motion/smoke-tooncrafter.mp4 \
  --model tooncrafter \
  --image https://example.com/frame-start.png \
  --image2 https://example.com/frame-end.png
```

## Cost per 60-second reel (12 scenes × ~5s)

| Strategy | Per clip | Per reel | Notes |
|---|---|---|---|
| All LTX | $0.065 | **~$0.78** | Full motion, premium |
| All ToonCrafter | $0.068 | **~$0.82** | Stylized / animated |
| Hybrid: 3 hero LTX + 9 Ken Burns | $0.065 × 3 | **~$0.20** | Recommended — matches `VIDEO-MODEL-RESEARCH.md` hybrid plan |
| All AnimateDiff | $0.08 | ~$0.96 | Stylized, shorter |

**At 7 reels/week with the hybrid plan: ~$1.40/week, ~$5.60/month.** Well under any reasonable creator budget and avoids all MPS debug hell.

## Smoke test status

**Not run.** `REPLICATE_API_TOKEN` is not set in the current environment. Per task constraints, no paid request is fired without explicit user authorization. Tool is ready; one-liners above are validated to parse (argparse + AST check passed).

## Upgrade note for `cto-media` agent

> Motion video pipeline pivots from local MPS (SVD-XT / AnimateDiff — both blocked on M4 16GB) to Replicate cloud inference of open-source weights. Primary model: `lightricks/ltx-video` (OpenRAIL-M, ~$0.065/clip). Use `automation/video-gen/tools/gen_motion_cloud.py --model ltx` — now supports `ltx` and `tooncrafter` in addition to `animatediff` / `svd` / `zeroscope`.

## Codebase changes

1. `tools/gen_motion_cloud.py` — added `ltx` and `tooncrafter` entries to `MODELS` map, plus `--image` / `--image2` CLI flags; updated existing lambdas to accept the new kwargs.
2. `SEEDANCE-HUNT.md` — new file; evidence dump confirming Seedance closed-source.
3. `SEEDANCE-DECISION.md` — this file; recommendation + cost model + one-liners.

No local models installed. No API calls fired.
