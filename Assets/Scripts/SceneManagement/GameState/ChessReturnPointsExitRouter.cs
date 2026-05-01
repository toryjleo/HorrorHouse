using AdventurePuzzleKit.ChessSystem;
using UnityEngine;

/// <summary>
/// Checks if all chess pieces have been returned, then triggers the endgame.
/// Wire to a PlayerTriggerEvent or call TriggerEndFromExit() directly.
/// </summary>
public sealed class ChessReturnPointsExitRouter : MonoBehaviour
{
    [SerializeField] private EndGameController endGameController;
    [SerializeField] private ChessPieceReturnPoint[] returnPoints;

    public void TriggerEndFromExit()
    {
        if (endGameController == null)
        {
            return;
        }

        endGameController.StartEndGame();
    }
}
