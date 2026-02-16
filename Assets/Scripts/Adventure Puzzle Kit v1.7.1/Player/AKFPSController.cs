using UnityEngine;

namespace AdventurePuzzleKit
{
    public class AKFPSController : MonoBehaviour
    {
        [Header("Movement Speeds")]
        [SerializeField] private float walkSpeed = 3.0f;              // Normal walking speed
        [SerializeField] private float sprintMultiplier = 2.0f;       // Multiplier when sprinting
        [SerializeField] private float crouchSpeed = 1.5f;            // Slower movement when crouched

        [Header("Jump Parameters")]
        [SerializeField] private float jumpForce = 5.0f;              // Force applied when jumping
        [SerializeField] private float gravity = 9.81f;               // Gravity effect when falling

        [Header("Look Sensitivity")]
        [SerializeField] private float mouseSensitivity = 2.0f;       // Mouse sensitivity
        [SerializeField] private float upDownRange = 80.0f;           // Vertical look limit (degrees)

        [Header("Crouch Settings")]
        [SerializeField] private float crouchHeight = 1.0f;           // Height of character when crouching
        [SerializeField] private float standHeight = 1.9f;            // Height when standing
        [SerializeField] private float cameraHeightOffset = 1.05f;   // Camera height offset from character base
        [SerializeField] private float crouchTransitionSpeed = 5.0f;  // Speed of crouch animation
        [SerializeField] private KeyCode crouchKey = KeyCode.LeftControl; // Key to toggle crouch
        [SerializeField] private LayerMask uncrouchObstructionMask = ~0;  // Layers that can block standing up

        [Header("Footstep Audio Settings")]
        [SerializeField] private AudioSource playerAudioSource;       // AudioSource used to play player sounds
        [Space(5)]
        [SerializeField] private AudioClip[] footstepSounds;          // Sounds for walking/running
        [SerializeField] private AudioClip jumpSound;                 // Sound played when jumping

        [Header("Footstep Intervals")]
        [SerializeField] private float walkStepInterval = 0.5f;       // Time between steps when walking
        [SerializeField] private float sprintStepInterval = 0.3f;     // Time between steps when sprinting
        [SerializeField] private float crouchStepInterval = 0.7f;     // Time between steps when crouched
        [SerializeField] private float velocityThreshold = 0.1f;      // Min horizontal velocity before footstep sound plays

        [Header("Control Toggles")]
        [SerializeField] public bool canJump = true; // Toggle for jumping

        public bool canMove = true;                                   // Toggle for player movement
        public bool canRotate = true;                                 // Toggle for player rotation
        private bool canCrouch = true;        // Used to disable crouching when walk speed is too low
        private bool isCrouching = false;     // Tracks crouch state
        private int lastPlayedIndex = -1;     // Used to avoid repeating the same footstep sound
        private bool isMoving;                // True when player is moving
        private float nextStepTime;           // Timer for footstep sounds
        private Camera mainCamera;            // Reference to main camera
        private float verticalRotation;       // Tracks up/down camera rotation
        private Vector3 currentMovement = Vector3.zero; // Full movement vector (incl. gravity)
        private CharacterController characterController; // CharacterController component

        private void Awake()
        {
            characterController = GetComponent<CharacterController>();
            mainCamera = Camera.main;
            SetCameraHeight(cameraHeightOffset);
        }

        private void Update()
        {
            // Handle player controls
            if (canMove) HandleMovement();
            if (canRotate) HandleRotation();
            HandleCrouching();
            HandleFootsteps();
        }

        // Allow speeds to be set dynamically (e.g., for slow states)
        public void SetMovementSpeeds(float newWalkSpeed, float newSprintMultiplier)
        {
            walkSpeed = Mathf.Clamp(newWalkSpeed, 0, 10);
            sprintMultiplier = Mathf.Clamp(newSprintMultiplier, 1, 5);

            // If walking speed is very low, disable crouch (e.g., during cutscenes or slow states)
            canCrouch = newWalkSpeed > 1.0f;
        }

        // Reposition camera to match character height (e.g., for child-scale characters)
        public void SetCameraHeight(float cameraHeightOffset)
        {
            if (mainCamera != null)
            {
                mainCamera.transform.localPosition = new Vector3(0, cameraHeightOffset, 0);
            }
        }

        // Handles player input and movement
        void HandleMovement()
        {
            // Determine speed modifiers based on crouch/sprint state
            float speedMultiplier = Input.GetKey(KeyCode.LeftShift) && !isCrouching ? sprintMultiplier : 1f;
            float speed = isCrouching ? crouchSpeed : walkSpeed;

            // Input axes for movement
            float verticalSpeed = Input.GetAxis("Vertical");
            float horizontalSpeed = Input.GetAxis("Horizontal");

            Vector3 horizontalMovement = new Vector3(horizontalSpeed, 0, verticalSpeed);

            // Normalize to prevent faster diagonal movement
            if (horizontalMovement.magnitude > 1)
            {
                horizontalMovement.Normalize();
            }

            // Apply speed and rotation
            horizontalMovement *= speed * speedMultiplier;
            horizontalMovement = transform.rotation * horizontalMovement;

            HandleGravityAndJumping(); // Apply gravity or jumping if needed

            // Combine horizontal and vertical movement
            currentMovement.x = horizontalMovement.x;
            currentMovement.z = horizontalMovement.z;

            // Apply final movement to character controller
            characterController.Move(currentMovement * Time.deltaTime);

            // Determine if player is actively moving
            isMoving = verticalSpeed != 0 || horizontalSpeed != 0;
        }

