//Control game state here

using System;
using UnityEngine;

namespace AdventurePuzzleKit
{
    public static class GameState
    {
        private const float DefaultTimeScale = 1f;
        private const float DefaultFixedDeltaTime = 0.02f;

        public static event Action Paused;
        public static event Action Resumed;
        public static event Action<bool> PauseStateChanged;

        public static bool IsExamining { get; set; }
        public static bool IsInventoryOpen { get; set; }
        public static bool IsUsingSystem { get; set; }
        public static bool isGamePaused { get; private set; }

        // A combined property to check if the player is "busy" with any major state
        public static bool IsPlayerBusy => IsExamining || IsInventoryOpen || isGamePaused || IsInteracting;

        public static bool IsInteracting => IsUsingSystem || IsExamining || isGamePaused;

        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]
        private static void ResetStatics()
        {
            IsExamining = false;
            IsInventoryOpen = false;
            IsUsingSystem = false;
            isGamePaused = false;
            ApplyTimeScale(false);
        }

        public static void PauseGameplay()
        {
            SetPaused(true);
        }

        public static void ResumeGameplay()
        {
            SetPaused(false);
        }

        public static void SetPaused(bool paused)
        {
            if (isGamePaused == paused)
            {
                return;
            }

            isGamePaused = paused;
            ApplyTimeScale(paused);
            PauseStateChanged?.Invoke(paused);

            if (paused)
            {
                Paused?.Invoke();
            }
            else
            {
                Resumed?.Invoke();
            }
        }

        private static void ApplyTimeScale(bool paused)
        {
            Time.timeScale = paused ? 0f : DefaultTimeScale;
            Time.fixedDeltaTime = paused ? 0f : DefaultFixedDeltaTime;
        }
    }
}

