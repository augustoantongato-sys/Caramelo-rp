using UnityEngine;
using UnityEngine.Events;

namespace CarameloRP
{
    /// <summary>
    /// Add to a collider to make a world object interactable.
    /// Assign an action in the Inspector (for example, open a gate or show a shop panel).
    /// </summary>
    [RequireComponent(typeof(Collider))]
    public sealed class CarameloInteractable : MonoBehaviour
    {
        [TextArea] public string prompt = "Interagir";
        public UnityEvent onInteract;

        public void Interact(GameObject actor)
        {
            onInteract?.Invoke();
        }
    }
}