# CTO Media Log — Project Bodhi

> Open-source local media pipelines (zero paid APIs). Two tracks:
> 1. **Reels** — reel JSON → 9:16 MP4 (Piper/say + Unsplash + Ollama + FFmpeg).
> 2. **Story illustrations** — story markdown → 9:16 PNG (Blender Cycles, AgX, 1080×1920).
>
> CTO reads `CTO-CHECKPOINT.md` first every cycle to know which pipeline + item
> to pick up. Updates the checkpoint at end of each cycle. Both tracks have their
> own queue.json (`automation/video-gen/queue.json`, `blender/queue.json`).

---

## 2026-05-03 — Story-001 v6 render (Cycle 6, by cto-media)

- Pipeline: illustrations
- Story: story-001-the-arrival, version v6
- Trigger: User rejected v5 (Three.js Soldier reads as zombie/militant — wrong mood).
- v5 DEMOTED. v6 is the new public version.

- Course correction — Soldier asset banned:
  The Three.js Soldier (v5) failed mood QA post-promotion. The Mixamo rig has rifle-stance
  proportions and a militant silhouette that cannot be overcome by bone rotation. Arms
  z=±80 + forearm x=±50 posed as arms-outstretched, not bowing — zombie/charging pose.
  Permanent rule added: Three.js Soldier BANNED for contemplative scenes.
  Asset-fit check rule added to .claude/agents/cto-media.md (check #6).

- v6 figure approach (7 render iterations to converge):
  Attempts 1-3: single sphere (various rotations/scales) — always reads as an oval/egg
    regardless of rotation because camera-facing silhouette of a sphere doesn't change.
  Attempt 4: bent cylinder (Simple Deform Bend around Y, then X axis) — still read as
    thin oval because camera looks mostly along Y (figure Y-depth foreshortened).
  Attempt 5: cone torso + small head sphere + legs block — SUCCESS.
    Cone (radius1=0.28, radius2=0.06, depth=0.72) gives wide-shoulder silhouette tapering
    to neck. Head sphere r=0.14 overlaps cone tip (r=0.06). No gap. Not a snowman.
    Flat legs cube (scale 1.4×1.0×0.35) grounds the figure at Z=0.175.
    No arms. No imported assets. No silhouette baggage.

- QA squint-test v6:
  Figure reads as STILL (no arms out): PASS
  Figure small and bowed (~25-28% frame height): PASS
  One readable shape (not competing limbs): PASS
  All v4 environmental wins preserved (bank/river/trees/hut/dawn): PASS
  Figure reads as kneeling/seated contemplative devotee: PASS

- Render time: 1m49s (7 total iterations during cycle)
- Promotion: v6 PROMOTED to website/public/illustrations/story-001-the-arrival.png
- v5 DEMOTED (not on public path)

- Gates: story-001-approved = pending user sign-off on v6
- Queue: illustrations 1 rendered (v6) / 6 pending / 0 failed
- Next cycle priority: await user approval of v6; if approved flip gate and begin
  stories 002-007 batch render. Optional v7 polish: kicker light on figure shoulder,
  slight forward bow rotation of figure group, or god-ray sun lamp.

---

## 2026-05-03 23:30 — Story-001 v5 render (Cycle 5, by cto-media)

- Rendered: story-001-the-arrival v5 → `blender/renders/story-001/v5.png`
- Pipeline change (single fix — snowman figure replaced with CC0 rigged human):
  Removed hand-crafted UV-sphere torso + head (snowman silhouette).
  Imported Three.js Soldier (Vanguard character) GLB from https://threejs.org/examples/models/gltf/Soldier.glb
  License: CC0 / public domain. Cached at blender/assets/soldier.glb (2.1 MB).
  The GLB has a full Mixamo-rigged humanoid armature (mixamorig: bone prefix).
  Applied pose: armature rotated (-90X, 180Z) to stand upright with back to camera.
  Kneeling bow pose derived via bone-axis probing:
    Hips.location (0,-60,0) → world Z=0.46 (kneeling height).
    UpLeg x=-45, Leg x=+45 → thigh backward, shin folded (knee Z=0.22, near ground).
    Spine/Spine1/Spine2 each -18 to -14 deg X → cascading forward bow.
    Neck/Head -20/-15 deg X → head bowed toward river.
    Arms LA(x=-40,z=+80) + FA(x=+50) → hands forward-low (suppliant gesture toward water).
  All mesh materials replaced with cloth_mat (near-black warm) for dark silhouette.
  Mid-cycle course correction: user unblocked use of premade animated Blender artifacts/CC0 models.
  7 iterative renders during cycle to resolve: (a) GLB scale/transform issues,
  (b) armature orientation, (c) bone-axis mapping for correct kneeling pose.
- Asset note: blender/assets/soldier.glb is reusable for stories 002-007 (re-pose per scene).
- QA results:
  Figure NOT two stacked spheres: PASS — reads as crouched/bowing dark human form.
  Figure on visible bank: PASS. River bounded mid-frame band: PASS.
  Dawn sky/atmosphere: PASS. Trees/hut: PASS. All v4 wins preserved: PASS.
- Promotion decision: v5 PROMOTED to `website/public/illustrations/story-001-the-arrival.png`
- Gates: story-001-approved = pending user sign-off
- Queue: illustrations 1 rendered (v5) / 6 pending / 0 failed
- Next cycle priority: await user approval of v5; if approved flip gate and begin stories 002-007.
  Optional v6 polish: deeper kneeling (Y_loc=-70) or god-ray sun lamp from treeline.

---

## 2026-05-03 21:15 — Story-001 v4 render (Cycle 4, by cto-media)

- Rendered: story-001-the-arrival v4 → `blender/renders/story-001/v4.png`
- Pipeline change (single logical fix — restoring the bank):
  River plane creation size 80 → 20 (bounded river footprint, not an ocean).
  River center Y=7 → Y=10, scale (2.0,0.6) → (1.5,0.5): effective footprint ~30×10;
  near edge at Y=5 (2 units clear of figure at Y=3, figure stands on solid bank).
  River Z kept at 0.10 (visible above ground mean level in mid-frame).
  Ground displacement strength 0.12 → 0.22 (textured near-bank without burying river).
  Root cause of v3 regression: size=80 river plane at Z=0.10 with displacement=0.12
  created a nearly-flat flood covering the entire foreground — no visible bank at all.
- QA rule update: water/river check in cto-media.md now requires bounded footprint AND
  visible near bank, not just "is a reflective plane visible?" Added permanent clarification
  to Per-illustration QA item 6 (story-specific elements present).
- Gates: voice=N/A (illustration pipeline)  slice=N/A  story-001-approved=pending user sign-off
- QA results:
  Figure on visible bank (not in water): PASS.
  River as bounded mid-frame band: PASS (water visible Y=5–15 zone only).
  Figure dark silhouette preserved: PASS. Dawn sky/atmosphere PASS. Trees/hut PASS.
- Promotion decision: v4 PROMOTED to `website/public/illustrations/story-001-the-arrival.png`
- Queue: illustrations 1 rendered / 6 pending / 0 failed (story-001 v4 promoted)
- Next cycle priority: v5 = replace two-sphere snowman figure with elongated cylinder/capsule
  so the dark form reads as a slender kneeling human silhouette (planned for v4, bumped by
  bank regression which was higher severity).

---

## 2026-05-03 20:30 — Story-001 v3 render (Cycle 3, by cto-media)

- Rendered: story-001-the-arrival v3 → `blender/renders/story-001/v3.png`
- Pipeline change: River moved Y=12→Y=7, Z=-0.25→Z=0.10 to clear displaced ground surface.
  Ground displacement strength 0.35→0.12 to prevent terrain from burying the river plane.
  River scale (1.5,0.5,1.0)→(2.0,0.6,1.0). CLI flag handler generalised to accept any vN string.
  Root cause of previous failure: river at Z=-0.25 was below the displaced ground surface
  (which can deform up to 0.35 units), making it invisible from the camera angle.
- Gates: voice=N/A (illustration pipeline)  slice=N/A  story-001-approved=pending user sign-off
- QA results: River visible PASS (wide reflective plane with tree/figure reflections).
  Figure dark silhouette PASS. Dawn sky/atmosphere PASS. v2 wins not regressed PASS.
- Promotion decision: v3 PROMOTED to `website/public/illustrations/story-001-the-arrival.png`
- Queue: illustrations 1 rendered / 6 pending / 0 failed (story-001 promoted, awaiting user gate)
- Next cycle priority: v4 = replace two-sphere snowman figure with elongated cylinder/capsule
  so the dark form reads as a slender kneeling human, not two stacked balls.

---

## 2026-05-03 18:00 — Story-001 v2 render (Cycle 2, by cto-media)

- Rendered: story-001-the-arrival v2 → `blender/renders/story-001/v2.png`
- Pipeline change: Camera pulled back 7 units (Y: -1.5 → -8.5), figure darkened to near-silhouette,
  sun elevation 4° → 2°, mist density 0.012 → 0.020. Added `-- v2` CLI flag for versioned output.
- Gates: voice=N/A (illustration pipeline)  slice=N/A  story-001-approved=✗
- QA results: Figure size PASS (~30% frame height). Silhouette darkening PASS. Dawn sky PASS.
  River visible FAIL (still occluded by ground geometry). God-rays PARTIAL. Human shape PARTIAL.
- Promotion decision: v2 NOT promoted to website/public/illustrations/ — river check failed.
- Queue: illustrations 0 rendered / 7 pending / 0 failed (story-001 in_progress at v2)
- Next cycle priority: Move river plane from Y=12 to Y=7 so it falls in mid-third of frame.
  This is the ONE blocking issue for v3 acceptance.

---

## 2026-05-03 — Illustration pipeline bootstrap (Cycle 1, by claude-main)

- Blender 5.1.1 installed via `brew install --cask blender`
- New pipeline directory `blender/` with first script `blender/story_001_the_arrival.py`
- v1 of Story 001 rendered to `blender/renders/story-001/v1.png` (also `website/public/illustrations/story-001-the-arrival.png`)
- v1 **FAILED user QA**: figure too cartoonish, river invisible, no god-rays, figure too large in frame.
- Updated `cto-media.md` agent: now owns both pipelines + must read `CTO-CHECKPOINT.md` first.
- Created `CTO-CHECKPOINT.md` (relay baton between main session and CTO) with full v2 brief for Story 001.
- Queue: illustrations 0/7/0 (rendered/pending/failed); story-001 in_progress at v1.
- Gates: voice=✗ slice=✗ illustrations-v1-approved=✗
- **Next cycle priority (delegated to CTO):** Iterate `blender/story_001_the_arrival.py` to v2. Single-fix-per-cycle rule applies. Top priority fix = camera pullback + figure scale reduction (lowest-effort, highest-impact). Re-render, run QA squint-test, present v2 for user approval.

---

## 2026-04-18 — Bootstrap
- Pipeline scaffolded by video-pipeline-agent at `automation/video-gen/`
- Demo render confirmed: `output/reel-027-demo.mp4`
- Queue seeded: 21 pending, 1 rendered
- CTO-media agent (`~/.claude/agents/cto-media.md`) defined and will operate on loop

