# Cassette Player Mechanic – Design & Implementation Plan

## 1. Overview

Implement a **cassette tape player** mechanic that:

- **Reuses** the existing `IInteractable` / `AKItem` interaction system.
- Uses **diegetic controls** (player clicks visible buttons on the cassette player model).
- Supports **cassette items** that can be inserted to play audiologs.
- Delivers a **polished vertical slice** in one room/scene, but is structured to be reusable.

Target: Unity project using **Adventure Puzzle Kit v1.7.1** (e.g. `IInteractable`, `AKItem`, `AKInteractor`, `AKUIManager`).

---

## 2. Goals & Non‑Goals

### 2.1 Goals

- **Extend interaction system**: Treat the cassette player as a first‑class `IInteractable` using the same pipeline as doors, keycard scanners, etc.
- **Diegetic UX**: Interact via **visible buttons** (Play, Stop, Eject, maybe one extra) rather than only “Press E to use”.
- **Tape + player combo**: Require a **cassette item** to be inserted before audio can play, to add a small but meaningful mechanic.
- **Low overhead**: Maximize reuse of existing systems; minimize new custom infrastructure.

### 2.2 Non‑Goals (for this vertical slice)

- No complex UI menus for tape selection.
- No multi-slot tape libraries or advanced audio scrubbing.
- No save/load system work beyond using existing game save hooks (if any).

---

## 3. Existing Systems to Integrate With

### 3.1 Core Interaction

- `IInteractable`  
  - Key methods: `StartLooking`, `StopInteraction`, `HandleInputClick`, `HandleInputHold`, `HandleInputStop`.
- `AKInteractor`  
  - Raycasts from camera, finds `AKItem`, forwards interaction events to the current `IInteractable`.
- `AKItem`  
  - Generic wrapper around interactables; ties into UI, highlighting, `SystemType` routing.
- `AKUIManager`  
  - Shows crosshair, prompts, interaction text (e.g. “Interact”, “Use”).

### 3.2 Inventory / Item Patterns (for reference)

- `KeycardScannerInteractable` and its inventory model.
- Other system interactables (e.g. valve wheel, fuse box) as patterns for stateful devices.

---

## 4. New Concepts & Data Structures

### 4.1 Cassette Tape Data (ScriptableObject)

Create a ScriptableObject type, e.g. `CassetteData`:

- **Fields (minimum):**
  - `string cassetteId` – unique ID used in inventory / logic (e.g. `"tape_lore_01"`).
  - `AudioClip audioClip` – audiolog audio.
  - `string displayName` – name shown in inventory (optional).
  - `string subtitleKey` – key for subtitles / localization (optional).
  - `bool isCritical` – whether this tape gates progression (optional).

- **Usage:**
  - Designers can create assets like `Cassette_Lore01.asset`, `Cassette_PlotMain01.asset`.
  - Cassette items reference one `CassetteData`.

### 4.2 Cassette Item (Pickup)

A pickup item in the world that:

- Is driven by an `AKItem` and an `IInteractable` or existing pickup system.
- References a `CassetteData` asset.
- Can be stored in the player’s inventory or tracked via an existing collection system.

Required behavior:

- On interact: add tape to inventory / collection in line with existing item patterns.
- Provide a way to query “Does the player have cassette X?” (similar to keycards or other tokens).

---

## 5. Cassette Player Interactable – Design

### 5.1 Script & Location

- New script: `CassettePlayerInteractable.cs`
- Suggested folder: `Assets/Scripts/YourGame/AudioLogs/` (or similar project-local folder).
- Implements `IInteractable`.
- Attached to the cassette player object that also has an `AKItem`.

### 5.2 Public Configuration

- References:
  - `AudioSource audioSource` – on the cassette player.
  - Optional visual hooks (lights, tape tray object, animations).
- State:
  - `bool requiresSpecificCassette` – if true, only accepts specified IDs.
  - `List<string> acceptedCassetteIds` or one `requiredCassetteId`.
- Events:
  - `UnityEvent OnTapeInserted`
  - `UnityEvent OnTapeEjected`
  - `UnityEvent OnTapePlay`
  - `UnityEvent OnTapeStop`
  - `UnityEvent OnTapeFinished` (for progression hooks).

### 5.3 Internal State Machine

Simple enum:

- `Idle` – no tape inserted.
- `TapeInserted` – tape present but not playing.
- `Playing` – currently playing audio.
- `Stopped` – tape in but stopped/paused.

Transitions:

- **Insert tape**: `Idle` → `TapeInserted`.
- **Play**: `TapeInserted` → `Playing` (if tape valid).
- **Stop**: `Playing` → `Stopped`.
- **Eject**: `TapeInserted` or `Stopped` (or `Playing` after implicit stop) → `Idle`.

Audio handling:

- On **Play**: set `audioSource.clip = tape.audioClip`, `audioSource.Play()`.
- On **Stop**: `audioSource.Stop()` and decide whether to reset or keep time; for simplicity, reset.
- On audio complete: detect via `!audioSource.isPlaying` and `Playing` state → `OnTapeFinished`.

---

## 6. Diegetic Button Interaction

### 6.1 Button Hit Zones

On the cassette player model:

- Add child transforms / colliders for:
  - `PlayButton`
  - `StopButton`
  - `EjectButton`
  - (Optional) `ExtraButton` (Next/Prev or power).

Implementation options:

1. **Child collider approach (recommended):**
   - Each button is a child GameObject with its own collider and a small helper script `CassetteButton` containing an enum `ButtonType { Play, Stop, Eject, Extra }`.
   - When `AKInteractor` raycasts, the hit transform will be one of these button objects.

