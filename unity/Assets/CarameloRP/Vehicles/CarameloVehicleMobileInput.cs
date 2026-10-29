using UnityEngine;

namespace CarameloRP
{
    /// <summary>
    /// Shared touch controls for the arcade vehicle controller.
    /// Connect UI buttons with the public Hold... methods, or use
    /// CarameloVehicleHoldButton on each button.
    /// </summary>
    public static class CarameloVehicleMobileInput
    {
        public static float Throttle { get; private set; }
        public static float Steering { get; private set; }
        public static bool Brake { get; private set; }

        public static void SetThrottle(bool held) => Throttle = held ? 1f : 0f;
        public static void SetReverse(bool held) => Throttle = held ? -1f : 0f;
        public static void SetLeft(bool held) => Steering = held ? -1f : (Steering < 0f ? 0f : Steering);
        public static void SetRight(bool held) => Steering = held ? 1f : (Steering > 0f ? 0f : Steering);
        public static void SetBrake(bool held) => Brake = held;

        public static void Reset()
        {
            Throttle = 0f;
            Steering = 0f;
            Brake = false;
        }
    }

    /// <summary>Attach to a UI button and choose its action in the Inspector.</summary>
    public sealed class CarameloVehicleHoldButton : MonoBehaviour,
        UnityEngine.EventSystems.IPointerDownHandler,
        UnityEngine.EventSystems.IPointerUpHandler,
        UnityEngine.EventSystems.IPointerExitHandler
    {
        public enum ButtonAction { Accelerate, Reverse, Left, Right, Brake }
        public ButtonAction action;

        public void OnPointerDown(UnityEngine.EventSystems.PointerEventData eventData)
        {
            SetHeld(true);
        }

        public void OnPointerUp(UnityEngine.EventSystems.PointerEventData eventData)
        {
            SetHeld(false);
        }

        public void OnPointerExit(UnityEngine.EventSystems.PointerEventData eventData)
        {
            SetHeld(false);
        }

        private void OnDisable()
        {
            SetHeld(false);
        }

        private void SetHeld(bool held)
        {
            switch (action)
            {
                case ButtonAction.Accelerate: CarameloVehicleMobileInput.SetThrottle(held); break;
                case ButtonAction.Reverse: CarameloVehicleMobileInput.SetReverse(held); break;
                case ButtonAction.Left: CarameloVehicleMobileInput.SetLeft(held); break;
                case ButtonAction.Right: CarameloVehicleMobileInput.SetRight(held); break;
                case ButtonAction.Brake: CarameloVehicleMobileInput.SetBrake(held); break;
            }
        }
    }

    /// <summary>Reads touch controls and forwards them to CarameloArcadeVehicle.</summary>
    [RequireComponent(typeof(CarameloArcadeVehicle))]
    public sealed class CarameloVehicleInputAdapter : MonoBehaviour
    {
        private CarameloArcadeVehicle vehicle;

        private void Awake()
        {
            vehicle = GetComponent<CarameloArcadeVehicle>();
        }

        private void Update()
        {
            float throttle = CarameloVehicleMobileInput.Throttle;
            float steering = CarameloVehicleMobileInput.Steering;
            bool brake = CarameloVehicleMobileInput.Brake;

#if UNITY_EDITOR || UNITY_STANDALONE
            float keyboardThrottle = Input.GetAxisRaw("Vertical");
            float keyboardSteering = Input.GetAxisRaw("Horizontal");
            throttle = Mathf.Abs(keyboardThrottle) > Mathf.Abs(throttle) ? keyboardThrottle : throttle;
            steering = Mathf.Abs(keyboardSteering) > Mathf.Abs(steering) ? keyboardSteering : steering;
            brake |= Input.GetKey(KeyCode.Space);
#endif
            vehicle.SetControls(throttle, steering, brake);
        }

        private void OnDisable()
        {
            CarameloVehicleMobileInput.Reset();
        }
    }
}