---
name: cassette-player-mechanic
overview: Design and implement a cassette tape player mechanic that reuses your existing modified interaction system, supports diegetic button controls, and integrates with cassette items to play audiologs in a single polished room/scene.
todos:
  - id: cassette-data
    content: Define cassette tape data assets (ScriptableObjects) that map cassette IDs to audio clips and optional metadata.
    status: pending
  - id: cassette-item
    content: Make cassette pickups that hook into the existing inventory system and reference cassette data IDs.
    status: pending
  - id: cassette-player-interactable
    content: Create a CassettePlayerInteractable implementing IInteractable, wired via AKItem/SystemType, to control audio playback and tape insertion/ejection.
    status: pending
  - id: cassette-buttons
    content: Configure button colliders on the cassette player model and map interaction raycasts to play/stop/eject actions.
    status: pending
  - id: cassette-progression
    content: Trigger optional progression/story events when key tapes start or finish playing in the vertical-slice scene.
    status: pending
isProject: false
---

### Goals

- **Extend interaction system**: Reuse your existing `IInteractable` / `AKItem` pipeline so the cassette player feels like all other interactables.
- **Diegetic controls**: Allow the player to look at and click visible buttons on the cassette player model (play/stop/eject, etc.).
- **Tape + player combo**: Require inserting cassette items to unlock specific audiologs, giving a few minutes of novel mechanic with minimal new systems.

### High-level approach

- **1. Define cassette data**
  - Create a cassette tape data representation that links a tape item to an audio clip and optional metadata (subtitle key, ID, progression flags).
  - Prefer a ScriptableObject so designers can add new tapes without code changes.
- **2. Make cassette items pickup-able and identifiable**
  - Ensure cassette pickups are standard `AKItem`-based interactables using your existing pickup/interact flow.
  - Give each cassette a unique ID and reference to its tape data asset so the player’s inventory knows which tape is held.
- **3. Implement a `CassettePlayerInteractable`**
  - Add a new interactable script under something like `[Assets/Scripts/YourGame/AudioLogs/CassettePlayerInteractable.cs](Assets/Scripts/YourGame/AudioLogs/CassettePlayerInteractable.cs)` that implements `IInteractable`.
  - Reuse the same pattern as existing systems such as `[Assets/Scripts/Adventure Puzzle Kit v1.7.1/Systems/Keycard/KeycardScannerInteractable.cs](Assets/Scripts/Adventure Puzzle Kit v1.7.1/Systems/Keycard/KeycardScannerInteractable.cs)`:
    - Expose a `SystemType` on the associated `AKItem` so `AKInteractor` can route interaction events.
    - Use the `HandleInputClick/Hold/Stop` callbacks for the different button interactions.
- **4. Map raycast hits to specific buttons**
  - Add small child colliders or trigger zones on the cassette player for each physical button (Play, Stop, Eject, maybe Next/Previous).
  - When `AKInteractor` focuses the cassette player `AKItem`, forward clicks to `CassettePlayerInteractable`, which determines which button collider was hit (via hit transform or a small helper component) and triggers the right method.
  - Keep interaction text minimal (e.g. generic "Use Player" label from `AKUIManager`) so the feel is diegetic but still readable.
- **5. State machine and audio playback**
  - Inside `CassettePlayerInteractable`, maintain simple states: `Idle`, `TapeInserted`, `Playing`, `Paused`, `Stopped`.
  - On **Eject**: if a tape is inserted, stop audio, update state, and optionally spawn / return the cassette to the world or inventory.
  - On **Play**: if a valid tape is inserted and not already playing, play the associated audiolog clip via an `AudioSource` on the player and set state to `Playing`.
  - On **Stop**: stop audio and reset to start or keep current time based on desired UX (simple first iteration: reset).
- **6. Inventory + tape insertion flow**
  - Choose one of two simple flows (we can refine after testing):
    - **Contextual use**: When the player looks at the cassette player while holding a cassette in their inventory, a `Use Tape` click inserts it (similar to how keycards are used with `[Assets/Scripts/Adventure Puzzle Kit v1.7.1/Systems/Keycard/KeycardScannerInteractable.cs](Assets/Scripts/Adventure Puzzle Kit v1.7.1/Systems/Keycard/KeycardScannerInteractable.cs)`).
    - **World object insertion**: The cassette is a world object you manually place into the player (pickup cassette, then interact with player to snap it in).
  - For minimal dev time, follow the keycard/door pattern: check inventory for the required cassette ID, consume or flag it as inserted, and update the player’s visual state.
- **7. Visual feedback and animation hooks**
  - Add events in `CassettePlayerInteractable` for button presses (play/stop/eject) to drive simple animations (button depress, tape door open/close) and lights (e.g. a small LED when playing).
  - Optionally, expose UnityEvents so you can hook extra logic per scene (e.g., when a specific tape finishes, unlock a door or mark a story beat).
- **8. Progression & audiolog management**
  - For story/progression tapes, add callbacks when a tape **starts** and **finishes** playing (e.g., `OnTapeStarted`, `OnTapeFinished`).
  - Integrate lightly with any existing quest/progression manager by firing events or setting flags when key tapes complete.

### Simple interaction flow (concept)

```mermaid
flowchart TD
  player[Player] --> interactor[AKInteractor]
  interactor --> akItem[AKItem (Cassette Player)]
  akItem --> cassetteSystem[CassettePlayerInteractable]
  player --> inventory[Inventory]
  inventory --> cassetteSystem
  cassetteSystem --> audioSource[AudioSource]
  cassetteSystem --> progression[Progression/Story Flags]
```



### Todos

- **cassette-data**: Define cassette tape data assets (ScriptableObjects) that map IDs to audio clips and metadata.
- **cassette-item**: Make cassette items pickup-able and identifiable via your existing inventory system.
- **cassette-player-interactable**: Implement `CassettePlayerInteractable` using the `IInteractable`/`AKItem` pattern, with simple states and audio control.
- **cassette-buttons**: Set up button colliders on the player model and map raycast hits to play/stop/eject logic.
- **cassette-progression**: Expose events for tape start/finish and hook at least one audiolog into your current scene as a vertical slice.

