using AdventurePuzzleKit;
using UnityEngine;

[DefaultExecutionOrder(-100)]
public sealed class GameStateControllerBehaviour : MonoBehaviour
{
    public static GameStateControllerBehaviour Instance { get; private set; }

    [SerializeField] private bool printState;
    [SerializeField] private bool startInPlayingState = true;

    public bool GameIsPaused => controller.CurrentState == controller.pausedState;

    private StateController controller;

    private void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Debug.LogError("Only one GameStateControllerBehaviour is allowed in the scene.", this);
            Destroy(gameObject);
            return;
        }

        Instance = this;
        controller = new StateController(printState);
        controller.playingState.notifyListenersEnter += GameState.ResumeGameplay;
        controller.pausedState.notifyListenersEnter += GameState.PauseGameplay;
    }

    private void Start()
    {
        controller.CurrentState.Enter();

        if (startInPlayingState)
        {
            controller.HandleTrigger(StateTrigger.invalid);
        }
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            Instance.controller.HandleTrigger(StateTrigger.hitPause);
        }
    }

    private void OnDestroy()
    {
        if (controller != null)
        {
            controller.playingState.notifyListenersEnter -= GameState.ResumeGameplay;
            controller.pausedState.notifyListenersEnter -= GameState.PauseGameplay;
        }

        if (Instance == this)
        {
            Instance = null;
        }
    }
}
