using System.Collections.Generic;
using AdventurePuzzleKit;
using UnityEngine;

// Starts after the player's Awake has established the standing camera pose.
[DefaultExecutionOrder(100)]
public sealed class WakeUpIntro : MonoBehaviour
{
    [SerializeField] private Camera gameplayCamera;
    [SerializeField] private Camera introCamera;
    [SerializeField] private Animator introAnimator;
    [SerializeField] private string stateName = "Base Layer.WakeUp";
    [Tooltip("Other scripts that read gameplay input during the intro.")]
    [SerializeField] private Behaviour[] additionalInputScripts;

    private readonly Dictionary<Behaviour, bool> savedEnabled = new Dictionary<Behaviour, bool>();
    private bool playing;
    private bool previousBusy;
    private bool previousCameraEnabled;
    private bool previousCursorVisible;
    private CursorLockMode previousCursorLock;
    private int stateHash;

    private void Start()
    {
        if (gameplayCamera == null || introCamera == null || introAnimator == null ||
            gameplayCamera == introCamera || !introCamera.gameObject.activeInHierarchy ||
            !introAnimator.gameObject.activeInHierarchy || introAnimator.runtimeAnimatorController == null)
        {
            Debug.LogError("WakeUpIntro: assign two distinct active cameras and the intro Animator/controller.", this);
            return;
        }

        stateHash = Animator.StringToHash(stateName);
        introAnimator.enabled = true;
        if (!introAnimator.HasState(0, stateHash))
        {
            introAnimator.enabled = false;
            Debug.LogError("WakeUpIntro: the Animator needs a state named " + stateName, this);
            return;
        }

        introAnimator.Play(stateHash, 0, 0f);
        introAnimator.Update(0f);
        AnimatorStateInfo state = introAnimator.GetCurrentAnimatorStateInfo(0);
        if (state.loop || state.length <= 0f || introAnimator.speed <= 0f || state.speed * state.speedMultiplier <= 0f)
        {
            introAnimator.enabled = false;
            Debug.LogError("WakeUpIntro: use a non-looping clip with positive duration and playback speed.", this);
            return;
        }

        previousBusy = GameState.IsUsingSystem;
        previousCameraEnabled = gameplayCamera.enabled;
        previousCursorVisible = Cursor.visible;
        previousCursorLock = Cursor.lockState;
        playing = true;
        GameState.IsUsingSystem = true;
        LockAll<AKFPSController>();
        LockAll<AKInteractor>();
        LockAll<AKCameraZoom>();
        LockAll<AKUIManager>();
        //LockAll<FlashlightController>();
        //LockAll<GasMaskController>();
        LockAll<GameStateControllerBehaviour>();
        if (additionalInputScripts != null)
            foreach (Behaviour script in additionalInputScripts) Lock(script);

        Cursor.visible = false;
        Cursor.lockState = CursorLockMode.Locked;
        introCamera.fieldOfView = gameplayCamera.fieldOfView;
        gameplayCamera.enabled = false;
        introCamera.enabled = true;
    }

    private void LockAll<T>() where T : Behaviour
    {
        foreach (T script in Object.FindObjectsByType<T>(FindObjectsSortMode.None)) Lock(script);
    }

    private void Lock(Behaviour script)
    {
        if (script == null || script == this || script == introAnimator || script is Camera || savedEnabled.ContainsKey(script)) return;
        savedEnabled.Add(script, script.enabled);
        script.enabled = false;
    }

    private void LateUpdate()
    {
        if (!playing) return;
        if (introAnimator == null || !introAnimator.isActiveAndEnabled)
        {
            RestoreGameplay();
            return;
        }

        AnimatorStateInfo state = introAnimator.GetCurrentAnimatorStateInfo(0);
        if (state.fullPathHash != stateHash || state.normalizedTime >= 1f) RestoreGameplay();
    }

    private void OnDisable() => RestoreGameplay();

    private void RestoreGameplay()
    {
        if (!playing) return;
        playing = false;
        if (introAnimator != null) introAnimator.enabled = false;
        if (introCamera != null) introCamera.enabled = false;
        if (gameplayCamera != null) gameplayCamera.enabled = previousCameraEnabled;
        GameState.IsUsingSystem = previousBusy;
        foreach (KeyValuePair<Behaviour, bool> entry in savedEnabled)
            if (entry.Key != null) entry.Key.enabled = entry.Value;
        savedEnabled.Clear();
        Cursor.visible = previousCursorVisible;
        Cursor.lockState = previousCursorLock;
    }
}
