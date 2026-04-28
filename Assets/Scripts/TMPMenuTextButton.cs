using UnityEngine;
using TMPro;
using UnityEngine.EventSystems;

public class TMPMenuTextButton : MonoBehaviour,
    IPointerEnterHandler,
    IPointerExitHandler,
    IPointerClickHandler,
    ISelectHandler,
    IDeselectHandler
{
    [SerializeField] TMP_Text text;

    [Header("Colors")]
    [SerializeField] Color normalColor = Color.white;
    [SerializeField] Color hoverColor = Color.red;
    [SerializeField] Color selectedColor = Color.red;

    bool isHovered;
    bool isSelected;

    void Reset() => text = GetComponentInChildren<TMP_Text>();

    void OnEnable()
    {
        isHovered = false;
        isSelected = EventSystem.current && EventSystem.current.currentSelectedGameObject == gameObject;
        ApplyColor();
    }

    void OnDisable()
    {
        isHovered = false;
        isSelected = false;
    }

    public void OnPointerEnter(PointerEventData eventData)
    {
        isHovered = true;
        ApplyColor();
    }

    public void OnPointerExit(PointerEventData eventData)
    {
        isHovered = false;
        ApplyColor();
    }

    public void OnPointerClick(PointerEventData eventData)
    {
        // Clicking a Selectable will usually also Select it, but this guarantees
        // the text color updates even if selection isn't changing.
        isSelected = true;
        ApplyColor();
    }

    public void OnSelect(BaseEventData eventData)
    {
        isSelected = true;
        ApplyColor();
    }

    public void OnDeselect(BaseEventData eventData)
    {
        isSelected = false;
        ApplyColor();
    }

    void ApplyColor()
    {
        if (!text) return;

        text.overrideColorTags = true;

        if (isSelected) text.color = selectedColor;
        else if (isHovered) text.color = hoverColor;
        else text.color = normalColor;
    }
}
