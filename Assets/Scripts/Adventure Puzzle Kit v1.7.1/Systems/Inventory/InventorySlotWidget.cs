using UnityEngine;
using UnityEngine.UI;

namespace AdventurePuzzleKit
{
    /// <summary>
    /// Represents a single slot in the 8-slot inventory panel.
    /// Attach to each slot GameObject in the panel prefab.
    /// </summary>
    public class InventorySlotWidget : MonoBehaviour
    {
        [SerializeField] private Button _button;
        [SerializeField] private Image _iconImage;
        [SerializeField] private Image _selectionBorder;

        private int _index;
        private InventoryPanelController _controller;
        private InventoryItem _item;

        public InventoryItem Item => _item;

        /// <summary>
        /// Called once by InventoryPanelController during initialization.
        /// </summary>
        public void Init(int index, InventoryPanelController controller)
        {
            _index = index;
            _controller = controller;
            _button.onClick.AddListener(OnClicked);
            Clear();
        }

        /// <summary>
        /// Fills the slot with an item. Pass null to clear.
        /// </summary>
        public void SetItem(InventoryItem item)
        {
            _item = item;

            if (item != null)
            {
                _iconImage.sprite = item.icon;
                _iconImage.enabled = true;
                _button.interactable = true;
            }
            else
            {
                Clear();
            }
        }

        /// <summary>
        /// Toggles the visual selection indicator.
        /// </summary>
        public void SetSelected(bool selected)
        {
            if (_selectionBorder != null)
            {
                _selectionBorder.enabled = selected;
            }
        }

        private void Clear()
        {
            _item = null;
            _iconImage.sprite = null;
            _iconImage.enabled = false;
            _button.interactable = false;
            SetSelected(false);
        }

        private void OnClicked()
        {
            _controller.OnSlotClicked(_index);
        }
    }
}
