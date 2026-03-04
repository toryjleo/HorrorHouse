# Cassette Player Mechanic – Design & Implementation Plan (Concise)

## 1. Overview

Build a cassette player mechanic that **reuses AKInteractor/AKItem**, supports **diegetic button clicks**, and plays **cassette audiologs**. Keep it modular and scene‑ready.

Target: Unity + Adventure Puzzle Kit v1.7.1.

---

## 2. Core Goals

- Reuse `IInteractable` / `AKItem` pipeline.
- Buttons on the model: **Play / Stop / Eject / Rewind**.
- Cassette items insertable from inventory.
- Minimal new systems; data‑driven tapes.

---

## 3. Data & Items

### 3.1 CassetteData (ScriptableObject)

Fields:
- `cassetteId`, `audioClip`, `displayName`, `subtitleKey?`, `isCritical?`

### 3.2 Cassette Item (Pickup)

- Standard `AKItem` pickup with a `CassetteData` reference.
- Inventory can query by `cassetteId`.

---

## 4. Cassette Player Interactable

- Script: `CassettePlayerInteractable.cs` (implements `IInteractable`).
- Attached to player object with `AKItem`.

### 4.1 State Machine

- `Idle` → `TapeInserted` → `Playing` → `Stopped` → `Idle`.

Transitions:
- **Insert**: `Idle` → `TapeInserted`.
- **Play**: `TapeInserted` → `Playing`.
- **Stop**: `Playing` → `Stopped` (reset time).
- **Rewind**: `Stopped` or `TapeInserted` → `TapeInserted` (set time = 0).
- **Eject**: `TapeInserted/Stopped/Playing` → `Idle`.

### 4.2 Audio

- `audioSource.clip = tape.audioClip` on play.
- `Stop()` + `time = 0` on Stop/Rewind.
- `OnTapeFinished` when playback ends.

---

## 5. Button Interaction (Diegetic)

Child colliders on the model:
- `PlayButton`, `StopButton`, `EjectButton`, `RewindButton`.

Helper component:
- `CassetteButton` with `ButtonType { Play, Stop, Eject, Rewind }`.

`HandleInputClick` resolves hit → dispatches to:
- `OnPlayButtonPressed()`
- `OnStopButtonPressed()`
- `OnEjectButtonPressed()`
- `OnRewindButtonPressed()`

---

## 6. Tape Insertion Flow

Inventory‑driven (keycard‑style):
- If no tape inserted, try insert from inventory.
- On eject, return to inventory or respawn pickup.
- Optional: `requiresSpecificCassette` + list of accepted IDs.

---

## 7. Events & Hooks

- `OnTapeInserted`, `OnTapeEjected`, `OnTapePlay`, `OnTapeStop`, `OnTapeFinished`.
- Use UnityEvents for lights, SFX, animations, progression.

---

## 8. Edge Cases

- Play/Rewind with no tape → ignore or SFX.
- Rewind while playing → stop + reset.
- Eject while playing → stop + eject.
- Wrong tape → reject feedback.

---

## 9. Implementation Steps (for another agent)

1. Create `CassetteData` assets.
2. Make cassette pickup items (AKItem + CassetteData).
3. Implement `CassettePlayerInteractable` with state + audio.
4. Add button colliders + `CassetteButton` enum.
5. Wire events in the test scene (playback + progression).
