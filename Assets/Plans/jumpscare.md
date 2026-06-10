# Jumpscare System

## Goal

Replace the current hardcoded endgame jumpscare panel with a **configurable, data-driven system** that supports **4 unique jumpscares**, each with its own image, audio, material effect, and duration derived from the assigned audio clip.

---

## Current State

The endgame sequence in [EndGameManager.cs](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/SceneManagement/GameState/EndGameManager.cs) currently runs a Glitch -> Breather -> Splash -> Quit flow.

Current implementation details:

- The scene already has a hidden full-screen `JumpScarePanel` under `EndGameCanvas`.
- `JumpScarePanel` is a UI `Image` with a `CanvasGroup`, making it suitable for alpha fades.
- `EndGameManager` has old `jumpscareRampDuration` and `jumpscareHoldDuration` fields, but the current coroutine does not use them.
- `EndGameManager` plays one `Sound` stinger through `AKAudioManager` during the glitch phase.
- Existing jumpscare audio clips live under `Assets/Audio/sfx/JumpScares`.
- Those clips still need to be checked for matching `Sound` ScriptableObjects and registration in the scene's `AKAudioManager` sounds array.

---

## Design

### 1. `JumpscareData` ScriptableObject

A new `ScriptableObject` defines the reusable asset data for a single jumpscare. Create one asset per scare, for 4 total configured scares.

| Field | Type | Purpose |
|---|---|---|
| `scareImage` | `Sprite` | Full-screen image displayed during the scare |
| `scareAudio` | `Sound` | Audio stinger played through the existing `AKAudioManager` |
| `scareMaterial` | `Material` | Optional material applied to the overlay `Image` for visual effects |
| `fadeInDuration` | `float` | How long the image ramps from 0 to 1 alpha |
| `fadeOutDuration` | `float` | How long the image fades out; 0 means hard cut |
| `showMouse` | `bool` | Whether to show the mouse during the jumpscare |

Duration is not stored manually on `JumpscareData`. The player derives the total scare duration from `scareAudio.clip.length`.

If `scareAudio` or `scareAudio.clip` is missing, the implementation should log a warning and use a small fallback duration only to avoid a broken coroutine.

### 2. `JumpscarePlayer` MonoBehaviour

A reusable component that **plays any `JumpscareData`**. It should be scene-placed and should also work in an isolated Unity test scene.

Responsibilities:

1. **Show overlay** - Sets the `scareImage` sprite and optional `scareMaterial` on a full-screen UI `Image`.
2. **Fade in** - Lerps `CanvasGroup.alpha` from 0 to 1 over `fadeInDuration`.
3. **Hold** - Maintains full visibility for `audioClip.length - fadeInDuration - fadeOutDuration`.
4. **Fade out** - Lerps `CanvasGroup.alpha` from 1 to 0 over `fadeOutDuration`.
5. **Audio** - Calls `AKAudioManager.instance.Play(scareAudio)` at scare start.
6. **Player freeze** - Calls `AKDisableManager.instance.DisablePlayerDefault(true, false, false)` on start and restores with `false` on end.
7. **Mouse cursor** - Shows/hides mouse based on `showMouse`. Always hides and locks the cursor at the end of the scare.

```
Coroutine flow:
------------------------------------------------
 Play audio      fadeIn      hold      fadeOut      done
    |              |          |          |            |
    |--------------|----------|----------|------------|
 alpha=0        alpha->1    alpha=1    alpha->0      hidden
```

No overlapping-playback or queueing behavior is required for the first implementation.

### 3. Integration - Standalone & Modular

`JumpscarePlayer` is a **standalone scene-placed component** with a static accessor. Any trigger in the game, including `EndGameManager`, can call it with a `JumpscareData` asset.

For the endgame flow, `EndGameManager` should become a consumer:

- Remove the old unused `jumpscareRampDuration` and `jumpscareHoldDuration` fields.
- Add a serialized `JumpscareData` reference for the endgame scare.
- Replace the hardcoded jumpscare/glitch stinger behavior with a call into `JumpscarePlayer`.
- Keep the existing Glitch -> Jumpscare -> Breather -> Splash -> Quit sequence shape.

Jumpscares can also be triggered in an isolated test scene by placing a `JumpscarePlayer`, assigning an overlay `Image`/`CanvasGroup`, and calling it with a test `JumpscareData` asset.

### 4. Audio Setup

Use the existing `AKAudioManager` path. Do not add a separate audio playback system unless `AKAudioManager` proves insufficient.

Implementation/setup checklist:

1. Inspect `Assets/Audio/sfx/JumpScares` and decide which 4 clips map to the 4 scares.
2. Check whether matching `Sound` ScriptableObjects already exist.
3. If missing, create `Sound` ScriptableObjects for the chosen clips.
4. Add those `Sound` assets to the active `AKAudioManager` sounds array so `AKAudioManager.instance.Play(scareAudio)` can find them.

### 5. The 4 Jumpscares

Each is a separate `JumpscareData` asset configured in the Inspector:

| # | Image | Audio | Material Effect | Duration |
|---|---|---|---|---|
| 1 | TBD | TBD `Sound` asset | Default / none | Derived from audio clip |
| 2 | TBD | TBD `Sound` asset | Screen distortion / wave | Derived from audio clip |
| 3 | TBD | TBD `Sound` asset | Color inversion / negative | Derived from audio clip |
| 4 | TBD | TBD `Sound` asset | Chromatic aberration / glitch | Derived from audio clip |

---

## Files to Create / Modify

| Action | File | Notes |
|---|---|---|
| **NEW** | `Assets/Scripts/Jumpscare/JumpscareData.cs` | ScriptableObject definition with image, sound, material, fades, and cursor flag |
| **NEW** | `Assets/Scripts/Jumpscare/JumpscarePlayer.cs` | Standalone MonoBehaviour, static accessor, runs scare coroutine |
| **MODIFY** | `Assets/Scripts/SceneManagement/GameState/EndGameManager.cs` | Remove unused jump duration fields and call `JumpscarePlayer` with assigned data |
| **NEW / CHECK** | `Sound` assets for chosen jumpscare clips | Required by `AKAudioManager` |
| **MODIFY / CHECK** | Active `AKAudioManager` in scene | Ensure chosen jumpscare `Sound` assets are in the sounds array |
| **NEW** | 4x `JumpscareData` assets | One per scare variant |

---

## Open Questions

1. **Material sourcing** - Do we already have materials in mind for the 4 effects, or should we create them?
2. **Image assets** - Are the 4 scare images ready, or is that a later step?
3. **Audio mapping** - Which 4 clips from `Assets/Audio/sfx/JumpScares` should be used for the 4 configured scares?
