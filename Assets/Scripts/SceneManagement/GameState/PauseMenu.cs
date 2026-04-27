using AdventurePuzzleKit;
using UnityEngine;

public sealed class PauseMenuUI : MonoBehaviour
{
    [SerializeField] private GameObject pauseMenuPanel;
    [SerializeField] private GameStateControllerBehaviour gameStateController;
    [SerializeField] private SceneManager sceneManager;

    private void Awake()
    {
        if (pauseMenuPanel != null)
        {
            pauseMenuPanel.SetActive(false);
        }

        if (gameStateController == null)
        {
            gameStateController = GameStateControllerBehaviour.Instance;
        }
    }

    private void OnEnable()
    {
        GameState.Paused += ShowPauseMenu;
        GameState.Resumed += HidePauseMenu;
    }

    private void OnDisable()
    {
        GameState.Paused -= ShowPauseMenu;
        GameState.Resumed -= HidePauseMenu;
    }

    public void ResumeGame()
    {
        if (gameStateController == null)
        {
            gameStateController = GameStateControllerBehaviour.Instance;
        }

        if (gameStateController != null)
        {
            gameStateController.ResumeFromPause();
        }
    }

    public void QuitGame()
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

    private void ShowPauseMenu()
    {
        if (pauseMenuPanel != null)
        {
            pauseMenuPanel.SetActive(true);
        }
    }

    private void HidePauseMenu()
    {
        if (pauseMenuPanel != null)
        {
            pauseMenuPanel.SetActive(false);
        }
    }
}
