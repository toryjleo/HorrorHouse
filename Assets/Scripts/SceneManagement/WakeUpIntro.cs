using System.Collections.Generic;
using AdventurePuzzleKit;
using AdventurePuzzleKit.FlashlightSystem;
using AdventurePuzzleKit.GasMaskSystem;
using UnityEngine;

// Run after other Start methods, but before the first Update/render.
[DefaultExecutionOrder(100)]
public sealed class WakeUpIntro : MonoBehaviour
{
    [SerializeField] private Camera gameplayCamera;
    [SerializeField] private Camera introCamera;
    [SerializeField] private Animator introAnimator;
    [SerializeField] private string stateName = "Base Layer.WakeUp";
    [Tooltip("Any additional gameplay scripts that read input.")]
    [SerializeField] private Behaviour[] additionalInputScripts;

    private readonly Dictionary<Behaviour, bool> inputStates = new Dictionary<Behaviour, bool>();
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
            Debug.LogError("WakeUpIntro: assign two distinct cameras and an active intro Animator with a controller.", this);
            return;
        }

        stateHash = Animator.StringToHash(stateName);
        introAnimator.enabled = true;
        if (!introAnimator.HasState(0, stateHash))
        {
            introAnimator.enabled = false;
            Debug.LogError("WakeUpIntro: missing Animator state " + stateName, this);
            return;
        }

        introAnimator.Play(stateHash, 0, 0f);
        introAnimator.Update(0f);
        AnimatorStateInfo state = introAnimator.GetCurrentAnimatorStateInfo(0);
        if (state.loop || state.length <= 0f || introAnimator.speed <= 0f || state.speed * state.speedMultiplier <= 0f)
        {
            introAnimator.enabled = false;
            Debug.LogError("WakeUpIntro: WakeUp must be non-looping, with positive duration and playback speed.", this);
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
        LockAll<FlashlightController>();
        LockAll<GasMaskController>();
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
        if (script == null || script == this || script is Camera || script == introAnimator || inputStates.ContainsKey(script)) return;
        inputStates.Add(script, script.enabled);
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
        if (state.fullPathHash != stateHash)
        {
            Debug.LogWarning("WakeUpIntro: WakeUp exited early; remove outgoing transitions from the state.", this);
            RestoreGameplay();
        }
        else if (state.normalizedTime >= 1f)
        {
            // Diagnose a mismatched end pose without moving the player's working camera.
            if (Vector3.Distance(introCamera.transform.position, gameplayCamera.transform.position) > 0.01f ||
                Quaternion.Angle(introCamera.transform.rotation, gameplayCamera.transform.rotation) > 0.5f)
                Debug.LogWarning("WakeUpIntro: match WakeUp's final camera pose to the gameplay camera to avoid a visible cut.", this);
            RestoreGameplay();
        }
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
        foreach (KeyValuePair<Behaviour, bool> entry in inputStates)
            if (entry.Key != null) entry.Key.enabled = entry.Value;
        inputStates.Clear();
        Cursor.visible = previousCursorVisible;
        Cursor.lockState = previousCursorLock;
    }
}
