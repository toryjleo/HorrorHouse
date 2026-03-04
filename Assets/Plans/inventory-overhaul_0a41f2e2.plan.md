---
name: inventory-overhaul
overview: Overhaul inventory to add a Resident Evil–style action dropdown, data-driven item actions, combine flow, and 3D examine viewer integration aligned with AKInteractor/AKItem.
todos:
  - id: inventory-data
    content: Extend item data to include action lists, icons, and 3D examine prefab references.
    status: pending
  - id: action-menu-ui
    content: Implement the dropdown action menu UI and input flow (Select/Back/Combine), aligned with AKUIManager prompts.
    status: pending
  - id: action-router
    content: Create an InventoryActionRouter for Use/Combine/Examine/Custom actions with safe fallbacks.
    status: pending
  - id: combine-recipes
    content: Define combine recipes (ScriptableObject database) and implement combine selection + validation.
    status: pending
  - id: examine-viewer
    content: Hook inventory items to the 3D viewer and enable item-specific interaction points in examine mode.
    status: pending
  - id: cassette-bridge
    content: Add a bridge so cassette examine actions can call the cassette player system (Play/Stop/Eject/Rewind) or show “No Player.”
    status: pending
  - id: ux-feedback
    content: Add rejection messaging for invalid combines and wrong-context actions; ensure selection state is preserved.
    status: pending
isProject: false
---

### Goals

- **AKInteractor-aligned flow** for inventory actions.
- **Dropdown action menu** per item (Use/Combine/Examine/Custom).
- **Item combination** via data-driven recipes.
- **3D examine mode** with item-specific interaction points.

### High-level approach

- Extend item definitions with action lists and viewer prefabs.
- Build a compact action menu and action router.
- Implement combine selection and recipe validation.
- Integrate the 3D viewer and pass interaction points to item scripts.
- Add the cassette action bridge and clean UX rejection feedback.
