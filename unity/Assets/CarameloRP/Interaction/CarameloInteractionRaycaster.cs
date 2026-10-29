using UnityEngine;
using UnityEngine.UI;

namespace CarameloRP
{
    /// <summary>
    /// Looks for interactable colliders from the center of the camera.
    /// Hook a mobile UI Button to Interact() for touch interaction.
    /// </summary>
    public sealed class CarameloInteractionRaycaster : MonoBehaviour
    {
        public Camera playerCamera;
        public Transform actor;
        public float distance = 3f;
        public LayerMask layers = ~0;
        public Text promptLabel;

        private CarameloInteractable current;

        private void Update()
        {
            if (playerCamera == null)
                playerCamera = Camera.main;

            CarameloInteractable found = null;
            if (playerCamera != null &&
                Physics.Raycast(playerCamera.transform.position, playerCamera.transform.forward,
                    out RaycastHit hit, distance, layers, QueryTriggerInteraction.Ignore))
            {
                found = hit.collider.GetComponentInParent<CarameloInteractable>();
            }

            current = found;
            if (promptLabel != null)
            {
                promptLabel.text = current != null ? current.prompt : string.Empty;
                promptLabel.enabled = current != null;
            }

#if UNITY_EDITOR || UNITY_STANDALONE
            if (current != null && Input.GetKeyDown(KeyCode.E))
                Interact();
#endif
        }

        public void Interact()
        {
            if (current == null)
                return;

            current.Interact(actor != null ? actor.gameObject : gameObject);
        }
    }
}