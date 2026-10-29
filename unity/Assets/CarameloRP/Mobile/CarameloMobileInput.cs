using UnityEngine;
using UnityEngine.EventSystems;

namespace CarameloRP
{
    // Add to a UI joystick area. Assign the knob RectTransform in the Inspector.
    public sealed class CarameloMobileInput : MonoBehaviour, IPointerDownHandler, IDragHandler, IPointerUpHandler
    {
        [SerializeField] private RectTransform knob;
        [SerializeField, Range(20f, 160f)] private float radius = 85f;
        public static Vector2 Move { get; private set; }
        public static bool SprintHeld { get; private set; }
        public static bool JumpPressed { get; private set; }

        private RectTransform area;
        private void Awake() { area = transform as RectTransform; }

        public void OnPointerDown(PointerEventData eventData) { OnDrag(eventData); }
        public void OnDrag(PointerEventData eventData)
        {
            if (area == null) return;
            Vector2 local;
            if (!RectTransformUtility.ScreenPointToLocalPointInRectangle(area, eventData.position,
                eventData.pressEventCamera, out local)) return;
            Vector2 normalized = Vector2.ClampMagnitude(local / radius, 1f);
            Move = normalized;
            if (knob != null) knob.anchoredPosition = normalized * radius;
        }
        public void OnPointerUp(PointerEventData eventData)
        {
            Move = Vector2.zero;
            if (knob != null) knob.anchoredPosition = Vector2.zero;
        }

        // Wire these to UI Button PointerDown/PointerUp or call from a small UI adapter.
        public void SetSprint(bool held) { SprintHeld = held; }
        public void PressJump() { JumpPressed = true; }
        public static bool ConsumeJump()
        {
            bool value = JumpPressed;
            JumpPressed = false;
            return value;
        }
    }
}