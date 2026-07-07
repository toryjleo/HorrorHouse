using UnityEngine;
using UnityEngine.UI;

public sealed class RayMarchCameraController : MonoBehaviour
{
    private static readonly int CamPosId = Shader.PropertyToID("_CamPos");
    private static readonly int CamDirId = Shader.PropertyToID("_CamDir");
    private static readonly int CamUpId = Shader.PropertyToID("_CamUp");
    private static readonly int CamFovId = Shader.PropertyToID("_CamFov");
    private static readonly int CamAspectId = Shader.PropertyToID("_CamAspect");

    [SerializeField] private Material targetMaterial;
    [SerializeField] private Graphic targetGraphic;

    [Header("Pose")]
    [SerializeField] private float yaw;
    [SerializeField] private float pitch;

    [Header("Input")]
    [SerializeField] private bool rotationInput = true;
    [SerializeField] private bool positionInput = false;
    [SerializeField] private float mouseSensitivity = 0.15f;
    [SerializeField] private float moveSpeed = 3f;

    private Material Material => targetGraphic != null ? targetGraphic.material : targetMaterial;

    private void Update()
    {
        Quaternion rotation = GetInputRotation();

        if (positionInput)
        {
            Vector3 move = new Vector3(Input.GetAxisRaw("Horizontal"), 0f, Input.GetAxisRaw("Vertical"));
        }

        PushCamera(Material, GetTargetAspect());
    }

    public void PushCamera(Material material, float aspect)
    {
        if (material == null)
        {
            return;
        }

        Quaternion rotation = Quaternion.Euler(pitch, yaw, 0f);

        material.SetVector(CamDirId, rotation * Vector3.forward);
        material.SetVector(CamUpId, rotation * Vector3.up);
        material.SetFloat(CamAspectId, aspect);
    }

    private Quaternion GetInputRotation()
    {
        if (rotationInput)
        {
            yaw += Input.GetAxisRaw("Mouse X") * mouseSensitivity;
            pitch -= Input.GetAxisRaw("Mouse Y") * mouseSensitivity;
            pitch = Mathf.Clamp(pitch, -85f, 85f);
        }

        return Quaternion.Euler(pitch, yaw, 0f);
    }

    private float GetTargetAspect()
    {
        if (targetGraphic != null)
        {
            Rect rect = targetGraphic.rectTransform.rect;
            if (rect.height > 0f)
            {
                return rect.width / rect.height;
            }
        }

        return Screen.width / Mathf.Max(1f, (float)Screen.height);
    }
}
