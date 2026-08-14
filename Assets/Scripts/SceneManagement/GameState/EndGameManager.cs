using System.Collections;
using AdventurePuzzleKit;
using UnityEngine;
using UnityEngine.Events;

/// <summary>
/// Orchestrates the endgame sequence: Glitch → Jumpscare → Breather → Splash → Quit.
/// Each phase is optional — disable by leaving its GameObject/duration unset.
/// Attach to a GameObject in the scene and wire via PlayerTriggerEvent or similar.
/// </summary>
public sealed class EndGameManager : MonoBehaviour
{
    // ── Phase durations ──────────────────────────────────────────────
    [Header("Phase Durations (seconds, real-time)")]
    [SerializeField] private float glitchDuration = 3f;
    [SerializeField] private float splashDuration = 10f;

    // ── UI panels ────────────────────────────────────────────────────
    [Header("UI Panels")]

    [Tooltip("Company logo splash screen")]
    [SerializeField] private GameObject splashPanel;

    // ── Audio ─────────────────────────────────────────────────────────
    [Header("Audio")]
    [SerializeField] private Sound endStinger;

    // ── Refs ──────────────────────────────────────────────────────────
    [Header("Refs")]
    [SerializeField] private SceneManager sceneManager;

    Coroutine endGameCouroutine = null;

    [SerializeField] private UnityEvent fifthEndingEvent = null;
    [SerializeField] private AudioSource fifthEndingSource = null;

    private bool hasStarted;

    public bool pawnReturned { get; set; } = false;

    // Pieces that are not a pawn.
    private int numberOfOtherPiecesReturned { get; set; } = 0;

    public void ReturnNonPawnPiece()
    {
        numberOfOtherPiecesReturned++;
    }

    private void Awake()
    {
        // Ensure all panels start hidden
        SetActive(splashPanel, false);
    }

    private void OnEnable()
    {
        GameStateControllerBehaviour.Instance.EndGameStateEnter.notifyListenersEnter += HandleEndGameStarted;
    }

    private void OnDisable()
    {
        GameStateControllerBehaviour.Instance.EndGameStateEnter.notifyListenersEnter -= HandleEndGameStarted;
    }

    private void HandleEndGameStarted()
    {
        if (hasStarted)
        {
            return;
        }

        hasStarted = true;

        int threshold = pawnReturned ? 50 + (numberOfOtherPiecesReturned * 10) : 0; // Increase chance by 10% for each non-pawn piece returned
        int roll = Random.Range(1, 101);

        if (roll <= threshold)
        {
            endGameCouroutine = StartCoroutine(AlternateGameSequence());
        }
        else
        {
            endGameCouroutine = StartCoroutine(EndGameSequence());
        }



    }

    private IEnumerator EndGameSequence()
    {
        // ── JUMPSCARE ─────────────────────────────────────────────────
        if (JumpscarePlayer.Instance != null)
        {
            Coroutine jumpScare = JumpscarePlayer.Instance.PlayRandomJumpscare();
            if (jumpScare != null)
            {
                yield return jumpScare;
            }
            else
            {
                FreezePlayer(false);
            }
        }
        else
        {
            FreezePlayer(false);
        }

        // ── SPLASH ───────────────────────────────────────────────────
        FreezePlayer(true);
        SetActive(splashPanel, true);
        PlaySound(endStinger);

        if (endStinger != null && endStinger.clip != null)
        {
            splashDuration = endStinger.clip.length;
        }
        yield return new WaitForSecondsRealtime(splashDuration);

        // ── QUIT ─────────────────────────────────────────────────────
        Quit();
    }

    private IEnumerator AlternateGameSequence()
    {

        // ── Door close, John Bishop Track Started ─────────────────────────────────────────────────
        // TODO: Test
        if (fifthEndingEvent != null)
        {
            if (fifthEndingSource != null)
            {
                if (fifthEndingSource.clip != null)
                {
                    fifthEndingSource.gameObject.SetActive(true);
                    float waitTime = fifthEndingSource.clip.length;
                    fifthEndingSource.Play();

                    fifthEndingEvent.Invoke(); // Close door, play sound effect

                    yield return new WaitForSecondsRealtime(waitTime);
                }
                else
                {
                    Debug.LogWarning("Fifth Ending Audio Source does not have an audio clip assigned in EndGameManager.");
                    FreezePlayer(false);
                }
            }
            else
            {
                Debug.LogWarning("Fifth Ending Audio Source is not assigned in EndGameManager.");
                FreezePlayer(false);
            }
        }
        else
        {
            Debug.LogWarning("Fifth Ending Event is not assigned in EndGameManager.");
            FreezePlayer(false);
        }

        // TODO: This is pretty standardized. Move to a function.
        // ── SPLASH ───────────────────────────────────────────────────
        FreezePlayer(true);
        SetActive(splashPanel, true);
        PlaySound(endStinger);

        if (endStinger != null && endStinger.clip != null)
        {
            splashDuration = endStinger.clip.length;
        }
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
