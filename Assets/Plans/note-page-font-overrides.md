# Per-page font overrides for custom notes

Status: Proposed design. This document does not implement the feature.

## Goal

Let each text entry (page) in a custom note optionally use its own font. Keep the font override beside that page's text in the Inspector so the relationship is clear.

Start with one working custom font as the note's default. Additional fonts are optional.

## Inspector layout

The note retains its existing default font setting. Each entry in the Note Pages list contains:

- **Text:** the existing multiline page text.
- **Font Override (Optional):** a `TMP_FontAsset` reference. Leave it empty to use the note's default font.

Example:

```text
Default Font: My Custom Font SDF

Note Pages
  Page 1
    Text: "I heard something downstairs."
    Font Override (Optional): None (uses default)

  Page 2
    Text: "DO NOT OPEN THE DOOR."
    Font Override (Optional): Another Font SDF

  Page 3
    Text: "I should have listened."
    Font Override (Optional): None (uses default)
```

An empty override field is the off option; a separate checkbox or enum is unnecessary. Assign a font asset to enable the override, and clear it to return to the default. Use TextMeshPro font assets, rather than assigning source `.ttf` or `.otf` files directly.

## Display behavior

- On opening a note, apply the current page's text and resolved font.
- On both next-page and previous-page navigation, update text and font together.
- Resolve the font as the page override when assigned, otherwise the note's default font.
- Always apply the resolved font, including when returning to a page with no override. Never inherit the font from the previously displayed page or note.
- Keep the existing shared TMP text object. Separate text objects are not required.
- Preserve the note's existing font size, color, text area, audio, and navigation behavior.

> [!IMPORTANT]
> The existing `FillNoteText` method in `CustomNoteUIManager` only sets `customNoteTextUI.text`. It does **not** set the font.
> The UI manager needs a new method (or `FillNoteText` needs to be extended) to accept and apply a `TMP_FontAsset` alongside the text.
> Without this, `NextPage` and `BackPage` will update the text but the font will remain whatever `CustomNoteInitialize` set on open.

The default font should be assigned. If both the override and default are missing, log a configuration warning and fall back to whatever font the TMP component already has in its prefab defaults.

## Implementation outline

Scope the first implementation to `CustomNoteController`, `CustomNoteUIManager`, and `CustomNoteEditor`. Other note types can be considered separately.

Represent each page as a serializable entry containing its text and optional `TMP_FontAsset` override.

Route opening, next-page, and previous-page display through a common page-display method so all paths apply the same font resolution rules.

Handle empty page lists safely, without indexing into a missing entry.

### Custom editor prototype

Replace the current `noteText` property field with a loop that draws each page entry's text and font override together. A working starting point:

```csharp
// In CustomNoteEditor, replace the existing noteText PropertyField draw
// with a loop over the new pages array.

SerializedProperty pages = serializedObject.FindProperty("pages");

EditorGUILayout.LabelField("Note Pages", EditorStyles.boldLabel);
pages.arraySize = EditorGUILayout.IntField("Size", pages.arraySize);

for (int i = 0; i < pages.arraySize; i++)
{
    SerializedProperty entry = pages.GetArrayElementAtIndex(i);
    EditorGUILayout.LabelField($"Page {i + 1}", EditorStyles.miniBoldLabel);
    EditorGUI.indentLevel++;
    EditorGUILayout.PropertyField(entry.FindPropertyRelative("text"), new GUIContent("Text"));
    EditorGUILayout.PropertyField(entry.FindPropertyRelative("fontOverride"), new GUIContent("Font Override (Optional)"));
    EditorGUI.indentLevel--;
    EditorGUILayout.Space(4);
}
```

This assumes a serializable struct on the controller side:

```csharp
[System.Serializable]
public struct NotePageEntry
{
    [TextArea(4, 8)] public string text;
    public TMP_FontAsset fontOverride;
}

[SerializeField] private NotePageEntry[] pages;
```

## Verification

1. Open a note: its text, page order, and default font display correctly.
2. Open a three-page note with default / override / default fonts. Confirm each page displays the expected font.
3. Navigate backward through those pages and confirm the same result.
4. Close on an overridden page, then reopen and check the opening page's font.
5. Clear an override and confirm that page returns to the default font.
6. Save and reload the scene and prefab to verify the text and font assignments persist.
7. Check empty pages and missing font assignments for clear, safe behavior.

## Out of scope

This feature assigns one font to each page. Multiple independently positioned text blocks on one page, per-page size and color overrides, and font-style enums are separate features.
