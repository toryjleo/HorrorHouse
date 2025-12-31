using System;
using UnityEngine;
using AdventurePuzzleKit;

/// <summary>
/// Stack zone that accepts wood from the PlayerInventory and
/// reveals stacked log visuals. When full, it opens a linked door.
/// </summary>
public class LogStack : MonoBehaviour, IInteractable
{
    [Header("Stack Settings")]
    [Tooltip("How many logs are required to complete the stack.")]
    [SerializeField] private int targetCount = 5;

    [Tooltip("Visual log meshes that will be enabled as logs are stacked.")]
    [SerializeField] private GameObject[] logVisuals;

    [Header("References")]
    [Tooltip("Door to open once the stack is complete.")]
    [SerializeField] private DoorController doorToOpen;

    [Tooltip("Player inventory that tracks whether a log is being carried.")]
    [SerializeField] private PlayerInventory playerInventory;

    public event Action OnStackCompleted;

    private int currentCount;
    private bool isComplete;

    private void Awake()
    {
        if (playerInventory == null)
        {
            playerInventory = FindObjectOfType<PlayerInventory>();
        }
    }

    private void Start()
    {
        // Ensure all stack visuals start disabled
        if (logVisuals != null)
        {
            foreach (var log in logVisuals)
            {
                if (log != null)
                {
                    log.SetActive(false);
                }
            }
        }
    }

    public void StartLooking()
    {
        if (playerInventory == null)
        {
            playerInventory = FindObjectOfType<PlayerInventory>();
        }

        bool hasWood = playerInventory != null && playerInventory.IsHoldingWood;

        // Show or hide the interact prompt based on whether the player
        // is currently carrying a log. This assumes the AKItem on this
        // object has its own "Show Interact Prompt" disabled.
        if (AKUIManager.instance != null)
        {
            AKUIManager.instance.SetHighlightName(
                null,
                null,
                null,
                hasWood ? true : false,
                null,
                null);
        }
    }

    public void StopInteraction()
    {
        // No special behaviour needed when look/interaction stops.
    }

    public void HandleInputClick()
    {
        if (isComplete)
            return;

        if (playerInventory == null)
        {
            Debug.LogWarning("LogStack: No PlayerInventory found in the scene.");
            return;
        }

        if (!playerInventory.IsHoldingWood)
        {
            // Player has nothing to stack.
            return;
        }

        if (!playerInventory.TryConsumeWood())
        {
            // Failed to consume for some reason; do nothing.
            return;
        }

        // Hide the interact prompt immediately after placing the log.
        if (AKUIManager.instance != null)
        {
            AKUIManager.instance.SetHighlightName(
                null,
                null,
                null,
                false,
                null,
                null);
        }

        // Consume one wood and show the next visual if available.
        if (currentCount < logVisuals.Length && logVisuals[currentCount] != null)
        {
            logVisuals[currentCount].SetActive(true);
        }

        currentCount++;

        if (currentCount >= targetCount)
        {
            isComplete = true;
            if (doorToOpen != null)
            {
                doorToOpen.OpenDoor();
            }
            else
            {
                Debug.LogWarning("LogStack: Stack complete but no DoorToOpen assigned.");
            }

            OnStackCompleted?.Invoke();
        }
    }

    public void HandleInputHold()
    {
        // Not used for simple stacking interaction.
    }

    public void HandleInputStop()
    {
        // Not used for simple stacking interaction.
    }
}
