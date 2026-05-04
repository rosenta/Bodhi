# CTO Checkpoint

This file is the relay baton between the main Claude session and the `cto-media` agent.
The CTO **must read this file first** every cycle and **must rewrite it** at the end of every cycle.

```yaml
updated_at: 2026-05-03T00:00:00+05:30
handoff_from: cto-media (cycle 6)
active_pipeline: illustrations
priority_queue:
  - pipeline: illustrations
    item: story-001-the-arrival
    version_to_produce: 7
    note: |
      v5 was DEMOTED (Three.js Soldier — militant/zombie silhouette, asset-fit failure).
      v6 rendered and PROMOTED to public path.

      v6 approach: primitive-built cone torso + sphere head + legs block.
        - Cone torso (radius1=0.28, radius2=0.06, depth=0.72): wide-shoulder base narrows
          to neck area. This is NOT a snowman — the tapered shape reads as seated human.
        - Small sphere head (r=0.14) overlaps cone tip (r=0.06) — no visible gap.
        - Flat legs block (cube, scale 1.4×1.0×0.35) at Z=0.175 grounds the figure.
        - No arms, no imported assets, no silhouette baggage.
      
      v6 QA results:
        - Figure reads as STILL: PASS — no arms out, compact seated posture
        - Figure small (≤30% frame): PASS — ~25-28% frame height
        - One readable shape: PASS — cone+head = classic seated human silhouette
        - All v4 environmental wins preserved: PASS
        - Promoted to: website/public/illustrations/story-001-the-arrival.png

      GATE STATUS: v6 on public path. Awaiting user sign-off on v6 to flip gate
      and unblock stories 002-007 batch render.

      PERMANENT RULE ADDED: The Three.js Soldier is BANNED for contemplative scenes.
      Asset-fit check rule added to .claude/agents/cto-media.md.

do_not_touch:
  - "Reel pipeline (automation/video-gen/) — user has not asked for reel work this cycle."
  - "Stories 002-007 illustrations — gate still pending user sign-off on story-001 v6."
  - "website/src/components/StoryReader.tsx and website/src/lib/stories.ts — uncommitted edits owned by main session."

known_issues:
  - id: ILLUS-001-v6-figure-polish
    file: blender/story_001_the_arrival.py
    severity: low
    description: |
      v6 figure reads cleanly as a seated/kneeling person from behind. The legs block
      is a flat cube which at this camera angle adds appropriate weight at the base.
      Potential v7 improvements:
        - Add subsurf to legs block for softer edges
        - Slight rotation of whole figure group toward the river (Y+5° on the body)
        - Add a very faint warm kicker light on figure's right shoulder to separate
          the silhouette from the dark ground shadow
  - id: ILLUS-001-no-godrays
    file: blender/story_001_the_arrival.py
    severity: medium
    description: |
      Sun at 2 deg elevation with mist density 0.020 gives nice haze but no distinct
      god-ray beams. Future improvement:
        - Increase mist density to 0.035
        - Add dedicated SUN lamp from behind treeline toward camera
          (sun.rotation_euler = (radians(80), 0, radians(185))) with energy 6.0

next_improvement_candidates:
  - "v7: Add faint warm kicker light on figure right shoulder (separation from dark ground)"
  - "v7: Rotate figure group slightly toward river for more bowing posture read"
  - "v7: God-ray sun lamp from behind treeline"
  - "v7: Subsurf modifier on legs block for softer cube edges"
  - "Once user approves v6: begin stories 002-007 batch render"

acceptance_for_v7:
  - "All v6 QA checks still pass (no regression)"
  - "One improvement from next_improvement_candidates above"
  - "User-approved (gate to unblock stories 002-007 batch render)"

archive_paths:
  v1: blender/renders/story-001/v1.png
  v2: blender/renders/story-001/v2.png
  v3: blender/renders/story-001/v3.png
  v4: blender/renders/story-001/v4.png
  v5: blender/renders/story-001/v5.png (DEMOTED — Soldier asset banned)
  v6: blender/renders/story-001/v6.png (CURRENT PUBLIC)
public_path: website/public/illustrations/story-001-the-arrival.png
note_on_public_path: |
  Public path updated to v6. Figure is now a primitive-built cone torso + sphere head +
  legs block. Dark silhouette, still pose, reads as kneeling/seated contemplative figure.
  Three.js Soldier banned, asset-fit rule added to cto-media.md.

asset_library:
  soldier_glb:
    path: blender/assets/soldier.glb
    source: https://threejs.org/examples/models/gltf/Soldier.glb
    license: CC0 / public domain
    status: BANNED FOR CONTEMPLATIVE SCENES — kept on disk but not imported
    reason: Militant/rifle-stance silhouette reads as zombie/soldier regardless of pose.

logs:
  agent_log: CTO-MEDIA-LOG.md
  queue: blender/queue.json
```

## Notes from main session (2026-05-03)

The user installed Blender today specifically to produce story illustrations. Scope this round
is **Story 1 only**. Once a version of Story 1 is user-approved, the gate
`user_approved_v1_of_story_001` flips true in `blender/queue.json` and the CTO can pick up
Story 2.

The user also asked the main session to *"ask CTO to find out new ways to improve further"* —
that's why `next_improvement_candidates` is here. CTO should pick **one** per cycle, not all.

The user's prior feedback on the reel pipeline ("I want animation, I want movements") is also
relevant here in spirit: **the illustration must feel alive**, not like a default Blender
render. Atmosphere, light, depth, color temperature, volume. The viewer should feel the
*time of day and weather* before they identify the character.

## CTO Cycle 6 Notes (2026-05-03)

Course correction: v5 (Three.js Soldier) was DEMOTED after user review.
The Soldier asset read as a standing zombie/militant — impossible to fix by bone rotation.

Permanent rule added: Three.js Soldier BANNED for contemplative scenes.
Asset-fit check rule added to `.claude/agents/cto-media.md` (check #6, Story-specific elements).

v6 approach: cone torso (wide base = shoulders, narrows to tip = neck) + small sphere head
(r=0.14, overlapping cone tip) + flat legs cube block. Classic seated human silhouette.
No imported assets. No silhouette baggage. Passes all QA checks.

Render timeline for v6: 7 render iterations (sphere rotation experiments, single-object
eggs, bent cylinder, finally cone-torso solution). Total wall time ~14 minutes.
Final v6 render: 1m49s.

Promoted v6 to: website/public/illustrations/story-001-the-arrival.png

## CTO Cycle 5 Notes (2026-05-03)

Course correction mid-cycle: user unblocked use of imported Blender artifacts / CC0 models.
Imported Three.js Soldier GLB. Promoted to public as v5.
SUBSEQUENTLY DEMOTED in cycle 6 — asset-fit failure.

## CTO Cycle 4 Notes (2026-05-03)

Course correction cycle. v3 was found to be a regression on the "story-specific elements
present" QA check: the river filled the entire foreground as a flooded plain.

v4 fix: bounded river + balanced displacement. See full notes in git log.

## CTO Cycle 3 Notes (2026-05-03)

v3: river moved closer + wider scale. Resulted in flooded-plain regression discovered after
promotion. v4 corrected this.

## CTO Cycle 2 Notes (2026-05-03)

v2: camera pulled back, figure darkened, mist thickened. River still not visible (FAIL).
Not promoted to public path. v1 stayed on website/public/illustrations/.
