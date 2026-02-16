using System.Collections.Generic;
using UnityEngine;

namespace AdventurePuzzleKit
{
    /// <summary>
    /// Shows a one-time "open inventory" prompt after the player picks up a chess piece.
    /// Prompt is completed once the player opens inventory for the first time.
    /// </summary>
    public class InventoryTutorialPrompt : MonoBehaviour
    {
        [Header("Prompt Content")]
        [SerializeField] private string promptLabel = "Open Inventory";
        [SerializeField] private Color promptColor = Color.white;

        [Header("Optional Key Override")]
        [Tooltip("Leave empty to use AKInputManager.toggleInventoryKey.")]
        [SerializeField] private string keyOverride = "";

        [Header("Persistence")]
        [SerializeField] private bool persistAcrossScenes = true;

        private bool _isSubscribed;
        private bool _awaitingInventoryOpen;
        private bool _isPromptVisible;
        private bool _isCompleted;

        private void Awake()
        {
            if (persistAcrossScenes)
            {
                DontDestroyOnLoad(gameObject);
            }
        }

        private void OnEnable()
        {
            TrySubscribe();
        }

        private void OnDisable()
        {
            Unsubscribe();
        }

        private void Update()
        {
            if (_isCompleted) return;

            // Inventory was opened at least once after we started waiting; consume the tutorial.
            if (_awaitingInventoryOpen && GameState.IsInventoryOpen)
            {
                CompleteTutorial();
                return;
            }

            // If gameplay state changed, assume another system may have replaced prompt display.
            if (_isPromptVisible && (GameState.IsPlayerBusy || GameState.IsExamining || GameState.IsUsingSystem))
            {
                _isPromptVisible = false;
            }

            // Re-subscribe if singleton came online after this object.
            if (!_isSubscribed)
            {
                TrySubscribe();
            }

            if (!_awaitingInventoryOpen) return;
            if (GameState.IsPlayerBusy || GameState.IsExamining || GameState.IsUsingSystem || GameState.IsInventoryOpen) return;
            if (_isPromptVisible) return;
            if (AKPromptManager.Instance == null) return;

            AKPromptManager.Instance.RegisterPrompts(new List<AKPromptManager.Prompt> { BuildPrompt() });
            _isPromptVisible = true;
        }

        private void OnInventoryItemAdded(InventoryItem item)
        {
            if (_isCompleted || _awaitingInventoryOpen || item == null) return;

            if (item.category == ItemCategory.ChessPiece)
            {
                _awaitingInventoryOpen = true;
            }
        }

        private void CompleteTutorial()
        {
            _awaitingInventoryOpen = false;
            _isCompleted = true;
            _isPromptVisible = false;
        }

        private AKPromptManager.Prompt BuildPrompt()
        {
            var prompt = new AKPromptManager.Prompt(GetPromptKey(), promptLabel)
            {
                Color = promptColor
            };

            return prompt;
        }

        private string GetPromptKey()
        {
            if (!string.IsNullOrWhiteSpace(keyOverride))
            {
                return keyOverride.Trim();
            }

            if (AKInputManager.instance != null)
            {
                return AKInputManager.instance.toggleInventoryKey.ToString();
            }

            return "I";
        }

        private void TrySubscribe()
        {
            if (_isSubscribed || PlayerInventory.instance == null) return;

            PlayerInventory.instance.OnItemAdded += OnInventoryItemAdded;
            _isSubscribed = true;
        }

        private void Unsubscribe()
        {
            if (!_isSubscribed || PlayerInventory.instance == null) return;

            PlayerInventory.instance.OnItemAdded -= OnInventoryItemAdded;
            _isSubscribed = false;
        }
    }
}
