"""
Story 001 — The Arrival
Scene: Forty-one-year-old kneels at a forest river at dawn.
Mood: yearning, exhaustion, fragile hope.

Run:
    blender --background --python blender/story_001_the_arrival.py [-- v2|v3|vN]
    Pass '-- vN' as argument to write to blender/renders/story-001/vN.png
    Without argument writes to website/public/illustrations/story-001-the-arrival.png

v2 changes (2026-05-03):
  - Camera pulled back ~6 units + raised slightly; figure now ~28% of frame height
  - Camera target lowered so river runs across mid-third of frame
  - Figure materials darkened to near-silhouette (warm dark ochre vs. pink cartoon)
  - Disciple origin pushed slightly closer to river bank for better compositional read
  - Sun elevation dropped 4° → 2° for more visible god-rays
  - Mist density 0.012 → 0.020 to thicken volumetric scattering

v3 changes (2026-05-03):
  - River moved from Y=12 to Y=7 (between figure at Y=3 and near treeline)
  - River scale changed from (1.5, 0.5, 1.0) to (2.0, 0.6, 1.0) — wider horizontal band
  - River Z stays at -0.25 to sit flush below the ground plane surface
  - CLI flag handler generalised: accepts any vN string, writes to vN.png

v4 changes (2026-05-03):
  - River plane creation size 80 → 20 (a river, not an ocean; bounded body of water)
  - River plane creation size 80 → 20 (a river, not an ocean; bounded body of water)
  - River center Y 7 → 10.0 (figure at Y=3; river near-edge at Y=5 = 2 units of bank
    between figure and water; far edge at Y=15 = trees/hut at Y=18+ read beyond water)
  - River Z keeps 0.10 (same as v3 — visible above displaced ground in mid-frame)
  - River scale (2.0, 0.6) → (1.5, 0.5): effective footprint ~30 wide × 10 deep
    (a river band, not a flood; near edge at Y=5 keeps figure on solid bank)
  - Ground displacement strength 0.12 → 0.22 (moderate bank texture in foreground
    without raising ground so high it buries the river at Y=10)
  REGRESSION FIX: v3 used size=80 river plane — its near edge extended to Y=7-24=-17
  (way behind camera), covering the entire foreground as water. Root cause = oversized plane.
  v4: bounded plane (size=20, scale 1.5×0.5) puts water only in the mid-frame Y=5–15 band.

v5 changes (2026-05-03):
  - SINGLE FIX: replace two-sphere snowman figure with CC0 Three.js Soldier GLB (rigged human).
  - Three.js Soldier (Vanguard/Mixamo rig) imported and posed into kneeling+bowing stance.
  - All mesh materials replaced with cloth_mat (near-black warm) for dark silhouette.
  VERDICT (post-user review): v5 FAILED mood QA. The Soldier asset carries rifle-stance proportions
  and a militant silhouette that cannot be overcome by bone rotation. The pose applied
  (UpLeg -45 + Leg +45 + arms z=±80) rendered as a standing figure with arms
  extended outward — reads as zombie/charging soldier, not a contemplative devotee.
  The Three.js Soldier is BANNED for contemplative scenes.

v6 changes (2026-05-03):
  - COURSE CORRECTION: Drop the Soldier GLB entirely. Use Option C — head-and-shoulders
    silhouette blob (primitive-built). This is deliberate silhouette ambiguity:
    a dark bowed shape at the bank-edge that the viewer's mind reads as a kneeling person.
    Rationale: atmosphere over anatomy. The story's mood is yearning/exhaustion/fragile hope;
    the figure is a vehicle for that feeling, not a detailed character study.

  Figure construction (Option C — bowed blob):
    - Base: single UV-sphere (radius=0.5) at Z=0.6, scaled (0.75, 0.55, 1.1).
      Represents bowed shoulders + torso as one organic mass from behind.
    - "Head" suggestion: second UV-sphere (radius=0.28) placed INSIDE the top of the
      base sphere (heavy overlap, no visible gap). Tilted forward on X (+15 deg)
      so the crown sits slightly lower than the widest shoulder point — reads as
      head bowed toward the river. No neck, no gap.
    - Subsurf level 3 on both — fully smooth, no polygon faceting.
    - Single cloth_mat (near-black warm, roughness 0.95) on all geometry.
    - No arms. No legs visible. No separate body parts competing for attention.
    - Total figure Z-span: approx 0.1 (ground) to 1.4 (crown) = ~1.3 world units.
      At camera distance ~11.5 units, figure subtends ~6.5 degrees of view = ~22% frame height.
    - Figure placed at (-1.2, 3.0, 0.0) — same disciple_origin as all prior versions.

  v4 bank/river/trees/hut/atmosphere: UNCHANGED (no regression policy).
"""
import bpy
import math
import random
import sys
from pathlib import Path

