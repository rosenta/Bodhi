# Media Division — Hiring Plan

> **Author:** Chief of Staff (Media Division)
> **Date:** 2026-04-18
> **Status:** DRAFT — awaiting user approval on (a) role count, (b) new custom subagent definitions, (c) sample-gate sequencing.
>
> **In-flight agents (do not re-dispatch):**
> 1. Hindi TTS sample agent — evaluating IndicTTS / XTTS-v2 / MMS-Hindi / Coqui
> 2. Hindi story rewrite sample agent — rope-and-snake in naive urban Hindi
> 3. Video-model research agent — Seedance feasibility on Apple Silicon + alternatives

---

## 1. Context Reset — Why v1 Failed and What v2 Must Fix

| Axis | v1 failure | v2 direction |
|---|---|---|
| Language | English, "literary" register | **Hindi**, naive / accessible register |
| Voice | macOS `say` — robotic | Natural Hindi TTS (open-source, local) |
| Visuals | Unsplash stills + Ken Burns | **Seedance** (or open-source fallback: AnimateDiff / SVD / CogVideoX) |
| Process | "Render the queue" | **Sample-gate every axis** before mass rendering |

User has repeated "verify with samples first" multiple times. Every new capability must pass a **1-sample approval gate** before any batch render.

---

## 2. Division Org Chart

```
                             USER (approver of gates)
                                    │
                       ┌────────────┴────────────┐
                       │  Chief of Staff (CoS)   │   ← this agent: orchestration, sequencing, gate enforcement
                       │  model: opus            │
                       └────────────┬────────────┘
                                    │
       ┌──────────────┬─────────────┼───────────────┬──────────────────┐
       │              │             │               │                  │
 ┌─────┴─────┐  ┌─────┴─────┐ ┌─────┴─────┐   ┌─────┴─────┐     ┌──────┴──────┐
 │  CREATIVE │  │   VOICE   │ │   VIDEO   │   │  POST &   │     │     QA      │
 │   track   │  │   track   │ │   track   │   │ ASSEMBLY  │     │  (gatekpr)  │
 └─────┬─────┘  └─────┬─────┘ └─────┬─────┘   └─────┬─────┘     └──────┬──────┘
       │              │             │               │                  │
       │              │             │               │                  │
  Hindi Copy     Hindi Voice    Shot Designer   Post-Prod          QA Reviewer
  Lead           Director       +               Engineer          (opus)
  (sonnet)       (sonnet)       Video Model     (sonnet)
                                Operator
                                (sonnet)
       │              │             │               │
       │              │             │               │
  Subtitle        (shares TTS    (depends on     Music Bed
  Specialist      engine with    Shot Designer   Curator
  (haiku)         VO Director)   prompts)        (haiku)

                 Pipeline Architect (sonnet) — cuts across all tracks, owns the glue
```

**9 roles total** (including CoS). Lean but not under-staffed — every role addresses a distinct failure axis of v1.

---

## 3. Role Table

| # | Role | Agent Type | Model | Scope (1 sentence) | Cadence | User-Gate? | Depends on |
|---|------|-----------|-------|--------------------|---------|-----------|------------|
| 0 | Chief of Staff (Media) | `chief-of-staff` (existing, repurposed) | opus | Orchestrates the pipeline, enforces gates, logs to `CHIEF-OF-STAFF-LOG.md`. | every 2–4 hr | n/a | — |
| 1 | Hindi Copy Lead | **NEW** `hindi-copy-lead` | sonnet | Rewrites 22 reel scripts + 6 stories into naive, accessible Hindi; owns tone. | per-batch (sample → approve → batch) | **YES** — sample before batch | in-flight story-rewrite agent |
| 2 | Hindi Voice Director | **NEW** `hindi-voice-director` | sonnet | Picks final TTS engine + voice, tunes prosody, handles Sanskrit pronunciation. | one-shot pick, then per-reel QA | **YES** — voice lock before any batch VO | in-flight TTS sample agent |
| 3 | Subtitle / Caption Specialist | **NEW** `subtitle-specialist` | haiku | Produces Hindi `.srt` + English `.srt` from final VO + script; burn-in timing. | per-reel | no (QA catches) | Copy Lead + Voice Director |
| 4 | Shot Designer | **NEW** `shot-designer` | sonnet | Converts each reel JSON scene's `visual` into an effective txt2vid / img2vid prompt. | per-reel (loop) | **YES** — prompt style lock after 1 reel | Video Model Operator (to sanity-check prompts render) |
| 5 | Video Model Operator | **NEW** `video-model-operator` | sonnet | Runs Seedance (or approved fallback) on Shot Designer's prompts; manages GPU memory. | per-reel (loop) | **YES** — model choice lock (Seedance vs AnimateDiff vs SVD) | in-flight video-model research agent |
| 6 | Music Bed Curator | **NEW** `music-bed-curator` | haiku | Selects / generates CC0 contemplative music per reel mood; normalizes loudness. | per-batch | no | Copy Lead (needs final mood/tone per reel) |
| 7 | Post-Production Engineer | **NEW** `post-production-engineer` | sonnet | FFmpeg assembly: video + VO + subtitles + music bed + text overlays → final 9:16. | per-reel | no | Roles 2, 3, 4, 5, 6 all feed this |
| 8 | QA Reviewer | **NEW** `qa-reviewer` | opus | Watches every rendered MP4 before ship; flags lip-sync, subtitle legibility, audio clipping, weak shots. | per-reel, **blocking** | **YES** — publish gate | Post-Production Engineer |
| 9 | Pipeline Architect | `architect` (existing) | sonnet | Owns the Python/bash glue; adds stages, wires CLI flags, keeps `automation/video-gen/` honest. | on-demand | no | cross-cutting |

