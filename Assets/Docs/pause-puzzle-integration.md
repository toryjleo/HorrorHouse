# Pause Menu + Puzzle Integration Guide

This project uses **Adventure Puzzle Kit (APK)** `GameState` pause/resume events. This doc explains how to make **puzzle items** behave correctly when the player pauses (ESC) and how to keep future puzzle code consistent.

## Goals

- Pausing should **stop player interaction** with puzzle items.
- Pausing should **not break puzzle state** (no half-finished interactions, no stuck UI, no double subscriptions).
- Resuming should restore the player to a **predictable state** (cursor, input, selection, prompts).

## The 4 Bins (Pick One Per Puzzle)

When adding or updating a puzzle item, decide which bin it belongs in and implement the matching behavior.

### 1) “Freeze World” puzzles (default)

**Examples:** doors/drawers, rotating valves, physics pushes, moving platforms, most “in-world” interactions.

**Expected pause behavior:**
- Input stops (no clicks, holds, or drags)
- Animations/physics stop (typically via `Time.timeScale = 0`)
- Interaction prompts/highlights stop updating

**Implementation notes:**
- Prefer using `Time.timeScale = 0` pause.
- Ensure the interaction component doesn’t keep processing input when paused (guard input with `if (GameState.IsPaused) return;` if available, or listen to pause events and disable input).

### 2) “UI Modal” puzzles (pausing closes or blocks the modal)

**Examples:** keypad UI, combination locks, inventory-like puzzle screens, dialogue-like puzzle panels.

**Expected pause behavior (choose one and be consistent per puzzle type):**
- **Close-on-pause:** pause immediately closes the puzzle UI and returns to gameplay state after resume.
- **Block-under-pause:** puzzle UI remains open visually, but input is blocked until resume.

**Implementation notes:**
- If the puzzle UI uses the Unity `EventSystem`, explicitly set/clear selected objects on open/close to avoid “sticky” selection.
- Avoid leaving the cursor in a weird state; the pause menu should be the only UI that owns cursor lock/visibility while paused.

### 3) “Timed” puzzles (explicit decision: stop timer or keep it running)

**Examples:** countdown puzzles, chase timers, “hold to complete” progress, traps.

**Expected pause behavior:**
- Most games **stop timers on pause**.

**Implementation notes:**
- If you use `Time.deltaTime`, timers stop automatically at `timeScale = 0`.
- If you use `unscaledDeltaTime` / `WaitForSecondsRealtime`, timers will continue during pause unless you explicitly stop them.
- Decide per puzzle: *should the timer stop on pause?* Document it in the puzzle component.

### 4) “Persistent Audio/FX” puzzles (audio/visual that should keep playing)

**Examples:** menu ambience, UI hums, non-gameplay audio.

**Expected pause behavior:**
- Usually **gameplay audio pauses**, while some UI audio may continue.

**Implementation notes:**
- Use a dedicated audio path (mixer group / sound category) so pause can mute/pause gameplay sounds without muting UI.
- If APK provides `AKAudioManager.PauseAll()`/`ResumeAll()`, decide whether pause should call those (and exclude UI audio if needed).

## Recommended Pattern for New Puzzle Code

### Subscribe only while “active”

If only one instance should react (e.g., the puzzle currently being interacted with), subscribe to pause events **only while active**, then unsubscribe when finished. This prevents *every* puzzle in the scene from responding.

Typical pattern:
- Subscribe in `BeginInteraction()` / `OpenPuzzleUI()` / `ExamineObject()`
- Unsubscribe in `EndInteraction()` / `ClosePuzzleUI()` / `DropObject()`

### If you subscribe in `OnEnable`, add a strong guard

It’s valid to subscribe in `OnEnable` **only** if the handler checks that *this* instance is the current active puzzle (for example, by comparing to a “current puzzle” reference).

Without that guard, pausing can trigger many puzzle objects at once.

## Pause Menu Integration Checklist (for implementors)

When you add a puzzle item or update an old one, verify:

1. **Input gating** — puzzle ignores input while paused.
2. **UI ownership** — pause menu is the only UI that should be selectable/interactive while paused.
3. **Prompt cleanup** — prompts/highlights are hidden or stop updating while paused (no floating “E - Interact” while in menus).
4. **No event leaks** — every `+=` has a matching `-=` (especially if subscribing during interactions).
5. **Reopen correctness** — closing/reopening pause doesn’t leave puzzle UI in a stuck/selected state.

## Common Pitfalls

- Subscribing every puzzle object to `GameState.Paused` in `OnEnable` → pause triggers multiple handlers.
- Using unscaled time for gameplay timers → timer continues while paused.
- Not clearing `EventSystem` selection on close → “selected” highlight persists across menu reopen.
- Leaving prompts registered when entering pause → prompts appear under pause UI.

