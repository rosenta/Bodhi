---
name: movie-generation
description: Generate short-form movies (reels, stories, shorts) with REAL motion — not slideshows. Open-source, local, Apple Silicon-friendly. Covers the full pipeline: Hindi TTS with natural prosody, AI video generation (LTX-Video MLX / AnimateDiff / SVD-XT), parallax fallbacks, kinetic typography, music bed, FFmpeg assembly, and a mandatory pre-ship motion-QA gate. Use whenever the task mentions reels, videos, shorts, animations, story videos, or when the user says "too static" / "slideshow" / "needs movement."
---

# Movie Generation Skill

Build **moving-image** short-form video on Apple Silicon, fully local, fully open-source. The sin to avoid: pan-and-zoom on JPEGs. That is a slideshow. A reel must move.

## The non-negotiable rules

1. **Every scene must have continuous motion.** Camera moves + character/object motion + atmospheric motion (wind, water, particles, light). Not one of these — a combination.
2. **Ken Burns alone = fail.** Ken Burns is a post-effect layered ON TOP of real motion, never the sole motion source.
3. **Pre-ship motion-QA is mandatory.** Before a reel is marked shipped, run SSIM sampling. If the clip is too similar frame-to-frame, it is too static. Back to rework.
4. **Hindi-first when the project is Hindi-first.** Voice, on-screen text, subtitles all in target language. Do not assume English.
5. **Local-only, zero paid APIs.** If a stage tries to reach the cloud, find the local alternative or cut the stage.
6. **Sample → approve → ship.** Never batch-render before the user has approved a single end-to-end sample.

## The pipeline (stages, in order)

### Stage 0 — Script intake

Input: a scene-by-scene JSON (`reel-*.json`) with `time`, `visual`, `voiceover`, `text_overlay` per scene.

If the script is in English but the final language is Hindi, insert a translation pre-stage: run each `voiceover` through a local LLM (Ollama llama3.2:3b) with a prompt that enforces spoken-tone, emotionally bound Hindi (see `content/stories/_samples/HINDI-CRAFT-BRIEF.md` for voice rules). Cache Hindi renditions to `cache/<reel>/scene-NN.hi.txt`.

### Stage 1 — Voice synthesis (TTS)

Engine priority (for Hindi):

| Engine | Install | Quality | Hardware |
|---|---|---|---|
| **MMS-TTS Hindi** (default) | `pip install "transformers<4.45" scipy torch` | Decent; needs post-processing for naturalness | CPU or MPS |
| Parler Indic-TTS | ai4bharat/indic-parler-tts (~900 MB) | Better prosody, prompt-steerable style | MPS/GPU |
| Coqui XTTS-v2 Hindi | pip in py3.10/3.11 venv | Best, supports voice cloning | MPS/GPU |

Naturalness techniques (layer them — each adds real human-ness):

1. **Chunked synthesis with real silence gaps** — split at sentence boundaries, synthesize each chunk separately, concatenate with **0.35s silence** between chunks and **0.7s after full stops / em-dashes**. This one technique does more than any parameter tuning.
2. **Text pre-processing:** add natural breath-commas, break compound sentences, expand numerals/abbreviations, normalize punctuation (use `।` for Devanagari full stop).
3. **VITS parameter tuning** (MMS-TTS): `speaking_rate=0.82`, `noise_scale=0.75`, `noise_scale_w=0.9` for slower expressive prosody.
4. **FFmpeg warm-EQ + light compression + subtle reverb**:
   ```
   asoftclip,
   equalizer=f=200:t=h:w=150:g=1.5,
   equalizer=f=4000:t=h:w=2000:g=-1.5,
   acompressor=threshold=-18dB:ratio=2:attack=20:release=250,
   aecho=0.8:0.9:40:0.15,
   loudnorm=I=-16:TP=-1.5:LRA=11
   ```

Output per scene: `cache/<reel>/scene-NN.wav` at 22.05 kHz mono.

### Stage 2 — Visual generation (REAL MOTION)

For each scene, pick ONE path based on the scene's role:

**Hero shots** (opener, turn-point, closer — 2-3 per reel):
- **LTX-Video 2.3 Distilled (MLX, Apple Silicon)** — `james-see/ltx-video-mac`. Install ~45-60 min first time (model download ~19 GB on Q4). Inference ~5 min per 5-second 720p clip.
  ```bash
  ltx-video-mac --input-image base.jpg --prompt "<detailed motion prompt>" \
    --duration 5 --fps 24 --output scene-01.mp4
  ```
- **AnimateDiff via ComfyUI** (fallback if LTX-Video flakes) — runs on MPS. Higher variance, shorter clips (~2-3s), faster render (~1-2 min).
- **SVD-XT on MPS** (last-resort AI path) — img2vid only, 2-4 seconds, tends to drift.

**Mid/B-roll shots** (10+ per reel):

NOT Ken Burns. Parallax composites minimum. Tools:
1. **Parallax composite** — for each scene, generate 3 layers (foreground subject, midground, background) using either local SDXL with transparent backgrounds or cut out of a source image (rembg). FFmpeg overlay with per-layer motion:
   ```bash
   # Each layer gets its own zoom + offset trajectory (different speeds = parallax)
   # Plus atmospheric particles (snow/dust/embers) as an additive-blend overlay
   ```
2. **Remotion** (React-based video) — programmatic kinetic motion, excellent for stylized mid-shots with animated elements. Install: `npx create-video`. Renders via Chromium headless.
3. **Blender CLI** — for 3D camera moves on a geometry-lit scene. Heavier to set up.
4. **Last resort** — Ken Burns PLUS animated light sweeps PLUS particle layer. Never Ken Burns alone.

