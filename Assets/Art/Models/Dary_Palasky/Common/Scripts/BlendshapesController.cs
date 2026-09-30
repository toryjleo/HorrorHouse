using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace DaryPalasky
{
    public class BlendshapesController : MonoBehaviour
    {
        [SerializeField]
        private SkinnedMeshRenderer skinnedMeshRenderer;
        [SerializeField]
        private int[] blendshapeIndices;

        void Start()
        {
            skinnedMeshRenderer = GetComponent<SkinnedMeshRenderer>();
        }

        public void UpdateBlendshapeWeight(float val)
        {            
            for (int i = 0; i < blendshapeIndices.Length; i++)
            {
                skinnedMeshRenderer.SetBlendShapeWeight(blendshapeIndices[i], val);
            }
        }
    }
}
