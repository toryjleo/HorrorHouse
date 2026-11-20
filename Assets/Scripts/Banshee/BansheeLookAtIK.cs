using UnityEngine;

/// <summary>
/// Makes a Humanoid character turn her head (and eyes, and a little of her body) toward a target using the
/// Animator's look-at IK.
///
/// Setup:
///  - Put this on the SAME GameObject as the Animator (OnAnimatorIK only fires there).
///  - In the Animator window: Layers tab -> gear icon on the layer -> tick "IK Pass".
///  - Call StartLooking() when she should begin looking at the target.
/// </summary>
[RequireComponent(typeof(Animator))]
public class BansheeLookAtIK : MonoBehaviour
{
    [Tooltip("What she looks at. If empty, the main camera (the player's view) is used.")]
    [SerializeField] private Transform target;

    [Header("Weights (0 = ignore the look-at, 1 = full)")]
    [Range(0f, 1f)] [SerializeField] private float headWeight = 1f;
    [Range(0f, 1f)] [SerializeField] private float bodyWeight = 0.2f;
    [Range(0f, 1f)] [SerializeField] private float eyesWeight = 1f;
    [Tooltip("0 = head may turn as far as it can, 1 = head barely turns. Raise this if the neck twists too far.")]
    [Range(0f, 1f)] [SerializeField] private float clampWeight = 0.5f;

    [Header("Timing")]
    [Tooltip("Seconds to blend the look-at in (and out).")]
    [SerializeField] private float blendTime = 1.0f;

    private Animator animator;
    private bool looking;
    private float weight; // current overall blend, 0..1

    private void Awake()
    {
        animator = GetComponent<Animator>();
    }

    /// <summary>Begin turning toward the target.</summary>
    public void StartLooking() => looking = true;

    /// <summary>Blend back to the animation's own head movement.</summary>
    public void StopLooking() => looking = false;

    private void Update()
    {
        float step = blendTime > 0f ? Time.deltaTime / blendTime : 1f;
        weight = Mathf.MoveTowards(weight, looking ? 1f : 0f, step);
    }

    private void OnAnimatorIK(int layerIndex)
    {
        if (target == null && Camera.main != null)
        {
            target = Camera.main.transform;
        }

        if (target == null || weight <= 0f)
        {
            animator.SetLookAtWeight(0f);
            return;
        }

        animator.SetLookAtWeight(weight, bodyWeight, headWeight, eyesWeight, clampWeight);
        animator.SetLookAtPosition(target.position);
    }
}
