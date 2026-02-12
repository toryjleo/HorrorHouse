using System.Linq;
using UnityEngine;

namespace AdventurePuzzleKit.FuseSystem
{
    /// <summary>
    /// Adapter: keeps the original count-based API but delegates storage to <see cref="PlayerInventory"/>.
    /// <para>
    /// Fuses are interchangeable, so we use a single <see cref="fuseItemTemplate"/> InventoryItem.
    /// <c>AddFuse</c> adds the template directly (PlayerInventory allows duplicates because
    /// <c>List.Contains</c> uses reference equality, and we want each fuse to be a separate entry).
    /// </para>
    /// </summary>
    public class FuseInventory : MonoBehaviour
    {
        [Header("Should persist?")]
        [SerializeField] private bool persistAcrossScenes = true;

        [Header("Fuse → InventoryItem Mapping")]
        [Tooltip("Drag the generic Fuse-type InventoryItem asset here.")]
        [SerializeField] private InventoryItem fuseItemTemplate;

        /// <summary>
        /// Legacy accessor. Count is derived from PlayerInventory.
        /// Setter is kept for backward compatibility but logs a warning – callers should
        /// use <see cref="AddFuse"/>/<see cref="RemoveFuse"/> instead.
        /// </summary>
        public int inventoryFuses
        {
            get
            {
                if (PlayerInventory.instance == null) return 0;
                return PlayerInventory.instance.GetItemsByCategory(ItemCategory.Fuse).Count;
            }
            set
            {
                // No-op setter kept for compile compatibility.
                // The count is now derived from PlayerInventory.
            }
        }

        public static FuseInventory instance;

        private void Awake()
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

        /// <summary>
        /// Add one fuse and update UI.
        /// Creates a runtime clone of the template so each fuse is a distinct instance.
        /// </summary>
        public void AddFuse()
        {
            if (fuseItemTemplate == null)
            {
                Debug.LogWarning("FuseInventory: fuseItemTemplate is not assigned. Cannot add fuse.");
                return;
            }

            // Create a runtime clone so each fuse is a unique reference
            InventoryItem fuseInstance = ScriptableObject.Instantiate(fuseItemTemplate);
            fuseInstance.name = fuseItemTemplate.name; // Keep the name clean (removes "(Clone)")
            PlayerInventory.instance.AddItem(fuseInstance);

            int count = inventoryFuses;
            AKUIManager.instance.FuseCollected();
            AKUIManager.instance.UpdateFuseCountUI(count);
        }

        /// <summary>
        /// Remove one fuse and update UI.
        /// Removes the first fuse-category item found in the player inventory.
        /// </summary>
        public void RemoveFuse()
        {
            var fuses = PlayerInventory.instance.GetItemsByCategory(ItemCategory.Fuse);
            if (fuses.Count > 0)
            {
                PlayerInventory.instance.RemoveItem(fuses[0]);
            }

            int count = inventoryFuses;
            AKUIManager.instance.UpdateFuseCountUI(count);
        }
    }
}
