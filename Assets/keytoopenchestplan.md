# Key to Open Chest Plan (Themed Key System)

## Goal
Keep `ExamineInspectPoint` generic and unchanged, but gate chest-open logic using a themed key. Reuse the **key-check pattern** from `TKDoorInteractable.CheckDoor()` (inventory contains key → allow; else denied), without importing its animation logic.

## Design Summary
- `ExamineInspectPoint` remains unchanged.
- Add a new **InspectKeyGate** component that exposes a *required key* field in the Inspector.
- The gate mirrors the core TKDoorInteractable logic:
  - Check `TKInventory.instance._keyList.Contains(requiredKey)`
  - Optionally remove the key after use
  - Invoke **allowed** or **denied** UnityEvents
- If `requiredKey` is not assigned, allow by default (optional gate).

## Proposed New Script
**`Scripts/Adventure Puzzle Kit v1.7.1/Systems/Examine/InspectKeyGate.cs`**

### Inspector Fields (mirrors TKDoorInteractable pattern)
- `requiredKey` (type: `AdventurePuzzleKit.ThemedKey.Key`, optional)
- `removeKeyAfterUse` (bool)
- `onAllowed` (UnityEvent) — open chest logic
- `onDenied` (UnityEvent) — play locked sound / prompt
- `lockedSound` (optional `Sound`) — reuse pattern from TKDoorInteractable

### Behavior (based on `TKDoorInteractable.CheckDoor()`)
- If `requiredKey == null` → invoke `onAllowed` (no gating)
- Else if `TKInventory.instance._keyList.Contains(requiredKey)`:
  - if `removeKeyAfterUse` → `TKInventory.instance.RemoveKey(requiredKey)`
  - invoke `onAllowed`
- Else → invoke `onDenied` (optionally play locked sound)

## Wiring in Unity (Planning Only)
1. Add `InspectKeyGate` to the chest or inspect-point GameObject.
2. In `ExamineInspectPoint.specialInteraction`, connect to `InspectKeyGate.TryOpen()`.
3. In `InspectKeyGate.onAllowed`, connect to chest open method (animation/state).
4. In `InspectKeyGate.onDenied`, connect to a locked sound or UI prompt.
5. Assign the themed `Key` ScriptableObject to `requiredKey`.

## Notes
- This keeps `ExamineInspectPoint` generic and reusable.
- Leverages existing TK key logic without duplicating animation logic.
- If you want parity with `TKDoorInteractable`, we can optionally add the same locked sound hook.
 - The gate component is the only new runtime code; all other steps are inspector wiring.
