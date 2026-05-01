//Control game state here

using System;
using UnityEngine;

namespace AdventurePuzzleKit
{
    public static class GameState
    {
        private const float DEFAULT_TIME_SCALE = 1f;
        private const float DEFAULT_FIXED_DELTA_TIME = 0.02f;

        public static event Action Paused;
        public static event Action Resumed;
        public static event Action<bool> PauseStateChanged;

        public static bool IsExamining { get; set; }
        public static bool IsInventoryOpen { get; set; }
        public static bool IsUsingSystem { get; set; }
        public static bool isGamePaused { get; private set; }
        public static bool IsEndGame { get; private set; }

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
            IsEndGame = false;
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
            Time.timeScale = paused ? 0f : DEFAULT_TIME_SCALE;
            Time.fixedDeltaTime = paused ? 0f : DEFAULT_FIXED_DELTA_TIME;
        }
    }
}
