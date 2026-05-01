using System.Collections;
using AdventurePuzzleKit;
using UnityEngine;

/// <summary>
/// Orchestrates the endgame sequence: Glitch → Jumpscare → Breather → Splash → Quit.
/// Each phase is optional — disable by leaving its GameObject/duration unset.
/// Attach to a GameObject in the scene and wire via PlayerTriggerEvent or similar.
/// </summary>
public sealed class EndGameController : MonoBehaviour
{
    // ── Phase durations ──────────────────────────────────────────────
    [Header("Phase Durations (seconds, real-time)")]
    [SerializeField] private float glitchDuration = 3f;
    [SerializeField] private float jumpscareRampDuration = 0.35f;
    [SerializeField] private float jumpscareHoldDuration = 0.15f;
    [SerializeField] private float breatherDuration = 5f;
    [SerializeField] private float splashDuration = 10f;

    // ── UI panels ────────────────────────────────────────────────────
    [Header("UI Panels")]
    [Tooltip("Full-screen glitch overlay (Not Responding dialog, scanlines, etc)")]
    [SerializeField] private GameObject glitchOverlayPanel;

    [Tooltip("Jumpscare image — alpha driven from 0 to 1")]
    [SerializeField] private CanvasGroup jumpscareCanvasGroup;

    [Tooltip("Company logo splash screen")]
    [SerializeField] private GameObject splashPanel;

    // ── Breather ─────────────────────────────────────────────────────
    [Header("Breather")]
    [Tooltip("Optional world object to reveal during the breather")]
    [SerializeField] private GameObject clueObject;

    // ── Audio ─────────────────────────────────────────────────────────
    [Header("Audio")]
    [SerializeField] private Sound jumpscareStinger;
    [SerializeField] private Sound endStinger;

    // ── Refs ──────────────────────────────────────────────────────────
    [Header("Refs")]
    [SerializeField] private SceneManager sceneManager;

    private bool hasStarted;

    private void Awake()
    {
        // Ensure all panels start hidden
        SetActive(glitchOverlayPanel, false);
        SetActive(splashPanel, false);

        if (jumpscareCanvasGroup != null)
        {
            jumpscareCanvasGroup.alpha = 0f;
            jumpscareCanvasGroup.gameObject.SetActive(false);
        }
    }

    // ── Public entry point ────────────────────────────────────────────
    /// <summary>
    /// Call this to start the endgame sequence. Safe to call multiple times — only runs once.
    /// Wire to a PlayerTriggerEvent.OnPlayerTrigger in the Inspector.
    /// </summary>
    public void StartEndGame()
    {
        if (hasStarted)
        {
            return;
        }

        hasStarted = true;

        // Transition the state machine
        if (GameStateControllerBehaviour.Instance != null)
        {
            GameStateControllerBehaviour.Instance.TriggerEndGame();
        }
        else
        {
            GameState.EnterEndGame();
        }

        StartCoroutine(EndGameSequence());
    }

    // ── The sequence ─────────────────────────────────────────────────
    private IEnumerator EndGameSequence()
    {
        // ── GLITCH ───────────────────────────────────────────────────
        if (glitchOverlayPanel != null)
        {
            FreezePlayer(true);
            SetActive(glitchOverlayPanel, true);
            StopAllGameAudio();

            yield return new WaitForSecondsRealtime(glitchDuration);
        }

        // ── JUMPSCARE ────────────────────────────────────────────────
        if (jumpscareCanvasGroup != null)
        {
            jumpscareCanvasGroup.gameObject.SetActive(true);
            PlaySound(jumpscareStinger);

            // Ramp alpha 0 → 1
            float elapsed = 0f;
            float duration = Mathf.Max(0.001f, jumpscareRampDuration);
            while (elapsed < duration)
            {
                elapsed += Time.unscaledDeltaTime;
                jumpscareCanvasGroup.alpha = Mathf.Clamp01(elapsed / duration);
                yield return null;
            }

            jumpscareCanvasGroup.alpha = 1f;

            if (jumpscareHoldDuration > 0f)
            {
                yield return new WaitForSecondsRealtime(jumpscareHoldDuration);
            }

            jumpscareCanvasGroup.gameObject.SetActive(false);
        }

        // ── BREATHER ─────────────────────────────────────────────────
        if (breatherDuration > 0f)
        {
            SetActive(glitchOverlayPanel, false);
            FreezePlayer(false);
            SetActive(clueObject, true);

            yield return new WaitForSecondsRealtime(breatherDuration);
        }

        // ── SPLASH ───────────────────────────────────────────────────
        FreezePlayer(true);
        SetActive(glitchOverlayPanel, false);
        SetActive(splashPanel, true);
        PlaySound(endStinger);

        yield return new WaitForSecondsRealtime(splashDuration);

        // ── QUIT ─────────────────────────────────────────────────────
        Quit();
    }

    // ── Helpers ───────────────────────────────────────────────────────
    private void FreezePlayer(bool freeze)
    {
        if (AKDisableManager.instance != null)
        {
            AKDisableManager.instance.DisablePlayerDefault(freeze, false, false);
        }
    }

    private void StopAllGameAudio()
    {
        if (AKAudioManager.instance != null)
        {
            AKAudioManager.instance.StopAll();
        }
    }

    private void PlaySound(Sound sound)
    {
        if (sound != null && AKAudioManager.instance != null)
        {
            AKAudioManager.instance.Play(sound);
        }
    }

    private static void SetActive(GameObject go, bool active)
    {
        if (go != null)
        {
            go.SetActive(active);
        }
    }

    private void Quit()
    {
        if (sceneManager != null)
        {
            sceneManager.EndGame();
            return;
        }

#if UNITY_EDITOR
        UnityEditor.EditorApplication.isPlaying = false;
#else
        Application.Quit();
#endif
    }
}
