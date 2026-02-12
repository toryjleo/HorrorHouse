# Inventory Menu Overhaul

Redesign the item/inventory menu system from grouped, fullscreen sub-inventories to a unified, flat, 8-slot right-side panel (RE7-style). Remove item grouping, change plug pickup flow, add auto-use on outlets, and rebind controls.

## User Review Required

> [!IMPORTANT]
> **This is a large refactor touching many systems.** The existing asset kit has 6 separate inventory systems (Chess, Fuse, ThemedKey, Valve, Keycard, Generator), each with their own singleton, UI containers, and item flows. This plan unifies them into one. We should implement this in phases so we can verify each phase works before moving on.

> [!WARNING]
> **Unity Inspector references will need to be re-wired.** The new inventory panel, slot widgets, and control changes will require manual reconnection in the Unity Editor after code changes. I will document what needs to be connected.

> [!IMPORTANT]
> **Scope clarification needed:**
> 1. When you say "items in the plugs" should be picked up the same as chess collectables — do you mean the **fuse box system** plugs as well, or only the chess puzzle outlets?
> 2. Should the Fuse system (the one with 4 generic fuse slots, not chess pieces) also move to the unified inventory, or stay count-based?
> 3. For the side panel — should the player **still be able to look around** while the inventory is open (just disable interaction), or fully freeze movement/look?
> 4. When you auto-use an item on a chess outlet, should it show an animation/confirmation, or just instantly place it?

---

## Proposed Changes

### Phase 1: Unified Inventory Data Layer

Replace 6 separate inventory singletons with one unified system. All collectible items become `InventoryItem` entries in a single list.

