using System.Collections.Generic;
using UnityEngine;

namespace DaryPalasky
{
    [System.Serializable]
    public class MaterialsByChangeable
    {
        public ChangeableFrom changeableFrom;
        public List<Material> materials;

        public MaterialsByChangeable()
        {
            this.changeableFrom = ChangeableFrom.None;
            this.materials = new List<Material>();
        }

        public MaterialsByChangeable(ChangeableFrom _changeableFrom, List<Material> _materials)
        {
            this.changeableFrom = _changeableFrom;
            this.materials = _materials;
        }
    }
}