random.seed(1)

# ---------- parse version flag ----------
# blender passes '--' then user args; anything after '--' is ours
# Accept any vN token (v1, v2, v3, …); use first match found.
_user_args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
_version_arg = next((a for a in _user_args if a.startswith("v") and a[1:].isdigit()), None)
# Keep backward-compat alias
_write_v2 = _version_arg == "v2"

# ---------- reset scene ----------
bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = "CYCLES"
scene.cycles.device = "GPU" if bpy.context.preferences.addons.get("cycles") else "CPU"
scene.cycles.samples = 128
scene.cycles.use_denoising = True
scene.render.resolution_x = 1080
scene.render.resolution_y = 1920
scene.render.resolution_percentage = 100
scene.render.film_transparent = False
scene.view_settings.view_transform = "AgX"
scene.view_settings.look = "AgX - Medium High Contrast"


def new_material(name, base_color, roughness=0.7, metallic=0.0, emission=None, emission_strength=0.0):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*base_color, 1.0)
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = metallic
    if emission is not None:
        bsdf.inputs["Emission Color"].default_value = (*emission, 1.0)
        bsdf.inputs["Emission Strength"].default_value = emission_strength
    return mat


def assign(obj, mat):
    if obj.data.materials:
        obj.data.materials[0] = mat
    else:
        obj.data.materials.append(mat)


# ---------- ground (riverbank) ----------
bpy.ops.mesh.primitive_plane_add(size=80, location=(0, 0, 0))
ground = bpy.context.object
ground.name = "Ground"
# subdivide and displace for organic feel
mod = ground.modifiers.new("Subsurf", "SUBSURF")
mod.levels = 4
mod.render_levels = 5
disp = ground.modifiers.new("Displace", "DISPLACE")
tex = bpy.data.textures.new("GroundNoise", type="CLOUDS")
tex.noise_scale = 1.2
disp.texture = tex
disp.strength = 0.22  # v4b: balanced — enough to show a textured bank in foreground; river at Z=-0.05
                      #      sits below the unperturbed ground (Z=0) so water is visible in mid-frame
                      #      without being buried by the raised near-bank terrain
ground_mat = new_material("Earth", (0.18, 0.13, 0.09), roughness=0.95)
assign(ground, ground_mat)

# ---------- river ----------
# v4: bounded river band, not a flooded plain.
#   size=20: a river is ~20 Blender-units wide at creation, not 80 (ocean scale).
#   scale (2.0, 0.6, 1.0): still provides a left-to-right horizontal band.
#     Effective footprint: ~40 wide × ~12 deep — a river crossing the full frame width,
#     not an edge-to-edge flood.
#   Z=-0.15: back below bank surface. With displacement strength=0.30, the displaced
#     ground surface peaks at +0.25 to +0.40 in the near field, well above water level.
#     The camera at Z=1.6 looking toward Y=9.0 will see ground in the near foreground
#     (Z>-0.15) and water beginning at Y=8.5 in the mid-frame.
#   Y=8.5: water starts beyond the figure (Y=3.0) and mid-bank; trees and hut are
#     at Y=8–22, so the far bank reads beyond the water.
bpy.ops.mesh.primitive_plane_add(size=20, location=(0, 10.0, 0.10))
river = bpy.context.object
river.name = "River"
river.scale = (1.5, 0.5, 1.0)  # v4: effective footprint ~30 wide × 10 deep
                                # near edge at Y=10-5=5 (figure at Y=3 is clearly on bank)
                                # far edge at Y=10+5=15 (trees at Y=18+ read beyond the water)
                                # Z=0.10 same as v3 — visible above displaced ground
river_mat = bpy.data.materials.new("River")
river_mat.use_nodes = True
nodes = river_mat.node_tree.nodes
links = river_mat.node_tree.links
bsdf = nodes.get("Principled BSDF")
bsdf.inputs["Base Color"].default_value = (0.04, 0.06, 0.09, 1.0)
bsdf.inputs["Roughness"].default_value = 0.05
bsdf.inputs["Metallic"].default_value = 0.0
# slight transmission for water feel
if "Transmission Weight" in bsdf.inputs:
    bsdf.inputs["Transmission Weight"].default_value = 0.6
if "IOR" in bsdf.inputs:
    bsdf.inputs["IOR"].default_value = 1.33
