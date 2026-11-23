using System.Collections;
using AdventurePuzzleKit;
using AdventurePuzzleKit.FlashlightSystem;
using UnityEngine;
using UnityEngine.Events;

/// <summary>
/// Banshee ending: plays the pick-up animation, lerps the player into the banshee's hand,
/// then carries the player with the hand (toward the mouth) until the "eaten" event fires.
///
/// The player is parented to an unscaled "carrier" object that copies the hand's pose every frame,
/// so the player is not scaled up by the giant banshee's hierarchy.
/// </summary>
public class BansheeGrabSequence : MonoBehaviour
{
    [Header("References")]
    [Tooltip("The banshee's Animator.")]
    [SerializeField] private Animator animator;

    [Tooltip("Where the player is lerped to (roughly where the hand is at the grab). Its position is where the player's feet go; its forward is where the player faces.")]
    [SerializeField] private Transform pickupLocation;

    [Tooltip("The witch's hand bone. After the lerp, the player follows this (position only).")]
    [SerializeField] private Transform handToFollow;

    [Tooltip("Optional: BansheeLookAtIK on the Animator's GameObject. Makes her look at the player once the sequence starts.")]
    [SerializeField] private BansheeLookAtIK lookAt;


    [Tooltip("Player's AKFPSController. Found automatically if left empty.")]
    [SerializeField] private AKFPSController player;

    [Header("Player Light")]
    [Tooltip("Prefab with a Light + FlickeringLight. Spawned as a child of the player when the sequence starts. Leave empty for no light.")]
    [SerializeField] private GameObject playerLightPrefab;

    [Tooltip("Local position of the light relative to the player.")]
    [SerializeField] private Vector3 playerLightOffset = new Vector3(0f, 1.5f, 0f);

    [Header("Timing")]

    [Tooltip("How long the lerp from the player's position into the hand takes.")]
    [SerializeField] private float snapDuration = 2.0f;

    [Header("Drop Into Mouth")]
    [Tooltip("Empty inside her mouth/throat, parented to her head bone so it moves with her. The player drops to this point.")]
    [SerializeField] private Transform mouthTarget;

    [Tooltip("Name of the Animator state holding the pick-up clip (as in the Animator window).")]
    [SerializeField] private string dropStateName = "PickUp";

    [Tooltip("How far through the animation (0-1) the player is dropped. Match this to when the mouth is open.")]
    [Range(0f, 1f)][SerializeField] private float dropAtNormalizedTime = 0.9f;

    [Tooltip("How long the drop takes, in seconds.")]
    [SerializeField] private float dropDuration = 0.35f;

    [Tooltip("Fired right after the player lands in the mouth. Hook up the fade, sound and ending here.")]
    [SerializeField] private UnityEvent onEaten;

    /*[Tooltip("Seconds after the player is in the hand before On Eaten fires. Ignored if the animation calls the 'Eat' event first.")]
    [SerializeField] private float eatDelay = 3.0f;

    [Header("Camera")]
    [Tooltip("How quickly the camera turns toward the look target while carried.")]
    [SerializeField] private float lookSpeed = 2.0f;

    [Header("Events")]
    [Tooltip("Fired when the player has been eaten. Hook up the fade / sound / ending here.")]
    [SerializeField] private UnityEvent onEaten;*/

    [Header("Testing")]
    [Tooltip("Press this key in Play mode to start the sequence. Set to None to disable.")]
    [SerializeField] private KeyCode testKey = KeyCode.G;

    //private Camera playerCamera;
    private bool started;
    private bool carrying;
    private bool inMouth;
    private Vector3 handLocalOffset; // Player position in the hand's local space, captured when the lerp ends
    //private bool cameraSteering;

    private void Awake()
    {
        if (player == null)
        {
            player = FindFirstObjectByType<AKFPSController>();
        }
        if (animator == null)
        {
            animator = GetComponentInChildren<Animator>();
        }
    }

    private void Update()
    {
        if (testKey != KeyCode.None && Input.GetKeyDown(testKey))
        {
            StartSequence();
        }
    }

    /// <summary>Starts the ending. Call this from the fall hitbox.</summary>
    public void StartSequence()
    {
        // TODO: Delete 'started' var and use a reference to the Coroutine instead.
        if (started) return;

        if (player == null || pickupLocation == null || handToFollow == null || animator == null)
        {
            Debug.LogError($"{nameof(BansheeGrabSequence)} on '{name}' is missing a reference (player, pickupLocation, handToFollow or animator).", this);
            return;
        }

        started = true;
        StartCoroutine(Sequence());
    }

