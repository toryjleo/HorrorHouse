using AdventurePuzzleKit;
using UnityEngine;
using UnityEngine.EventSystems;

public sealed class PauseMenu : MonoBehaviour
{
    [SerializeField] private GameObject pauseMenuPanel;
    [SerializeField] private GameObject firstSelected;
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
        if (AKDisableManager.instance != null)
        {
            AKDisableManager.instance.DisablePlayerDefault(true, false, false);
        }
        else
        {
            Cursor.visible = true;
            Cursor.lockState = CursorLockMode.None;
        }

        if (pauseMenuPanel != null)
        {
            pauseMenuPanel.SetActive(true);
        }

        if (EventSystem.current != null && firstSelected != null)
        {
            EventSystem.current.SetSelectedGameObject(firstSelected);
        }
    }

    private void HidePauseMenu()
    {
        if (EventSystem.current != null)
        {
            EventSystem.current.SetSelectedGameObject(null);
        }

        if (pauseMenuPanel != null)
        {
            pauseMenuPanel.SetActive(false);
        }

        if (AKDisableManager.instance != null)
        {
            AKDisableManager.instance.DisablePlayerDefault(false, false, false);
        }
        else
        {
            Cursor.visible = false;
            Cursor.lockState = CursorLockMode.Locked;
        }
    }
}
