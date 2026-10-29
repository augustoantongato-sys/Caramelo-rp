using UnityEngine;

namespace CarameloRP
{
    public enum CarameloQualityLevel { Auto, Low, Medium, High }

    public sealed class CarameloQuality : MonoBehaviour
    {
        [SerializeField] private CarameloQualityLevel startupQuality = CarameloQualityLevel.Auto;
        [SerializeField, Range(24, 60)] private int targetFrameRate = 30;
        public CarameloQualityLevel Current { get; private set; }

        private void Awake()
        {
            DontDestroyOnLoad(gameObject);
            Apply(startupQuality);
        }

        public void Apply(CarameloQualityLevel requested)
        {
            if (requested == CarameloQualityLevel.Auto)
            {
                int memory = SystemInfo.systemMemorySize;
                int gpu = SystemInfo.graphicsMemorySize;
                requested = (memory >= 6000 && gpu >= 3000) ? CarameloQualityLevel.High :
                    (memory >= 3500 && gpu >= 1500) ? CarameloQualityLevel.Medium : CarameloQualityLevel.Low;
            }

            Current = requested;
            Application.targetFrameRate = targetFrameRate;
            QualitySettings.vSyncCount = 0;
            QualitySettings.streamingMipmapsActive = true;

            switch (requested)
            {
                case CarameloQualityLevel.Low:
                    QualitySettings.SetQualityLevel(0, true);
                    QualitySettings.shadows = ShadowQuality.Disable;
                    QualitySettings.shadowDistance = 0f;
                    ScalableBufferManager.ResizeBuffers(1f, 1f);
                    break;
                case CarameloQualityLevel.High:
                    QualitySettings.SetQualityLevel(Mathf.Min(2, QualitySettings.names.Length - 1), true);
                    QualitySettings.shadows = ShadowQuality.All;
                    QualitySettings.shadowResolution = ShadowResolution.Medium;
                    QualitySettings.shadowDistance = 45f;
                    ScalableBufferManager.ResizeBuffers(1.15f, 1.15f);
                    break;
                default:
                    QualitySettings.SetQualityLevel(Mathf.Min(1, QualitySettings.names.Length - 1), true);
                    QualitySettings.shadows = ShadowQuality.HardOnly;
                    QualitySettings.shadowResolution = ShadowResolution.Low;
                    QualitySettings.shadowDistance = 25f;
                    ScalableBufferManager.ResizeBuffers(1f, 1f);
                    break;
            }
        }
    }
}