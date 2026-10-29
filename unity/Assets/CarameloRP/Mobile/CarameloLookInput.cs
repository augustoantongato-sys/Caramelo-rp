using UnityEngine;
using UnityEngine.EventSystems;

namespace CarameloRP
{
    // Put this on a transparent UI panel covering the right side of the screen.
    public sealed class CarameloLookInput : MonoBehaviour, IPointerDownHandler, IDragHandler
    {
        [SerializeField] private CarameloCameraFollow cameraFollow;
        [SerializeField, Range(0.1f, 2f)] private float sensitivity = 1f;
        private Vector2 previous;

        public void OnPointerDown(PointerEventData eventData) { previous = eventData.position; }

        public void OnDrag(PointerEventData eventData)
        {
            if (!cameraFollow) return;
            Vector2 current = eventData.position;
            cameraFollow.SetLookInput((current - previous) * sensitivity);
            previous = current;
        }
    }
}