**Staffing math:** 6 new custom subagents + 2 reused existing (`chief-of-staff`, `architect`) + 1 already-exists (`cto-media`, likely retired after v2 cutover).

---

## 4. Critical Path

```
[ RESEARCH gate (already running) ]
    │
    ├─── TTS sample (3 engines compared, 1 chosen)   ─┐
    ├─── Video-model research (Seedance feasibility)  ├── GATE 1: voice + model approved
    └─── Hindi story rewrite sample (1 story)        ─┘
                   │
                   ▼
   [ ROLE SPAWN — hire Copy Lead + Voice Director + Video Model Operator + Shot Designer ]
                   │
                   ▼
   [ 1-REEL VERTICAL SLICE ] ── one reel end-to-end: script → VO → shots → assembly → QA
                   │
                   ▼
              GATE 2: vertical slice approved  ← HUMAN WATCHES THE MP4
                   │
                   ▼
   [ BATCH MODE ] ── Copy Lead batch-rewrites all 22 reels + 6 stories
                   │
                   ▼
   [ PARALLEL RENDER ] ── Shot Designer + Model Operator + Post-Prod loop, QA gates each
                   │
                   ▼
              Ship queue empty
```

**Critical path (one sentence):** In-flight research gate → Gate 1 (voice + model lock) → hire 4 track leads → 1 vertical-slice reel → Gate 2 (full-slice approval) → batch rewrite + parallel render + per-reel QA → ship.

**Parallelizable:**
- After Gate 1: Copy Lead (text) runs in parallel with Video Model Operator (shots) — they share no state.
- After Gate 2: Shot Designer + Model Operator + Post-Prod form a per-reel pipeline; QA batches 3–5 reels at a time.
- Subtitle Specialist + Music Bed Curator run as leaf nodes — never blocking.

**Serial chokepoints:**
- Voice lock (Gate 1) blocks all VO generation.
- Model lock (Gate 1) blocks all shot rendering.
- QA Reviewer (Gate 3 — per-reel) blocks publish — but approved reels can queue for release independently.

---

## 5. Sequencing Plan

### Cycle 1 — **Research settle** (now → +2 hr)
- Let 3 in-flight sample agents finish. Do NOT dispatch more.
- CoS collects their output: best Hindi TTS engine, best story-rewrite voice, Seedance feasibility verdict.
- CoS writes a 1-page "samples summary" for the user.
- **User reviews samples. Approves or redirects.** (Gate 1 proper.)

### Cycle 2 — **Hire the 4 core track leads** (after Gate 1)
- Create `hindi-copy-lead`, `hindi-voice-director`, `shot-designer`, `video-model-operator` subagent files (user approves file content first).
- Assign each a 1-reel scope: rewrite **reel-011** (or whichever user picks), generate VO, generate shots, pass to Post-Prod.
- Do not hire Music Bed Curator, Subtitle Specialist, or QA yet — they're not on the critical path for the vertical slice.

### Cycle 3 — **Vertical slice render** (after Cycle 2)
- Hire `post-production-engineer` and `qa-reviewer`.
- Assemble the one reel end-to-end.
- **User watches the MP4.** (Gate 2.)
- If rejected: iterate on the specific failed axis (voice? shots? assembly?). No new reels until this one ships.

### Cycle 4 — **Batch rewrite** (after Gate 2)
- Copy Lead rewrites remaining 21 reels + 6 stories into Hindi. Leaf task — does not block anything else.
- In parallel: Shot Designer + Model Operator + Post-Prod render the next 3 reels using the approved style.
- QA gates each reel individually.

