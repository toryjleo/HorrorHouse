# Inventory Menu Overhaul (Codex Plan)

Redesign the item/inventory menu system from grouped, fullscreen sub-inventories to a unified, flat 8-slot right-side panel (RE7-style). Remove item grouping, change plug pickup flow, add auto-use on outlets, and rebind controls.

---

## Scope + Open Questions (need confirmation before build)

1. Do “items in the plugs” include **both** Chess outlet pieces and **Fuse Box** fuses, or only Chess?
2. Should the **Fuse Box (4-slot count)** stay count-based or be converted to itemized inventory?
3. When the side panel is open, can the player still look around (interaction disabled), or should movement/look be frozen?
4. On auto-use: should correct item placement show a short confirm animation/text, or be instant?
5. Inventory overflow behavior when at 8 slots: block pickup + prompt, auto-drop, or open panel to replace?

---

## Phase 0: Prep and Safety

- **Back up** current scene UI references: note all inventory-related fields on `AKUIManager` and any per-puzzle UI containers in `Basement_1`.
- Add a temporary **compatibility shim** so existing puzzle scripts can still compile while the unified inventory is phased in.
- Decide the overflow UX and side-panel interaction mode now (see questions).

---

## Phase 1: Unified Inventory Data Layer (no UI changes yet)

### New ScriptableObject: `InventoryItem`
- Fields: `itemName`, `icon` (Sprite), `worldPrefab` (GameObject), `category` enum (ChessPiece, Fuse, Key, Valve, Keycard, General).
- Holds **typed references** for existing systems (e.g., `ChessPiece`, `Valve`, `Keycard`) to keep puzzle logic intact.

### New Singleton: `PlayerInventory`
- `List<InventoryItem> items` (max 8).
- `AddItem`, `RemoveItem`, `HasItem`, `GetItemsByCategory`.
- Events: `OnItemAdded`, `OnItemRemoved`, `OnSelectionChanged`.
- `selectedItem` field for UI and auto-use flows.

### Temporary Adapter Layer (minimize breakage)
- Keep existing inventory singletons intact initially, but change them to **delegate** to `PlayerInventory`.
- This enables a **compile-safe** transition of all call sites.

**Success criteria:** project compiles, existing flows still work.

---

## Phase 2: Right-Side Panel UI (new UI + wiring)

### New UI Scripts
- `InventorySlotWidget`: displays icon, selection state, click handler.
- `InventoryPanelController`: manages 8 slots, item name/description, and open/close.

### `AKUIManager` Integration
- `OpenInventoryUI/CloseInventoryUI` delegate to `InventoryPanelController`.
- Add `OpenInventoryForOutlet(IOutletContext)` to open panel in auto-use mode.
- **Retain** non-inventory HUD elements: prompt system, crosshair, flashlight, gas mask, health, post-processing.

**Unity Editor wiring required** (document concrete fields to reconnect).

---

## Phase 3: Examine-Before-Pickup for Plug Items

Use the existing examine system for items already placed in outlets.

**Required settings (per repo instructions):**
- Add `ExaminableItem` to the spawned plug item.
- `ExaminableItem.Is Collectable = true`.
- `AKItem.System Type = None` (so E doesn’t pick up directly).
- `AKItem.Show Examine Prompt = true`.
- `AKItem.Show Pickup Prompt = false`.

### Flow
- Interact with occupied outlet → `ExaminableItem.ExamineObject()` on the placed item.
- On collect: remove from outlet, add to `PlayerInventory`, destroy placed visual.
- Remove the old “open inventory → back button to retrieve” flow.

**Success criteria:** occupied outlet uses examine flow and collection key.

---

## Phase 4: Auto-Use on Outlets (with Error Feedback)

### New Outlet Interface
Define `IOutletContext` (or similar) so auto-use is not chess-only:
- `bool TryPlaceItem(InventoryItem item)`
- `void OnCancel()`

### Placement Rules
- Selecting an item while an outlet is active attempts placement:
  - **Success:** remove item from inventory, place item, close panel, play insert sound.
  - **Fail:** show brief error text (e.g., “That doesn’t fit here”), keep panel open.

### UI Prompt
Use existing prompt system in `AKUIManager` for temporary messages, or add a dedicated TMP text element (but avoid duplicating prompt systems).

---

## Phase 5: Input Rebinding (context-gated)

### `AKInputManager` default keys (Inspector)
- Inventory toggle: `Tab`.
- Interact: `F` + `Mouse0` (Left Click).
- Cancel/Back: `Space` + `Mouse1` (Right Click).

### `AKInteractor`
- Add mouse input alternatives, **but only when interaction is allowed**.
- Ensure Right Click cancel does not break camera/aim in normal play.

**Success criteria:** consistent behavior in normal play, examine, and inventory states.

---

## Files Likely to Need Updates

- `ChessFuseCollectable.cs`: add `PlayerInventory.AddItem`.
- `ChessFuseBoxInteractable.cs`: use `OpenInventoryForOutlet`, `TryPlaceItem`, and examine flow.
- `FuseInventory.cs` / `FuseboxController.cs`: migrate to `PlayerInventory` or keep count system and adapt.
- `AKUIManager.cs`: inventory UI integration + prompt reuse.

---

## Manual Verification Checklist (Unity Editor)

1. **Inventory panel toggle**: Tab opens/closes side panel; Space/Right Click close.
2. **Item population**: chess pieces, fuses, keys appear in 8-slot list.
3. **Overflow handling**: 9th item triggers chosen UX.
4. **Occupied outlet examine**: interact opens examine; collect removes from outlet + adds to inventory.
5. **Empty outlet auto-use**: inventory opens; correct item places; wrong item shows error text.
6. **Controls**: F/Left Click interact; Right Click/Space cancel; Tab toggle.
7. **HUD unchanged**: flashlight, gas mask, health, crosshair intact.

---

## Notes

- Implement **one phase at a time** and test in `Basement_1`.
- Keep inspector wiring notes as you modify `AKUIManager` and UI prefabs.
