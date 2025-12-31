using UnityEngine;
using AdventurePuzzleKit;

/// <summary>
/// Log system item used by AKItem when SystemType is set to LogSys.
/// Handles picking up a single wood log into the PlayerInventory.
/// </summary>
public class LogItem : MonoBehaviour, IInteractable
{
    [Tooltip("Reference to the player's inventory. If left empty, it will be found at runtime.")]
    [SerializeField] private PlayerInventory playerInventory;

    private void Awake()
    {
        if (playerInventory == null)
        {
            playerInventory = FindObjectOfType<PlayerInventory>();
        }
    }

    public void StartLooking()
    {
        // No special behaviour needed for now.
    }

    public void StopInteraction()
    {
        // No special behaviour needed for now.
    }

    public void HandleInputClick()
    {
        if (playerInventory == null)
        {
            Debug.LogWarning("LogItem: No PlayerInventory found in the scene.");
            return;
        }

        if (playerInventory.TryPickupWood())
        {
            gameObject.SetActive(false);
        }
    }

    public void HandleInputHold()
    {
        // Not used for simple pickup.
    }

    public void HandleInputStop()
    {
        // Not used for simple pickup.
    }
}

