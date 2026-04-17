# Project Bodhi — Local Reel Video Pipeline

Zero-API-cost, fully local pipeline that converts a reel JSON script into a 9:16
1080x1920 MP4 ready for Instagram / TikTok. Runs on a MacBook. No paid services.

## Stack

| Layer     | Tool                                  | Notes |
|-----------|---------------------------------------|-------|
| TTS       | **Piper** (preferred) or macOS `say`  | `say` is the zero-install fallback and what Tier A uses by default |
| Visuals   | **FFmpeg** gradient/still + Ken Burns | Tier A — ships today, guaranteed to work |
| Stock img | `source.unsplash.com` free CDN        | No API key. Silently falls back to gradients if offline |
| AI text   | **Ollama** (`llama3.2:3b`) for query rewriting + captions | Uses what the user already has |
| Assembly  | **FFmpeg** concat + drawtext + amix   | Single binary, already installed |

Tier B (AI-generated video via Stable Video Diffusion / AnimateDiff through
ComfyUI or diffusers) is documented at the bottom but NOT required for v1.

## Install

```bash
# Required (likely already installed)
brew install ffmpeg

# Optional: Piper for better TTS than `say`
# Download a voice model, e.g. en_US-ryan-medium:
mkdir -p ~/piper && cd ~/piper
curl -LO https://github.com/OHF-Voice/piper1-gpl/releases/download/v1.0.0/piper_macos_aarch64.tar.gz
tar -xzf piper_macos_aarch64.tar.gz
# and grab a voice from https://huggingface.co/rhasspy/piper-voices
# e.g. en_US-ryan-medium.onnx + .onnx.json into ~/piper/voices/
export PIPER_BIN="$HOME/piper/piper"
export PIPER_VOICE="$HOME/piper/voices/en_US-ryan-medium.onnx"

# Ollama — verify you have a text model available
ollama list        # expect llama3.2:3b or similar
```

Python deps: stdlib only. No `pip install` needed for v1.

## Usage

```bash
cd /Users/aera/Documents/random/VivekChudamani/automation/video-gen

# Render a single reel
python3 generate_reel.py ../content/reels/reel-027-story-the-kneel.json

# Force a specific TTS engine
TTS_ENGINE=say python3 generate_reel.py <path-to.json>
TTS_ENGINE=piper python3 generate_reel.py <path-to.json>

# Skip stock-image download (use gradients only, fully offline)
USE_STOCK=0 python3 generate_reel.py <path-to.json>

# Skip Ollama (use raw visual text as query)
USE_OLLAMA=0 python3 generate_reel.py <path-to.json>

# Output goes to output/reel-NNN.mp4 by default.
```

Optional: drop a royalty-free track at `music/bed.mp3`. It will be auto-mixed
under the voiceover at -20dB. If the file is absent, the video is pure VO + silence.

## Pipeline (what `generate_reel.py` does)

1. Parse the reel JSON — extract `script[]` scenes.
2. For each scene:
   - Parse `time` ("0-6s") → target duration.
   - **Voiceover:** synthesise VO text to `cache/vo_<scene>.wav` via Piper or
     `say`. Measure real duration with `ffprobe`.
   - **Visual query rewrite:** optionally pipe the scene's `visual` description
     through Ollama (`llama3.2:3b`) to extract 2-3 concrete search terms.
   - **Visual asset:**
     - Tier A: download 1080x1920 image from `source.unsplash.com/1080x1920/?query`
       to `cache/img_<scene>.jpg`. On failure, generate an animated gradient.
   - **Scene clip:** ffmpeg Ken Burns pan/zoom on the still, burn in
     `text_overlay` via `drawtext`, mux with VO audio. Output `cache/scene_<n>.mp4`.
3. **Concat** all scene clips (concat demuxer) → `cache/_concat.mp4`.
4. **Mix music:** if `music/bed.mp3` exists, `amix` it under the VO at low
   volume; otherwise keep VO-only. Encode final H.264 + AAC, 1080x1920, 30fps.
5. Write `output/reel-<id>.mp4`.

## Tier B (future — AI-generated motion)

Use **ComfyUI** locally with one of:
- **Stable Video Diffusion (SVD-XT)** — image → 4 second animated clip.
- **AnimateDiff** — text → short video via SD 1.5 motion module.

Install ComfyUI, place SVD model in `ComfyUI/models/checkpoints/`, then swap
the `generate_visual_clip()` function to render via ComfyUI's API (`/prompt`)
instead of Ken Burns. Keep everything else identical. Budget ~30-90s per clip
on M-series, expect 6-8GB VRAM/unified memory.

For style consistency across scenes, use the vision model (`qwen2.5vl:7b` or
`llama3.2-vision:11b`) to caption an anchor image then feed that caption into
SVD's text conditioning.

## Known limitations (v1)

- `say` voices are robotic vs. Piper/Coqui — swap to Piper for production.
- `source.unsplash.com` is deprecated-ish; if it 404s consistently, cache a
  local image pool under `cache/stock/` or swap to Pexels public CDN.
- Ken Burns on a still is "motion graphics", not cinema. Tier B fixes this.
- FFmpeg drawtext needs a font file — we default to SF Pro / Helvetica on macOS.
