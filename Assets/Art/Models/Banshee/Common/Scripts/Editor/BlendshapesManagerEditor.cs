using UnityEditor;
using UnityEngine;

using UnityEditor.UIElements;
using UnityEngine.UIElements;

namespace DaryPalasky
{
    [CustomEditor(typeof(BlendshapesManager))]
    public class BlendshapesManagerEditor : Editor
    {
        const string resourceFilename = "blendshapesmanager-custom-editor-uie";
        private BlendshapesManager blendshapesManager;
        private SerializedProperty blendshapesControllersList;

        private void OnEnable()
        {
            blendshapesManager = target as BlendshapesManager;
            // transition = serializedObject.FindProperty("transition");
            blendshapesControllersList = serializedObject.FindProperty("blendshapesControllers");
        }

        public override VisualElement CreateInspectorGUI()
        {
            VisualElement customInspector = new VisualElement();
            var visualTree = Resources.Load(resourceFilename) as VisualTreeAsset;
            visualTree.CloneTree(customInspector);
            customInspector.styleSheets.Add(Resources.Load($"{resourceFilename}-style") as StyleSheet);

            customInspector.Q<Slider>("transition_slider").RegisterValueChangedCallback(evt =>
            {
                // Debug.Log(evt.newValue);
                blendshapesManager.UpdateAll();
            });

            customInspector.Q<Button>("fetch_button").clicked += FetchButtonClick;

            // PropertyField myList = customInspector.Q<PropertyField>("blendshapesmanager_list");

            return customInspector;
        }

        public void FetchButtonClick()
        {
            blendshapesControllersList.ClearArray();

            BlendshapesController[] controllers = blendshapesManager.GetComponentsInChildren<BlendshapesController>();
            foreach (var controller in controllers)
            {
                blendshapesControllersList.arraySize++;

                // Gets a serializedProperty for the new element
                var element = blendshapesControllersList.GetArrayElementAtIndex(blendshapesControllersList.arraySize - 1);

                // Assign the objectReference to the ActionDamage
                element.objectReferenceValue = controller;
            }

            serializedObject.ApplyModifiedProperties();
        }
    }
}