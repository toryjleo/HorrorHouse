# Ray Marcher Mini-Project Plan

> Goal: Build a clean, reusable ray marcher that renders SDF scenes — both as a standalone visual and as the material for a [JumpscareData](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Jumpscare/JumpscareData.cs#4-43) asset (via the existing `_ScareProgress` pipeline).

> Adaptation note: Keep the standalone editor toy as a real long-term goal, but do not make it the first dependency. The first useful milestone should be a correct, self-contained raymarched jumpscare material. After that works, promote the same shader/config data into an editor-driven toy.

---

## Current State

- [RayMarcher.shader](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Shaders/RayMarcher.shader) — 264-line UI fullscreen ray marcher following [Art of Code tutorials](https://www.youtube.com/watch?v=AfKGMUDWfuE&t=8s)
  - **5 SDF primitives**: sphere, box, capsule, cylinder, torus
  - **Lighting**: single orbiting point light, diffuse + shadow rays
  - **Camera**: hardcoded `rayOrigin = (0,2,0)`, direction derived from UVs
  - **Scene**: a single box on a ground plane (previous scene commented out)
- [JumpscareCodeGlitch.shader](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Shaders/JumpscareCodeGlitch.shader) — existing jumpscare effect shader driven by `_ScareProgress`
- [JumpscarePlayer.cs](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Jumpscare/JumpscarePlayer.cs) / [JumpscareData.cs](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Jumpscare/JumpscareData.cs) — data-driven jumpscare system, already sends `_ScareProgress` (0→1) to any material

## Important Constraints

- `JumpscarePlayer` instantiates `JumpscareData.ScareMaterial` at playback time and stores the clone privately. Any separate renderer that drives the original material asset will **not** affect the live jumpscare material.
- `_ScareProgress` is the only material value currently guaranteed to be pushed during jumpscare playback.
- The current `sdBox` is unsigned. Boolean operations and smooth blends need signed SDFs, so fix this before adding subtract/intersect/blend features.
- The UI fullscreen ray direction needs aspect/FOV handling before this becomes reusable outside the current square-ish tutorial view.
- For the jumpscare use case, `_ScareProgress` should push the raymarch camera forward near the end of the scare. Player/input control should still drive camera rotation.

---

## Phase 1 — Shape Library Cleanup
**Time: ~30–45 min** · Low risk

The existing SDFs work but the file is messy. Clean it up before adding complexity.

- [x] **Extract SDF functions to an include file** — Create `Assets/Shaders/Includes/SDF.cginc`
  - Move `sdCapsule`, `sdCylinder`, `sdTorus`, `sdBox` into it
  - Add `sdSphere(float3 p, float3 center, float radius)` as a proper function (currently inline)
  - `#include "Includes/SDF.cginc"` from [RayMarcher.shader](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Shaders/RayMarcher.shader)
- [x] **Fix `sdBox` before using booleans** — use the signed box formula:
  ```hlsl
  float sdBox(float3 p, float3 b) {
      float3 q = abs(p) - b;
      return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
  }
  ```
- [x] **Clean up dead code** — Remove the commented-out `GetDistance` block (lines 140–157)
- [x] **Consistent naming** — All SDFs follow `sdName(float3 p, ...)` convention; verify parameters match [Inigo Quilez reference](https://iquilezles.org/articles/distfunctions/)
- [x] **Raise shader target if needed** — move from `#pragma target 2.0` to `#pragma target 3.0` once scene keywords/material IDs/smooth ops are added. Not needed for Phase 1; keep `2.0` until later features require it.

> [!TIP]
> Keeping SDFs in a shared `.cginc` means the jumpscare shader can also `#include` them later if you want ray-marched jumpscare visuals.

---

## Phase 2 — SDF Boolean & Blend Operators
**Time: ~30–60 min** · Medium risk (getting smooth blend right takes iteration)

These go into `SDF.cginc` alongside the primitives.

- [ ] **Hard boolean ops** (trivial)
  - `opUnion(a, b)` → `min(a, b)` *(already used inline)*
  - `opSubtract(base, cutter)` → `max(base, -cutter)` *(cube minus sphere is `opSubtract(cube, sphere)`)*
  - `opIntersect(a, b)` → `max(a, b)`
- [ ] **Smooth blend ops**
  - `opSmoothUnion(a, b, k)` — smooth min
  - `opSmoothSubtract(a, b, k)` — smooth subtraction
  - `opSmoothIntersect(a, b, k)` — smooth intersection
- [ ] **Test in `GetDistance`** — Replace the current box+plane scene with a quick test: sphere smoothly subtracted from a box

> [!NOTE]
> The smooth blend formula (from IQ):
> ```hlsl
> float opSmoothUnion(float d1, float d2, float k) {
>     float h = clamp(0.5 + 0.5*(d2-d1)/k, 0.0, 1.0);
>     return lerp(d2, d1, h) - k*h*(1.0-h);
> }
> ```
> `opSmoothSubtract` is the same idea but with `max(-d1, d2)` logic.

---

## Phase 3 — Grid Repetition
**Time: ~30–45 min** · Low risk (it's one function)

Builds directly on the boolean ops from Phase 2. The classic SDF repetition trick — a cube-with-sphere-subtracted repeating infinitely.

- [ ] Add `opRepeat(float3 p, float3 spacing)` to `SDF.cginc`:
  ```hlsl
  float3 opRepeat(float3 p, float3 s) {
      return fmod(abs(p) + 0.5 * s, s) - 0.5 * s;
  }
  ```
- [ ] In `GetDistance`, apply repeat to `p` before evaluating the cube-minus-sphere:
  ```hlsl
  float3 q = opRepeat(p, float3(3.0, 3.0, 3.0));
  float cube = sdBox(q, float3(1.0, 1.0, 1.0));
  float sphere = length(q) - 1.3;
  float cell = opSubtract(cube, sphere); // sphere carved from cube
  ```
- [ ] **Domain clamping** — If you want finite repetition (not infinite), clamp the repeat index

> [!NOTE]
> A cube with a sphere subtracted from it is **trivially easy** with the ops from Phase 2. `opSubtract(sdBox(...), sdSphere(...))` and you're done. The repetition (`opRepeat`) is also a one-liner. Together this is ~20 min of shader work.

---

## Phase 4 — Camera Controls
**Time: ~45–90 min** · Medium risk

Currently the camera is hardcoded in the fragment shader. You need a camera that supports three separate concerns:

- Fixed, correct projection: FOV and aspect ratio are required, not optional.
- Player/input-controlled rotation: the view direction should be driven from C# during preview/runtime.
- Jumpscare forward slide: `_ScareProgress` moves the camera forward only near the end of the scare.

### 4a. Shader-Side Camera Uniforms

- [ ] Add uniform properties to [RayMarcher.shader](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Shaders/RayMarcher.shader):
  - `_CamPos` (float3) — base ray origin before scare slide
  - `_CamDir` (float3) — forward direction driven by player/input rotation
  - `_CamUp` (float3) — up vector (default [(0,1,0)](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Jumpscare/JumpscarePlayer.cs#40-50))
  - `_CamFov` (float) — vertical FOV in degrees; required for all ray generation
  - `_CamAspect` (float) — aspect ratio; required so UI rects and screen sizes do not stretch the raymarched scene
  - `_ScareProgress` (float) — 0→1 jumpscare timeline
  - `_ScareSlideStart` (float) — progress threshold where forward motion begins, e.g. `0.75`
  - `_ScareSlideDistance` (float) — max forward camera movement
- [ ] Build a proper camera basis in the frag shader from these vectors to construct `rayDirection` per pixel:
  ```hlsl
  float3 forward = normalize(_CamDir);
  float3 right = normalize(cross(forward, normalize(_CamUp)));
  float3 up = cross(right, forward);
  ```
- [ ] Apply late-progress camera slide after building the base camera pose:
  ```hlsl
  float slideT = smoothstep(_ScareSlideStart, 1.0, saturate(_ScareProgress));
  float3 rayOrigin = _CamPos + forward * (_ScareSlideDistance * slideT);
  ```
- [ ] Use FOV and aspect in ray generation:
  ```hlsl
  float fovScale = tan(radians(_CamFov) * 0.5);
  float2 screen = float2(IN.uv.x * _CamAspect, IN.uv.y) * fovScale;
  float3 rayDirection = normalize(forward + right * screen.x + up * screen.y);
  ```

### 4b. C# Camera Controller

- [ ] Create `Assets/Scripts/RayMarcher/RayMarchCameraController.cs`
  - Drives `_CamPos`, `_CamDir`, `_CamUp`, `_CamFov`, and `_CamAspect` on the material every frame via `Material.SetVector` / `SetFloat`
  - Keeps camera position independent from scare slide; scare slide happens in shader from `_ScareProgress`
  - **Orbit mode**: WASD/mouse to orbit around a focus point + scroll to zoom
  - Right-click drag to rotate, middle-click to pan
  - Sensitivity / speed as serialized fields
- [ ] Works in both Play Mode and Edit Mode (use `[ExecuteAlways]` or editor script if desired)

> [!IMPORTANT]
> For the jumpscare use case, player/input should control rotation while `_ScareProgress` controls the late forward push. The controller should support disabling position input independently from rotation input so the scare cannot fight the player camera direction.

---

## Phase 5 — Scene Composition System
**Time: ~1–1.5 hr** · Medium complexity

Shapes are defined directly in HLSL as scene functions. A lightweight ScriptableObject handles camera, lights, and scene selection — no shape arrays, no buffer packing.

> This phase is still worth doing for the standalone editor toy. Treat it as the second product milestone, after the raymarched jumpscare material works by itself.

> [!TIP]
> You mentioned XML — a **ScriptableObject** is a better fit here. It's inspector-editable, drag-and-droppable, version-controllable, and already your pattern for [JumpscareData](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Jumpscare/JumpscareData.cs#4-43). XML adds a parser with no benefit in this context.

### 5a. Hardcoded Scene Functions (in shader)

Each scene is a self-contained `GetDistance` variant authored directly in HLSL. This is where your SDF primitives + ops from Phases 1–3 get composed into actual scenes.

- [ ] Write `GetDistance_Default()` — current box + plane (cleanup of what's there)
- [ ] Write `GetDistance_Jumpscare()` — the jumpscare scene (e.g., morphing shapes driven by `_ScareProgress`)
- [ ] Write `GetDistance_RepeatingGrid()` — cube-minus-sphere repetition from Phase 3
- [ ] Use `#pragma multi_compile _SCENE_DEFAULT _SCENE_JUMPSCARE _SCENE_GRID` to switch between them
- [ ] A top-level `GetDistance(float3 p)` dispatches based on the active keyword:
  ```hlsl
  float GetDistance(float3 p) {
      #if defined(_SCENE_JUMPSCARE)
          return GetDistance_Jumpscare(p);
      #elif defined(_SCENE_GRID)
          return GetDistance_RepeatingGrid(p);
      #else
          return GetDistance_Default(p);
      #endif
  }
  ```

### 5b. Scene Config ScriptableObject (lightweight)

- [ ] Create `Assets/Scripts/RayMarcher/RayMarchSceneConfig.cs` — a `ScriptableObject`
  - `SceneType` enum (Default, Jumpscare, RepeatingGrid) — selects the shader keyword
  - `Vector3 cameraPosition`, `Vector3 cameraTarget` — default camera pose
  - `float cameraFov`, `float cameraAspect`
  - `float scareSlideStart`, `float scareSlideDistance`
  - `RayMarchLight[] lights` — position, color, intensity, orbiting toggle
  - **No shape data** — shapes live in the shader, this SO is just config

### 5c. C# Scene Renderer

- [ ] Create `Assets/Scripts/RayMarcher/RayMarchRenderer.cs` — MonoBehaviour
  - Takes a `RayMarchSceneConfig` SO reference and a target [Material](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Jumpscare/JumpscarePlayer.cs#168-178)
  - On start / when config changes: enables the correct `_SCENE_*` keyword on the material
  - Every frame: pushes camera + light uniforms to the material
  - Compatible with normal preview materials and editor toy use
  - **Not automatically compatible with live jumpscare playback** unless `JumpscarePlayer` exposes/applies the cloned runtime material, or the chosen scene/camera/light values are baked into the assigned material before playback

### 5d. Standalone Editor Toy

- [ ] Create a prefab or scene view setup with:
  - A fullscreen UI Image using `RayMarcher.shader`
  - A `RayMarchRenderer` pointed at the image material
  - A `RayMarchSceneConfig` asset selected in the inspector
  - Optional input camera controller for orbit/pan/zoom
- [ ] Add editor-friendly controls:
  - Scene type dropdown
  - Camera pose reset
  - Light orbit toggle
  - `_ScareProgress` scrub slider for previewing jumpscare timing without entering a real jumpscare
  - FOV control
  - Aspect ratio mode/control
  - Scare slide start/distance controls

---

## Phase 6 — Materials / Colors *(Optional)*
**Time: ~30–60 min** · Low–Medium risk

- [ ] Add per-shape color in each `GetDistance_*()` scene function
  - `GetDistance` returns a `float2` or struct: [(distance, materialId)](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Jumpscare/JumpscarePlayer.cs#40-50)
  - Closest shape's color is used for shading
- [ ] Pass a small color palette array via uniform (e.g., `fixed4 _ShapeColors[8]`)
- [ ] Apply color in `GetLight` / frag shader after determining which shape was hit

> Skip this if time is tight. Grayscale diffuse looks great for horror.

---

## Integration with Jumpscare System

The ray marcher plugs into the existing jumpscare pipeline with **zero changes** to [JumpscarePlayer](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Jumpscare/JumpscarePlayer.cs#6-201) only if the jumpscare scene is fully represented by shader defaults/material properties plus `_ScareProgress`:

1. Create a [Material](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Jumpscare/JumpscarePlayer.cs#168-178) using [RayMarcher.shader](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Shaders/RayMarcher.shader)
2. Add `_ScareProgress` as a uniform to drive the scene and the late forward camera slide
3. Assign that material as `scareMaterial` on a [JumpscareData](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Jumpscare/JumpscareData.cs#4-43) asset
4. [JumpscarePlayer](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Jumpscare/JumpscarePlayer.cs#6-201) will display it fullscreen and drive `_ScareProgress` automatically

Minimum camera values that must be set before/during playback:

- `_CamPos` — base camera position
- `_CamDir` — player/input-controlled camera direction
- `_CamUp` — usually world up
- `_CamFov` — fixed projection FOV
- `_CamAspect` — fixed projection aspect
- `_ScareSlideStart` and `_ScareSlideDistance` — forward push timing/distance

If the jumpscare needs runtime camera/lights/scene keywords from a `RayMarchSceneConfig`, add one of these later:

- Expose a read-only current runtime material from `JumpscarePlayer` and let a raymarch integration component apply config to it during playback.
- Add optional raymarch config fields to `JumpscareData` and have `JumpscarePlayer` apply them immediately after cloning the material.
- Keep jumpscare configs baked into separate material assets and reserve `RayMarchRenderer` for editor/standalone preview.

## Recommended Milestones

1. **Correct shader core** — signed SDFs, include file, hard booleans, aspect/FOV camera.
2. **First jumpscare material** — one `GetDistance_Jumpscare` scene driven by `_ScareProgress`, with late forward camera slide.
3. **Standalone preview toy** — `RayMarchSceneConfig`, `RayMarchRenderer`, orbit controller, progress scrubber.
4. **Shared runtime integration** — only if you need the standalone config system to drive live jumpscares too.

---

## Summary — Time Estimates

| Phase | Task | Est. Time |
|---|---|---|
| 1 | Shape Library Cleanup | 30–45 min |
| 2 | Boolean & Blend Ops | 30–60 min |
| 3 | Grid Repetition | 30–45 min |
| 4 | Camera Controls | 45–90 min |
| 5 | Scene Composition | 1–1.5 hr |
| 6 | Materials *(optional)* | 30–60 min |
| **Total** | | **~3.5–5.5 hr** (3–4.5 hr without materials) |
