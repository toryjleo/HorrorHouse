using UnityEngine;

namespace AdventurePuzzleKit.ChessSystem
{
    // Allows interaction with chess-related objects (fuse piece, fuse box, or return point)
    public class ChessItem : MonoBehaviour, IInteractable
    {
        [SerializeField] private ItemType _itemType = ItemType.None;
        private enum ItemType { None, ChessFuse, Fusebox, ReturnPoint }

        // References to specific interactable components
        private ChessFuseCollectable _fuseCollectable;
        private ChessFuseBoxInteractable _fuseboxInteractable;
        private ChessPieceReturnPoint _returnPoint;

        private void Awake()
        {
            // Cache appropriate component based on item type
            switch (_itemType)
            {
                case ItemType.ChessFuse:
                    if (!TryGetComponent(out _fuseCollectable))
                    {
                        Debug.LogWarning($"Chess Item '{gameObject.name}' is set to ChessFuse but has no ChessFuseCollectable attached.");
                    }
                    break;
                case ItemType.Fusebox:
                    if (!TryGetComponent(out _fuseboxInteractable))
                    {
                        Debug.LogWarning($"Chess Item '{gameObject.name}' is set to Fusebox but has no ChessFuseBoxInteractable attached.");
                    }
                    break;
                case ItemType.ReturnPoint:
                    if (!TryGetComponent(out _returnPoint))
                    {
                        Debug.LogWarning($"Chess Item '{gameObject.name}' is set to ReturnPoint but has no ChessPieceReturnPoint attached.");
                    }
                    break;
            }
        }

        public void StartLooking() { }

        public void StopInteraction() { }

        public void HandleInputClick()
        {
            switch (_itemType)
            {
                case ItemType.ChessFuse:
                    _fuseCollectable?.PickupChessPiece();
                    break;
                case ItemType.Fusebox:
                    _fuseboxInteractable?.InteractFuseBox();
                    break;
                case ItemType.ReturnPoint:
                    _returnPoint?.HandleInputClick();
                    break;
            }
        }

        public void HandleInputHold() { }

        public void HandleInputStop() { }
    }
}
