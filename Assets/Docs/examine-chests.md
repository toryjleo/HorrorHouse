This doc outlines what you need to set up a chest (or any interactable box) for the Examine system.

## Core components
- **ExaminableItem.cs** is the main script that drives examining. It can live on the model itself or on an empty parent object. If you use an empty parent, enable **Empty Parent** on the component.
- **Inspect points** are empty GameObjects that define spots the player can examine. Each inspect point must have **ExamineInspectPoint.cs** attached.
  - **ExamineInspectPoint.cs** includes a description string and an interaction event hook.
  - Any object with **ExamineInspectPoint.cs** must be on the **InspectPoint** layer.

## Reveal setup (optional)
- **InspectReveal** can be triggered to hide one object and show another (useful for secret compartments, hidden items, etc.).

## Quick checklist
- ExaminableItem.cs placed on model or empty parent (and **Empty Parent** enabled if needed).
- One or more inspect points with **ExamineInspectPoint.cs**.
- Inspect points are on the **InspectPoint** layer.
- Optional: InspectReveal configured for swap/reveal behavior.
