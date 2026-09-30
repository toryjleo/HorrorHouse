This doc outlines what you need to set up a chest (or any interactable box) for the Examine system.

## Core components
- **ExaminableItem.cs** is the main script that drives examining. It can live on the model itself or on an empty parent object. If you use an empty parent, enable **Empty Parent** on the component.
- **AKItem.cs** must be used alongside ExaminableItem on the same object.
- **Box Collider** is required on the same object as ExaminableItem and AKItem.
- **Inspect points** are empty GameObjects that define spots the player can examine. Each inspect point must have **ExamineInspectPoint.cs** attached.
  - **ExamineInspectPoint.cs** includes a description string and an interaction event hook.
  - Any object with **ExamineInspectPoint.cs** must be on the **InspectPoint** layer.

## Reveal setup (optional)
- **InspectReveal** can be triggered to hide one object and show another (useful for secret compartments, hidden items, etc.).
- ExamineInspectPoints are disabled by default. Turned on at inspection
- Make an empty parent for inspect point to turn on. The model and the actual ExamineInspectPoints gameobject can be seperate children
- **Box Collider** placed on InspectPoint object and object tagged as "InspectPoint".

## Quick checklist
- ExaminableItem.cs placed on model or empty parent (and **Empty Parent** enabled if needed).
- AKItem placed on model or empty parent (and **Empty Parent** enabled if needed).
- Box Collider on the same object as ExaminableItem and AKItem.
- Parent object tagged as **InteractiveObject**
- One or more inspect points with **ExamineInspectPoint.cs**.
- Inspect points are on the **InspectPoint** layer.
- Optional: InspectReveal configured for swap/reveal behavior.
- Make sure Inspect Points are a good sixe
