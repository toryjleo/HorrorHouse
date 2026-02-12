using TMPro;
using UnityEngine;
using AdventurePuzzleKit.ChessSystem;

namespace AdventurePuzzleKit
{
    /// <summary>
    /// Manages the 8-slot inventory panel. Subscribes to <see cref="PlayerInventory"/>
    /// events and keeps the slot widgets in sync with the player's items.
    /// </summary>
    public class InventoryPanelController : MonoBehaviour
    {
        [Header("Slots")]
        [Tooltip("Drag the 8 InventorySlotWidget objects here, in order.")]
        [SerializeField] private InventorySlotWidget[] _slots = new InventorySlotWidget[8];

        [Header("Item Info Display")]
        [SerializeField] private TMP_Text _itemNameText;
        [SerializeField] private TMP_Text _itemDescText;

        [Header("Panel Root")]
        [Tooltip("The root GameObject that gets enabled/disabled to show/hide the panel.")]
        [SerializeField] private GameObject _panelRoot;

        private int _selectedIndex = -1;

        // Outlet context: when non-null, clicking a chess piece auto-places it
        private ChessFuseBoxInteractable _activeOutlet;

        // ── Lifecycle ──────────────────────────────────────────────────

        private void Awake()
        {
            // Initialize each slot with its index and a reference back to this controller
            for (int i = 0; i < _slots.Length; i++)
            {
                if (_slots[i] != null)
                {
                    _slots[i].Init(i, this);
                }
            }

            // Start hidden
            if (_panelRoot != null)
            {
                _panelRoot.SetActive(false);
            }
        }

        private void OnEnable()
        {
            if (PlayerInventory.instance != null)
            {
                PlayerInventory.instance.OnItemAdded += OnInventoryChanged;
                PlayerInventory.instance.OnItemRemoved += OnInventoryChanged;
                PlayerInventory.instance.OnSelectionChanged += OnSelectionChanged;
            }
        }

        private void OnDisable()
        {
            if (PlayerInventory.instance != null)
            {
                PlayerInventory.instance.OnItemAdded -= OnInventoryChanged;
                PlayerInventory.instance.OnItemRemoved -= OnInventoryChanged;
                PlayerInventory.instance.OnSelectionChanged -= OnSelectionChanged;
            }
        }

        // ── Public API (called by AKUIManager) ─────────────────────────

        /// <summary>
        /// Shows the inventory panel and refreshes all slots.
        /// </summary>
        public void Open()
        {
            if (_panelRoot != null)
            {
                _panelRoot.SetActive(true);
            }

            RefreshSlots();
        }

        /// <summary>
        /// Hides the inventory panel and clears selection.
        /// </summary>
        public void Close()
        {
            if (_panelRoot != null)
            {
                _panelRoot.SetActive(false);
            }

            ClearSelection();
            ClearOutletContext();
        }

        public bool IsOpen => _panelRoot != null && _panelRoot.activeSelf;

        // ── Slot interaction ───────────────────────────────────────────

        /// <summary>
        /// Called by <see cref="InventorySlotWidget"/> when a slot is clicked.
        /// </summary>
        public void OnSlotClicked(int index)
        {
            if (index < 0 || index >= _slots.Length) return;

            InventoryItem item = _slots[index].Item;
            if (item == null) return;

            // If an outlet is active and the item is a chess piece, auto-place it
            if (_activeOutlet != null && item.category == ItemCategory.ChessPiece && item.chessPiece != null)
            {
                _activeOutlet.PlaceFuse(item.chessPiece);
                AKUIManager.instance.DisableInventoryFusebox();
                return;
            }

            // Toggle selection if same slot clicked again
            if (_selectedIndex == index)
            {
                ClearSelection();
                return;
            }

            SetSelection(index, item);
        }

        // ── Outlet context ─────────────────────────────────────────────

        /// <summary>
        /// Called by AKUIManager when the panel is opened for an outlet interaction.
        /// </summary>
        public void SetOutletContext(ChessFuseBoxInteractable outlet)
        {
            _activeOutlet = outlet;
        }

        /// <summary>
        /// Clears the outlet context (called on Close or after placement).
        /// </summary>
        public void ClearOutletContext()
        {
            _activeOutlet = null;
        }

        // ── Internal ───────────────────────────────────────────────────

        private void RefreshSlots()
        {
            var items = PlayerInventory.instance != null
                ? PlayerInventory.instance.Items
                : null;

            for (int i = 0; i < _slots.Length; i++)
            {
                if (_slots[i] == null) continue;

                if (items != null && i < items.Count)
                {
                    _slots[i].SetItem(items[i]);
                }
                else
                {
                    _slots[i].SetItem(null);
                }

                _slots[i].SetSelected(i == _selectedIndex);
            }
        }

        private void SetSelection(int index, InventoryItem item)
        {
            // Deselect previous
            if (_selectedIndex >= 0 && _selectedIndex < _slots.Length && _slots[_selectedIndex] != null)
            {
                _slots[_selectedIndex].SetSelected(false);
            }

            _selectedIndex = index;

            // Select new
            if (_slots[_selectedIndex] != null)
            {
                _slots[_selectedIndex].SetSelected(true);
            }

            // Update info text
            if (_itemNameText != null)
            {
                _itemNameText.text = item.itemName ?? "";
            }
            if (_itemDescText != null)
            {
                _itemDescText.text = ""; // Description field ready for future use
            }

            // Update PlayerInventory's selected item
            if (PlayerInventory.instance != null)
            {
                PlayerInventory.instance.SelectedItem = item;
            }
        }

        private void ClearSelection()
        {
            if (_selectedIndex >= 0 && _selectedIndex < _slots.Length && _slots[_selectedIndex] != null)
            {
                _slots[_selectedIndex].SetSelected(false);
            }

            _selectedIndex = -1;

            if (_itemNameText != null)
            {
                _itemNameText.text = "";
            }
            if (_itemDescText != null)
            {
                _itemDescText.text = "";
            }

            if (PlayerInventory.instance != null)
            {
                PlayerInventory.instance.SelectedItem = null;
            }
        }

        // ── Event handlers ─────────────────────────────────────────────

        private void OnInventoryChanged(InventoryItem _)
        {
            // Only refresh if the panel is currently visible
            if (IsOpen)
            {
                RefreshSlots();
            }
        }

        private void OnSelectionChanged(InventoryItem item)
        {
            // External selection changes (e.g., from auto-use) sync the UI
            if (!IsOpen) return;

            if (item == null)
            {
                ClearSelection();
                return;
            }

            // Find the slot index for this item
            for (int i = 0; i < _slots.Length; i++)
            {
                if (_slots[i] != null && _slots[i].Item == item)
                {
                    SetSelection(i, item);
                    return;
                }
            }
        }
    }
}
