using System.Collections.Generic;
using UnityEngine;

namespace AdventurePuzzleKit
{
    /// <summary>
    /// Shows a one-time crawl tutorial prompt while player is in a volume.
    /// Completes permanently once the crawl key is pressed inside the volume.
    /// </summary>
    public class CrawlTutorialVolumePrompt : MonoBehaviour
    {
        [Header("Volume")]
        [SerializeField] private bool useBuiltInTriggerCallbacks = true;
        [SerializeField] private string playerTag = "Player";

        [Header("Crawl Input")]
        [SerializeField] private KeyCode crawlKey = KeyCode.LeftControl;

        [Header("Prompt Content")]
        [SerializeField] private string keyLabelOverride = "CTRL";
        [SerializeField] private string promptLabel = "Toggle Crawl";
        [SerializeField] private Color promptColor = Color.white;

        private bool _playerInside;
        private bool _isPromptVisible;
        private bool _isCompleted;

        private void Update()
        {
            if (_isCompleted) return;

            if (!_playerInside)
            {
                if (_isPromptVisible)
                {
                    AKPromptManager.Instance?.ClearPrompts();
                    _isPromptVisible = false;
                }
                return;
            }

            if (Input.GetKeyDown(crawlKey))
            {
                _isCompleted = true;
                if (_isPromptVisible)
                {
                    AKPromptManager.Instance?.ClearPrompts();
                }
                _isPromptVisible = false;
                return;
            }

            if (_isPromptVisible && (GameState.IsPlayerBusy || GameState.IsExamining || GameState.IsUsingSystem))
            {
                _isPromptVisible = false;
            }

            if (GameState.IsPlayerBusy || GameState.IsExamining || GameState.IsUsingSystem || GameState.IsInventoryOpen) return;
            if (_isPromptVisible) return;
            if (AKPromptManager.Instance == null) return;

            AKPromptManager.Instance.RegisterPrompts(new List<AKPromptManager.Prompt> { BuildPrompt() });
            _isPromptVisible = true;
        }

        private void OnTriggerEnter(Collider other)
        {
            if (!useBuiltInTriggerCallbacks) return;
            if (!other.CompareTag(playerTag)) return;

            EnterTutorialVolume();
        }

        private void OnTriggerExit(Collider other)
        {
            if (!useBuiltInTriggerCallbacks) return;
            if (!other.CompareTag(playerTag)) return;

            ExitTutorialVolume();
        }

        // For custom trigger events (UnityEvent / AK trigger callback).
        public void EnterTutorialVolume()
        {
            if (_isCompleted) return;
            _playerInside = true;
        }

        // For custom trigger events (UnityEvent / AK trigger callback).
        public void ExitTutorialVolume()
        {
            _playerInside = false;
        }

        public void ResetTutorial()
        {
            _isCompleted = false;
            _playerInside = false;
            if (_isPromptVisible)
            {
                AKPromptManager.Instance?.ClearPrompts();
            }
            _isPromptVisible = false;
        }

        private AKPromptManager.Prompt BuildPrompt()
        {
            var prompt = new AKPromptManager.Prompt(GetPromptKeyLabel(), promptLabel)
            {
                Color = promptColor
            };

            return prompt;
        }

        private string GetPromptKeyLabel()
        {
            if (!string.IsNullOrWhiteSpace(keyLabelOverride))
            {
                return keyLabelOverride.Trim();
            }

            return crawlKey.ToString();
        }
    }
}
