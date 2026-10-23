using TMPro;
using UnityEngine;

namespace AdventurePuzzleKit.NoteSystem
{
    [CreateAssetMenu(fileName = "Note Page Style", menuName = "AdventurePuzzleKit/Note Page Style")]
    public class NotePageStyle : ScriptableObject
    {
        [Tooltip("Leave empty to use the note's default font.")]
        [InspectorName("Font")] public TMP_FontAsset fontOverride;
        [InspectorName("Font Size"), Min(1)] public int fontSizeOverride = 25;
    }
}
