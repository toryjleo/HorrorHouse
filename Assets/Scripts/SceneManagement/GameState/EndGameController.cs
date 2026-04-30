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
    [SerializeField] private float jumpscareHoldDurationSeconds = 0.15f;
    [SerializeField] private bool hideJumpscareOnSplash = true;

    [Header("Audio")]
    [SerializeField] private bool stopAllAkAudioOnStart = true;
    [SerializeField] private Sound jumpscareStinger;
    [SerializeField] private Sound endStinger;

    [Header("Optional Distortion (assign existing music filter)")]
    [SerializeField] private AudioDistortionFilter musicDistortionFilter;
    [SerializeField] private AudioSource musicAudioSource;
    [SerializeField, Range(0f, 1f)] private float jumpscareDistortionLevel = 0.9f;
    [SerializeField] private float jumpscareDistortionRampDurationSeconds = 0.1f;
    [SerializeField] private bool resetDistortionAfterSplash = true;
    [SerializeField, Range(0f, 1f)] private float jumpscareVolumeMultiplier = 0.4f;
    [SerializeField] private float jumpscareVolumeRampDurationSeconds = 0.1f;
    [SerializeField] private bool resetVolumeAfterSplash = true;

    [Header("Refs")]
    [SerializeField] private SceneManager sceneManager;

    private bool hasStarted;
    private Coroutine routine;
    private float initialDistortionLevel;
    private bool initialDistortionEnabled;
    private float initialMusicVolume;

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

        if (musicDistortionFilter != null)
        {
            initialDistortionLevel = musicDistortionFilter.distortionLevel;
            initialDistortionEnabled = musicDistortionFilter.enabled;

            if (musicAudioSource == null)
            {
                musicAudioSource = musicDistortionFilter.GetComponent<AudioSource>();
            }
        }

        if (musicAudioSource != null)
        {
            initialMusicVolume = musicAudioSource.volume;
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

            if (jumpscareStinger != null && AKAudioManager.instance != null)
            {
                AKAudioManager.instance.Play(jumpscareStinger);
            }

            float elapsedSeconds = 0f;
            float durationSeconds = Mathf.Max(0.001f, jumpscareRampDurationSeconds);
            float distortionDurationSeconds = Mathf.Max(0.001f, jumpscareDistortionRampDurationSeconds);
            float volumeDurationSeconds = Mathf.Max(0.001f, jumpscareVolumeRampDurationSeconds);
            while (elapsedSeconds < durationSeconds)
            {
                elapsedSeconds += Time.unscaledDeltaTime;
                jumpscareCanvasGroup.alpha = Mathf.Clamp01(elapsedSeconds / durationSeconds);

                if (musicDistortionFilter != null)
                {
                    if (!musicDistortionFilter.enabled)
                    {
                        musicDistortionFilter.enabled = true;
                    }

                    float distortionT = Mathf.Clamp01(elapsedSeconds / distortionDurationSeconds);
                    musicDistortionFilter.distortionLevel = Mathf.Lerp(initialDistortionLevel, jumpscareDistortionLevel, distortionT);
                }

                if (musicAudioSource != null)
                {
                    float volumeT = Mathf.Clamp01(elapsedSeconds / volumeDurationSeconds);
                    musicAudioSource.volume = Mathf.Lerp(initialMusicVolume, initialMusicVolume * jumpscareVolumeMultiplier, volumeT);
                }

                yield return null;
            }

            jumpscareCanvasGroup.alpha = 1f;

            if (jumpscareHoldDurationSeconds > 0f)
            {
                yield return new WaitForSecondsRealtime(jumpscareHoldDurationSeconds);
            }
        }

        if (hideJumpscareOnSplash && jumpscareCanvasGroup != null)
        {
            jumpscareCanvasGroup.gameObject.SetActive(false);
        }

        if (splashPanel != null)
        {
            splashPanel.SetActive(true);
        }

        if (resetDistortionAfterSplash && musicDistortionFilter != null)
        {
            musicDistortionFilter.distortionLevel = initialDistortionLevel;
            musicDistortionFilter.enabled = initialDistortionEnabled;
        }

        if (resetVolumeAfterSplash && musicAudioSource != null)
        {
            musicAudioSource.volume = initialMusicVolume;
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
