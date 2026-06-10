# Jumpscare System

## Goal

Replace the single white-image jumpscare with a **configurable, data-driven system** that supports **4 unique jumpscares**, each with its own image, audio, material effect, optional scripting, and independent duration.

---

## Current State

The endgame sequence in [EndGameManager.cs](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/SceneManagement/GameState/EndGameManager.cs) currently handles a jumpscare as part of the Glitch → Breather → Splash → Quit flow. The jumpscare is hardcoded:

- A single white overlay image
- Fixed `jumpscareRampDuration` (0.35s) and `jumpscareHoldDuration` (0.15s)
- One `Sound` stinger via `AKAudioManager`
- No material effect, no per-scare customization

---

## Design

### 1. `JumpscareData` ScriptableObject

A new `ScriptableObject` that defines everything about a single jumpscare. Create one asset per scare (4 total).

| Field | Type | Purpose |
|---|---|---|
| `scareImage` | `Sprite` | Full-screen image displayed during the scare |
| `scareAudio` | `Sound` | Audio stinger (existing `Sound` SO) played via `AKAudioManager` |
| `scareMaterial` | `Material` | Material applied to the overlay `RawImage`/`Image` for visual effects (distortion, color grading, etc.) |
| `totalDuration` | `float` | Total length of the jumpscare in seconds (real-time) |
| `fadeInDuration` | `float` | How long the image ramps from 0→1 alpha |
| `fadeOutDuration` | `float` | How long the image fades out (0 = hard cut) |
| `onScareStart` | `UnityEvent` | Hook for per-scare custom scripting (camera shake, light flicker, etc.) |
| `onScareEnd` | `UnityEvent` | Hook for cleanup after the scare |

> [!TIP]
> Using a `ScriptableObject` means each scare is a drag-and-drop asset. Tweaking duration or swapping audio/image requires zero code changes.

### 2. `JumpscarePlayer` MonoBehaviour

A reusable component that **plays any `JumpscareData`**. Responsibilities:

1. **Show overlay** — Sets the `scareImage` sprite and `scareMaterial` on a full-screen UI element
2. **Fade in** — Lerps alpha from 0→1 over `fadeInDuration`
3. **Hold** — Maintains full visibility for `totalDuration - fadeInDuration - fadeOutDuration`
4. **Fade out** — Lerps alpha from 1→0 over `fadeOutDuration`
5. **Audio** — Calls `AKAudioManager.instance.Play(scareAudio)` at scare start
6. **Player freeze** — Calls `AKDisableManager.instance.DisablePlayerDefault(true, ...)` on start, restores on end
7. **Events** — Fires `onScareStart` / `onScareEnd` for custom per-scare logic

```
Coroutine flow:
───────────────────────────────────────────────
 onScareStart     fadeIn      hold      fadeOut      onScareEnd
    ↓               ↓          ↓          ↓            ↓
    │──── Play() ───│──────────│──────────│────────────│
    │               ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░│
    alpha=0        alpha→1    alpha=1    alpha→0      done
```

### 3. Integration — Standalone & Modular

`JumpscarePlayer` is a **standalone scene-placed component** with a static accessor. Any trigger in the game (collider, event, `EndGameManager`, etc.) can call `JumpscarePlayer.Play(data)` from anywhere. `EndGameManager` becomes just another consumer — its jumpscare phase simply calls into `JumpscarePlayer` with whichever `JumpscareData` asset is assigned.

This means jumpscares can be used at **any point** in the game, not just the ending.

### 4. The 4 Jumpscares

Each is a separate `JumpscareData` asset configured in the Inspector:

| # | Image | Audio | Material Effect | Custom Script Ideas | Duration |
|---|---|---|---|---|---|
| 1 | *TBD* | *TBD stinger* | Default (none/unlit) | — | Short (~0.5s) |
| 2 | *TBD* | *TBD stinger* | Screen distortion / wave | Camera shake | Medium (~1s) |
| 3 | *TBD* | *TBD stinger* | Color inversion / negative | Light flicker via `onScareStart` | Medium (~1.5s) |
| 4 | *TBD* | *TBD stinger* | Chromatic aberration / glitch | Screen shake + audio distortion | Long (~2.5s) |

> [!NOTE]
> Durations and effects above are placeholders. Since everything is on the `JumpscareData` SO, you can tweak all values in the Inspector without touching code.

---

## Files to Create / Modify

| Action | File | Notes |
|---|---|---|
| **NEW** | `Assets/Scripts/Jumpscare/JumpscareData.cs` | ScriptableObject definition |
| **NEW** | `Assets/Scripts/Jumpscare/JumpscarePlayer.cs` | Standalone MonoBehaviour, static accessor, runs scare coroutine |
| **MODIFY** | `Assets/Scripts/SceneManagement/GameState/EndGameManager.cs` | Replace hardcoded jumpscare with `JumpscarePlayer.Play(data)` call |
| **NEW** | 4× `JumpscareData` assets (created in Unity Inspector) | One per scare variant |

---

## Open Questions

1. **Material sourcing** — Do you already have materials in mind for the 4 effects, or should we plan to create them?
2. **Audio** — Will these use existing `Sound` SOs, or do we need to create new ones and add them to the `AKAudioManager` sounds array?
3. **Image assets** — Do you have the 4 scare images ready, or is that a later step?
