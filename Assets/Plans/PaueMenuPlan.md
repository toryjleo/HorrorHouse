# Pause Menu Implementation Plan

Add a pause menu triggered by `Escape` with a `PAUSED` title and `Resume` / `Quit` buttons.

This version is synced to the current codebase and uses a simpler rule:

`Escape` should work during interactions, but pause should not preserve live interaction state.
Instead, it should first close the current transient interaction/UI cleanly, then enter pause from a neutral gameplay state.

---

## Recommendation

Use **close-then-pause**, not **pause-and-preserve**.

### Why this is cleaner

- Most interaction systems already own a proper close path that restores player state, cursor state, prompts, and temporary UI.
- Preserving interaction state during pause would require the pause system to understand and restore many subsystem-specific states.
- Several systems still process input independently, so pausing in place would require a wide input audit and more cross-system coupling.
- Closing the active interaction first keeps pause behavior predictable: pause always means "gameplay is suspended from a normal baseline state".

### Product behavior

- If the player is in normal gameplay, `Escape` opens pause immediately.
- If the player is examining an item, reading a note, in inventory, using a keypad/phone/safe/padlock, etc., `Escape` first closes that interaction, then opens pause in the same keypress.
- `Resume` returns to normal gameplay, not back into the old interaction.

---

## Existing System Notes

### Useful current behavior

- `GameState.isGamePaused` already exists in [GameState.cs](/home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/GameState.cs:10).
- `AKDisableManager.DisablePlayerDefault()` already centralizes cursor, crosshair, player movement, interactor, and zoom state in [AKDisableManager.cs](/home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKDisableManager.cs:43).
- Many interaction systems already have explicit close/exit methods:
  - Examine: `DropObject(...)` in [ExaminableItem.cs](/home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Systems/Examine/ExaminableItem.cs:253)
  - Inventory: `CloseInventoryUI()` in [AKUIManager.cs](/home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKUIManager.cs:383)
  - Safe: `CloseSafeUI()` in [SafeController.cs](/home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Systems/Safe/SafeController.cs:112)
  - Keypad: `CloseKeypad()` in [KeypadController.cs](/home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Systems/Keypad/KeypadController.cs:79)
  - Phone: `CloseKeypad()` in [PhoneController.cs](/home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Systems/Phone/PhoneController.cs:78)
  - Padlock: `DisablePadlock()` in [PadlockController.cs](/home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Systems/Padlock/PadlockController.cs:132)
  - Notes: `CloseNote()` in the note controllers

### Important limitation

`GameState.isGamePaused` does **not** automatically freeze all input. Some scripts respect `GameState.IsPlayerBusy`, but others read input directly in their own `Update()` methods. So the pause plan should not rely on `Time.timeScale = 0` alone.

---

## Proposed Architecture

### 1. New `PauseManager`

Create [PauseManager.cs](/home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/PauseMenu/PauseManager.cs).

Responsibilities:

- Listen for `Escape`
- If currently paused, resume
- If not paused:
  - close any active transient interaction/UI first
  - then enter pause
- Show/hide the pause menu panel
- Set and clear `GameState.isGamePaused`
- Set `Time.timeScale`
- Set `AudioListener.pause`
- Handle `Quit`

Suggested flow:

```csharp
private void Update()
{
    if (!Input.GetKeyDown(KeyCode.Escape)) return;

    if (GameState.isGamePaused)
    {
        ResumeGame();
        return;
    }

    CloseTransientStateBeforePause();
    PauseGame();
}
```

### 2. Add a central "close transient state" pass

This is the key change that makes the feature clean.

Add a method in `PauseManager` that asks the currently active systems to close themselves using their existing cleanup methods.

Suggested order:

1. Close notes
2. Close examine
3. Close keypad / phone / safe / padlock
4. Close inventory
5. Enter pause

Reasoning:

