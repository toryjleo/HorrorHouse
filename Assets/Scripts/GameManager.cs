using UnityEngine;

/// <summary>
/// Very simple game manager that enables the finish trigger
/// once the log stack has reached full capacity.
/// </summary>
public class GameManager : MonoBehaviour
{
    [Header("Gameplay References")]
    [Tooltip("Log stack that signals when all required wood has been placed.")]
    [SerializeField] private LogStack logStack;

    [Tooltip("Collider used as the finish trigger volume.")]
    [SerializeField] private Collider finishTriggerCollider;

    [Header("Audio")]
    [Tooltip("Audio source positioned at the top of the stairs.")]
    [SerializeField] private AudioSource stairsAudioSource;

    [Tooltip("Clip played at game start.")]
    [SerializeField] private AudioClip startClip;

    [Tooltip("Clip played when the log stack is complete.")]
    [SerializeField] private AudioClip stackCompleteClip;

    [Header("Timeout Settings")]
    [Tooltip("If greater than zero, triggers a timeout after this many seconds.")]
    [SerializeField] private float timeLimitSeconds = 60f;

    [Tooltip("Clip played when the time limit is reached.")]
    [SerializeField] private AudioClip timeoutClip;

    [Tooltip("Delay before quitting after the timeout clip (seconds).")]
    [SerializeField] private float timeoutQuitDelay = 4f;

    private float elapsedTime;
    private bool timeoutTriggered;

    private void Awake()
    {
        // Ensure the finish trigger starts disabled so the player
        // can't end the game before completing the stack.
        if (finishTriggerCollider != null)
        {
            finishTriggerCollider.enabled = false;
        }

        // Play start audio at the top of the stairs after a short delay, if configured.
        if (stairsAudioSource != null && startClip != null)
        {
            Invoke(nameof(PlayStartAudio), 1f);
        }
    }

    private void OnEnable()
    {
        if (logStack != null)
        {
            logStack.OnStackCompleted += HandleStackCompleted;
        }
    }

    private void OnDisable()
    {
        if (logStack != null)
        {
            logStack.OnStackCompleted -= HandleStackCompleted;
        }
    }

    private void Update()
    {
        if (timeoutTriggered)
            return;

        if (timeLimitSeconds > 0f)
        {
            elapsedTime += Time.deltaTime;
            if (elapsedTime >= timeLimitSeconds)
            {
                TriggerTimeout();
            }
        }
    }

    private void HandleStackCompleted()
    {
        if (finishTriggerCollider != null)
        {
            finishTriggerCollider.enabled = true;
        }

        // Play completion audio at the top of the stairs, if configured.
        if (stairsAudioSource != null && stackCompleteClip != null)
        {
            stairsAudioSource.PlayOneShot(stackCompleteClip);
        }
    }

    private void PlayStartAudio()
    {
        if (stairsAudioSource != null && startClip != null)
        {
            stairsAudioSource.PlayOneShot(startClip);
        }
    }

    private void TriggerTimeout()
    {
        timeoutTriggered = true;

        if (stairsAudioSource != null && timeoutClip != null)
        {
            stairsAudioSource.PlayOneShot(timeoutClip);
        }

        float delay = timeoutQuitDelay;
        if (timeoutClip != null)
        {
            delay += timeoutClip.length;
        }

        Invoke(nameof(QuitGame), delay);
    }

    private void QuitGame()
    {
#if UNITY_EDITOR
        UnityEditor.EditorApplication.isPlaying = false;
#else
        Application.Quit();
#endif
    }
}
