using UnityEngine;

[DefaultExecutionOrder(-100)]
public sealed class GameStateControllerBehaviour : MonoBehaviour
{
    public static GameStateControllerBehaviour Instance { get; private set; }

    [SerializeField] private bool printState;
    [SerializeField] private bool startInPlayingState = true;

    public StateController Controller { get; private set; }

    private void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Debug.LogError("Only one GameStateControllerBehaviour is allowed in the scene.", this);
            Destroy(gameObject);
            return;
        }

        Instance = this;
        Controller = new StateController(printState);
    }

    private void Start()
    {
        Controller.CurrentState.Enter();

        if (startInPlayingState)
        {
            Controller.HandleTrigger(StateTrigger.invalid);
        }
    }

    private void OnDestroy()
    {
        if (Instance == this)
        {
            Instance = null;
        }
    }
}
