using UnityEngine;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class RayMarchCamera : MonoBehaviour
{
    [SerializeField] private Shader shader;

    public Material RayMarchMaterial
    {
        get
        {
            if (!rayMarchMat)
            {
                rayMarchMat = new Material(shader); // Make the material locally. Not saved to disk
                rayMarchMat.hideFlags = HideFlags.HideAndDontSave; // Do not let garbage collector destroyed
            }
            return rayMarchMat;
        }
    }


    public Camera Camera
    {
        get
        {
            if (!rayMarchCamera)
            {
                rayMarchCamera = GetComponent<Camera>();
            }
            return rayMarchCamera;
        }
    }



    private Material rayMarchMat;

    private Camera rayMarchCamera;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {

        if (!RayMarchMaterial)
        {
            Graphics.Blit(source, destination);
            return;
        }

        RayMarchMaterial.SetMatrix("_CamFrustum", CamFrustum(Camera));
        RayMarchMaterial.SetMatrix("_CamToWorld", Camera.cameraToWorldMatrix);
        RayMarchMaterial.SetVector("_CamWorldSpace", Camera.transform.position);

        RenderTexture.active = destination;
        GL.PushMatrix();
        GL.LoadOrtho();
        RayMarchMaterial.SetPass(0);
        GL.Begin(GL.QUADS);

        // BL 
        GL.MultiTexCoord2(0, 0.0f, 0.0f);
        GL.Vertex3(0.0f, 0.0f, 3.0f); // Use 3rd value to align with matrix index
        // BR 
        GL.MultiTexCoord2(0, 1.0f, 0.0f);
        GL.Vertex3(1.0f, 0.0f, 2.0f); // Use 3rd value to align with matrix index
        // TR 
        GL.MultiTexCoord2(0, 1.0f, 1.0f);
        GL.Vertex3(1.0f, 1.0f, 1.0f); // Use 3rd value to align with matrix index
        // TL 
        GL.MultiTexCoord2(0, 0.0f, 1.0f);
        GL.Vertex3(0.0f, 1.0f, 0.0f); // Use 3rd value to align with matrix index

        GL.End();
        GL.PopMatrix();
    }

    private Matrix4x4 CamFrustum(Camera cam)
    {
        Matrix4x4 frustum = Matrix4x4.identity;
        float fov = Mathf.Tan(cam.fieldOfView * 0.5f * Mathf.Deg2Rad);

        Vector3 goUp = Vector3.up * fov;
        Vector3 goRight = Vector3.right * fov * cam.aspect;

        Vector3 TL = (-Vector3.forward - goRight + goUp);
        Vector3 TR = (-Vector3.forward + goRight + goUp);
        Vector3 BR = (-Vector3.forward + goRight - goUp);
        Vector3 BL = (-Vector3.forward - goRight - goUp);

        frustum.SetRow(0, TL);
        frustum.SetRow(1, TR);
        frustum.SetRow(2, BR);
        frustum.SetRow(3, BL);


        return frustum;
    }

}
