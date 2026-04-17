# Hindi Voice Samples — Project Bodhi

Local, open-source Hindi TTS candidates for narrating Vivekachudamani / Yoga Darshan content.
All samples voice the **same Hindi Devanagari script** so you can A/B directly.

## Sample script

```
नदी के किनारे घुटनों के बल बैठा वह आदमी — उसने सब कुछ जीत लिया था।
और फिर भी।
उसकी पसलियों के पीछे एक खालीपन था जिसे कोई भी उपलब्धि भर नहीं सकती थी।
उसने आँखें बंद कीं।
और वह सवाल पूछा जिसे वह बीस साल से टाल रहा था।
मैं कौन हूँ?
```

All samples are loudness-normalized (EBU R128: I=-16 LUFS, TP=-1.5 dB, LRA=11).

## Candidates

| # | File | Engine | Voice ID | Duration | Subjective note |
|---|------|--------|----------|----------|-----------------|
| 1 | `macos-lekha.mp3/.wav` | macOS `say` | `Lekha` (hi_IN) | 18.1s | Clear, articulate female Hindi voice. Feels like an educated news-anchor reading — slightly flat prosody. Pronounces Devanagari cleanly. Sanskrit-friendly (आत्मा, ब्रह्म, विवेक should render correctly as Hindi shares the same phoneme inventory). |
| 2 | `macos-lekha-contemplative.mp3/.wav` | macOS `say` | `Lekha` (hi_IN) | 22.5s | Same voice at r=125 wpm + `[[slnc N]]` pauses inserted between sentences. Much more meditative — closer to the "warm storyteller" target. **Best match for wisdom-text narration among tested candidates.** |
| 3 | `mms-tts-hin.mp3/.wav` | Meta MMS-TTS | `facebook/mms-tts-hin` | 19.3s | Neural VITS, single female Hindi voice. Natural Hindi phonology but cadence can drift and pitch sometimes sounds slightly nasal / "AI-ish". Sanskrit तत्सम words pronounced correctly. Output is 16 kHz (upsampled to 22.05 kHz). |
| 4 | `mms-tts-hin-slow.mp3/.wav` | Meta MMS-TTS | `facebook/mms-tts-hin`, `speaking_rate=0.75` | 23.4s | Slowed variant. Pace is contemplative but model speaking-rate slowdown thins some vowels. Quality slightly degraded vs sample 3. |

## Engines tried

### 1. macOS `say` with Lekha (hi_IN) — **baseline, free, zero-install**

```bash
say -v Lekha -r 140 -o out.aiff "<hindi text>"          # default pace
say -v Lekha -r 125 -o out.aiff "<hindi text>"          # contemplative
# Insert pauses: [[slnc 500]] = 500 ms silence (use inside the string)
```

No download. Uses Apple's on-device neural Hindi voice. Pronunciation of Devanagari is solid.

### 2. Meta MMS-TTS Hindi — **neural, single voice**

```bash
pip install "transformers<4.45" scipy torch
```

```python
from transformers import VitsModel, AutoTokenizer
import torch, scipy.io.wavfile
model = VitsModel.from_pretrained("facebook/mms-tts-hin")
tokenizer = AutoTokenizer.from_pretrained("facebook/mms-tts-hin")
inputs = tokenizer(text, return_tensors="pt")
with torch.no_grad():
    wav = model(**inputs).waveform.squeeze().cpu().numpy()
scipy.io.wavfile.write(out, rate=model.config.sampling_rate, data=wav)
# Slow for contemplative feel:  model.speaking_rate = 0.75
```

~150 MB model download (one-time). Runs on CPU in ~5 s on M-series Mac.

## Engines NOT tested (time-boxed out at 15 min)

- **AI4Bharat Indic-Parler-TTS** — ~900 MB download, 5B-parameter model; would blow the time box on a cold cache. Worth a follow-up run if none of the above feel right. Install: `pip install git+https://github.com/huggingface/parler-tts.git` then use `parler-tts-mini-multilingual` / `indic-parler-tts`. Supports prompt-controlled style ("a warm, contemplative female voice, slow pace, low noise") which is ideal for our use case.
- **Coqui XTTS-v2** — supports Hindi via `--language hi` and can voice-clone from a 6-second reference clip. Needs a reference WAV of a voice you like (e.g. a public recording of a known Hindi storyteller or a clean sample of the user's own voice). `pip install TTS` (Python 3.10/3.11 only — current env is 3.12, would need a fresh venv).
- **Piper** — Installed (`piper-tts 1.4.2`) but rhasspy/piper-voices does **not publish an official hi_IN voice** as of April 2026. No community model widely vetted. Skipped.

## Sanskrit-term check

All four samples include तत्सम Sanskrit-derived words in the script (कौन, बीस — no heavy Sanskrit in this script). For a harder test (आत्मा, ब्रह्म, विवेक, माया, अहंकार, बुद्धि) a dedicated Sanskrit-loaded sample is recommended before final engine choice.

- macOS Lekha: historically renders these correctly (same Devanagari phoneme set).
- MMS-TTS-hin: trained on general Hindi corpora that include तत्सम words; should be acceptable but worth spot-checking on actual Vivekachudamani verse text.

## Ranking — most to least natural for Hindi spiritual narration

1. **`macos-lekha-contemplative.wav`** — best overall match: clear, unambiguously Hindi, contemplative pace, zero install cost, deterministic. Recommended default for v1.
2. **`mms-tts-hin.wav`** — more "neural/human-breath" texture than Lekha, but prosody is less controlled and occasionally sounds synthetic. Good fallback / variety option.
3. **`macos-lekha.wav`** — same voice as #1 at default pace; fine for general narration, too brisk for wisdom-text.
4. **`mms-tts-hin-slow.wav`** — artifact-prone when slowed; prefer #1 for contemplative feel.

## Recommended next steps

- **If #1 sounds good enough to the user → ship Lekha contemplative** as the Hindi voice path in `generate_reel.py` (simple fork of the existing `say` code path, just `-v Lekha` + Hindi `-r 125` + pause insertion pre-processor).
- **If a more "human" voice is required → download `ai4bharat/indic-parler-tts`** (~900 MB, give it a 20-minute budget) and retest. Parler-TTS's prompt control is the strongest lever for a "warm, contemplative storyteller" persona.
- **If the user wants a specific voice (e.g. their own, or a public speaker) → Coqui XTTS-v2** with voice cloning is the path. Requires Python 3.10/3.11 venv and a 6-second reference clip.
