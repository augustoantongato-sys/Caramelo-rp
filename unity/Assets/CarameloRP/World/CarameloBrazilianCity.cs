using UnityEngine;

namespace CarameloRP
{
    /// <summary>
    /// Creates a lightweight, original Brazilian-city blockout at runtime.
    /// Replace generated primitives with authored prefabs/meshes for production art.
    /// </summary>
    public sealed class CarameloBrazilianCity : MonoBehaviour
    {
        [Header("Generation")]
        [SerializeField] private int seed = 3107;
        [SerializeField, Range(4, 18)] private int hillsideRows = 10;
        [SerializeField, Range(5, 24)] private int housesPerRow = 12;
        [SerializeField] private bool generateOnStart = true;

        [Header("Materials")]
        [SerializeField] private Material roadMaterial;
        [SerializeField] private Material concreteMaterial;
        [SerializeField] private Material grassMaterial;
        [SerializeField] private Material pitchMaterial;
        [SerializeField] private Material[] houseMaterials;

        private Transform root;
        private System.Random random;

        private void Start()
        {
            if (generateOnStart) Generate();
        }

        [ContextMenu("Generate Caramelo City")]
        public void Generate()
        {
            if (root) Destroy(root.gameObject);
            random = new System.Random(seed);
            root = new GameObject("CarameloCity_Generated").transform;
            root.SetParent(transform, false);

            BuildGroundAndRoads();
            BuildHillsideCommunity();
            BuildCommercialStreet();
            BuildSchool();
            BuildFootballCourt();
            BuildStreetProps();
        }

        private void BuildGroundAndRoads()
        {
            CreateBox("Base terrain", new Vector3(0, -1.2f, 0), new Vector3(260, 2, 220), ColorFrom(0.24f, 0.36f, 0.22f), grassMaterial);
            CreateBox("Main avenue", new Vector3(0, 0.02f, -18), new Vector3(260, 0.18f, 13), ColorFrom(0.12f, 0.13f, 0.14f), roadMaterial);
            CreateBox("Cross street", new Vector3(28, 0.03f, 32), new Vector3(13, 0.18f, 150), ColorFrom(0.13f, 0.14f, 0.15f), roadMaterial);
            for (int x = -120; x <= 120; x += 12)
            {
                CreateBox("Lane marking", new Vector3(x, 0.13f, -18), new Vector3(5, 0.025f, 0.18f), new Color(0.92f, 0.82f, 0.42f), null);
            }
            CreateBox("Sidewalk north", new Vector3(0, 0.12f, -9.8f), new Vector3(260, 0.28f, 3.4f), ColorFrom(0.54f, 0.54f, 0.51f), concreteMaterial);
            CreateBox("Sidewalk south", new Vector3(0, 0.12f, -26.2f), new Vector3(260, 0.28f, 3.4f), ColorFrom(0.54f, 0.54f, 0.51f), concreteMaterial);
        }

        private void BuildHillsideCommunity()
        {
            // A stepped hillside gives the first playable build a recognizable community silhouette.
            for (int row = 0; row < hillsideRows; row++)
            {
                float z = 18 + row * 8.2f;
                float y = row * 1.65f;
                float width = Mathf.Lerp(105, 62, row / (float)hillsideRows);
                CreateBox("Hillside terrace " + row, new Vector3(-62, y - 0.5f, z), new Vector3(width + 12, 1.4f, 8.5f), ColorFrom(0.35f, 0.31f, 0.25f), concreteMaterial);

                for (int i = 0; i < housesPerRow; i++)
                {
                    float x = -62 - width * 0.5f + 5 + i * (width - 10) / Mathf.Max(1, housesPerRow - 1);
                    float jitter = Next(-1.3f, 1.3f);
                    float w = Next(4.2f, 6.5f);
                    float h = Next(3.0f, 5.0f);
                    float d = Next(4.8f, 7.0f);
                    Color wall = PickHouseColor();
                    Vector3 pos = new Vector3(x, y + h * 0.5f, z + jitter);
                    CreateBox("Community house", pos, new Vector3(w, h, d), wall, null);
                    CreateBox("Flat roof", pos + Vector3.up * (h * 0.5f + 0.12f), new Vector3(w + 0.2f, 0.24f, d + 0.2f), ColorFrom(0.48f, 0.48f, 0.45f), concreteMaterial);
                    CreateBox("Door", pos + new Vector3(0, -h * 0.18f, -d * 0.501f), new Vector3(0.85f, 1.7f, 0.08f), ColorFrom(0.19f, 0.12f, 0.08f), null);
                    CreateBox("Window", pos + new Vector3(w * 0.22f, 0.1f, -d * 0.506f), new Vector3(0.9f, 0.75f, 0.06f), ColorFrom(0.12f, 0.27f, 0.35f), null);
                    if (random.NextDouble() > 0.42)
                    {
                        CreateCylinder("Water tank", pos + new Vector3(w * 0.18f, h * 0.5f + 0.85f, d * 0.12f), new Vector3(0.9f, 1.25f, 0.9f), ColorFrom(0.16f, 0.2f, 0.23f));
                    }
                }
            }
            // Stairs climbing the terraces.
            for (int i = 0; i < 18; i++)
                CreateBox("Community stair", new Vector3(-7, i * 0.52f, 22 + i * 2.4f), new Vector3(3.2f, 0.28f, 2.6f), ColorFrom(0.58f, 0.56f, 0.51f), concreteMaterial);
        }

