using System.Collections;
using AdventurePuzzleKit;
using UnityEngine;

public sealed class EndGameController : MonoBehaviour
{
    [Header("Splash (MVP)")]
    [SerializeField] private GameObject splashPanel;
    [SerializeField] private float splashDurationSeconds = 2f;

    [Header("Optional Jumpscare (Nice)")]
    [SerializeField] private bool enableJumpscare;
    [SerializeField] private CanvasGroup jumpscareCanvasGroup;
    [SerializeField] private float jumpscareRampDurationSeconds = 0.35f;

    [Header("Audio")]
    [SerializeField] private bool stopAllAkAudioOnStart = true;
    [SerializeField] private Sound endStinger;

    [Header("Refs")]
    [SerializeField] private SceneManager sceneManager;

    private bool hasStarted;
    private Coroutine routine;

    private void Awake()
    {
        if (splashPanel != null)
        {
            splashPanel.SetActive(false);
        }

        if (jumpscareCanvasGroup != null)
        {
            jumpscareCanvasGroup.alpha = 0f;
            jumpscareCanvasGroup.gameObject.SetActive(false);
        }
    }

    public void StartEndGame()
    {
        if (hasStarted)
        {
            return;
        }

        hasStarted = true;

        GameState.SetPaused(false);
        GameState.EnterEndGame();

        if (stopAllAkAudioOnStart && AKAudioManager.instance != null)
        {
            AKAudioManager.instance.StopAll();
        }

        if (routine != null)
        {
            StopCoroutine(routine);
        }

        routine = StartCoroutine(RunRoutine());
    }

    private IEnumerator RunRoutine()
    {
        if (AKDisableManager.instance != null)
        {
            AKDisableManager.instance.DisablePlayerDefault(true, false, false);
        }
        else
        {
            Cursor.visible = false;
            Cursor.lockState = CursorLockMode.None;
        }

        if (enableJumpscare && jumpscareCanvasGroup != null)
        {
            jumpscareCanvasGroup.alpha = 0f;
            jumpscareCanvasGroup.gameObject.SetActive(true);

            float elapsedSeconds = 0f;
            float durationSeconds = Mathf.Max(0.001f, jumpscareRampDurationSeconds);
            while (elapsedSeconds < durationSeconds)
            {
                elapsedSeconds += Time.unscaledDeltaTime;
                jumpscareCanvasGroup.alpha = Mathf.Clamp01(elapsedSeconds / durationSeconds);
                yield return null;
            }

            jumpscareCanvasGroup.alpha = 1f;
        }

        if (splashPanel != null)
        {
            splashPanel.SetActive(true);
        }

        if (endStinger != null && AKAudioManager.instance != null)
        {
            AKAudioManager.instance.Play(endStinger);
        }

        yield return new WaitForSecondsRealtime(Mathf.Max(0f, splashDurationSeconds));

        if (sceneManager != null)
        {
            sceneManager.EndGame();
            yield break;
        }

#if UNITY_EDITOR
        UnityEditor.EditorApplication.isPlaying = false;
#else
        Application.Quit();
#endif
    }
}
