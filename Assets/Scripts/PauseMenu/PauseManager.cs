using UnityEngine;

namespace AdventurePuzzleKit
{
    public class PauseManager : MonoBehaviour
    {
        [Header("Pause UI")]
        [SerializeField] private GameObject pauseMenuPanel = null;

        [Header("Should persist?")]
        [SerializeField] private bool persistAcrossScenes = true;

        public static PauseManager instance;

        private void Awake()
        {
            if (instance != null)
            {
                Destroy(gameObject);
                return;
            }

            instance = this;

            if (persistAcrossScenes)
            {
                DontDestroyOnLoad(gameObject);
            }

            if (pauseMenuPanel != null)
            {
                pauseMenuPanel.SetActive(false);
            }
        }

        private void Update()
        {
            if (!Input.GetKeyDown(KeyCode.Escape)) return;

            if (GameState.isGamePaused)
            {
                ResumeGame();
                return;
            }

            CloseTransientStateBeforePause();
            PauseGame();
        }

        public void PauseGame()
        {
            if (GameState.isGamePaused) return;

            GameState.isGamePaused = true;
            Time.timeScale = 0f;
            AudioListener.pause = true;
            Cursor.visible = true;
            Cursor.lockState = CursorLockMode.None;

            if (pauseMenuPanel != null)
            {
                pauseMenuPanel.SetActive(true);
            }
        }

        public void ResumeGame()
        {
            if (!GameState.isGamePaused) return;

            if (pauseMenuPanel != null)
            {
                pauseMenuPanel.SetActive(false);
            }

            AudioListener.pause = false;
            Time.timeScale = 1f;
            GameState.isGamePaused = false;
            Cursor.visible = false;
            Cursor.lockState = CursorLockMode.Locked;
        }

        public void QuitGame()
        {
            AudioListener.pause = false;
            Time.timeScale = 1f;
            GameState.isGamePaused = false;

#if UNITY_EDITOR
            UnityEditor.EditorApplication.isPlaying = false;
#else
            Application.Quit();
#endif
        }

        private void CloseTransientStateBeforePause()
        {
            PauseCloseRegistry.CloseCurrent();
        }

        private void OnDestroy()
        {
            if (instance != this) return;

            AudioListener.pause = false;
            Time.timeScale = 1f;
            GameState.isGamePaused = false;
            instance = null;
        }
    }
}