        private void BuildCommercialStreet()
        {
            for (int i = 0; i < 9; i++)
            {
                float x = -105 + i * 24;
                Vector3 p = new Vector3(x, 2.2f, -2.2f);
                CreateBox("Shop building", p, new Vector3(17, 4.4f, 9), ColorFrom(0.7f, 0.66f, 0.57f), null);
                CreateBox("Shopfront glass", p + new Vector3(0, -0.55f, -4.56f), new Vector3(10, 2.1f, 0.08f), ColorFrom(0.16f, 0.31f, 0.37f), null);
                CreateBox("Shop awning", p + new Vector3(0, 0.9f, -5.1f), new Vector3(11, 0.35f, 1.3f), i % 2 == 0 ? ColorFrom(0.72f, 0.18f, 0.12f) : ColorFrom(0.12f, 0.28f, 0.62f), null);
            }
        }

        private void BuildSchool()
        {
            Vector3 p = new Vector3(80, 3.1f, 42);
            CreateBox("School building", p, new Vector3(42, 6.2f, 24), ColorFrom(0.82f, 0.76f, 0.58f), null);
            CreateBox("School entrance", p + new Vector3(0, -1.2f, -12.2f), new Vector3(8, 3.8f, 0.35f), ColorFrom(0.18f, 0.34f, 0.45f), null);
            CreateBox("School sign", p + new Vector3(0, 2.2f, -12.45f), new Vector3(12, 1.0f, 0.2f), ColorFrom(0.1f, 0.26f, 0.18f), null);
            CreateBox("School yard", new Vector3(80, 0.05f, 61), new Vector3(56, 0.2f, 22), ColorFrom(0.32f, 0.48f, 0.29f), grassMaterial);
        }

        private void BuildFootballCourt()
        {
            Vector3 p = new Vector3(-82, 0.18f, -65);
            CreateBox("Football pitch", p, new Vector3(58, 0.25f, 34), ColorFrom(0.12f, 0.38f, 0.19f), pitchMaterial);
            CreateBox("Pitch halfway line", p + Vector3.up * 0.14f, new Vector3(0.18f, 0.025f, 31), Color.white, null);
            CreateBox("Goal left", p + new Vector3(-27, 1.1f, 0), new Vector3(0.25f, 2.2f, 7), Color.white, null);
            CreateBox("Goal right", p + new Vector3(27, 1.1f, 0), new Vector3(0.25f, 2.2f, 7), Color.white, null);
        }

        private void BuildStreetProps()
        {
            for (int i = 0; i < 22; i++)
            {
                float x = -118 + i * 11;
                CreateCylinder("Street light pole", new Vector3(x, 3.6f, -7.2f), new Vector3(0.12f, 3.6f, 0.12f), ColorFrom(0.17f, 0.18f, 0.2f));
                CreateBox("Street light arm", new Vector3(x + 0.65f, 7.1f, -7.2f), new Vector3(1.4f, 0.12f, 0.12f), ColorFrom(0.17f, 0.18f, 0.2f), null);
            }
        }

        private GameObject CreateBox(string label, Vector3 position, Vector3 scale, Color color, Material material)
        {
            GameObject go = GameObject.CreatePrimitive(PrimitiveType.Cube);
            go.name = label; go.transform.SetParent(root, false);
            go.transform.localPosition = position; go.transform.localScale = scale;
            Apply(go, color, material); return go;
        }

        private GameObject CreateCylinder(string label, Vector3 position, Vector3 scale, Color color)
        {
            GameObject go = GameObject.CreatePrimitive(PrimitiveType.Cylinder);
            go.name = label; go.transform.SetParent(root, false);
            go.transform.localPosition = position; go.transform.localScale = scale;
            Apply(go, color, null); return go;
        }

        private static void Apply(GameObject go, Color color, Material material)
        {
            Renderer renderer = go.GetComponent<Renderer>();
            if (renderer == null) return;
            if (material != null) renderer.sharedMaterial = material;
            else renderer.material.color = color;
        }

        private Color PickHouseColor()
        {
            if (houseMaterials != null && houseMaterials.Length > 0)
                return houseMaterials[random.Next(houseMaterials.Length)].color;
            Color[] palette = { ColorFrom(0.76f,0.62f,0.43f), ColorFrom(0.62f,0.7f,0.72f),
                ColorFrom(0.72f,0.48f,0.38f), ColorFrom(0.72f,0.7f,0.58f), ColorFrom(0.48f,0.59f,0.48f) };
            return palette[random.Next(palette.Length)];
        }
        private float Next(float min, float max) { return min + (float)random.NextDouble() * (max - min); }
        private static Color ColorFrom(float r, float g, float b) { return new Color(r, g, b, 1f); }
    }
}