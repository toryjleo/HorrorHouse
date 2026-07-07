using UnityEngine;
using UnityEngine.UI;

public sealed class RayMarchCameraController : MonoBehaviour
{
    [SerializeField] private Material targetMaterial;
    [SerializeField] private Graphic targetGraphic;

    [Header("Pose")]
    [SerializeField] private Vector3 position = new Vector3(0f, 2f, 0f);
    [SerializeField] private float yaw;
    [SerializeField] private float pitch;
    [SerializeField] private float fov = 60f;

    [Header("Input")]
    [SerializeField] private bool rotationInput = true;
    [SerializeField] private bool positionInput = false;
    [SerializeField] private float mouseSensitivity = 0.15f;
    [SerializeField] private float moveSpeed = 3f;

    private Material Material => targetGraphic != null ? targetGraphic.material : targetMaterial;

    private void Update()
    {
        if (rotationInput)
        {
            yaw += Input.GetAxisRaw("Mouse X") * mouseSensitivity;
            pitch -= Input.GetAxisRaw("Mouse Y") * mouseSensitivity;
            pitch = Mathf.Clamp(pitch, -85f, 85f);
        }

        Quaternion rotation = Quaternion.Euler(pitch, yaw, 0f);

        if (positionInput)
        {
            Vector3 move = new Vector3(Input.GetAxisRaw("Horizontal"), 0f, Input.GetAxisRaw("Vertical"));
            position += rotation * move.normalized * (moveSpeed * Time.deltaTime);
        }

        PushCamera(rotation);
    }

    private void PushCamera(Quaternion rotation)
    {
        Material material = Material;
        if (material == null)
        {
            return;
        }

        material.SetVector("_CamPos", position);
        material.SetVector("_CamDir", rotation * Vector3.forward);
        material.SetVector("_CamUp", rotation * Vector3.up);
        material.SetFloat("_CamFov", fov);
        material.SetFloat("_CamAspect", Screen.width / Mathf.Max(1f, (float)Screen.height));
    }
}