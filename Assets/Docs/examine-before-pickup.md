# Examine Before Pickup (Editor-Only Setup)

This setup makes items require examination before they can be collected. Interaction is driven by the Examine system, not the direct pickup path.

## Goal
- Press the examine key to inspect the item.
- Only while examining can the player pick up the item.
- All prompts are managed via the editor (no runtime prompt injection needed).

## Required Components
1) `ExaminableItem`
2) The item-specific system component (e.g., `KeycardItem`, `TKItem`, `ChessItem`, `ValveItem`, etc.)
3) `AKItem` (for prompts and general interaction)

## Editor Steps
1) Add `ExaminableItem` to the object.
2) In `ExaminableItem`:
   - Enable `Is Collectable`.
   - Set `System Type` to the matching system (e.g., `KeycardSys`, `ChessSys`).
   - Optionally set UI fields (name/description) for the examine UI.
3) In `AKItem`:
   - Set `System Type` to `None` to prevent direct pickup on E.
   - Enable `Show Examine Prompt` (and optionally `Show Name Highlight`).
   - Disable `Show Pickup Prompt` to avoid mixed messaging.

## How It Works (Under The Hood)
- `AKInteractor` sends `mainInteractionKey` to `AKItem.HandleInputClick()` (direct pickup path).
- `AKItem.HandleExamine()` routes to `ExaminableItem`.
- `ExaminableItem` only calls `CollectItem()` when `Is Collectable` is true and the pickup key is pressed while examining.

## Notes
- The pickup key is defined by `AKInputManager.pickupItemKey`.
- The examine key is defined by `AKInputManager.examineKey`.
- If you want E to examine, update input bindings or modify `AKInteractor`.
