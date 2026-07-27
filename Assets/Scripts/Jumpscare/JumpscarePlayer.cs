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

    [Header("Ray March Camera")]
    [SerializeField] private RayMarchCameraController rayMarchCameraController;
    [SerializeField] private bool driveRayMarchCamera = true;

    [Header("End Game Jumpscares")]
    [SerializeField] private JumpscareData[] endGameJumpscares;

    public static JumpscarePlayer Instance { get; private set; }

    private Material runtimeMaterial;

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

        DestroyRuntimeMaterial();
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

    public Coroutine PlayRandomJumpscare()
    {
        if (Instance == null)
        {
            Debug.LogWarning($"{nameof(JumpscarePlayer)}.{nameof(PlayRandomJumpscare)} called, but no player exists in the scene.");
            return null;
        }

        JumpscareData randomData = Instance.GetRandomJumpscare();
        if (randomData == null)
        {
            Debug.LogWarning($"{nameof(JumpscarePlayer)}.{nameof(PlayRandomJumpscare)} called, but no endgame jumpscares are assigned.");
            return null;
        }

        return Instance.StartCoroutine(Instance.PlayRoutine(randomData));
    }

    private IEnumerator PlayRoutine(JumpscareData data)
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

        float elapsed = 0f;
        while (elapsed < totalDuration)
        {
            elapsed += Time.unscaledDeltaTime;
            float progress = Mathf.Clamp01(elapsed / totalDuration);

            overlayCanvasGroup.alpha = EvaluateAlpha(elapsed, totalDuration, fadeInDuration, fadeOutDuration);
            SetShaderProgress(data, progress);
            PushRayMarchCamera();

            yield return null;
        }

        overlayCanvasGroup.alpha = fadeOutDuration > 0f ? 0f : 1f;
        SetShaderProgress(data, 1f);
        PushRayMarchCamera();

        HideOverlay();
        FreezePlayer(false);
        SetCursorVisible(false);
    }

    private JumpscareData GetRandomJumpscare()
    {
        if (endGameJumpscares == null || endGameJumpscares.Length == 0)
        {
            return null;
        }

        return endGameJumpscares[Random.Range(0, endGameJumpscares.Length)];
    }

    private void ShowOverlay(JumpscareData data)
    {
        overlayImage.sprite = data.ScareImage;
        DestroyRuntimeMaterial();

        if (data.ScareMaterial != null)
        {
            runtimeMaterial = Instantiate(data.ScareMaterial);
            overlayImage.material = runtimeMaterial;
            SetShaderProgress(data, 0f);
            PushRayMarchCamera();
        }
        else
        {
            overlayImage.material = null;
        }

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
            overlayImage.material = null;
            overlayImage.gameObject.SetActive(false);
        }

        DestroyRuntimeMaterial();
    }

    private static float EvaluateAlpha(float elapsed, float totalDuration, float fadeInDuration, float fadeOutDuration)
    {
        if (fadeInDuration > 0f && elapsed < fadeInDuration)
        {
            return Mathf.Clamp01(elapsed / fadeInDuration);
        }

        if (fadeOutDuration > 0f)
        {
            float fadeOutStart = Mathf.Max(0f, totalDuration - fadeOutDuration);
            if (elapsed >= fadeOutStart)
            {
                return 1f - Mathf.Clamp01((elapsed - fadeOutStart) / fadeOutDuration);
            }
        }

        return 1f;
    }

    private void SetShaderProgress(JumpscareData data, float progress)
    {
        if (runtimeMaterial == null || string.IsNullOrWhiteSpace(data.ShaderProgressProperty))
        {
            return;
        }

        runtimeMaterial.SetFloat(data.ShaderProgressProperty, progress);
    }

    private void PushRayMarchCamera()
    {
        if (!driveRayMarchCamera || rayMarchCameraController == null || runtimeMaterial == null)
        {
            return;
        }

        rayMarchCameraController.PushCamera(runtimeMaterial, GetOverlayAspect());
    }

    private float GetOverlayAspect()
    {
        Rect rect = overlayImage.rectTransform.rect;
        if (rect.height > 0f)
        {
            return rect.width / rect.height;
        }

        return Screen.width / Mathf.Max(1f, (float)Screen.height);
    }

    private void DestroyRuntimeMaterial()
    {
        if (runtimeMaterial == null)
        {
            return;
        }

        Destroy(runtimeMaterial);
        runtimeMaterial = null;
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