### Cycle 5..N — **Steady state loop**
- Render 2–3 reels per cycle (per-cycle budget matches `cto-media`'s original discipline).
- Music Bed Curator + Subtitle Specialist join the pipeline as polish layers.
- CoS reports queue state every 2 hr.

---

## 6. Human-Approval Gates (mandatory)

| Gate | When | What the user approves | Blocks |
|------|------|------------------------|--------|
| **Gate 1 — Research Settle** | After 3 in-flight sample agents finish | (a) Hindi TTS engine + voice; (b) Video model (Seedance vs fallback); (c) Hindi rewrite tone | All hiring of track leads |
| **Gate 2 — Vertical Slice** | After 1 reel is rendered end-to-end | Full MP4: voice, shots, subtitles, music, pacing, mouth/visual alignment | Any batch rendering |
| **Gate 3 — Per-Reel Publish** | Every rendered reel, forever | QA Reviewer flags → user approves ship or kick-back | Publishing that specific reel |

**The two that must exist before ANY mass rendering:** Gate 1 (voice + model) and Gate 2 (vertical slice). Without both, we repeat the v1 mistake at Hindi scale.

---

## 7. Top 3 Risks + Mitigations

### Risk 1 — Seedance doesn't run on Apple Silicon
**Likelihood:** moderate. Seedance is newer and model weights + CUDA assumptions are common.
**Impact:** blocks entire video track. Fallback to AnimateDiff / SVD / CogVideoX adds 1 cycle.
**Mitigation:** In-flight research agent is already investigating this. Video Model Operator role is defined model-agnostic — we hire the role, then slot whichever model survives. If all open-source options fail on M-series, escalate to user: "accept cloud inference for video only, or accept Ken Burns 2.0 as interim?"

### Risk 2 — Hindi TTS prosody is wrong for Sanskrit-laden text
**Likelihood:** high. Most Hindi TTS models are trained on news / conversational corpora, not Sanskrit verse. `श्लोक` and `सूत्र` will be mispronounced.
**Impact:** voice lands "Hindi" but not "spiritually credible" — the naive-accessibility gain gets wiped out by mispronounced key terms.
**Mitigation:** Hindi Voice Director's first task after engine-lock is a **Sanskrit pronunciation test set** — 20 key terms (ātman, brahman, viveka, buddhi, etc.) recorded and QA'd. If the chosen engine fails, prepend IPA/Devanagari overrides or fall back to phonetic respelling in the script.

### Risk 3 — "Naive Hindi" drifts into either (a) childish or (b) still-literary
**Likelihood:** moderate. Naive-vs-childish is a tone edge the Copy Lead must hold.
**Impact:** content either talks down to the audience or replicates the v1 "not accessible enough" problem in Hindi.
**Mitigation:** Before Cycle 2, Copy Lead produces a **1-page tone bible** with 5 do/don't examples (calibrated against the in-flight rope-and-snake sample). User signs off before the batch rewrite. QA Reviewer holds the tone bible as a rubric for every reel.

---

## 8. New Custom Subagent Definitions (DRAFTS — do NOT create files yet)

> User must approve before these are saved to `~/.claude/agents/<name>.md`. Stubs below.

### 8.1 `hindi-copy-lead.md`
```yaml
---
name: hindi-copy-lead
description: Rewrites Project Bodhi reel scripts and short stories from English into naive, accessible urban Hindi while preserving Sanskrit key terms. Owns the tone bible.
tools: ["Read", "Write", "Edit", "Grep", "Glob"]
model: sonnet
---
```
**System prompt (draft):** "You are the Hindi Copy Lead for Project Bodhi. Rewrite English reel scripts (`content/reels/reel-*.json` script fields) and short stories into **naive urban Hindi** — accessible to a non-scholar Delhi/Mumbai listener, while preserving Sanskrit technical terms (ātman, brahman, viveka) in Devanagari with brief in-line gloss on first use. Hold the tone bible at `content/stories/_samples/HINDI-TONE-BIBLE.md`. Never publish without CoS passing the user's tone-bible approval. Append to `HINDI-COPY-LOG.md`."

### 8.2 `hindi-voice-director.md`
```yaml
---
name: hindi-voice-director
description: Selects and tunes the Hindi TTS engine for Project Bodhi. Owns Sanskrit pronunciation overrides, prosody presets, and VO QA.
tools: ["Read", "Write", "Edit", "Bash", "Grep"]
model: sonnet
---
```
**System prompt (draft):** "You own voice for Project Bodhi. After Gate 1 lock, your engine/voice choice is frozen for the duration of the launch. Maintain `automation/video-gen/voice/pronunciation-overrides.json` for Sanskrit terms. Before any batch, run the 20-term pronunciation test set and attach output to `CTO-MEDIA-LOG.md`. Never swap engines mid-batch."

### 8.3 `shot-designer.md`
```yaml
---
name: shot-designer
description: Converts reel JSON scene visual descriptions into effective txt2vid / img2vid prompts for the chosen open-source video model.
tools: ["Read", "Write", "Edit", "Grep"]
model: sonnet
---
```
**System prompt (draft):** "For each scene in a reel JSON, read the `visual` field and produce a video-model prompt aligned with the approved style (see `automation/video-gen/shots/STYLE-LOCK.md`). Include camera direction, lighting, subject specificity, aspect-ratio tokens. Never invent scenes not in the JSON. Output to `automation/video-gen/shots/<reel-id>/scene-NN.prompt.txt`."

### 8.4 `video-model-operator.md`
```yaml
---
name: video-model-operator
description: Runs the approved open-source video model (Seedance or fallback) per scene on Apple Silicon. Manages unified-memory budget and fallbacks.
tools: ["Read", "Write", "Bash", "Grep"]
model: sonnet
---
```
**System prompt (draft):** "Consume Shot Designer's prompt files. Run the model fixed by Gate 1. Respect unified-memory ceiling; if OOM, fall back to the pre-approved lower-res preset. Output `automation/video-gen/shots/<reel-id>/scene-NN.mp4`. Log failures with the exact error string; never silently skip."

### 8.5 `post-production-engineer.md`
```yaml
---
name: post-production-engineer
description: Final FFmpeg assembly — concatenates scene clips, muxes VO, overlays subtitles + text, mixes music bed, exports 9:16 1080x1920 H.264.
tools: ["Read", "Write", "Bash", "Grep"]
model: sonnet
---
```
**System prompt (draft):** "Assemble one reel: scene clips from `shots/` + VO from `voice/` + subtitles from `subtitles/` + music from `music/`. Target: 1080x1920, 30fps, H.264 + AAC, 45–60s, loudness-normalized. Output `output/reel-NNN.mp4`. Hand off to QA Reviewer — do not mark done until QA passes."

### 8.6 `qa-reviewer.md`
```yaml
---
name: qa-reviewer
description: Watches every rendered reel before ship. Gates publish. Flags lip-sync, subtitle legibility, audio clipping, weak shots, pronunciation errors, tone-bible violations.
tools: ["Read", "Bash", "Grep"]
model: opus
---
```
**System prompt (draft):** "You are the final gate. For each MP4 in `output/`, produce a QA report: (a) audio peaks + clipping check via ffprobe; (b) duration + resolution + framerate verification; (c) subtitle timing sanity; (d) pronunciation spot-check against `voice/pronunciation-overrides.json`; (e) tone-bible compliance (sample 3 lines); (f) shot continuity — does any scene look broken? Output PASS/WARN/FAIL per reel with rationale. Only PASS ships. FAIL returns to the responsible role."

### 8.7 `subtitle-specialist.md`
```yaml
---
name: subtitle-specialist
description: Produces Hindi and English SRT subtitle tracks from final VO + script, with burn-in timing and font selection.
tools: ["Read", "Write", "Bash"]
model: haiku
---
```

### 8.8 `music-bed-curator.md`
```yaml
---
name: music-bed-curator
description: Selects or generates CC0 contemplative music per reel mood. Normalizes loudness to -20dB under VO.
tools: ["Read", "Write", "Bash"]
model: haiku
---
```

---

## 9. What Happens Next

**Immediate (no new dispatches):**
- CoS waits for the 3 in-flight sample agents to finish.
- CoS reads their outputs, compiles a 1-page samples summary for the user.
- CoS surfaces Gate 1 to the user with an explicit approval checklist: (a) pick TTS engine, (b) pick video model, (c) approve tone bible v0.

**After Gate 1 approval:**
- User (or orchestrator) creates the 4 core subagent files (copy-lead, voice-director, shot-designer, video-model-operator) using the drafts in §8.
- CoS dispatches all 4 with a **single-reel scope**. The 4 produce output for one reel only.

**After Gate 2 approval:**
- User (or orchestrator) creates remaining 4 subagent files (post-prod, qa-reviewer, subtitle, music-bed).
- CoS enters steady-state loop: 2–3 reels per cycle, QA per reel.

**No mass rendering before Gate 1 and Gate 2 both pass.** This is the one hard rule.

---

## 10. Appendix — Mapping v1 Failure Modes to v2 Roles

| v1 failure | v2 role that owns the fix |
|---|---|
| Robotic English voice | Hindi Voice Director |
| "Not naive" prose | Hindi Copy Lead + Tone Bible |
| Still images with Ken Burns = not cinema | Shot Designer + Video Model Operator |
| No pre-ship review | QA Reviewer |
| English-only reach | Subtitle Specialist (Hindi + English SRTs) |
| Silent background | Music Bed Curator |
| Pipeline drift / brittle glue | Pipeline Architect |
| "Render everything" without sampling | Chief of Staff enforces Gates 1 and 2 |
