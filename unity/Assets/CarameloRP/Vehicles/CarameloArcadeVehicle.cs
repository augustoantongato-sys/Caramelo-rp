using UnityEngine;

namespace CarameloRP
{
    /// <summary>Simple mobile-friendly prototype vehicle. Use WheelColliders for production physics.</summary>
    [RequireComponent(typeof(Rigidbody))]
    public sealed class CarameloArcadeVehicle : MonoBehaviour
    {
        [SerializeField] private float acceleration = 18f;
        [SerializeField] private float reverseAcceleration = 9f;
        [SerializeField] private float maxSpeed = 22f;
        [SerializeField] private float steeringDegreesPerSecond = 85f;
        [SerializeField] private float brakeStrength = 7f;

        public static float Throttle { get; private set; }
        public static float Steering { get; private set; }
        public static bool BrakeHeld { get; private set; }
        private Rigidbody body;

        private void Awake()
        {
            body = GetComponent<Rigidbody>();
            body.mass = 1150f;
            body.drag = 0.18f;
            body.angularDrag = 2.2f;
            body.interpolation = RigidbodyInterpolation.Interpolate;
            body.constraints = RigidbodyConstraints.FreezeRotationX | RigidbodyConstraints.FreezeRotationZ;
        }

        public static void SetControls(float throttle, float steering, bool brake)
        {
            Throttle = Mathf.Clamp(throttle, -1f, 1f);
            Steering = Mathf.Clamp(steering, -1f, 1f);
            BrakeHeld = brake;
        }

        private void FixedUpdate()
        {
            Vector3 flatVelocity = Vector3.ProjectOnPlane(body.velocity, Vector3.up);
            float forwardSpeed = Vector3.Dot(flatVelocity, transform.forward);
            if (Mathf.Abs(forwardSpeed) < maxSpeed || Mathf.Sign(Throttle) != Mathf.Sign(forwardSpeed))
                body.AddForce(transform.forward * (Throttle >= 0 ? acceleration : reverseAcceleration) * Throttle, ForceMode.Acceleration);

            float speedFactor = Mathf.Clamp01(flatVelocity.magnitude / 2f);
            if (flatVelocity.sqrMagnitude > 0.25f)
            {
                float direction = forwardSpeed >= 0 ? 1f : -1f;
                Quaternion turn = Quaternion.Euler(0f, Steering * steeringDegreesPerSecond * speedFactor * direction * Time.fixedDeltaTime, 0f);
                body.MoveRotation(body.rotation * turn);
            }

            if (BrakeHeld)
                body.velocity = Vector3.MoveTowards(body.velocity, Vector3.zero, brakeStrength * Time.fixedDeltaTime);
        }
    }
}