#### [NEW] [InventoryItem.cs](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/ScriptableObjects/InventoryItem.cs)
- New ScriptableObject that holds: `itemName`, `icon` (Sprite), `worldPrefab` (GameObject), `itemCategory` (enum: ChessPiece, Fuse, Key, Valve, Keycard, General)
- Replace [ChessPiece](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/ScriptableObjects/ChessPiece.cs#5-22), [Key](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKUIManager.cs#1002-1014), [Keycard](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKUIManager.cs#1002-1014), [Valve](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKUIManager.cs#933-945) ScriptableObjects' role as data containers. Those SOs can stay as-is, but `InventoryItem` wraps them with a reference field so existing puzzle logic can still access the typed data

#### [NEW] [PlayerInventory.cs](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/PlayerInventory.cs)
- Singleton replacing [ChessInventory](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Systems/Chess/ChessInventory.cs#6-52), [FuseInventory](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Systems/Fuse%20Box/FuseInventory.cs#6-55), [TKInventory](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKUIManager.cs#902-915), [ValveInventory](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKUIManager.cs#971-984), [KeycardInventory](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKUIManager.cs#1024-1037), `GeneratorInventory`
- `List<InventoryItem> items` (max 8 capacity)
- `AddItem(InventoryItem)`, `RemoveItem(InventoryItem)`, `HasItem(InventoryItem)`, `GetItemsByCategory(category)`
- Events: `OnItemAdded`, `OnItemRemoved` for UI to subscribe to
- `InventoryItem selectedItem` — tracks the currently selected/highlighted item

---

### Phase 2: Right-Side Panel UI

Replace fullscreen grouped inventory with a compact right-side panel.

#### [NEW] [InventorySlotWidget.cs](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Systems/Inventory/InventorySlotWidget.cs)
- Replaces [ChessSlotWidget](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Systems/Chess/ChessSlotWidget.cs#7-38)
- Has `Image icon`, `Button button`, `bool isSelected`
- `SetItem(InventoryItem)` — show icon, enable button
- `OnClick()` — marks item as selected in `PlayerInventory`, triggers auto-use if an outlet is active

#### [NEW] [InventoryPanelController.cs](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Systems/Inventory/InventoryPanelController.cs)
- Manages the side panel UI: 8 `InventorySlotWidget` slots, item name/description text at the bottom
- Subscribes to `PlayerInventory.OnItemAdded/OnItemRemoved` to refresh slots
- Methods: [Open()](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKUIManager.cs#362-372), [Close()](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKUIManager.cs#602-606), `RefreshSlots()`, `SetOutletContext(ChessFuseBoxInteractable)` — when opening for an outlet, auto-use the selected item

#### [MODIFY] [AKUIManager.cs](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKUIManager.cs)
- Remove all grouped inventory container fields (`themedKeyUI`, `valveUI`, `chessPuzzleUI`, `keycardUI`, `fuseboxUI`, `generatorUI`, all container fields, all slot arrays)
- Remove methods: [EnabledChessPuzzleUIContainer](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKUIManager.cs#622-630), [FillChessInventorySlot](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKUIManager.cs#631-641), [ResetChessInventorySlot](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKUIManager.cs#642-646), [EnabledThemedKeyUIContainer](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKUIManager.cs#893-901), [FillTKInventorySlot](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKUIManager.cs#902-915), [ResetTKInventorySlot](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKUIManager.cs#916-930), [EnabledValveUIContainer](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKUIManager.cs#946-954), [FillValveInventorySlot](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKUIManager.cs#971-984), [ResetValveInventorySlot](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKUIManager.cs#985-999), [DisableUIContainers](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKUIManager.cs#535-542), [FuseCollected](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKUIManager.cs#1055-1067), [UpdateFuseCountUI](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKUIManager.cs#1067-1072), etc.
- [OpenInventoryUI](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKUIManager.cs#362-372) / [CloseInventoryUI](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKUIManager.cs#373-384) now delegate to `InventoryPanelController.Open/Close`
- Add `OpenInventoryForOutlet(ChessFuseBoxInteractable)` — opens panel in "outlet selection" mode
- **Keep**: prompt system, crosshair, examine UI, post-processing, flashlight HUD, gas mask HUD, health HUD (these are HUD elements, not inventory)

---

### Phase 3: Inspect-to-Pickup for Plug Items

Items sitting in puzzle outlets (chess fuseboxes) use the **existing [ExaminableItem](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Systems/Examine/ExaminableItem.cs#18-461) examine system** — the player inspects the item in the outlet, and during inspection can press the collect key to pick it up. This replaces the current "open inventory → press back button to retrieve" flow.

The existing examine system already supports this via the `isCollectable` flag on [ExaminableItem](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Systems/Examine/ExaminableItem.cs#18-461) — when true, the player can press `pickupItemKey` during examination to trigger [CollectItem()](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Systems/Examine/ExaminableItem.cs#423-439) → [DropObject(false)](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Systems/Examine/ExaminableItem.cs#238-259) (which removes it from the world).

#### [MODIFY] [ChessFuseBoxInteractable.cs](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Systems/Chess/ChessFuseBoxInteractable.cs)
- When a fuse is already placed and the player interacts:
  - **Trigger the `ExaminableItem.ExamineObject()` flow** on the spawned fuse object — player sees the item up close with name/description, rotate it, and has the option to collect it (press pickup key)
  - On collect: remove from outlet, add to `PlayerInventory`, destroy the spawned visual
  - Remove the [RemoveFuseButton](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKUIManager.cs#647-655) / [OpenInventoryFusebox](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKUIManager.cs#656-662) menu-based retrieval flow
- Add an [ExaminableItem](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Systems/Examine/ExaminableItem.cs#18-461) component on the spawned fuse prefab (or configure it at spawn time) with `isCollectable = true`

#### [MODIFY] [ChessItem.cs](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Systems/Chess/ChessItem.cs)
- [HandleInputClick](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKItem.cs#224-233) for Fusebox type: check if fuse is placed → trigger examine on the placed fuse. If empty → open inventory for outlet selection

---

### Phase 4: Auto-Use on Chess Outlets (with Error Feedback)

When interacting with an empty chess outlet, open the inventory side panel. Selecting an item attempts to place it.

**RE-style error handling:** In Resident Evil, using the wrong item on a puzzle shows a brief dismissive text like *"It doesn't fit here"* or *"That doesn't work"*. The item stays in inventory and the player can try again or cancel. We'll follow the same pattern:
- **Wrong item selected** → show a brief text prompt at the bottom of the screen (e.g. *"That doesn't fit here..."*), item remains in inventory, outlet panel stays open so the player can try another item or cancel
- **Correct item selected** → place it, close panel, play insert sound

#### [MODIFY] [InventorySlotWidget.cs](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Systems/Inventory/InventorySlotWidget.cs)
- `OnClick()` checks if `InventoryPanelController.ActiveOutlet != null`
  - If yes → calls `ActiveOutlet.TryPlaceFuse(item)` which returns success/fail
    - **Success**: removes item from inventory, closes panel
    - **Fail**: shows error text prompt ("That doesn't fit here..."), panel stays open
  - If no → just selects the item for general use

#### [MODIFY] [ChessFuseBoxInteractable.cs](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Systems/Chess/ChessFuseBoxInteractable.cs)
- [InteractFuseBox()](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Systems/Chess/ChessFuseBoxInteractable.cs#47-53) now calls `AKUIManager.instance.OpenInventoryForOutlet(this)` instead of [OpenInventoryFusebox](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKUIManager.cs#656-662)
- Add `bool TryPlaceFuse(InventoryItem item)` — returns `true` if the item matches `chessPieceScriptable`, `false` otherwise. On success, calls existing [PlaceFuse()](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Systems/Chess/ChessFuseBoxInteractable.cs#69-83) logic

#### [MODIFY] [AKUIManager.cs](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKUIManager.cs)
- Add `ShowErrorPrompt(string message, float duration)` — displays a temporary text message (e.g. 2 seconds) at the bottom of the screen, then auto-hides. Uses a simple coroutine with a `TMP_Text` element

---

### Phase 5: Input Rebinding

#### [MODIFY] [AKInputManager.cs](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKInputManager.cs)
- Change default values (to be set in Inspector):
  - `toggleInventoryKey` → `KeyCode.Tab`
  - `closeInventoryKey` → `KeyCode.Tab` (same key toggles)
  - `mainInteractionKey` → `KeyCode.F`
  - Add `cancelKey` → `KeyCode.Space`
- Mouse inputs handled in [AKInteractor](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKInteractor.cs#5-100): Left Click = interact, Right Click = cancel/back

#### [MODIFY] [AKInteractor.cs](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKInteractor.cs)
- Add Left Click (`Mouse0`) as alternate interact in [HandleInput()](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKInteractor.cs#66-84)
- Add Right Click (`Mouse1`) as cancel/back

#### [MODIFY] [AKUIManager.cs](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKUIManager.cs)
- [Update()](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Systems/Examine/ExaminableItem.cs#182-191): inventory toggle via Tab, close also via Tab (already a toggle). Add Right Click / Space as close/cancel

---

### Files That Will Need Inventory Call Updates

These files currently call the old per-system inventory methods and will need updating to use `PlayerInventory`:

| File | Current Call | New Call |
|------|-------------|----------|
| [ChessFuseCollectable.cs](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Systems/Chess/ChessFuseCollectable.cs) | `ChessInventory.instance.AddChessPiece()` | `PlayerInventory.instance.AddItem()` |
| [ChessFuseBoxInteractable.cs](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Systems/Chess/ChessFuseBoxInteractable.cs) | `ChessInventory.instance.RemoveChessPiece()` / [AddChessPiece()](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Systems/Chess/ChessInventory.cs#32-41) | `PlayerInventory.instance.RemoveItem()` / `AddItem()` |
| [FuseInventory.cs](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Systems/Fuse%20Box/FuseInventory.cs) | Self-contained count | Wrap or replace with `PlayerInventory` |
| [FuseboxController.cs](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Systems/Fuse%20Box/FuseboxController.cs) | `FuseInventory.instance.inventoryFuses` | `PlayerInventory.instance.GetItemsByCategory(Fuse).Count` |

---

## Verification Plan

### Manual Verification (Unity Editor)

Since this is a Unity project with no existing automated tests and heavy reliance on Inspector-wired references, verification must be manual:

1. **Inventory Panel Opens/Closes**: Press Tab → side panel appears on right side, game world still visible. Press Tab again → closes. Press Space or Right Click → also closes.
2. **Items Populate Correctly**: Pick up chess pieces, fuses, keys → they appear as individual items in the 8 slots (no grouping).
3. **8-Slot Limit**: Pick up 8+ items → 9th item cannot be added (or some overflow behavior TBD with user).
4. **Plug Direct Pickup**: Walk up to a chess outlet that has a piece in it → press F/Left Click → piece goes directly into inventory. No inventory UI pops up, no back button. 
5. **Chess Outlet Auto-Use**: Walk up to an empty chess outlet → press F/Left Click → inventory panel opens on right side → click an item → item is placed into the outlet automatically, panel closes.
6. **Controls**: F and Left Click both interact. Right Click and Space both cancel/close. Tab opens/closes inventory.
7. **HUD Elements Unchanged**: Flashlight indicator, gas mask visor, health bar, crosshair — all still work as before.

> [!TIP]
> I recommend implementing and testing **one phase at a time** in the Unity Editor. Phase 1 (data layer) can compile-check, Phase 2 (UI) needs a new Canvas setup in the Scene, Phases 3-5 modify interaction flows.
