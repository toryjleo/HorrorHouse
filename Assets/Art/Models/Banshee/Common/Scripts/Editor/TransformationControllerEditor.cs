using UnityEditor;
using UnityEngine;

using UnityEditor.UIElements;
using UnityEngine.UIElements;

namespace DaryPalasky
{
    [CustomEditor(typeof(TransformationController))]
    public class TransformationControllerEditor : Editor
    {
        const string resourceFilename = "transformationcontroller-custom-editor-uie";
        private TransformationController transformationController;
        private SerializedProperty materialsList;

        private VisualElement transformEyesSection;
        private VisualElement disappearingHairASection;
        private VisualElement disappearingHairBSection;
        private VisualElement veinsSection;
        private VisualElement transformSection;
        private VisualElement humanRoughnessSection;
        private VisualElement clothRoughnessSection;
        private VisualElement veinsRoughnessSection;
        private VisualElement transformRoughnessSection;

        private void OnEnable()
        {
            transformationController = target as TransformationController;
            materialsList = serializedObject.FindProperty("materials");
        }

        public override VisualElement CreateInspectorGUI()
        {
            VisualElement customInspector = new VisualElement();
            var visualTree = Resources.Load(resourceFilename) as VisualTreeAsset;
            visualTree.CloneTree(customInspector);
            customInspector.styleSheets.Add(Resources.Load($"{resourceFilename}-style") as StyleSheet);

            transformEyesSection = customInspector.Q<VisualElement>("transform-eyes-section");
            disappearingHairASection = customInspector.Q<VisualElement>("disappearing-hair-a-section");
            disappearingHairBSection = customInspector.Q<VisualElement>("disappearing-hair-b-section");
            veinsSection = customInspector.Q<VisualElement>("veins-section"); 
            transformSection = customInspector.Q<VisualElement>("transform-section"); 
            humanRoughnessSection = customInspector.Q<VisualElement>("human-roughness-section"); 
            clothRoughnessSection = customInspector.Q<VisualElement>("cloth-roughness-section"); 
            veinsRoughnessSection = customInspector.Q<VisualElement>("veins-roughness-section"); 
            transformRoughnessSection = customInspector.Q<VisualElement>("transform-roughness-section");

            customInspector.Q<Slider>("transform_eyes_slider").RegisterValueChangedCallback(evt =>
            {
                // Debug.Log(evt.newValue);
                transformationController.UpdateTransformEyes();
            });
            customInspector.Q<Slider>("disappearing_hair_a_slider").RegisterValueChangedCallback(evt =>
            {
                transformationController.UpdateDisappearingHairA();
            });
            customInspector.Q<Slider>("disappearing_hair_b_slider").RegisterValueChangedCallback(evt =>
            {
                transformationController.UpdateDisappearingHairB();
            });
            customInspector.Q<Slider>("veins_slider").RegisterValueChangedCallback(evt =>
            {
                transformationController.UpdateVeins();
            });
            customInspector.Q<Slider>("transform_slider").RegisterValueChangedCallback(evt =>
            {
                transformationController.UpdateTransform();
            });
            customInspector.Q<Slider>("human_roughness_slider").RegisterValueChangedCallback(evt =>
            {
                transformationController.UpdateHumanRoughness();
            });
            customInspector.Q<Slider>("cloth_roughness_slider").RegisterValueChangedCallback(evt =>
            {
                transformationController.UpdateClothRoughness();
            });
            customInspector.Q<Slider>("veins_roughness_slider").RegisterValueChangedCallback(evt =>
            {
                transformationController.UpdateVeinsRoughness();
            });
            customInspector.Q<Slider>("transform_roughness_slider").RegisterValueChangedCallback(evt =>
            {
                transformationController.UpdateTransformRoughness();
            });

            customInspector.Q<Toggle>("show-transform-eyes-section").RegisterValueChangedCallback(evt =>
            {
                // Debug.Log(evt.newValue);
                if (evt.newValue)
                {
                    transformEyesSection.style.display = DisplayStyle.Flex;
                } else
                {
                    transformEyesSection.style.display = DisplayStyle.None;
                }                
            });
            customInspector.Q<Toggle>("show-disappearing-hair-a-section").RegisterValueChangedCallback(evt =>
            {   
                if (evt.newValue)
                {
                    disappearingHairASection.style.display = DisplayStyle.Flex;
                }
                else
                {
                    disappearingHairASection.style.display = DisplayStyle.None;
                }
            });
            customInspector.Q<Toggle>("show-disappearing-hair-b-section").RegisterValueChangedCallback(evt =>
            {
                if (evt.newValue)
                {
                    disappearingHairBSection.style.display = DisplayStyle.Flex;
                }
                else
                {
                    disappearingHairBSection.style.display = DisplayStyle.None;
                }
            });
            customInspector.Q<Toggle>("show-veins-section").RegisterValueChangedCallback(evt =>
            {
                if (evt.newValue)
                {
                    veinsSection.style.display = DisplayStyle.Flex;
                }
                else
                {
                    veinsSection.style.display = DisplayStyle.None;
                }
            });
            customInspector.Q<Toggle>("show-transform-section").RegisterValueChangedCallback(evt =>
            {
                if (evt.newValue)
                {
                    transformSection.style.display = DisplayStyle.Flex;
                }
                else
                {
                    transformSection.style.display = DisplayStyle.None;
                }
            });
            customInspector.Q<Toggle>("show-human-roughness-section").RegisterValueChangedCallback(evt =>
            {
                if (evt.newValue)
                {
                    humanRoughnessSection.style.display = DisplayStyle.Flex;
                }
                else
                {
                    humanRoughnessSection.style.display = DisplayStyle.None;
                }
            });
            customInspector.Q<Toggle>("show-cloth-roughness-section").RegisterValueChangedCallback(evt =>
            {
                if (evt.newValue)
                {
                    clothRoughnessSection.style.display = DisplayStyle.Flex;
                }
                else
                {
                    clothRoughnessSection.style.display = DisplayStyle.None;
                }
            });
            customInspector.Q<Toggle>("show-veins-roughness-section").RegisterValueChangedCallback(evt =>
            {
                if (evt.newValue)
                {
                    veinsRoughnessSection.style.display = DisplayStyle.Flex;
                }
                else
                {
                    veinsRoughnessSection.style.display = DisplayStyle.None;
                }
            });
            customInspector.Q<Toggle>("show-transform-roughness-section").RegisterValueChangedCallback(evt =>
            {
                if (evt.newValue)
                {
                    transformRoughnessSection.style.display = DisplayStyle.Flex;
                }
                else
                {
                    transformRoughnessSection.style.display = DisplayStyle.None;
                }
            });

            // PropertyField myList = customInspector.Q<PropertyField>("blendshapesmanager_list");

            return customInspector;
        }
    }
}