- These systems already know how to restore prompts, colliders, cursor state, and player control.
- Pause stays decoupled from internal subsystem details.
- Resume becomes trivial because there is no suspended subsystem to reconstruct.

### 3. Add a small integration layer for systems that cannot currently be closed externally

Some close methods are private or only reachable through UI buttons. That is the main cleanup task required for this design.

Recommended changes:

- Expose a public inventory close method in `AKUIManager`
- Expose a public safe close method in `SafeController`
- Expose a public padlock close method in `PadlockController`
- Add a small public helper in each note UI/controller family if needed so pause can close the active note safely

Keep these wrappers narrow. The pause system should call existing close logic, not duplicate it.

Example pattern:

```csharp
public void ForceCloseForPause()
{
    if (!isOpen) return;
    CloseKeypad();
}
```

### 4. Add a lightweight input guard where needed

Even with close-then-pause, you still want a small protection layer during the paused state itself.

Minimum required:

- Add an early return in [AKFPSController.cs](/home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Player/AKFPSController.cs:67) so mouse look does not continue at `timeScale = 0`
- Add `if (GameState.isGamePaused) return;` guards to any remaining scripts that can still process gameplay input while paused

This guard pass should be limited to scripts that remain active after transient UI closes, such as equipment toggles or other always-on player systems.

---

## Pause/Resume Rules

### On Pause

1. Close transient interaction/UI state
2. `GameState.isGamePaused = true`
3. `Time.timeScale = 0f`
4. `AudioListener.pause = true`
5. Show cursor and unlock it
6. Show pause menu panel

### On Resume

1. Hide pause menu panel
2. `AudioListener.pause = false`
3. `Time.timeScale = 1f`
4. `GameState.isGamePaused = false`
5. Restore gameplay cursor state: hidden + locked

### On Quit

Use the same editor/build split already used in [SceneManager.cs](/home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/SceneManagement/SceneManager.cs:17).

---

## Why Not Preserve Interaction State

Avoid this approach for this project.

Problems it would introduce:

- Examine mode has live object transforms, inspect points, custom UI, and camera state.
- Puzzle UIs and notes each have their own active object references and close flows.
- Some systems disable input through `AKDisableManager`, while others keep local booleans.
- Resume would need to restore subsystem-specific state in the correct order, which is fragile.

That is higher risk for little product value. Closing the interaction before pausing is the cleaner dependency boundary.

---

## Unity UI Setup

Create the pause UI in the editor:

1. Add a `Canvas`
2. Add a full-screen dark `PauseMenuPanel`
3. Add a `PAUSED` title
4. Add `Resume` and `Quit` buttons
5. Disable the panel by default
6. Wire the buttons to `PauseManager.ResumeGame()` and `PauseManager.QuitGame()`

The earlier visual recommendations are still fine; they are just separate from the implementation decision.

---

## Verification Plan

### Manual tests

1. In normal gameplay, press `Escape`
   - Pause menu opens
   - Player cannot move or look
   - Audio pauses
   - Cursor unlocks

2. While examining an item, press `Escape`
   - Item exits examine mode cleanly
   - Pause menu opens immediately after
   - No stuck prompts, inspect points, or cursor issues remain

3. While inventory is open, press `Escape`
   - Inventory closes
   - Pause menu opens

4. While using keypad / phone / safe / padlock, press `Escape`
   - Active UI closes cleanly
   - Pause menu opens

5. While reading each note type, press `Escape`
   - Note closes cleanly
   - Pause menu opens

6. Click `Resume`
   - Pause menu closes
   - Gameplay input returns normally
   - Player is back in neutral gameplay, not inside an old interaction

7. Click `Quit`
   - Play mode stops in editor
   - Build quits in standalone

### Regression checks

- No duplicated prompts after resuming
- No invisible active UI left behind
- No stuck cursor-visible state after resume
- No stuck `GameState.IsUsingSystem`, `IsExamining`, or `IsInventoryOpen` flags
