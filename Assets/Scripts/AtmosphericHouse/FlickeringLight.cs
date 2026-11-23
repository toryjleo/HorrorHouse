using System;
using UnityEngine;

/// <summary>
/// Flickers a Light by cycling through a sequence of 4 preset settings (intensity + range).
/// The sequence is a list of indices (0-3) into those presets. Each entry is applied for
/// the same amount of time, then the list loops.
/// </summary>
[RequireComponent(typeof(Light))]
public class FlickeringLight : MonoBehaviour
{
    [Serializable]
    private struct LightSetting
    {
        public float intensity;
        public float range;
    }

    [Header("The 4 light settings")]
    [SerializeField]
    private LightSetting[] settings = new LightSetting[4]
    {
        new LightSetting { intensity = 0f, range = 5f },
        new LightSetting { intensity = 1f, range = 8f },
        new LightSetting { intensity = 2f, range = 10f },
        new LightSetting { intensity = 3f, range = 12f },
    };

    private int[] sequence = { 1, 1, 1, 3, 1, 2, 0, 1, 1, 2, 2, 3, 1, 2, 1, 1, 1, 1, 1, 1, 1, 3, 0, 0 };

    [Tooltip("Seconds each entry in the sequence is applied.")]
    [SerializeField] private float secondsPerStep = 0.1f;

    private Light targetLight;
    private int step;
    private float timer;

    private void Awake()
    {
        targetLight = GetComponent<Light>();
    }

    private void OnEnable()
    {
        step = 0;
        timer = 0f;
        Apply();
    }

    private void Update()
    {
        if (sequence == null || sequence.Length == 0 || secondsPerStep <= 0f) return;

        timer += Time.deltaTime;
        while (timer >= secondsPerStep)
        {
            timer -= secondsPerStep;
            step = (step + 1) % sequence.Length;
            Apply();
        }
    }

    private void Apply()
    {
        if (sequence == null || sequence.Length == 0 || settings.Length == 0) return;

        int index = Mathf.Clamp(sequence[step % sequence.Length], 0, settings.Length - 1);
        targetLight.intensity = settings[index].intensity;
        targetLight.range = settings[index].range;
    }
}
