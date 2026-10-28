using UnityEngine;

/// <summary>
/// Used for swaying garlic on rope assets
/// </summary>
public class GentleSway : MonoBehaviour
{
    public float maxAngle = 6f;     // degrees of swing
    public float speed = 0.6f;      // how fast it sways
    public float noiseScale = 1f;   // randomness

    float seed;
    Quaternion startRot;

    void Start()
    {
        startRot = transform.localRotation;
        seed = Random.value * 100f;   // so each garlic sways differently
    }

    void Update()
    {
        float t = Time.time * speed;
        float x = (Mathf.PerlinNoise(seed, t * noiseScale) - 0.5f) * 2f * maxAngle;
        float z = (Mathf.PerlinNoise(seed + 50f, t * noiseScale) - 0.5f) * 2f * maxAngle;
        transform.localRotation = startRot * Quaternion.Euler(x, 0, z);
    }
}