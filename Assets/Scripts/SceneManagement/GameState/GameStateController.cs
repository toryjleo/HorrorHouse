using UnityEngine;


public enum StateTrigger
{
    hitPause,
    endGame,
    invalid
}

public class StateController
{
    public EnterState enterState;
    public PlayingState playingState;
    public PausedState pausedState;
    public EndGameState endGameState;


    private State state;

    public bool printState = false;
    #region Properties

    public State CurrentState => state;

    #endregion

    public StateController(bool printState = false)
    {
        this.printState = printState;
        enterState = new EnterState(this);
        playingState = new PlayingState(this);
        pausedState = new PausedState(this);
        endGameState = new EndGameState(this);

        state = enterState;
        state.PrintStateEnter();
    }

    /// <summary>
    /// Sends a trigger to the current state. May trigger a state change.
    /// </summary>
    /// <param name="trigger">Trigger to send to state</param>
    public void HandleTrigger(StateTrigger trigger)
    {
        State newState = state.HandleTrigger(trigger);
        if (newState != null)
        {
            if (printState)
            {
                newState.PrintStateEnter();
            }

            state.Exit();
            state = newState;
            newState.Enter();
        }
        else
        {
            Debug.LogError("StateController > No transition from " + state.Name + " on trigger " + trigger);
        }
    }

    /// <summary>
    /// Set the state machine to the initial configuration
    /// </summary>
    public void Reset()
    {
        state = enterState;
    }
}

/// <summary>
/// Abstract game state declaration
/// </summary>
public abstract class State
{
    public event StateChangeHandler notifyListenersEnter;
    public event StateChangeHandler notifyListenersExit;

    protected StateController controller;

    public State(StateController controller)
    {
        this.controller = controller;
    }

    public virtual string Name { get; }

    /// <summary>
    /// Handles a trigger for this state
    /// </summary>
    /// <param name="trigger">Trigger to create a state transition</param>
    /// <returns>The new state if there is a transision</returns>
    public abstract State HandleTrigger(StateTrigger trigger);

    /// <summary>
    /// Prints the current state
    /// </summary>
    public void PrintStateEnter()
    {
        Debug.Log("GameState >  " + Name);
    }

    /// <summary>
    /// Called when entering this state
    /// </summary>
    public virtual void Enter()
    {
        notifyListenersEnter?.Invoke();
    }

    /// <summary>
    /// Called when leaving this state
    /// </summary>
    public void Exit()
    {
        notifyListenersExit?.Invoke();
    }
}

public class EnterState : State
{
    public EnterState(StateController controller) : base(controller)
    {
    }

    public override string Name => "Enter";

    public override State HandleTrigger(StateTrigger trigger)
    {
        return controller.playingState;
    }
}

public class PlayingState : State
{
    public PlayingState(StateController controller) : base(controller)
    {
    }

    public override string Name => "Playing";

    public override State HandleTrigger(StateTrigger trigger)
    {
        switch (trigger)
        {
            case StateTrigger.hitPause:
                return controller.pausedState;
            case StateTrigger.endGame:
                return controller.endGameState;
            default:
                return null;
        }
    }
}

public class PausedState : State
{
    public PausedState(StateController controller) : base(controller)
    {
    }

    public override string Name => "Paused";

    public override State HandleTrigger(StateTrigger trigger)
    {
        switch (trigger)
        {
            case StateTrigger.hitPause:
                return controller.playingState;
            default:
                return null;
        }
    }
}

/// <summary>
/// Terminal state — the game is ending. No transitions out.
/// </summary>
public class EndGameState : State
{
    public EndGameState(StateController controller) : base(controller)
    {
    }

    public override string Name => "EndGame";

    public override State HandleTrigger(StateTrigger trigger)
    {
        return null;
    }
}

public delegate void StateChangeHandler();