2. **Single collider + screen-space mapping (not necessary for first pass):**
   - More complex; skip for now.

### 6.2 Mapping to `IInteractable` Methods

- `StartLooking` / `StopInteraction`:
  - Behave like other interactables; show generic prompt like “Use Cassette Player”.
- `HandleInputClick`:
  - Given a raycast hit or current focus transform, determine which button was clicked (via `CassetteButton` component).
  - Dispatch to methods `OnPlayButtonPressed()`, `OnStopButtonPressed()`, `OnEjectButtonPressed()`.
- `HandleInputHold` / `HandleInputStop`:
  - Likely unused for first version, but kept for future (e.g. hold to fast-forward).

---

## 7. Tape Insertion Flow

### 7.1 Inventory‑Driven Flow (Keycard‑Style)

Pattern similar to `KeycardScannerInteractable`:

- When player interacts with the cassette player and has a tape in inventory:
  - If no tape is currently inserted:
    - Check inventory for an appropriate cassette ID.
    - Remove it or mark it as “in use”.
    - Transition `Idle` → `TapeInserted`.
    - Trigger `OnTapeInserted` + update visuals.
  - If a tape is already inserted:
    - Use Eject button to remove it and restore tape to inventory or spawn world item.

Implementation notes:

- Keep logic generic enough to allow:
  - “Accept any tape” players.
  - “Accept only specific tape(s)” players (e.g. puzzle gating).

### 7.2 World Object Variant (Optional Later)

- Instead of inventory, the tape remains a physical object that is picked and snapped to the tray.
- For the vertical slice, prefer the **inventory‑driven** variant for simplicity.

---

## 8. Visual & Feedback Hooks

- **Animations:**
  - Button press/release animations.
  - Tape tray open/close.
- **Lights/Indicators:**
  - Small LED for “Power/Play”.
- **Audio SFX:**
  - Button click sounds.
  - Eject / tape insert sounds.
- **UI Text:**
  - Keep minimal, e.g. “Use Cassette Player,” optionally change hint when player has a tape vs not.

All of these should be optional references exposed on `CassettePlayerInteractable` and wired via `UnityEvents` or direct `Animator` / `AudioSource` calls.

---

## 9. Implementation Steps (for another agent)

1. **Cassette Data**
   - Create `CassetteData` ScriptableObject type.
   - Add inspector fields for ID, audio clip, display name, optional metadata.
   - Create 1–3 cassette assets for test audiologs.

2. **Cassette Item**
   - Create a cassette pickup prefab using existing pickup pattern:
     - `GameObject` with collider, `AKItem`, needed `IInteractable` script.
     - Field to reference `CassetteData`.
   - Extend or reuse inventory/collection logic so we can:
     - Add cassette by ID.
     - Check if player has cassette X.
   - Place at least one cassette in the vertical slice scene.

3. **Cassette Player Interactable**
   - Create `CassettePlayerInteractable` implementing `IInteractable`.
   - Attach to cassette player object that has an `AKItem`.
   - Wire `AKItem` `SystemType` or equivalent so `AKInteractor` routes inputs to this script.
   - Implement:
     - State machine (Idle / TapeInserted / Playing / Stopped).
     - `HandleInputClick` to dispatch to button methods.
     - Audio playback via `AudioSource`.
     - Events for tape insert/eject/play/stop/finish.

4. **Button Colliders & Mapping**
   - Add child button objects with colliders and `CassetteButton` component (enum type).
   - Ensure `AKInteractor` raycast hits these colliders, but the associated `AKItem` is on the root object.
   - In `CassettePlayerInteractable`, use the raycast hit transform to resolve which button was pressed and call corresponding handler.

5. **Progression Hooks**
   - On `OnTapeFinished`, invoke a UnityEvent that can:
     - Set a progression flag.
     - Trigger an external script (e.g. unlock a door).
   - In the test scene, wire one cassette’s `OnTapeFinished` to a simple visible effect (e.g. open door) to prove the flow.

6. **Polish for Vertical Slice**
   - Add SFX and basic button animations.
   - Tune interaction text and crosshair feedback.
   - Ensure the mechanic fits naturally into one room (tape → player → door unlock or story beat).

---

## 10. Edge Cases & Behaviors

- **Press Play with no tape**:
  - Do nothing or play a “no tape” click sound.
- **Insert wrong tape (if restricted)**:
  - Reject with SFX / subtle feedback.
- **Eject while playing**:
  - Stop audio and move to `Idle`.
- **Player walks away mid‑play**:
  - Audio can continue or stop based on design choice; default suggestion: continue playing as environmental audio.
- **Multiple players/instances**:
  - System should support multiple cassette players using different `CassetteData` or requirements.

---

## 11. Testing Checklist

- Player can **pick up** at least one cassette.
- Player can **interact** with cassette player; prompts show correctly.
- Clicking **Play** without tape does not break anything (and gives sensible feedback).
- Inserting tape works; state transitions to `TapeInserted`.
- Clicking **Play** starts audio; clicking **Stop** stops it.
- Clicking **Eject** stops audio (if playing) and returns/removes tape as designed.
- Audio completion triggers `OnTapeFinished`, and any wired progression event fires correctly.
- Using multiple tapes (if set up) plays the correct audio per tape.

---

## 12. Future Extensions (Optional)

- Add **Next/Previous** buttons for multi-track tapes or collections.
- Add a small **UI overlay** showing tape name and time.
- Integrate with **subtitle system** using `subtitleKey` from `CassetteData`.
- Expand to **portable tape player** item that the player carries.