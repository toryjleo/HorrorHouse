using UnityEngine;

public class PlayerInventory : MonoBehaviour
{
    [Header("Held Wood Settings")]
    [Tooltip("Visual shown when the player is holding a wood log.")]
    [SerializeField] private GameObject heldWoodVisual;

    public bool IsHoldingWood { get; private set; }

    private void Start()
    {
        UpdateHeldWoodVisual();
    }

    public bool TryPickupWood()
    {
        if (IsHoldingWood)
            return false;

        IsHoldingWood = true;
        UpdateHeldWoodVisual();
        return true;
    }

    public bool TryConsumeWood()
    {
        if (!IsHoldingWood)
            return false;

        IsHoldingWood = false;
        UpdateHeldWoodVisual();
        return true;
    }

    private void UpdateHeldWoodVisual()
    {
        if (heldWoodVisual != null)
        {
            heldWoodVisual.SetActive(IsHoldingWood);
        }
    }
}
