using AdventurePuzzleKit;
using UnityEngine;

[CreateAssetMenu(fileName = "New Jumpscare", menuName = "Horror House/Jumpscare Data", order = 0)]
public sealed class JumpscareData : ScriptableObject
{
    [Header("Visuals")]
    [SerializeField] private Sprite scareImage;
    [SerializeField] private Material scareMaterial;

    [Header("Audio")]
    [SerializeField] private Sound scareAudio;

    [Header("Timing")]
    [Min(0f)]
    [SerializeField] private float fadeInDuration = 0.05f;

    [Min(0f)]
    [SerializeField] private float fadeOutDuration = 0f;

    [Header("Cursor")]
    [SerializeField] private bool showMouse;

    public Sprite ScareImage => scareImage;
    public Material ScareMaterial => scareMaterial;
    public Sound ScareAudio => scareAudio;
    public float FadeInDuration => fadeInDuration;
    public float FadeOutDuration => fadeOutDuration;
    public bool ShowMouse => showMouse;

    public float GetAudioDuration(float fallbackDuration)
    {
        if (scareAudio != null && scareAudio.clip != null)
        {
            return scareAudio.clip.length;
        }

        return fallbackDuration;
    }
}
