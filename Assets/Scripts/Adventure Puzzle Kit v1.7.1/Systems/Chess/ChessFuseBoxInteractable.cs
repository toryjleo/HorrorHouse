using UnityEngine;
using AdventurePuzzleKit.ExamineSystem;

namespace AdventurePuzzleKit.ChessSystem
{
    public class ChessFuseBoxInteractable : MonoBehaviour, IOutletContext
    {
        [Header("Fuse Box Type")]
        [SerializeField] private ChessPiece chessPieceScriptable = null; // The correct fuse type that powers this box

        [Header("Started with a fuse?")]
        [SerializeField] private bool fusePlaced;                        // Whether this box starts with a fuse
        [SerializeField] private ChessPiece starterFuseScriptable = null; // The starting fuse (if any)

        [Header("Fuse Spawn Location")]
        [SerializeField] private Transform fuseLocation = null;          // Where the fuse should be spawned
        [SerializeField] private Vector3 spawnOffset = Vector3.zero;     // Position offset for the fuse object
        [SerializeField] private Quaternion fuseRotation = Quaternion.identity; // Rotation for the placed fuse

        [Header("Light Object")]
        [SerializeField] private Renderer fuseBoxLightRend = null;       // The light renderer used for color feedback

        [Header("Power Manager")]
        [SerializeField] private ChessPowerManager powerManager = null;  // Reference to the master manager that tracks fuse status

        [Header("Audio")]
        [SerializeField] private Sound insertFuseSound = null;           // Sound when inserting or removing a fuse

        // Private fields
        private GameObject spawnedFuse;          // The visual fuse object in the scene
        private bool isPowered;                 // Whether this box is currently powered
        private Material fuseBoxLightMaterial;  // Material instance for changing fuse light color

        public ChessPiece currentFuse { get; set; } // The currently placed fuse (if any)

        private void Awake()
        {
            // Cache the material first — SpawnFuse needs it
            fuseBoxLightMaterial = fuseBoxLightRend.material;

            // If this box starts with a fuse, spawn it at the beginning
            if (fusePlaced)
            {
                SpawnFuse(starterFuseScriptable);
            }
        }

        // Called when the player interacts with the fuse box
        public void InteractFuseBox()
        {
            if (fusePlaced && spawnedFuse != null)
            {
                // Occupied: examine the placed piece so player can collect it
                var examine = spawnedFuse.GetComponent<ExaminableItem>();
                if (examine != null)
                {
                    examine.ExamineObject();
                    return;
                }
            }

            // Empty: open inventory for placement
            AKUIManager.instance.OpenInventoryFusebox(this);
        }

        // ── IOutletContext ──────────────────────────────────────────────

        public bool TryPlaceItem(InventoryItem item)
        {
            if (fusePlaced) return false;
            if (item == null || item.category != ItemCategory.ChessPiece || item.chessPiece == null)
                return false;

            PlaceFuse(item.chessPiece);
            return true;
        }

        public void OnCancel() { /* No cleanup needed for chess outlets */ }

        // Check if the currently placed fuse is the correct one
        public void CheckFuseBox(ChessPiece fuseType)
        {
            bool wasPowered = isPowered;

            // Set powered state depending on whether the correct fuse is inserted
            isPowered = fuseType == chessPieceScriptable;

            // Only update fuse count if power state changed
            if (wasPowered != isPowered)
            {
                powerManager.UpdateFuseCount(isPowered);
            }
        }

        // Called when the player places a fuse into the box
        public void PlaceFuse(ChessPiece fuseType)
        {
            if (!fusePlaced)
            {
                fusePlaced = true;
                SpawnFuse(fuseType);                           // Create the visual fuse
                ChessInventory.instance.RemoveChessPiece(fuseType); // Remove it from the inventory
                CheckFuseBox(fuseType);                        // Check if it's the correct one
            }

            // Play audio feedback
            AKAudioManager.instance.Play(insertFuseSound);
        }

        // Instantiates the fuse object in the world and sets it visually
        private void SpawnFuse(ChessPiece fuseType)
        {
            currentFuse = fuseType;

            // Update the light to green when a fuse is placed
            fuseBoxLightMaterial.color = Color.green;

            // Instantiate and align in local space so rotation follows the fuse location.
            spawnedFuse = Instantiate(fuseType.ChessPrefab, fuseLocation.transform);
            spawnedFuse.transform.localPosition = spawnOffset;
            spawnedFuse.transform.localRotation = fuseRotation;

            // Configure ExaminableItem so the placed piece can be examined & collected
            var examine = spawnedFuse.GetComponent<ExaminableItem>();
            if (examine == null)
                examine = spawnedFuse.AddComponent<ExaminableItem>();

            examine.isCollectable = true;

            // Ensure there's a collider for the examine raycast
            if (spawnedFuse.GetComponent<Collider>() == null)
                spawnedFuse.AddComponent<BoxCollider>();

            // Wire custom collect: remove from outlet + add back to inventory
            examine.SetCollectAction(() => OnPlugCollected(fuseType));
        }

        // Called when the player collects a piece from this outlet via examine
        private void OnPlugCollected(ChessPiece fuseType)
        {
            fusePlaced = false;
            fuseBoxLightMaterial.color = Color.red;

            // Return to inventory via adapter (flows through to PlayerInventory)
            ChessInventory.instance.AddChessPiece(fuseType);

            // Destroy the placed visual
            Destroy(spawnedFuse);

            // Update power logic
            CheckFuseBox(null);

            // Play audio feedback
            AKAudioManager.instance.Play(insertFuseSound);
        }

        // Called when the player removes a fuse from the box
        public void RemoveFuse(ChessPiece fuseType)
        {
            if (fusePlaced)
            {
                fusePlaced = false;

                // Set light back to red to show it's inactive
                fuseBoxLightMaterial.color = Color.red;

                // Return the fuse to the inventory
                ChessInventory.instance.AddChessPiece(fuseType);

                // Destroy the placed fuse object
                Destroy(spawnedFuse);

                // Update power logic
                CheckFuseBox(null);

                // Play audio feedback
                AKAudioManager.instance.Play(insertFuseSound);
            }
        }

        // Cleanup if this object is destroyed
        private void OnDestroy()
        {
            Destroy(fuseBoxLightRend);
        }
    }
}