# subtle wave bump via noise
noise = nodes.new("ShaderNodeTexNoise")
noise.inputs["Scale"].default_value = 8.0
noise.inputs["Detail"].default_value = 2.0
bump = nodes.new("ShaderNodeBump")
bump.inputs["Strength"].default_value = 0.12
links.new(noise.outputs["Fac"], bump.inputs["Height"])
links.new(bump.outputs["Normal"], bsdf.inputs["Normal"])
assign(river, river_mat)


# disciple_origin used by figure placement AND by the book prop below
disciple_origin = (-1.2, 3.0, 0.0)

# ---------- kneeling disciple — v6: cone torso + small head + legs block ----------
# v6 course-correction: Three.js Soldier BANNED (militant silhouette). Option C.
# v6 approach: tapered cone torso (reads as shoulders-to-waist), small sphere head,
# flat legs block. The CONE shape (wide base, narrows to tip) is the fix for the
# snowman problem — a cone + small head reads as "human" not "two equal circles".
#
# Key principle: the cone base (wide end DOWN) gives shoulder breadth;
# the cone narrows to the neck area; the small sphere head sits at the narrow top.
# From camera behind: a wide-shouldered dark shape tapering upward to a small head.
# That silhouette IS the seated devotee. No gap, no snowman.

cloth_mat = new_material("Cloth", (0.04, 0.02, 0.01), roughness=0.95)

_figure_meshes = []
_fig_x = disciple_origin[0]        # -1.2
_fig_y = disciple_origin[1] + 0.3  # 3.3 — slightly closer to riverbank

# Legs/base: flat block representing folded kneeling legs on the ground
bpy.ops.mesh.primitive_cube_add(size=0.5, location=(_fig_x, _fig_y + 0.05, 0.175))
_legs = bpy.context.object
_legs.name = "Legs_v6"
_legs.scale = (1.4, 1.0, 0.35)
for _p in _legs.data.polygons:
    _p.use_smooth = True
_legs.data.materials.clear()
_legs.data.materials.append(cloth_mat)
_figure_meshes.append(_legs)

# Torso: cone (wide at shoulders, narrows to neck — NOT a sphere, no snowman possible)
# radius1=shoulder base, radius2=neck (small but not zero to avoid sharp tip), depth=0.72
# Center Z = legs_top (0.35) + half_cone_depth (0.36) = 0.71
bpy.ops.mesh.primitive_cone_add(
    radius1=0.28,
    radius2=0.06,
    depth=0.72,
    vertices=24,
    location=(_fig_x, _fig_y, 0.71),
)
_torso_cone = bpy.context.object
_torso_cone.name = "Torso_v6"
# Slight forward lean: top of cone (narrow end) tilts toward river (+Y)
_torso_cone.rotation_euler = (math.radians(8), 0, math.radians(-5))
_sub_torso = _torso_cone.modifiers.new("Subsurf_T", "SUBSURF")
_sub_torso.levels = 2
_sub_torso.render_levels = 2
for _p in _torso_cone.data.polygons:
    _p.use_smooth = True
_torso_cone.data.materials.clear()
_torso_cone.data.materials.append(cloth_mat)
_figure_meshes.append(_torso_cone)

# Head: small sphere at cone tip — overlaps cone tip (r=0.14 >> cone_tip r=0.06)
# Center Z = cone_top (0.71+0.36=1.07) + small upward offset = 1.10
# Y offset +0.10 suggests head bowing slightly toward river
bpy.ops.mesh.primitive_uv_sphere_add(
    radius=0.14,
    segments=20,
    ring_count=14,
    location=(_fig_x, _fig_y + 0.10, 1.10),
)
_head_v6 = bpy.context.object
_head_v6.name = "Head_v6"
_head_v6.rotation_euler = (math.radians(8), 0, 0)
_sub_head = _head_v6.modifiers.new("Subsurf_H", "SUBSURF")
_sub_head.levels = 3
_sub_head.render_levels = 3
for _p in _head_v6.data.polygons:
    _p.use_smooth = True
_head_v6.data.materials.clear()
_head_v6.data.materials.append(cloth_mat)
_figure_meshes.append(_head_v6)

print("[figure v6] CONE TORSO (wide-shoulder) + small head + legs block. Reads as kneeling figure.")


