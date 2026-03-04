# Inventory Overhaul – Design & Implementation Plan

## 1. Overview

Create an **inventory overhaul** that:

- **Reuses** the existing `AKInteractor` / `AKItem` interaction pipeline and UI feel.
- Adds a **Resident Evil–style dropdown menu** per item (Use / Combine / Examine / etc.).
- Supports **item combination** and **contextual actions** (e.g., tapes can Play/Stop/Eject when examined).
- Leverages the **3D viewer interaction system** for examine/inspect mode.

Target: Unity project using **Adventure Puzzle Kit v1.7.1** (e.g. `AKInteractor`, `AKItem`, `AKUIManager`).

---

## 2. Goals & Non‑Goals

### 2.1 Goals

- **AKInteractor‑aligned flow**: Inventory interactions feel like an extension of the world interaction system (same prompts, same routing, same mental model).
- **Dropdown action menu**: Each inventory item presents a small contextual menu (Resident Evil style).
- **Item combination**: Combine two items into a new item or state (e.g., “Battery + Tape Player → Powered Tape Player”).
- **3D inspect mode**: Examine an item using the existing 3D viewer, with optional per‑item interactions (play/stop/eject for tapes).
- **Modular & data‑driven**: Item actions come from data, not hardcoded per item.

### 2.2 Non‑Goals (initial iteration)

- No full grid‑based inventory layout overhaul unless needed.
- No save/load revamp beyond existing item state persistence.
- No complex crafting trees or multi‑step recipes.

---

## 3. Existing Systems to Integrate With

- `AKInteractor` – world raycast + input routing.
- `AKItem` – item metadata and interaction routing.
- `AKUIManager` – prompt display and UI hooks.
- 3D viewer / inspect system – used for item examination and special actions.

---

## 4. Core UX Flow

### 4.1 Inventory Interaction (High Level)

1. Player opens inventory and highlights an item.
2. A **dropdown menu** appears next to the item with contextual actions.
3. Selecting an action triggers one of:
   - **Use** (consume/activate item)
   - **Combine** (choose second item, resolve recipe)
   - **Examine** (enter 3D viewer/inspect mode)
   - **Custom** (e.g., Play/Stop/Eject for tapes)

### 4.2 Examine Flow (3D Viewer)

- When **Examine** is chosen, the item is displayed in the 3D viewer.
- The viewer can expose **item‑specific buttons** (e.g., Play/Stop/Eject for cassette items).
- Exiting examine returns to the inventory menu without losing selection.

---

## 5. Data Model & Extensibility

### 5.1 Inventory Item Definition

Add or extend item data to include:

- `itemId` (string)
- `displayName`
- `icon`
- `itemPrefab` (for 3D examine)
- `actions` (list of action definitions)

### 5.2 Action Definition (Data‑Driven)

Define an `ItemAction` structure, e.g.:

- `ActionType` enum: `Use`, `Combine`, `Examine`, `Custom`
- `label` (e.g., "Use", "Combine", "Examine", "Play")
- `requiredContext` (optional: e.g., requires cassette player in scene)
- `customHandlerId` (for item‑specific scripts)

### 5.3 Combine Recipes

Define a `CombineRecipe` structure:

- `inputA`, `inputB` (unordered)
- `resultItemId`
- `consumeInputs` (bool)
- `resultState` (optional metadata)

This can live in a ScriptableObject database for easy tuning.

---

## 6. UI & Interaction Integration

### 6.1 Dropdown Menu (Resident Evil Style)

- Appears near the selected item slot.
- Highlights the current option with a simple selector.
- Supports keyboard/controller + mouse.
- Keep it small and fast: 3–5 options per item.

### 6.2 AKInteractor Alignment

- The inventory menu should **reuse** the same input bindings where possible.
- Use similar **prompt text** conventions (e.g., “Select”, “Back”, “Combine”).
- Avoid introducing a parallel UI style that feels disconnected from world interactions.

---

## 7. Item‑Specific Behavior Examples

### 7.1 Cassette Tape Item

Actions:
- `Examine` → open 3D viewer.
- `Play` / `Stop` / `Eject` (only in examine mode).

Behavior:
- In examine mode, the tape can trigger the cassette player system if a player device is available.
- If no player exists, show disabled or “No Player” feedback.

### 7.2 Key Items

Actions:
- `Use` → consume or set a progression flag.
- `Combine` → if valid recipe exists.
- `Examine` → optional (e.g., clue text).

---

## 8. Implementation Steps (for another agent)

1. **Inventory action data**
   - Extend item data to include a list of actions.
   - Build a simple database or ScriptableObject for item definitions.

2. **Dropdown menu UI**
   - Implement a compact action menu that appears near selected item.
   - Support input navigation and selection.
   - Hook up to `AKUIManager` for consistent prompts.

3. **Action routing**
   - Create an `InventoryActionRouter` that maps action selection → handler.
   - Built‑in handlers: `Use`, `Combine`, `Examine`.
   - Custom handler hooks for item‑specific logic.

4. **Combine flow**
   - When `Combine` is chosen, prompt player to select second item.
   - Validate against recipe database.
   - Produce result item, update inventory, play feedback.

5. **Examine / 3D viewer integration**
   - Wire inventory item to spawn in viewer.
   - Allow item‑specific buttons (e.g., Play/Stop/Eject for cassette items).
   - Return to inventory with current selection preserved.

6. **Cassette action bridging**
   - Add a lightweight bridge so the tape in examine mode can call the cassette system (Play/Stop/Eject).
   - If no player is available, disable or show “Requires cassette player.”

---

## 9. Edge Cases & Behaviors

- **Combine with invalid item**: show a quick “Not combinable” message and return to menu.
- **Examine item without prefab**: fall back to static UI panel.
- **Use item in wrong context**: show feedback, don’t consume.
- **Custom actions**: safely ignore if handler missing (log warning).

---

## 9.1 Risks & Mitigations

- **Item state leakage**: when exiting examine, ensure the item’s state (inserted, playing, combined result) is explicitly committed back to inventory data. Use a single “apply state” step on exit.
- **Combine UX complexity**: clearly indicate when the player is in “combine select” mode, and provide a consistent way to cancel back to the item menu without losing selection.

---

## 10. Testing Checklist

- Inventory item menu opens and closes cleanly.
- Action list is correct per item and updates with item state.
- Combine flow works for at least one valid recipe and one invalid attempt.
- Examine mode opens with 3D viewer and returns without input lock issues.
- Cassette item actions call Play/Stop/Eject when available, and show sensible feedback when not.

---

## 11. Future Extensions (Optional)

- Grid‑based inventory layout (Resident Evil classic). 
- Item stacking and quantity actions.
- Drag‑and‑drop combine.
- Per‑item inspection hotspots (zoom to clue area).
