using UnityEngine;


public enum StateTrigger
{

}

public class StateController
{
    private State state;

    public bool printState = false;
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