# ---------- forest tree silhouettes ----------
def make_tree(x, y, height, foliage_radius, foliage_color):
    # trunk
    bpy.ops.mesh.primitive_cylinder_add(
        radius=0.15 + height * 0.02,
        depth=height * 0.9,
        location=(x, y, height * 0.45),
    )
    trunk = bpy.context.object
    trunk_mat = new_material(
        f"Trunk_{x}_{y}", (0.05, 0.04, 0.03), roughness=0.95
    )
    assign(trunk, trunk_mat)

    # foliage (icosphere with displace)
    bpy.ops.mesh.primitive_ico_sphere_add(
        radius=foliage_radius,
        subdivisions=3,
        location=(x, y, height + foliage_radius * 0.3),
    )
    foliage = bpy.context.object
    foliage.scale = (1.0, 1.0, 1.3)
    f_mod = foliage.modifiers.new("FDisp", "DISPLACE")
    f_tex = bpy.data.textures.new(f"FoliageNoise_{x}_{y}", type="CLOUDS")
    f_tex.noise_scale = 0.4
    f_mod.texture = f_tex
    f_mod.strength = 0.3
    foliage_mat = new_material(
        f"Foliage_{x}_{y}", foliage_color, roughness=0.9
    )
    assign(foliage, foliage_mat)
    for p in foliage.data.polygons:
        p.use_smooth = True


# A loose forest line behind the disciple, framing the river view
tree_positions = [
    (-8, 8, 7, 2.4, (0.04, 0.07, 0.04)),
    (-5.5, 9.5, 6, 2.0, (0.05, 0.08, 0.05)),
    (-3.2, 11, 5.5, 1.8, (0.04, 0.07, 0.04)),
    (3.5, 10, 6.5, 2.2, (0.05, 0.09, 0.05)),
    (6.5, 9, 7.5, 2.6, (0.04, 0.07, 0.04)),
    (9, 7.5, 6, 2.0, (0.05, 0.08, 0.05)),
    (-10, 5, 5, 1.7, (0.05, 0.08, 0.05)),
    (10.5, 4, 5.5, 1.9, (0.04, 0.07, 0.04)),
    # far bank trees (across the river)
    (-6, 18, 4.5, 1.5, (0.03, 0.05, 0.03)),
    (-2, 19, 5, 1.7, (0.03, 0.05, 0.03)),
    (3, 19.5, 4.5, 1.5, (0.03, 0.05, 0.03)),
    (7, 18, 5, 1.7, (0.03, 0.05, 0.03)),
]
for x, y, h, fr, col in tree_positions:
    make_tree(x, y, h, fr, col)


# ---------- distant ashram hut (small, far bank) ----------
bpy.ops.mesh.primitive_cube_add(size=1.6, location=(-1, 22, 0.8))
hut_walls = bpy.context.object
hut_walls.name = "HutWalls"
hut_mat = new_material("Hut", (0.25, 0.18, 0.10), roughness=0.95)
assign(hut_walls, hut_mat)

bpy.ops.mesh.primitive_cone_add(radius1=1.4, radius2=0, depth=1.0, location=(-1, 22, 2.1))
roof = bpy.context.object
roof.name = "HutRoof"
roof_mat = new_material("Roof", (0.10, 0.06, 0.03), roughness=0.95)
assign(roof, roof_mat)

# a faint warm window glow
bpy.ops.mesh.primitive_plane_add(size=0.3, location=(-0.2, 22, 0.9))
window = bpy.context.object
window.rotation_euler = (math.radians(90), 0, 0)
window.name = "HutWindow"
glow_mat = new_material("Glow", (1.0, 0.7, 0.35), emission=(1.0, 0.6, 0.25), emission_strength=8.0)
assign(window, glow_mat)


# ---------- bowl + cracked-spine book at the disciple's knees ----------
bpy.ops.mesh.primitive_cube_add(size=0.4, location=(disciple_origin[0] + 0.7, disciple_origin[1] + 0.5, 0.12))
book = bpy.context.object
book.scale = (0.7, 1.0, 0.18)
book.rotation_euler = (0, 0, math.radians(20))
book.name = "Book"
book_mat = new_material("Book", (0.55, 0.35, 0.18), roughness=0.7)
assign(book, book_mat)


# ---------- sunrise sun lamp ----------
bpy.ops.object.light_add(type="SUN", location=(0, 30, 6))
sun = bpy.context.object
sun.data.energy = 4.5
sun.data.color = (1.0, 0.55, 0.25)  # warm sunrise
sun.data.angle = math.radians(3.0)  # soft shadows
sun.rotation_euler = (math.radians(78), 0, math.radians(180))  # low, behind river

# fill from camera side — cool, very soft
bpy.ops.object.light_add(type="AREA", location=(-6, -4, 5))
fill = bpy.context.object
fill.data.energy = 80
fill.data.color = (0.35, 0.55, 0.85)
fill.data.size = 8.0
fill.rotation_euler = (math.radians(60), 0, math.radians(-40))