    // Animation event: add an event named "Eat" to the clip at the frame the hand reaches the mouth.
    //public void Eat() => eatSignalled = true;

    private IEnumerator Sequence()
    {
        LockPlayer();
        SpawnPlayerLight();

        // Flashlight off, and the player can't turn it back on during the sequence.
        if (FlashlightController.instance != null)
        {
            FlashlightController.instance.ForceOff(true);
        }

        animator.SetBool("IsPickingUp", true);

        if (lookAt != null)
        {
            lookAt.StartLooking();
        }


        yield return SnapIntoHand();

        // Carried by the hand until the animation is far enough along for the drop.
        yield return new WaitUntil(() =>
        {
            AnimatorStateInfo s = animator.GetCurrentAnimatorStateInfo(0);
            return s.IsName(dropStateName) && s.normalizedTime >= dropAtNormalizedTime;
        });

        yield return DropIntoMouth();

        onEaten?.Invoke();
    }

    private IEnumerator DropIntoMouth()
    {
        // Let go of the hand.
        carrying = false;

        if (mouthTarget == null)
        {
            Debug.LogWarning($"{nameof(BansheeGrabSequence)} on '{name}': Mouth Target is not assigned, skipping the drop.", this);
            yield break;
        }

        Transform p = player.transform;
        Vector3 startPos = p.position;

        float t = 0f;
        while (t < dropDuration)
        {
            t += Time.deltaTime;
            float k = Mathf.Clamp01(t / dropDuration);

            // k * k starts slow and speeds up, like falling.
            p.position = Vector3.Lerp(startPos, mouthTarget.position, k * k);

            yield return null;
        }

        // Stay inside the mouth as her head keeps moving.
        inMouth = true;
    }

    private void SpawnPlayerLight()
    {
        if (playerLightPrefab == null) return;

        GameObject lightObj = Instantiate(playerLightPrefab, player.transform);
        lightObj.transform.localPosition = playerLightOffset;
        lightObj.transform.localRotation = Quaternion.identity;
    }

    /// <summary>
    /// Locks player in place but allow for rotation.
    /// </summary>
    private void LockPlayer()
    {
        player.SetCutsceneLock(true);
        player.canRotate = true;

        // A CharacterController fights being moved or parented, so turn it off.
        var cc = player.GetComponent<CharacterController>();
        if (cc != null) cc.enabled = false;

        // No more physics on the player while in the banshee's hand.
        var rb = player.GetComponent<Rigidbody>();
        if (rb != null) rb.isKinematic = true;

        /*playerCamera = player.GetComponentInChildren<Camera>();
        cameraSteering = true;*/
    }

    private IEnumerator SnapIntoHand()
    {

        Transform p = player.transform;
        Vector3 startPos = p.position;
        Quaternion startRot = p.rotation;

        float t = 0f;
        while (t < snapDuration)
        {
            t += Time.deltaTime;
            float k = Mathf.SmoothStep(0f, 1f, Mathf.Clamp01(t / snapDuration));

            // Lerp toward the hand's current pose so the player tracks it even while it moves.
            p.SetPositionAndRotation(
                Vector3.Lerp(startPos, pickupLocation.position, k),
                Quaternion.Slerp(startRot, pickupLocation.rotation, k));

            yield return null;
        }

        // Remember where the player sits relative to the hand right now, so there is no pop when following starts.
        handLocalOffset = handToFollow.InverseTransformPoint(p.position);
        carrying = true;
    }

    // LateUpdate runs after the Animator, so the player follows the hand's final pose for this frame.
    private void LateUpdate()
    {
        if (carrying)
        {
            // Position only: rotation stays under the player's mouse look.
            player.transform.position = handToFollow.TransformPoint(handLocalOffset);
        }
        else if (inMouth)
        {
            player.transform.position = mouthTarget.position;
        }

        // Steer the camera for the whole sequence (grab, lerp and carry), not just while carried.
        /*if (cameraSteering && playerCamera != null)
        {
            Quaternion want;
            if (lookTarget != null)
            {
                want = Quaternion.LookRotation(lookTarget.position - playerCamera.transform.position, Vector3.up);
            }
            else
            {
                // No look target: level the view so the player isn't left staring at the floor.
                want = Quaternion.LookRotation(Vector3.ProjectOnPlane(player.transform.forward, Vector3.up), Vector3.up);
            }

            playerCamera.transform.rotation = Quaternion.Slerp(playerCamera.transform.rotation, want, Time.deltaTime * lookSpeed);
        }*/
    }

}
