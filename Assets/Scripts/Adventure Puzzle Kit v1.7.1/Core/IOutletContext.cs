namespace AdventurePuzzleKit
{
    /// <summary>
    /// Generic outlet interface. Any interactable that accepts items from
    /// the inventory panel implements this so placement is not system-specific.
    /// </summary>
    public interface IOutletContext
    {
        /// <summary>
        /// Attempt to place an item into this outlet.
        /// Returns true if the item was accepted (placed), false if rejected (wrong type).
        /// </summary>
        bool TryPlaceItem(InventoryItem item);

        /// <summary>
        /// Called when the player closes the panel without placing anything.
        /// </summary>
        void OnCancel();
    }
}