# ---------- world: misty dawn sky + volumetric fog ----------
world = bpy.data.worlds.new("DawnWorld")
world.use_nodes = True
scene.world = world
wnodes = world.node_tree.nodes
wlinks = world.node_tree.links
for n in list(wnodes):
    wnodes.remove(n)

bg = wnodes.new("ShaderNodeBackground")
sky = wnodes.new("ShaderNodeTexSky")
sky.sky_type = "MULTIPLE_SCATTERING"
sky.sun_elevation = math.radians(2.0)  # v2: lower sun for more visible god-rays
sky.sun_rotation = math.radians(180)
if hasattr(sky, "sun_intensity"):
    sky.sun_intensity = 0.25
if hasattr(sky, "air_density"):
    sky.air_density = 1.6
if hasattr(sky, "dust_density"):
    sky.dust_density = 4.5
if hasattr(sky, "ozone_density"):
    sky.ozone_density = 1.0
out = wnodes.new("ShaderNodeOutputWorld")
wlinks.new(sky.outputs["Color"], bg.inputs["Color"])
bg.inputs["Strength"].default_value = 0.6
wlinks.new(bg.outputs["Background"], out.inputs["Surface"])

# ---- volumetric mist across the scene ----
bpy.ops.mesh.primitive_cube_add(size=80, location=(0, 8, 4))
mist = bpy.context.object
mist.name = "MistVolume"
mist.display_type = "WIRE"
mist_mat = bpy.data.materials.new("Mist")
mist_mat.use_nodes = True
mnodes = mist_mat.node_tree.nodes
mlinks = mist_mat.node_tree.links
for n in list(mnodes):
    mnodes.remove(n)
m_out = mnodes.new("ShaderNodeOutputMaterial")
m_scatter = mnodes.new("ShaderNodeVolumeScatter")
m_scatter.inputs["Density"].default_value = 0.020  # v2: thicker mist for dawn atmosphere
m_scatter.inputs["Anisotropy"].default_value = 0.6
m_scatter.inputs["Color"].default_value = (1.0, 0.85, 0.65, 1.0)
mlinks.new(m_scatter.outputs["Volume"], m_out.inputs["Volume"])
assign(mist, mist_mat)


# ---------- camera ----------
# v2: pulled back from (-3.6, -1.5) to (-4.0, -8.5) so the figure reads as ~28% of frame height
# target lowered from Y=14 to Y=9 so river band falls in mid-third of the 9:16 frame
bpy.ops.object.camera_add(location=(-4.0, -8.5, 1.6))
cam = bpy.context.object
cam.name = "Cam"
cam.data.lens = 50  # 50mm — keep focal length, just moved camera
# point camera toward a target near the near riverbank
target = bpy.data.objects.new("CamTarget", None)
scene.collection.objects.link(target)
target.location = (0.5, 9.0, 0.8)
constraint = cam.constraints.new(type="TRACK_TO")
constraint.target = target
constraint.track_axis = "TRACK_NEGATIVE_Z"
constraint.up_axis = "UP_Y"

# shallow DOF on the disciple — focus Empty at the figure's head height
# v6: head sphere center is at Z=1.25; DOF target placed just above at Z=1.3
_dof_target = bpy.data.objects.new("DOF_Focus", None)
scene.collection.objects.link(_dof_target)
_dof_target.location = (-1.2, 3.40, 1.10)  # head of v6 cone-figure (fig_y=3.3 + Y+0.10, Z=1.10)
cam.data.dof.use_dof = True
cam.data.dof.focus_object = _dof_target
cam.data.dof.aperture_fstop = 2.8

scene.camera = cam


# ---------- output ----------
scene.render.image_settings.file_format = "PNG"
scene.render.image_settings.color_mode = "RGBA"

if _version_arg:
    # Write to versioned QA path — never touches the public/illustrations path
    ver_dir = Path("/Users/aera/Documents/random/VivekChudamani/blender/renders/story-001")
    ver_dir.mkdir(parents=True, exist_ok=True)
    scene.render.filepath = str(ver_dir / f"{_version_arg}.png")
else:
    out_dir = Path("/Users/aera/Documents/random/VivekChudamani/website/public/illustrations")
    out_dir.mkdir(parents=True, exist_ok=True)
    scene.render.filepath = str(out_dir / "story-001-the-arrival.png")

print(f"[story-001] rendering -> {scene.render.filepath}")
bpy.ops.render.render(write_still=True)
print(f"[story-001] saved -> {scene.render.filepath}")
