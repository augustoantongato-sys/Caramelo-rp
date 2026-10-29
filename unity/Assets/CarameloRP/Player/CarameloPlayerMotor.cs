using UnityEngine;

namespace CarameloRP
{
    [RequireComponent(typeof(CharacterController))]
    public sealed class CarameloPlayerMotor : MonoBehaviour
    {
        [SerializeField] private Transform cameraTransform;
        [SerializeField] private float walkSpeed = 4.2f;
        [SerializeField] private float sprintSpeed = 6.5f;
        [SerializeField] private float rotationSpeed = 540f;
        [SerializeField] private float jumpHeight = 1.15f;
        [SerializeField] private float gravity = -22f;
        private CharacterController controller;
        private float verticalVelocity;

        private void Awake() { controller = GetComponent<CharacterController>(); }

        private void Update()
        {
            Vector2 input = CarameloMobileInput.Move;
#if UNITY_EDITOR || UNITY_STANDALONE
            input = new Vector2(Input.GetAxisRaw("Horizontal"), Input.GetAxisRaw("Vertical"));
            if (Input.GetKey(KeyCode.LeftShift)) CarameloMobileInputInputSprint(true);
            else CarameloMobileInputInputSprint(false);
            if (Input.GetButtonDown("Jump")) CarameloMobileInput.PressJump();
#endif
            Vector3 forward = cameraTransform ? Vector3.ProjectOnPlane(cameraTransform.forward, Vector3.up).normalized : transform.forward;
            Vector3 right = cameraTransform ? Vector3.ProjectOnPlane(cameraTransform.right, Vector3.up).normalized : transform.right;
            Vector3 direction = Vector3.ClampMagnitude(forward * input.y + right * input.x, 1f);

            if (controller.isGrounded && verticalVelocity < 0f) verticalVelocity = -2f;
            if (controller.isGrounded && CarameloMobileInput.ConsumeJump())
                verticalVelocity = Mathf.Sqrt(jumpHeight * -2f * gravity);
            verticalVelocity += gravity * Time.deltaTime;

            if (direction.sqrMagnitude > 0.01f)
            {
                Quaternion target = Quaternion.LookRotation(direction, Vector3.up);
                transform.rotation = Quaternion.RotateTowards(transform.rotation, target, rotationSpeed * Time.deltaTime);
            }

            float speed = CarameloMobileInput.SprintHeld ? sprintSpeed : walkSpeed;
            Vector3 velocity = direction * speed + Vector3.up * verticalVelocity;
            controller.Move(velocity * Time.deltaTime);
        }

#if UNITY_EDITOR || UNITY_STANDALONE
        private static void CarameloMobileInputInputSprint(bool held)
        {
            // Keyboard sprint fallback; mobile sprint is wired through the HUD.
            _keyboardSprint = held;
        }
        private static bool _keyboardSprint;
#endif
    }
}