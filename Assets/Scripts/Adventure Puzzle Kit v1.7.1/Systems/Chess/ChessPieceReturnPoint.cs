using UnityEngine;
using UnityEngine.Events;

namespace AdventurePuzzleKit.ChessSystem
{
    /// <summary>
    /// World-space interactable placed at a chess piece's original location.
    /// After the puzzle is completed, the player can return the matching piece here.
    /// Implements <see cref="IOutletContext"/> so the inventory panel can place items into it.
    /// </summary>
    public class ChessPieceReturnPoint : MonoBehaviour, IOutletContext, IInteractable
    {
        [Header("Expected Chess Piece")]
        [Tooltip("Only this piece can be placed here.")]
        [SerializeField] private ChessPiece expectedPiece = null;

        [Header("Original World Object")]
        [Tooltip("The original fuse collectable GameObject. Re-enabled when the piece is returned.")]
        [SerializeField] private GameObject originalFuseObject = null;

        // Captured automatically in OnValidate when originalFuseObject is assigned in the Inspector
        [HideInInspector] [SerializeField] private Vector3 originalPosition;
        [HideInInspector] [SerializeField] private Quaternion originalRotation;

#if UNITY_EDITOR
        private void OnValidate()
        {
            if (originalFuseObject != null)
            {
                originalPosition = originalFuseObject.transform.position;
                originalRotation = originalFuseObject.transform.rotation;
            }
        }
#endif

        [Header("Audio")]
        [SerializeField] private Sound returnSound = null;

        [Header("Events")]
        [Tooltip("Fires after the piece is placed back (e.g., close the safe for the pawn).")]
        [SerializeField] private UnityEvent onPieceReturned = null;

        private bool pieceReturned = false;

        // ── IInteractable ──────────────────────────────────────────────

        public void StartLooking() { }
        public void StopInteraction() { }

        public void HandleInputClick()
        {
            if (pieceReturned) return;

            // Open inventory with this return point as the outlet context
            AKUIManager.instance.OpenInventoryForOutlet(this);
        }

        public void HandleInputHold() { }
        public void HandleInputStop() { }

        // ── IOutletContext ──────────────────────────────────────────────

        public bool TryPlaceItem(InventoryItem item)
        {
            Debug.Log($"[ReturnPoint] TryPlaceItem called on '{gameObject.name}'. pieceReturned={pieceReturned}, item={item?.name}, expectedPiece={expectedPiece?.name}");

            if (pieceReturned) return false;
            if (item == null || item.category != ItemCategory.ChessPiece || item.chessPiece == null)
            {
                Debug.Log($"[ReturnPoint] Rejected: item null or not a chess piece. category={item?.category}, chessPiece={item?.chessPiece}");
                return false;
            }

            // Only accept the matching piece
            if (item.chessPiece != expectedPiece)
            {
                Debug.Log($"[ReturnPoint] Rejected: piece mismatch. Got '{item.chessPiece.name}', expected '{expectedPiece?.name}'");
                return false;
            }

            Debug.Log("[ReturnPoint] Piece accepted. Removing from inventory...");

            // Remove from inventory
            ChessInventory.instance.RemoveChessPiece(item.chessPiece);

            Debug.Log($"[ReturnPoint] originalFuseObject is {(originalFuseObject != null ? originalFuseObject.name : "NULL")}");

            // Restore original position/rotation and re-enable
            if (originalFuseObject != null)
            {
                originalFuseObject.transform.position = originalPosition;
                originalFuseObject.transform.rotation = originalRotation;
                originalFuseObject.SetActive(true);
                Debug.Log($"[ReturnPoint] Re-enabled '{originalFuseObject.name}' at {originalPosition}");
            }

            // Play audio
            if (returnSound != null)
                AKAudioManager.instance.Play(returnSound);

            // Mark as returned
            pieceReturned = true;

            Debug.Log("[ReturnPoint] Firing onPieceReturned event...");

            // Fire event (e.g., close the safe for the pawn)
            onPieceReturned?.Invoke();

            // Disable this trigger so it can't be interacted with again
            gameObject.tag = "Untagged";

            Debug.Log("[ReturnPoint] Done. Tag set to Untagged.");
            return true;
        }

        public void OnCancel()
        {
            // No cleanup needed — player just closed the inventory without placing
        }
    }
}
