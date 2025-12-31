using UnityEngine;

public class FinishTrigger : MonoBehaviour
{
    [Tooltip("Optional tag to filter the player object.")]
    [SerializeField] private string playerTag = "Player";

    [Tooltip("Delay before quitting the game (seconds).")]
    [SerializeField] private float quitDelay = 1.5f;

    private bool hasTriggered;

    private void OnTriggerEnter(Collider other)
    {
        if (hasTriggered)
            return;

        if (!string.IsNullOrEmpty(playerTag) && !other.CompareTag(playerTag))
            return;

        hasTriggered = true;

        Debug.Log("Thanks for playing! Exiting game...");
        Invoke(nameof(QuitGame), quitDelay);
    }

    private void QuitGame()
    {
#if UNITY_EDITOR
        UnityEditor.EditorApplication.isPlaying = false;
#else
        Application.Quit();
#endif
    }
}

