using System.Collections;
using AdventurePuzzleKit;
using UnityEngine;
using UnityEngine.UI;

public sealed class JumpscarePlayer : MonoBehaviour
{
    private const float MissingAudioFallbackDuration = 0.5f;

    [Header("Overlay")]
    [SerializeField] private Image overlayImage;
    [SerializeField] private CanvasGroup overlayCanvasGroup;

    public static JumpscarePlayer Instance { get; private set; }

    private void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Debug.LogWarning($"Multiple {nameof(JumpscarePlayer)} instances found. Using '{Instance.name}'.");
            return;
        }

        Instance = this;
        HideOverlay();
    }

    private void OnDestroy()
    {
        if (Instance == this)
        {
            Instance = null;
        }
    }

    public static Coroutine Play(JumpscareData data)
    {
        if (Instance == null)
        {
            Debug.LogWarning($"{nameof(JumpscarePlayer)}.{nameof(Play)} called, but no player exists in the scene.");
            return null;
        }

        return Instance.StartCoroutine(Instance.PlayRoutine(data));
    }

    public IEnumerator PlayRoutine(JumpscareData data)
    {
        if (data == null)
        {
            Debug.LogWarning($"{nameof(JumpscarePlayer)} cannot play a null {nameof(JumpscareData)}.");
            yield break;
        }

        if (overlayImage == null || overlayCanvasGroup == null)
        {
            Debug.LogWarning($"{nameof(JumpscarePlayer)} requires an overlay Image and CanvasGroup.");
            yield break;
        }

        float totalDuration = data.GetAudioDuration(MissingAudioFallbackDuration);
        if (data.ScareAudio == null || data.ScareAudio.clip == null)
        {
            Debug.LogWarning($"{data.name} has no scare audio clip. Using {MissingAudioFallbackDuration:0.##}s fallback duration.");
        }

        ShowOverlay(data);
        FreezePlayer(true);
        SetCursorVisible(data.ShowMouse);
        PlaySound(data.ScareAudio);

        float fadeInDuration = Mathf.Min(data.FadeInDuration, totalDuration);
        float fadeOutDuration = Mathf.Min(data.FadeOutDuration, Mathf.Max(0f, totalDuration - fadeInDuration));
        float holdDuration = Mathf.Max(0f, totalDuration - fadeInDuration - fadeOutDuration);

        yield return FadeAlpha(0f, 1f, fadeInDuration);

        if (holdDuration > 0f)
        {
            yield return new WaitForSecondsRealtime(holdDuration);
        }

        yield return FadeAlpha(1f, 0f, fadeOutDuration);

        HideOverlay();
        FreezePlayer(false);
        SetCursorVisible(false);
    }

    private void ShowOverlay(JumpscareData data)
    {
        overlayImage.sprite = data.ScareImage;
        overlayImage.material = data.ScareMaterial;
        overlayCanvasGroup.alpha = 0f;
        overlayCanvasGroup.blocksRaycasts = true;
        overlayCanvasGroup.interactable = false;
        overlayImage.gameObject.SetActive(true);
    }

    private void HideOverlay()
    {
        if (overlayCanvasGroup != null)
        {
            overlayCanvasGroup.alpha = 0f;
            overlayCanvasGroup.blocksRaycasts = false;
            overlayCanvasGroup.interactable = false;
        }

        if (overlayImage != null)
        {
            overlayImage.gameObject.SetActive(false);
        }
    }

    private IEnumerator FadeAlpha(float from, float to, float duration)
    {
        if (duration <= 0f)
        {
            overlayCanvasGroup.alpha = to;
            yield break;
        }

        float elapsed = 0f;
        while (elapsed < duration)
        {
            elapsed += Time.unscaledDeltaTime;
            overlayCanvasGroup.alpha = Mathf.Lerp(from, to, Mathf.Clamp01(elapsed / duration));
            yield return null;
        }

        overlayCanvasGroup.alpha = to;
    }

    private static void FreezePlayer(bool freeze)
    {
        if (AKDisableManager.instance != null)
        {
            AKDisableManager.instance.DisablePlayerDefault(freeze, false, false);
        }
    }

    private static void PlaySound(Sound sound)
    {
        if (sound != null && AKAudioManager.instance != null)
        {
            AKAudioManager.instance.Play(sound);
        }
    }

    private static void SetCursorVisible(bool visible)
    {
        Cursor.visible = visible;
        Cursor.lockState = visible ? CursorLockMode.None : CursorLockMode.Locked;
    }
}
