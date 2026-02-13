using UnityEngine;
using AdventurePuzzleKit.ChessSystem;
using AdventurePuzzleKit.ValveSystem;
using AdventurePuzzleKit.KeycardSystem;
using AdventurePuzzleKit.ThemedKey;

namespace AdventurePuzzleKit
{
    public enum ItemCategory { ChessPiece, Fuse, Key, Valve, Keycard, General }

    [CreateAssetMenu(menuName = "Adventure Kit/Inventory Item")]
    public class InventoryItem : ScriptableObject
    {
        [Header("Display")]
        public string itemName;
        public Sprite icon;

        [Header("World")]
        public GameObject worldPrefab;

        [Header("Classification")]
        public ItemCategory category;

        [Header("Typed Back-References (set the one matching category)")]
        [Tooltip("Set when category == ChessPiece")]
        public ChessPiece chessPiece;

        [Tooltip("Set when category == Valve")]
        public Valve valve;

        [Tooltip("Set when category == Keycard")]
        public Keycard keycard;

        [Tooltip("Set when category == Key")]
        public Key key;
    }
}