        // Apply jumping and gravity
        void HandleGravityAndJumping()
        {
            if (characterController.isGrounded)
            {
                currentMovement.y = -0.5f; // Small push to stay grounded

                if (canJump && Input.GetButtonDown("Jump"))
                {
                    currentMovement.y = jumpForce;

                    // Play jump sound
                    if (playerAudioSource != null && jumpSound != null)
                    {
                        playerAudioSource.PlayOneShot(jumpSound);
                    }
                }
            }
            else
            {
                // Apply gravity over time
                currentMovement.y -= gravity * Time.deltaTime;
            }
        }

        // Rotate player and camera with the mouse
        void HandleRotation()
        {
            // Horizontal rotation
            float mouseXRotation = Input.GetAxis("Mouse X") * mouseSensitivity;
            transform.Rotate(0, mouseXRotation, 0);

            // Vertical rotation (clamped)
            verticalRotation -= Input.GetAxis("Mouse Y") * mouseSensitivity;
            verticalRotation = Mathf.Clamp(verticalRotation, -upDownRange, upDownRange);
            mainCamera.transform.localRotation = Quaternion.Euler(verticalRotation, 0, 0);
        }

        // Handles crouch toggle and transition
        void HandleCrouching()
        {
            // If crouch is disabled, force standing height
            if (!canCrouch)
            {
                if (isCrouching && CanStandUp())
                {
                    isCrouching = false;
                    characterController.height = standHeight;
                    transform.localScale = new Vector3(1, 1, 1); // Reset scale
                    SetCameraHeight(cameraHeightOffset); // Reset camera height
                }
                return;
            }

            // Toggle crouch state on key press
            if (Input.GetKeyDown(crouchKey))
            {
                if (isCrouching)
                {
                    if (CanStandUp())
                    {
                        isCrouching = false;
                    }
                }
                else
                {
                    isCrouching = true;
                }
            }

            // Smoothly transition height and scale
            float targetHeight = isCrouching ? crouchHeight : standHeight;
            float targetScale = isCrouching ? (crouchHeight / standHeight) : 1f;
            float targetCameraHeight = isCrouching ? (cameraHeightOffset * targetScale) : cameraHeightOffset;
            
            characterController.height = Mathf.MoveTowards(characterController.height, targetHeight, Time.deltaTime * crouchTransitionSpeed);
            Vector3 targetScaleVec = new Vector3(1, targetScale, 1);
            transform.localScale = Vector3.Lerp(transform.localScale, targetScaleVec, Time.deltaTime * crouchTransitionSpeed);
            
            // Adjust camera height based on crouch state
            float currentCameraY = mainCamera.transform.localPosition.y;
            float newCameraY = Mathf.Lerp(currentCameraY, targetCameraHeight, Time.deltaTime * crouchTransitionSpeed);
            mainCamera.transform.localPosition = new Vector3(0, newCameraY, 0);
        }

        bool CanStandUp()
        {
            Bounds bounds = characterController.bounds;
            float currentLocalScaleY = Mathf.Max(transform.localScale.y, 0.0001f);
            float parentScaleY = transform.lossyScale.y / currentLocalScaleY;
            float targetTop = bounds.min.y + (standHeight * parentScaleY);
            float extraHeight = targetTop - bounds.max.y;

            if (extraHeight <= 0f)
            {
                return true;
            }

            float checkRadius = Mathf.Min(bounds.extents.x, bounds.extents.z) * 0.95f;
            Vector3 castOrigin = new Vector3(bounds.center.x, bounds.max.y - checkRadius, bounds.center.z);

            return !Physics.SphereCast(
                castOrigin,
                checkRadius,
                Vector3.up,
                out _,
                extraHeight,
                uncrouchObstructionMask,
                QueryTriggerInteraction.Ignore
            );
        }

        // Triggers footstep sounds based on movement and state
        void HandleFootsteps()
        {
            if (GameState.IsInventoryOpen) return; // Don't play footsteps in menus

            // Determine step interval based on crouch/sprint
            float currentStepInterval = isCrouching ? crouchStepInterval : (Input.GetKey(KeyCode.LeftShift) ? sprintStepInterval : walkStepInterval);

            // Use horizontal movement speed only; ignore slight vertical grounding force.
            Vector3 horizontalVelocity = new Vector3(characterController.velocity.x, 0f, characterController.velocity.z);
            float adjustedVelocityThreshold = Mathf.Max(0.05f, velocityThreshold);

            // Play footstep sound if grounded, moving, and enough time has passed
            if (characterController.isGrounded && isMoving && Time.time > nextStepTime && horizontalVelocity.magnitude > adjustedVelocityThreshold)
            {
                PlayFoostepSounds();
                nextStepTime = Time.time + currentStepInterval;
            }
        }

        // Picks and plays a random footstep sound
        void PlayFoostepSounds()
        {
            int randomIndex;

            if (footstepSounds.Length == 1)
            {
                randomIndex = 0;
            }
            else
            {
                // Avoid repeating the last sound
                randomIndex = Random.Range(0, footstepSounds.Length - 1);
                if (randomIndex >= lastPlayedIndex)
                {
                    randomIndex++;
                }
            }

            lastPlayedIndex = randomIndex;
            playerAudioSource.clip = footstepSounds[randomIndex];
            playerAudioSource.Play();
        }

        // Disables player control when needed (e.g., in cutscenes)
        public void SetPlayerDisableMode(bool active)
        {
            canMove = !active;
            canRotate = !active;
        }
    }
}
