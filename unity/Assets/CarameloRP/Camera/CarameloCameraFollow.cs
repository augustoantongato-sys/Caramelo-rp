using UnityEngine;

namespace CarameloRP
{
    public sealed class CarameloCameraFollow : MonoBehaviour
    {
        [SerializeField] private Transform target;
        [SerializeField] private Vector3 offset = new Vector3(0f, 2.2f, -4.6f);
        [SerializeField, Range(1f, 20f)] private float followSharpness = 10f;
        [SerializeField, Range(1f, 20f)] private float lookSharpness = 12f;
        [SerializeField] private float lookHeight = 1.35f;
        [SerializeField] private float minPitch = -25f;
        [SerializeField] private float maxPitch = 65f;
        private float yaw;
        private float pitch = 12f;

        public void SetLookInput(Vector2 delta)
        {
            yaw += delta.x * 0.12f;
            pitch = Mathf.Clamp(pitch - delta.y * 0.10f, minPitch, maxPitch);
        }

        private void LateUpdate()
        {
            if (!target) return;
            Quaternion orbit = Quaternion.Euler(pitch, yaw + target.eulerAngles.y, 0f);
            Vector3 desired = target.position + orbit * offset;
            float blend = 1f - Mathf.Exp(-followSharpness * Time.deltaTime);
            transform.position = Vector3.Lerp(transform.position, desired, blend);
            Vector3 focus = target.position + Vector3.up * lookHeight;
            Quaternion look = Quaternion.LookRotation(focus - transform.position, Vector3.up);
            transform.rotation = Quaternion.Slerp(transform.rotation, look,
                1f - Mathf.Exp(-lookSharpness * Time.deltaTime));
        }
    }
}