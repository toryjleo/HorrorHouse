using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace DaryPalasky
{
    public class TransformationController : MonoBehaviour
    {   
        public List<MaterialsByChangeable> materials = new List<MaterialsByChangeable>();
                
        [SerializeField]
        private float _transform_eyes;                
        public float TransformEyes
        {
            get
            {
                return _transform_eyes;
            }
            set
            {
                _transform_eyes = value;

                UpdateTransformEyes();
                // from banshee
                // Mat_Eyes.SetFloat("_BansheeEyes", _BansheeEyes * (1f / 100f));
                // from girl & boy 
                // Mat_Eyes.SetFloat("_TransformEyes", _TransformEyes * (1f / 100f));
            }
        }
        public void UpdateTransformEyes()
        {
            float finalVal = _transform_eyes * (1f / 100f);

            MaterialsByChangeable materialsByChangeable = materials.Find(mbc => mbc.changeableFrom == ChangeableFrom.Transform_Eyes);

            if (materialsByChangeable != null)
            {
                foreach (Material material in materialsByChangeable.materials)
                {
                    material.SetFloat("_TransformEyes", finalVal);
                }
            }
        }

        [SerializeField]
        public float _disappearing_hair_a;
        public float Disappearing_Hair_A
        {
            get
            {
                return _disappearing_hair_a;
            }
            set
            {
                _disappearing_hair_a = value;

                UpdateDisappearingHairA();
                // from banshee
                /*
                 Mat_Hair.SetFloat("_Disappearing_H_Hair", _Disappearing_H_Hair * (3.5f/100f));
                 */
                // from girl & boy
                // Mat_Hair.SetFloat("_Disappearing_Hair_A", _disappearing_hair_a * (3.5f/100f));
            }
        }
        public void UpdateDisappearingHairA()
        {
            float finalVal = _disappearing_hair_a * (3.5f / 100f);

            MaterialsByChangeable materialsByChangeable = materials.Find(mbc => mbc.changeableFrom == ChangeableFrom.Disappearing_Hair_A);

            if (materialsByChangeable != null)
            {
                foreach (Material material in materialsByChangeable.materials)
                {
                    material.SetFloat("_Disappearing_Hair_A", finalVal);
                }
            }
        }

        [SerializeField]
        public float _disappearing_hair_b;
        public float Disappearing_Hair_B
        {
            get
            {
                return _disappearing_hair_b;
            }
            set
            {
                _disappearing_hair_b = value;

                UpdateDisappearingHairB();
                // from banshee
                // Mat_Hair.SetFloat("_Disappearing_B_Hair", _Disappearing_B_Hair * (3.5f / 100f));
                // from girl & boy
                // Mat_Hair.SetFloat("_Disappearing", _Disappearing * (3.5f/100f));
            }
        }
        public void UpdateDisappearingHairB()
        {
            float finalVal = _disappearing_hair_b * (3.5f / 100f);

            MaterialsByChangeable materialsByChangeable = materials.Find(mbc => mbc.changeableFrom == ChangeableFrom.Disappearing_Hair_B);

            if (materialsByChangeable != null)
            {
                foreach (Material material in materialsByChangeable.materials)
                {
                    material.SetFloat("_Disappearing_Hair_B", finalVal);
                }
            }
        }

        [SerializeField]
        public float _veins;
        public float Veins
        {
            get
            {
                return _veins;
            }
            set
            {
                _veins = value;
                
                UpdateVeins();
                /* from banshee
                Mat_Head.SetFloat("_Veins", finalVal);
                Mat_Body.SetFloat("_Veins", finalVal);
                Mat_Nails.SetFloat("_Veins", finalVal);
                Mat_DressUp.SetFloat("_Veins", finalVal);
                Mat_DressDown.SetFloat("_Veins", finalVal);
                Mat_Laces.SetFloat("_Veins", finalVal);
                */
                // from girl & boy
                // Mat_Head.SetFloat("_Veins", finalVal);
                // Mat_Body.SetFloat("_Veins", finalVal);                
            }
        }
        public void UpdateVeins()
        {
            float finalVal = _veins * (2f / 100f);

            MaterialsByChangeable materialsByChangeable = materials.Find(mbc => mbc.changeableFrom == ChangeableFrom.Veins);

            if (materialsByChangeable != null)
            {
                foreach (Material material in materialsByChangeable.materials)
                {
                    material.SetFloat("_Veins", finalVal);
                }
            }
        }

        [SerializeField]
        public float _transform;
        public float Transform
        {
            get
            {
                return _transform;
            }
            set
            {
                _transform = value;
                
                UpdateTransform();
                /* from banshee
                Mat_Head.SetFloat("_Banshee", finalVal);
                Mat_Body.SetFloat("_Banshee", finalVal);
                Mat_Nails.SetFloat("_Banshee", finalVal);
                Mat_DressUp.SetFloat("_Banshee", finalVal);
                Mat_DressDown.SetFloat("_Banshee", finalVal);
                Mat_Laces.SetFloat("_Banshee", finalVal); 
                */
                /* from girl
                Mat_Head.SetFloat("_Transform", finalVal);
                Mat_Body.SetFloat("_Transform", finalVal);
                Mat_Dress.SetFloat("_Transform", finalVal);
                Mat_Collar.SetFloat("_Transform", finalVal);
                Mat_Ribbon.SetFloat("_Transform", finalVal);
                Mat_Boots.SetFloat("_Transform", finalVal);
                Mat_Teeth.SetFloat("_Transform", finalVal);
                */
                /* from boy
                Mat_Head.SetFloat("_Transform", finalVal);
                Mat_Body.SetFloat("_Transform", finalVal);
                Mat_Blouse.SetFloat("_Transform", finalVal);
                Mat_Shorts.SetFloat("_Transform", finalVal);
                Mat_Socks.SetFloat("_Transform", finalVal);
                Mat_Boots.SetFloat("_Transform", finalVal);
                Mat_Teeth.SetFloat("_Transform", finalVal);
                */
            }
        }
        public void UpdateTransform()
        {
            float finalVal = _transform * (2f / 100f);

            MaterialsByChangeable materialsByChangeable = materials.Find(mbc => mbc.changeableFrom == ChangeableFrom.Transform);

            if (materialsByChangeable != null)
            {
                foreach (Material material in materialsByChangeable.materials)
                {
                    material.SetFloat("_Transform", finalVal);
                }
            }
        }

        [SerializeField]
        public float _human_roughness;
        public float Human_Roughness
        {
            get
            {
                return _human_roughness;
            }
            set
            {
                _human_roughness = value;
                
                UpdateHumanRoughness();
                // from banshee
                /*
                Mat_Head.SetFloat("_Human_Roughness", finalVal);
                Mat_Body.SetFloat("_Human_Roughness", finalVal);
                Mat_Nails.SetFloat("_Human_Roughness", finalVal);
                 */
                // from girl & boy
                // Mat_Head.SetFloat("_Human_Roughness", finalVal);
                // Mat_Body.SetFloat("_Human_Roughness", finalVal);

            }
        }
        public void UpdateHumanRoughness()
        {
            float finalVal = _human_roughness * (10f / 100f);

            MaterialsByChangeable materialsByChangeable = materials.Find(mbc => mbc.changeableFrom == ChangeableFrom.Human_Roughness);

            if (materialsByChangeable != null)
            {
                foreach (Material material in materialsByChangeable.materials)
                {
                    material.SetFloat("_Human_Roughness", finalVal);
                }
            }
        }

        [SerializeField]
        public float _cloth_roughness;
        public float Cloth_Roughness
        {
            get
            {
                return _cloth_roughness;
            }
            set
            {
                _cloth_roughness = value;
                
                UpdateClothRoughness();
                /* from banshee
                Mat_DressUp.SetFloat("_DressRoughness", finalVal);
                Mat_DressDown.SetFloat("_DressRoughness", finalVal);
                Mat_Laces.SetFloat("_DressRoughness", finalVal);
                 */
                /* from girl
                Mat_Dress.SetFloat("_Cloth_Roughness", finalVal);
                Mat_Collar.SetFloat("_Cloth_Roughness", finalVal);
                Mat_Ribbon.SetFloat("_Cloth_Roughness", finalVal);
                Mat_Boots.SetFloat("_Cloth_Roughness", finalVal);
                */
                /* from boy
                Mat_Blouse.SetFloat("_Cloth_Roughness", finalVal);
                Mat_Shorts.SetFloat("_Cloth_Roughness", finalVal);
                Mat_Socks.SetFloat("_Cloth_Roughness", finalVal);
                Mat_Boots.SetFloat("_Cloth_Roughness", finalVal);
                */

            }
        }
        public void UpdateClothRoughness()
        {
            float finalVal = _cloth_roughness * (1f / 100f);

            MaterialsByChangeable materialsByChangeable = materials.Find(mbc => mbc.changeableFrom == ChangeableFrom.Cloth_Roughness);

            if (materialsByChangeable != null)
            {
                foreach (Material material in materialsByChangeable.materials)
                {
                    material.SetFloat("_Cloth_Roughness", finalVal);
                }
            }
        }

        [SerializeField]
        public float _veins_roughness;
        public float Veins_Roughness
        {
            get
            {
                return _veins_roughness;
            }
            set
            {
                _veins_roughness = value;
                
                UpdateVeinsRoughness();
                /* from banshee
                Mat_Head.SetFloat("_Veins_Roughness", finalVal);
                Mat_Body.SetFloat("_Veins_Roughness", finalVal);
                Mat_Nails.SetFloat("_Veins_Roughness", finalVal);
                 */
                // from girl & boy
                // Mat_Head.SetFloat("_Veins_Roughness", finalVal);
                // Mat_Body.SetFloat("_Veins_Roughness", finalVal);
            }
        }
        public void UpdateVeinsRoughness()
        {
            float finalVal = _veins_roughness * (1f / 100f);

            MaterialsByChangeable materialsByChangeable = materials.Find(mbc => mbc.changeableFrom == ChangeableFrom.Veins_Roughness);

            if (materialsByChangeable != null)
            {
                foreach (Material material in materialsByChangeable.materials)
                {
                    material.SetFloat("_Veins_Roughness", finalVal);
                }
            }
        }


        [SerializeField]
        public float _transform_roughness;
        public float Transform_Roughness
        {
            get
            {
                return _transform_roughness;
            }
            set
            {
                _transform_roughness = value;
                
                UpdateTransformRoughness();
                /* from banshee
                Mat_Head.SetFloat("_Banshee_Roughness", finalVal);
                Mat_Body.SetFloat("_Banshee_Roughness", finalVal);
                Mat_Nails.SetFloat("_Banshee_Roughness", finalVal);
                 */
                // from girl & boy
                // Mat_Head.SetFloat("_Transform_Roughness", finalVal);
                // Mat_Body.SetFloat("_Transform_Roughness", finalVal);
            }
        }
        public void UpdateTransformRoughness()
        {
            float finalVal = _transform_roughness * (10f / 100f);

            MaterialsByChangeable materialsByChangeable = materials.Find(mbc => mbc.changeableFrom == ChangeableFrom.Transform_Roughness);

            if (materialsByChangeable != null)
            {
                foreach (Material material in materialsByChangeable.materials)
                {
                    material.SetFloat("_Transform_Roughness", finalVal);
                }
            }
        }

        // these are used for the custom editor
        [SerializeField]
        private bool showAdvancedOptions = false;
        [SerializeField]
        private bool showTransformEyesSection = true;
        [SerializeField]
        private bool showDisappearingHairASection = true;
        [SerializeField]
        private bool showDisappearingHairBSection = true;
        [SerializeField]
        private bool showVeinsSection = true;
        [SerializeField]
        private bool showTransformSection = true;
        [SerializeField]
        private bool showHumanRoughnessSection = true;
        [SerializeField]
        private bool showClothRoughnessSection = true;
        [SerializeField]
        private bool showVeinsRoughnessSection = true;
        [SerializeField]
        private bool showTransformRoughnessSection = true;
    }
}
