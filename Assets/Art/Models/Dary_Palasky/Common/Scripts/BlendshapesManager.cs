using System.Collections.Generic;
using UnityEngine;

namespace DaryPalasky
{
    public class BlendshapesManager : MonoBehaviour
    {
        [SerializeField]
        private float transition;
        [SerializeField]
        private List<BlendshapesController> blendshapesControllers = new List<BlendshapesController>();

        [SerializeField]
        private bool showAdvancedOptions = false;

        /// <summary>Use this to set the transition</summary>
        public float Transition
        {
            get
            {
                return transition;
            }
            set
            {
                transition = value;

                UpdateAll();
            }
        }

        /// <summary>It should be used only from the Editor script
        ///  use the property Transition instead.
        /// </summary>
        public void UpdateAll()
        {
            for (int i = 0; i < blendshapesControllers.Count; i++)
            {
                blendshapesControllers[i].UpdateBlendshapeWeight(transition);
            }
        }
    }
}
