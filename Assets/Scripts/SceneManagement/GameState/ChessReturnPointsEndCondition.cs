using System.Collections.Generic;
using AdventurePuzzleKit.ChessSystem;
using UnityEngine;

public sealed class ChessReturnPointsEndCondition : MonoBehaviour
{
    [Header("Refs")]
    [SerializeField] private EndGameController endGameController;

    [Header("Config")]
    [SerializeField] private bool autoFindReturnPointsInScene = true;
    [SerializeField] private ChessPieceReturnPoint[] returnPoints;

    private readonly HashSet<ChessPieceReturnPoint> completed = new HashSet<ChessPieceReturnPoint>();

    private void Awake()
    {
        if (autoFindReturnPointsInScene)
        {
            returnPoints = FindObjectsByType<ChessPieceReturnPoint>(FindObjectsSortMode.None);
        }

        if (returnPoints == null || returnPoints.Length == 0)
        {
            return;
        }

        for (int index = 0; index < returnPoints.Length; index++)
        {
            ChessPieceReturnPoint point = returnPoints[index];
            if (point == null)
            {
                continue;
            }

            point.PieceReturned += HandlePieceReturned;
            if (point.IsPieceReturned)
            {
                completed.Add(point);
            }
        }

        TryComplete();
    }

    private void OnDestroy()
    {
        if (returnPoints == null)
        {
            return;
        }

        for (int index = 0; index < returnPoints.Length; index++)
        {
            ChessPieceReturnPoint point = returnPoints[index];
            if (point != null)
            {
                point.PieceReturned -= HandlePieceReturned;
            }
        }
    }

    private void HandlePieceReturned(ChessPieceReturnPoint point)
    {
        if (point == null)
        {
            return;
        }

        completed.Add(point);
        TryComplete();
    }

    private void TryComplete()
    {
        if (endGameController == null || returnPoints == null || returnPoints.Length == 0)
        {
            return;
        }

        if (completed.Count < returnPoints.Length)
        {
            return;
        }

        endGameController.StartEndGame();
    }
}

