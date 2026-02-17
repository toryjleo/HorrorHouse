using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace AdventurePuzzleKit
{
    /// <summary>
    /// Central inventory singleton. Holds up to <see cref="maxSlots"/> InventoryItems
    /// and fires events so UI and gameplay systems can react.
    /// </summary>
    public class PlayerInventory : MonoBehaviour
    {
        [Header("Should persist?")]
        [SerializeField] private bool persistAcrossScenes = true;

        [Header("Capacity")]
        [SerializeField] private int maxSlots = 8;

        // ── Runtime state ──────────────────────────────────────────────
        private readonly List<InventoryItem> _items = new List<InventoryItem>();
        private InventoryItem _selectedItem;

        // ── Public read-only access ────────────────────────────────────
        public IReadOnlyList<InventoryItem> Items => _items;
        public int MaxSlots => maxSlots;
        public bool IsFull => _items.Count >= maxSlots;

        public InventoryItem SelectedItem
        {
            get => _selectedItem;
            set
            {
                if (_selectedItem == value) return;
                _selectedItem = value;
                OnSelectionChanged?.Invoke(_selectedItem);
            }
        }

        // ── Events ─────────────────────────────────────────────────────
        public event Action<InventoryItem> OnItemAdded;
        public event Action<InventoryItem> OnItemRemoved;
        public event Action<InventoryItem> OnSelectionChanged;

        // ── Audio ──────────────────────────────────────────────────────
        [Header("Audio")]
        [Tooltip("Sound played when any item is picked up.")]
        [SerializeField] private Sound pickupSound;

        // ── Singleton ──────────────────────────────────────────────────
        public static PlayerInventory instance;

        private void Awake()
        {
            if (instance != null)
            {
                Destroy(gameObject);
                return;
            }

            instance = this;
            if (persistAcrossScenes)
            {
                DontDestroyOnLoad(gameObject);
            }
        }

        // ── Core API ───────────────────────────────────────────────────

        /// <summary>
        /// Attempts to add an item. Returns false if the inventory is full.
        /// </summary>
        public bool AddItem(InventoryItem item)
        {
            if (item == null)
            {
                Debug.LogWarning("PlayerInventory.AddItem called with null item.");
                return false;
            }

            if (IsFull)
            {
                Debug.Log($"Inventory full ({maxSlots}/{maxSlots}). Cannot add '{item.itemName}'.");
                return false;
            }

            _items.Add(item);
            OnItemAdded?.Invoke(item);

            if (pickupSound != null)
                AKAudioManager.instance.Play(pickupSound);

            return true;
        }

        /// <summary>
        /// Removes the first occurrence of the item. Returns false if not found.
        /// </summary>
        public bool RemoveItem(InventoryItem item)
        {
            if (item == null) return false;

            if (_items.Remove(item))
            {
                // Clear selection if the removed item was selected
                if (_selectedItem == item)
                {
                    SelectedItem = null;
                }

                OnItemRemoved?.Invoke(item);
                return true;
            }

            return false;
        }

        /// <summary>
        /// Checks whether the inventory contains the given item.
        /// </summary>
        public bool HasItem(InventoryItem item)
        {
            return item != null && _items.Contains(item);
        }

        /// <summary>
        /// Returns all items matching the given category.
        /// </summary>
        public List<InventoryItem> GetItemsByCategory(ItemCategory category)
        {
            return _items.Where(i => i.category == category).ToList();
        }
    }
}
