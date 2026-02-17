using UnityEngine;

namespace AdventurePuzzleKit
{
    /// <summary>
    /// Plays a looping ambient sound (music / atmosphere) when the scene starts.
    /// Place on any scene GameObject — assign the Sound ScriptableObject in the Inspector.
    /// Make sure the Sound SO has "Loop" checked.
    /// </summary>
    public class AmbiencePlayer : MonoBehaviour
    {
        [Header("Ambient Sound")]
        [Tooltip("Sound ScriptableObject to loop. Ensure 'Loop' is enabled on the SO.")]
        [SerializeField] private Sound ambienceSound;

        [Header("Options")]
        [Tooltip("If true, fades in gradually instead of starting at full volume.")]
        [SerializeField] private bool fadeIn = false;
        [SerializeField] private float fadeInDuration = 3f;

        private void Start()
        {
            if (ambienceSound == null)
            {
                Debug.LogWarning("AmbiencePlayer: No ambience Sound assigned.", this);
                return;
            }

            AKAudioManager.instance.Play(ambienceSound);

            if (fadeIn)
            {
                StartCoroutine(FadeInCoroutine());
            }
        }

        private System.Collections.IEnumerator FadeInCoroutine()
        {
            // Find the source that AKAudioManager created for this Sound
            if (ambienceSound.source == null) yield break;

            float targetVolume = ambienceSound.source.volume;
            ambienceSound.source.volume = 0f;

            float elapsed = 0f;
            while (elapsed < fadeInDuration)
            {
                elapsed += Time.deltaTime;
                ambienceSound.source.volume = Mathf.Lerp(0f, targetVolume, elapsed / fadeInDuration);
                yield return null;
            }

            ambienceSound.source.volume = targetVolume;
        }

        private void OnDestroy()
        {
            // Stop ambience when this object is destroyed (e.g., scene unload)
            if (ambienceSound != null && AKAudioManager.instance != null)
            {
                AKAudioManager.instance.StopPlaying(ambienceSound);
            }
        }
    }
}
