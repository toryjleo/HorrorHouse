# Reminder: Examine Before Pickup

To require examination before pickup (no runtime prompt changes):
- Add `ExaminableItem` and set `Is Collectable` + correct `System Type`.
- Set `AKItem.System Type` to `None` so E does not pick up directly.
- Enable `AKItem.Show Examine Prompt` and disable `Show Pickup Prompt`.

Detailed steps: `Docs/examine-before-pickup.md`.