Prompt craft for AI video — be specific about motion:
```
Bad:  "Man kneeling at river"
Good: "Slow dolly-in on a man kneeling at a river's edge. Wind ripples the grass around him. His shoulders rise and fall once as he exhales. Golden hour side-lighting breathes across his face. Shallow depth of field with background trees softly blurred and swaying. 24fps, cinematic."
```

### Stage 3 — Kinetic typography (on-screen text)

Static `drawtext` is a slideshow tell. Text must animate in.

- **Per-phrase entry:** each phrase of `text_overlay` slides/fades in on its own beat, synced to voiceover cadence.
- **Mask reveals:** for emphasis lines (the keep-worthy screenshot line), use a brush-stroke or typewriter reveal via FFmpeg `enable` expressions + crop masks.
- **Devanagari font:** use `Noto Sans Devanagari Bold` for impact, `Noto Serif Devanagari` for quotes. Fallback: `Kohinoor Devanagari`. Test for glyph correctness (conjuncts like ज्ञ, श्र render properly).
- **Shadow + gradient underlay** for legibility against moving footage.

### Stage 4 — Assembly

FFmpeg concat with crossfades (not hard cuts):
```bash
ffmpeg -i scene-01.mp4 -i scene-02.mp4 ... \
  -filter_complex "[0:v][1:v]xfade=transition=fade:duration=0.4:offset=<t>[v01]; ..." \
  -map "[vN]" -map "0:a" -c:v libx264 -preset slow -crf 20 \
  -r 30 -s 1080x1920 -c:a aac -b:a 192k out.mp4
```

Audio mux: voiceover track + music bed (Free Music Archive CC0, `music/bed-contemplative.mp3`) at -18 dB relative ducked under VO. Normalize final to -14 LUFS broadcast target.

### Stage 5 — Pre-ship motion QA (MANDATORY)

Before marking any reel as rendered/shipped:

1. **Static check (SSIM sampling):**
   ```python
   # Pseudocode — sample 5 frames, compute pairwise SSIM
   frames = extract_frames_at([0.1, 0.3, 0.5, 0.7, 0.9] * duration)
   ssim_pairs = [ssim(frames[i], frames[i+1]) for i in range(4)]
   mean_ssim = sum(ssim_pairs) / 4
   assert mean_ssim < 0.92, f"Too static (SSIM={mean_ssim}); rework."
   # Target band for moving reels: 0.55-0.80
   ```
2. **Audio QA:** duration in [40, 65]s, audio present, no clipping (peak < -1 dBTP), loudness -14±1 LUFS.
3. **Resolution QA:** 1080×1920, 30fps, H.264.
4. **Visual QA (human-in-the-loop for first 3 reels):** play the MP4. If it *feels* like a slideshow, it is. Back to rework regardless of SSIM.

Only after all four checks pass is the reel moved from `pending` → `rendered` in `queue.json`.

## Pipeline architecture (what scripts exist)

```
automation/video-gen/
├── generate_reel.py            # main orchestrator
├── tools/
│   ├── synthesize_voice.sh     # Stage 1 wrapper
│   ├── generate_video_clip.sh  # Stage 2 — routes to LTX / AnimateDiff / parallax
│   ├── animate_text.py         # Stage 3 — kinetic typography
│   ├── motion_qa.py            # Stage 5 — SSIM check
│   └── ollama_visual_query.sh  # helper for motion-prompt expansion
├── cache/<reel>/               # per-scene intermediates
├── output/                     # shipped MP4s
├── samples/                    # pre-approval samples (voice, text, scenes)
├── queue.json                  # render queue state + user-gate flags
└── music/                      # CC0 bed tracks
```

## Dispatch pattern

When asked to "generate a reel" for Project Bodhi:

1. **Check gates.** Read `queue.json`. If `gates.voice_approved` or `gates.slice_approved` is false, do NOT batch-render; produce a single sample and stop.
2. **Pick ONE reel** as the vertical slice (shortest JSON, narrative mode preferred).
3. **Run stages 0-4.**
4. **Run stage 5 QA** — if it fails, iterate on the failing stage. Do NOT ship.
5. **Report with the MP4 path** and the QA metrics.

## Anti-patterns (hard fails)

- Using Unsplash stills with Ken Burns as the whole visual pipeline. That is slideshow.
- Shipping without running motion QA.
- Hard cuts between scenes (no crossfade).
- Static `drawtext` in modern reel format.
- Batch-rendering before the user has approved a vertical slice.
- Mixing Hindi voice with English on-screen text without a deliberate reason.
- Calling a cloud API anywhere.
- Pretending a 3-second clip at the opening is "motion" and then 50 seconds of Ken Burns is fine. It isn't.

## Fallback ladder when LTX-Video is slow/broken

1. LTX-Video MLX on Apple Silicon (primary)
2. AnimateDiff via ComfyUI headless (MPS)
3. SVD-XT (MPS, img2vid)
4. Parallax composite (FFmpeg, deterministic, always works)
5. (LAST RESORT) Ken Burns + particle field + light animation + color grade shift — clearly inferior; use only if all AI paths fail and user has been warned.

## When to ask the user

- Before committing to an AI video model install (19+ GB download, ~45 min first-run): confirm they want to proceed
- Before batch-rendering more than 1 reel: confirm the vertical slice looks right
- If a scene consistently fails QA after 3 reworks: surface the issue, don't silently ship a degraded clip

## Success criterion

A reel is successful when a viewer, watching at 1× speed with sound on, cannot tell it was assembled from stock assets. The motion is continuous. The voice sounds human. The text animates. The story flows scene-to-scene.
