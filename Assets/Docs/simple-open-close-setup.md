# SimpleOpenClose Interaction Setup

How to make an Atmospheric House `SimpleOpenClose` object (door, drawer, cabinet, etc.) work with the Adventure Puzzle Kit interaction system.

## Per-Object Setup

1. **Tag** — Set the GameObject's tag to `InteractiveObject`
2. **Collider** — Ensure the object has a `Collider` (Box, Mesh, etc.) for the interaction raycast
3. **SimpleOpenClose** — Should already be attached (from the Atmospheric House asset). If not, add it and configure its Animator
4. **AKItem** — Add an `AKItem` component:
   - **System Type** → `SimpleOpenCloseSys`
   - **Show Name Highlight** → ✅ enabled
   - **Highlight Name** → e.g. "Door", "Drawer", "Cabinet"
   - **Show Interact Prompt** → ✅ enabled (shows "E - Interact" when looking at it)
   - **Show Emission Highlight** → optional, enables glow effect when looking at the object

## How It Works

- `AKInteractor` raycasts from the camera → hits a collider tagged `InteractiveObject` → finds the `AKItem` component
- `AKItem` shows the highlight name and prompts, then dispatches input to the `SimpleOpenClose` script
- `SimpleOpenClose.HandleInputClick()` calls `ObjectClicked()`, which plays the Open/Close animation
