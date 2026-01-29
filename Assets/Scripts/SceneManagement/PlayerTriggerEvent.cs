using UnityEngine;
using UnityEngine.Events;

public class PlayerTriggerEvent : MonoBehaviour
{
    [SerializeField] private string playerTag = "Player";
    public UnityEvent OnPlayerTrigger;

    private void OnTriggerEnter(Collider other)
    {
        if (!other.CompareTag(playerTag))
        {
            return;
        }

        OnPlayerTrigger?.Invoke();
    }
}
