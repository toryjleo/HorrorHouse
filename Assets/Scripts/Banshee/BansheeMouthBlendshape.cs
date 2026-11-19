using UnityEngine;

/// <summary>
/// Opens the banshee's mouth (a blendshape) as the pick-up animation progresses.
///
/// Add to the banshee (anywhere the Animator can be found below it, or assign it). It reads how far through
/// the pick-up state the animation is (0 = start, 1 = end) and ramps the blendshape from 0 to Max Weight
/// between Open Start and Open End. Running in LateUpdate means it applies after the Animator each frame.
/// </summary>
public class BansheeMouthBlendshape : MonoBehaviour
{
    [Header("References")]
    [Tooltip("The banshee's Animator. Found automatically if left empty.")]
    [SerializeField] private Animator animator;

    [Tooltip("The Skinned Mesh Renderer that has the mouth blendshape. Found automatically by shape name if left empty.")]
    [SerializeField] private SkinnedMeshRenderer face;

    [Header("Blendshape")]
    [SerializeField] private string blendShapeName = "Head2.Scream";

    [Tooltip("Blendshape weight when fully open (0-100). Lower it if 100 looks too extreme.")]
    [Range(0f, 100f)] [SerializeField] private float maxWeight = 100f;

    [Header("Timing")]
    [Tooltip("Name of the Animator state that holds the pick-up clip (as shown in the Animator window).")]
    [SerializeField] private string stateName = "PickUp";

    [Tooltip("How far through the animation (0-1) the mouth starts to open.")]
    [Range(0f, 1f)] [SerializeField] private float openStart = 0.6f;

    [Tooltip("How far through the animation (0-1) the mouth is fully open.")]
    [Range(0f, 1f)] [SerializeField] private float openEnd = 0.85f;

    private int shapeIndex = -1;

    private void Awake()
    {
        if (animator == null)
        {
            animator = GetComponentInChildren<Animator>();
        }

        if (face == null)
        {
            foreach (var smr in GetComponentsInChildren<SkinnedMeshRenderer>(true))
            {
                if (smr.sharedMesh != null && smr.sharedMesh.GetBlendShapeIndex(blendShapeName) >= 0)
                {
                    face = smr;
                    break;
                }
            }
        }

        if (face == null || face.sharedMesh == null)
        {
            Debug.LogError($"{nameof(BansheeMouthBlendshape)} on '{name}': no mesh with blendshape '{blendShapeName}' found. Assign the Face field.", this);
            enabled = false;
            return;
        }

        shapeIndex = face.sharedMesh.GetBlendShapeIndex(blendShapeName);
        if (shapeIndex < 0)
        {
            Debug.LogError($"{nameof(BansheeMouthBlendshape)} on '{name}': '{face.name}' has no blendshape named '{blendShapeName}'.", this);
            enabled = false;
        }
    }

    // LateUpdate runs after the Animator, so nothing in the animation can overwrite the weight.
    private void LateUpdate()
    {
        float weight = 0f;

        if (animator != null)
        {
            AnimatorStateInfo state = animator.GetCurrentAnimatorStateInfo(0);

            // Only drive the mouth while the pick-up state is playing (not during Idle or a transition into it).
            if (state.IsName(stateName))
            {
                float t = Mathf.InverseLerp(openStart, openEnd, state.normalizedTime);
                weight = Mathf.SmoothStep(0f, maxWeight, t);
            }
        }

        face.SetBlendShapeWeight(shapeIndex, weight);
    }
}
