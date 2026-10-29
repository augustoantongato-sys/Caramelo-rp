using UnityEngine;

namespace CarameloRP
{
    /// <summary>Assembles the five independent city regions into one connected world.</summary>
    public sealed class CarameloWorldAssembler : MonoBehaviour
    {
        [SerializeField] private bool generateOnStart = true;
        [SerializeField] private int worldSeed = 3107;
        [SerializeField] private float moduleSize = 120f;
        [SerializeField] private Material concrete;
        [SerializeField] private Material asphalt;
        [SerializeField] private Material grass;

        private Transform worldRoot;
        public Transform SuggestedPlayerSpawn { get; private set; }

        private void Start() { if (generateOnStart) GenerateWorld(); }

        [ContextMenu("Generate Caramelo RP World")]
        public void GenerateWorld()
        {
            if (worldRoot != null) Destroy(worldRoot.gameObject);
            worldRoot = new GameObject("CarameloRP_World").transform;
            worldRoot.SetParent(transform, false);

            // Each region owns its own local 120m x 120m coordinate space.
            AddRegion(CarameloRegionType.Favela, new Vector3(-moduleSize, 0, 0), 11);
            AddRegion(CarameloRegionType.Residential, Vector3.zero, 23);
            AddRegion(CarameloRegionType.Commercial, new Vector3(moduleSize, 0, 0), 37);
            AddRegion(CarameloRegionType.Recreation, new Vector3(0, 0, moduleSize), 41);
            AddRegion(CarameloRegionType.Landmark, new Vector3(moduleSize, 0, moduleSize), 53);

            GameObject spawn = new GameObject("Suggested_Player_Spawn");
            spawn.transform.SetParent(worldRoot, false);
            spawn.transform.localPosition = new Vector3(0, 1.2f, -30);
            SuggestedPlayerSpawn = spawn.transform;
        }

        private void AddRegion(CarameloRegionType type, Vector3 position, int seedOffset)
        {
            GameObject regionObject = new GameObject(type + "_Module");
            regionObject.transform.SetParent(worldRoot, false);
            regionObject.transform.localPosition = position;
            CarameloMapModule module = regionObject.AddComponent<CarameloMapModule>();
            module.Configure(type, worldSeed + seedOffset);
            module.Generate();
        }
    }
}