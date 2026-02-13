using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace AdventurePuzzleKit.ChessSystem
{
    /// <summary>
    /// Adapter: keeps the original API but delegates storage to <see cref="PlayerInventory"/>.
    /// All existing call sites (ChessFuseCollectable, ChessFuseBoxInteractable, AKUIManager)
    /// continue to work without modification.
    /// </summary>
    public class ChessInventory : MonoBehaviour
    {
        [Header("Should persist?")]
        [SerializeField] private bool persistAcrossScenes = true;

        [Header("Chess → InventoryItem Mapping")]
        [Tooltip("Drag every ChessPiece-type InventoryItem asset here so the adapter can look up the mapping.")]
        [SerializeField] private List<InventoryItem> chessPieceMappings = new List<InventoryItem>();

        /// <summary>
        /// Legacy accessor. Rebuilds the list from PlayerInventory each time it is read.
        /// Write access is intentionally removed – use <see cref="AddChessPiece"/>/<see cref="RemoveChessPiece"/>.
        /// </summary>
        public List<ChessPiece> chessPieceList
        {
            get
            {
                if (PlayerInventory.instance == null)
                    return new List<ChessPiece>();

                return PlayerInventory.instance
                    .GetItemsByCategory(ItemCategory.ChessPiece)
                    .Where(i => i.chessPiece != null)
                    .Select(i => i.chessPiece)
                    .ToList();
            }
        }

        public static ChessInventory instance;

        void Awake()
        {
            if (instance != null)
            {
                Destroy(gameObject);
            }
            else
            {
                instance = this;
                if (persistAcrossScenes)
                {
                    DontDestroyOnLoad(gameObject);
                }
            }
        }

        // ── Mapping helpers ────────────────────────────────────────────

        private InventoryItem FindMapping(ChessPiece chessPiece)
        {
            return chessPieceMappings.FirstOrDefault(m => m != null && m.chessPiece == chessPiece);
        }

        // ── Public API (unchanged signatures) ──────────────────────────

        public void AddChessPiece(ChessPiece chessPiece)
        {
            InventoryItem mapped = FindMapping(chessPiece);
            if (mapped == null)
            {
                Debug.LogWarning($"ChessInventory: No InventoryItem mapping found for ChessPiece '{chessPiece?.name}'. Skipping add.");
                return;
            }

            if (!PlayerInventory.instance.HasItem(mapped))
            {
                PlayerInventory.instance.AddItem(mapped);
                AKUIManager.instance.FillChessInventorySlot();
                AKUIManager.instance.ChessPieceCollected();
            }
        }

        public void RemoveChessPiece(ChessPiece chessPiece)
        {
            InventoryItem mapped = FindMapping(chessPiece);
            if (mapped == null)
            {
                Debug.LogWarning($"ChessInventory: No InventoryItem mapping found for ChessPiece '{chessPiece?.name}'. Skipping remove.");
                return;
            }

            if (PlayerInventory.instance.HasItem(mapped))
            {
                PlayerInventory.instance.RemoveItem(mapped);
                AKUIManager.instance.ResetChessInventorySlot();
            }
        }
    }
}
