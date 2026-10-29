using UnityEngine;

namespace CarameloRP
{
    public enum CarameloRegionType { Favela, Residential, Commercial, Recreation, Landmark }

    /// <summary>Generates one self-contained 120m x 120m Brazilian city region.</summary>
    public sealed class CarameloMapModule : MonoBehaviour
    {
        [SerializeField] private CarameloRegionType region = CarameloRegionType.Favela;
        [SerializeField] private int seed = 3107;
        [SerializeField] private bool generateOnStart;
        [SerializeField] private Material concrete;
        [SerializeField] private Material asphalt;
        [SerializeField] private Material grass;
        private Transform generated;
        private System.Random rng;

        public CarameloRegionType Region { get { return region; } }
        public void Configure(CarameloRegionType type, int moduleSeed)
        {
            region = type; seed = moduleSeed;
        }

        private void Start() { if (generateOnStart) Generate(); }

        [ContextMenu("Generate Region")]
        public void Generate()
        {
            if (generated != null) Destroy(generated.gameObject);
            rng = new System.Random(seed);
            generated = new GameObject(region + "_Generated").transform;
            generated.SetParent(transform, false);
            Ground();
            switch (region)
            {
                case CarameloRegionType.Favela: BuildFavela(); break;
                case CarameloRegionType.Residential: BuildResidential(); break;
                case CarameloRegionType.Commercial: BuildCommercial(); break;
                case CarameloRegionType.Recreation: BuildRecreation(); break;
                case CarameloRegionType.Landmark: BuildLandmark(); break;
            }
            BoundaryRoads();
        }

        private void Ground()
        {
            Box("Ground", new Vector3(0,-1,0), new Vector3(120,2,120), C(.25f,.34f,.24f), grass);
            Box("Main road", new Vector3(0,.05f,-48), new Vector3(120,.2f,12), C(.12f,.13f,.14f), asphalt);
            Box("Road shoulder north",new Vector3(0,.08f,-55),new Vector3(120,.16f,1.5f),C(.42f,.41f,.37f),concrete);
            Box("Road shoulder south",new Vector3(0,.08f,-41),new Vector3(120,.16f,1.5f),C(.42f,.41f,.37f),concrete);
            Box("Cross road", new Vector3(48,.05f,0), new Vector3(12,.2f,120), C(.12f,.13f,.14f), asphalt);
            for (int x=-54;x<=54;x+=9) Box("Road dash",new Vector3(x,.17f,-48),new Vector3(4,.035f,.16f),C(.9f,.82f,.58f),null);
            Box("North sidewalk",new Vector3(0,.12f,-40.5f),new Vector3(120,.3f,3),C(.55f,.54f,.5f),concrete);
            Box("South sidewalk",new Vector3(0,.12f,-55.5f),new Vector3(120,.3f,3),C(.55f,.54f,.5f),concrete);
        }

        private void BoundaryRoads()
        {
            Box("East connector",new Vector3(54,.06f,0),new Vector3(12,.2f,120),C(.12f,.13f,.14f),asphalt);
            Box("West connector",new Vector3(-54,.06f,0),new Vector3(12,.2f,120),C(.12f,.13f,.14f),asphalt);
            Box("North connector",new Vector3(0,.06f,54),new Vector3(120,.2f,12),C(.12f,.13f,.14f),asphalt);
        }

        private void BuildFavela()
        {
            for(int row=0;row<8;row++)
            {
                float z=-25+row*10, y=row*1.45f, width=92-row*5.2f;
                Box("Retaining terrace",new Vector3(-7,y-.55f,z),new Vector3(width,1.5f,9.5f),C(.38f,.34f,.29f),concrete);
                for(int i=0;i<9;i++)
                {
                    float x=-7-width*.5f+5+i*(width-10)/8f;
                    float w=R(5,7), h=R(3.3f,5.2f), d=R(5,7);
                    Vector3 p=new Vector3(x,y+h*.5f,z+R(-1.4f,1.4f));
                    Color[] palette={C(.76f,.61f,.43f),C(.55f,.66f,.69f),C(.72f,.46f,.38f),C(.72f,.69f,.57f),C(.46f,.56f,.46f)};
                    Box("Favela house",p,new Vector3(w,h,d),palette[rng.Next(palette.Length)],null);
                    Box("Roof slab",p+Vector3.up*(h*.5f+.12f),new Vector3(w+.25f,.24f,d+.25f),C(.48f,.48f,.45f),concrete);
                    Box("Front door",p+new Vector3(0,-h*.18f,-d*.5f-.05f),new Vector3(.85f,1.65f,.1f),C(.18f,.12f,.08f),null);
                    Box("Window",p+new Vector3(w*.22f,.1f,-d*.5f-.06f),new Vector3(.9f,.7f,.08f),C(.12f,.27f,.35f),null);
                    Box("Window frame",p+new Vector3(w*.22f,.1f,-d*.5f-.12f),new Vector3(1.08f,.86f,.06f),C(.82f,.8f,.72f),null);
                    Box("Facade band",p+new Vector3(0,-h*.34f,-d*.5f-.08f),new Vector3(w,.18f,.14f),C(.82f,.76f,.64f),null);
                    if(rng.NextDouble()>.55) Box("Small balcony",p+new Vector3(0,.15f,-d*.5f-.55f),new Vector3(w*.55f,.16f,1.05f),C(.48f,.48f,.46f),concrete);
                    if(rng.NextDouble()>.35) Cylinder("Water tank",p+new Vector3(w*.18f,h*.5f+.85f,d*.12f),new Vector3(1,1.25f,1),C(.16f,.2f,.23f));
                    if(rng.NextDouble()>.72) Box("Satellite dish",p+new Vector3(-w*.28f,h*.5f+.65f,d*.2f),new Vector3(.8f,.12f,.8f),C(.72f,.72f,.68f),null);
                }
            }
            for(int i=0;i<24;i++) Box("Stair step",new Vector3(34,i*.43f,-30+i*2.2f),new Vector3(3.2f,.25f,2.2f),C(.59f,.57f,.52f),concrete);
            for(int i=0;i<7;i++) Box("Alley",new Vector3(-48+i*15,.1f,12),new Vector3(2,.2f,48),C(.42f,.4f,.36f),concrete);
            for(int i=0;i<9;i++)
            {
                float x=-48+i*12;
                Cylinder("Favela utility pole",new Vector3(x,5,3),new Vector3(.16f,5,.16f),C(.2f,.19f,.17f));
                Box("Utility crossbar",new Vector3(x,9.7f,3),new Vector3(1.5f,.12f,.16f),C(.18f,.17f,.15f),null);
            }

            // Campo comunitário de futebol na favela, com grama, marcações, gols, alambrado e arquibancada.
            Vector3 field = new Vector3(-30,.22f,-30);
            Box("Favela football pitch",field,new Vector3(42,.28f,25),C(.12f,.39f,.17f),grass);
            Box("Pitch center line",field+new Vector3(0,.16f,0),new Vector3(.16f,.025f,23),Color.white,null);
            Box("Pitch center circle",field+new Vector3(0,.18f,0),new Vector3(7,.025f,.16f),Color.white,null);
            Box("Pitch left touchline",field+new Vector3(-20,.18f,0),new Vector3(.14f,.025f,24),Color.white,null);
            Box("Pitch right touchline",field+new Vector3(20,.18f,0),new Vector3(.14f,.025f,24),Color.white,null);
            Box("Pitch far touchline",field+new Vector3(0,.18f,12),new Vector3(40,.025f,.14f),Color.white,null);
            Box("Pitch near touchline",field+new Vector3(0,.18f,-12),new Vector3(40,.025f,.14f),Color.white,null);
            Box("Favela goal left",field+new Vector3(-20,1.25f,0),new Vector3(.25f,2.5f,5),Color.white,null);
            Box("Favela goal right",field+new Vector3(20,1.25f,0),new Vector3(.25f,2.5f,5),Color.white,null);
            for(int side=-1;side<=1;side+=2)
                for(int i=0;i<13;i++)
                    Box("Pitch fence",field+new Vector3(-20+i*3.3f,1.8f,side*13.2f),new Vector3(.08f,3.6f,.08f),C(.22f,.25f,.23f),null);
            Box("Community stand",field+new Vector3(0,1.1f,-17),new Vector3(18,2.2f,3),C(.48f,.46f,.42f),concrete);
            for(int i=0;i<4;i++) Box("Stand step",field+new Vector3(0,.45f+i*.38f,-18+i*.65f),new Vector3(16,.18f,1.2f),C(.62f,.6f,.55f),concrete);
            Box("Community court",new Vector3(-30,.18f,-5),new Vector3(25,.3f,18),C(.16f,.38f,.2f),grass);
            for(int i=0;i<5;i++) Tree(new Vector3(48+i*3,0,35+i*5));
        }

        private void BuildResidential()
        {
            for(int z=0;z<4;z++) for(int x=0;x<4;x++)
            {
                float px=-38+x*25, pz=-25+z*22;
                if(Mathf.Abs(px-48)<12 || Mathf.Abs(pz+48)<10) continue;
                float w=R(12,17), d=R(10,15), h=R(5,8);
                Box("Residential house",new Vector3(px,h*.5f,pz),new Vector3(w,h,d),C(.72f,.68f,.58f),null);
                Box("Roof",new Vector3(px,h+.15f,pz),new Vector3(w+.3f,.3f,d+.3f),C(.35f,.25f,.2f),concrete);
                Box("Front facade window",new Vector3(px-3,h*.62f,pz-d*.5f-.08f),new Vector3(2.1f,1.35f,.12f),C(.12f,.28f,.36f),null);
                Box("Front facade door",new Vector3(px+3,h*.35f,pz-d*.5f-.1f),new Vector3(1.3f,2.5f,.15f),C(.24f,.16f,.1f),null);
                Box("Garage",new Vector3(px,h*.25f,pz-d*.5f-.1f),new Vector3(3,2.5f,.15f),C(.25f,.28f,.3f),null);
                Box("Front yard",new Vector3(px,.08f,pz-d*.5f-3),new Vector3(w,.16f,5),C(.32f,.43f,.27f),grass);
                Box("Boundary wall",new Vector3(px,.65f,pz-d*.5f-5.6f),new Vector3(w,1.3f,.25f),C(.68f,.66f,.6f),concrete);
                Box("Driveway",new Vector3(px+4,.12f,pz-d*.5f-3),new Vector3(4,.2f,5),C(.48f,.47f,.43f),concrete);
            }
            for(int i=0;i<10;i++) Tree(new Vector3(-48+i*10,0,25));
            Box("Neighborhood square",new Vector3(-25,.1f,35),new Vector3(30,.2f,22),C(.34f,.45f,.3f),grass);
        }

        private void BuildCommercial()
        {
            for(int i=0;i<7;i++)
            {
                float x=-42+i*14;
                Box("Shop",new Vector3(x,2.6f,-24),new Vector3(11,5.2f,12),C(.72f,.66f,.55f),null);
                Box("Storefront",new Vector3(x,1.65f,-30.1f),new Vector3(7,2.4f,.12f),C(.12f,.29f,.35f),null);
                Box("Shop awning",new Vector3(x,3.2f,-31.2f),new Vector3(8,.35f,2),i%2==0?C(.72f,.16f,.12f):C(.12f,.28f,.62f),null);
            }
            Box("Market feira",new Vector3(-20,.2f,20),new Vector3(50,.3f,22),C(.45f,.4f,.31f),concrete);
            for(int i=0;i<6;i++)
            {
                float x=-40+i*8;
                Box("Market stall",new Vector3(x,1.5f,18),new Vector3(6,3,5),C(.75f,.68f,.48f),null);
                Box("Market canopy",new Vector3(x,3.1f,18),new Vector3(6.5f,.25f,5.5f),i%2==0?C(.75f,.15f,.12f):C(.9f,.85f,.72f),null);
            }
            Box("Gas station canopy",new Vector3(35,4,22),new Vector3(25,.5f,16),C(.85f,.78f,.12f),null);
            for(int i=0;i<4;i++) Box("Fuel pump",new Vector3(27+i*5,1.1f,22),new Vector3(1.2f,2.2f,1),C(.8f,.8f,.78f),null);
        }

        private void BuildRecreation()
        {
            Box("School building",new Vector3(25,3.5f,20),new Vector3(38,7,20),C(.82f,.76f,.59f),null);
            Box("School entrance",new Vector3(25,2,9.8f),new Vector3(8,4,.3f),C(.16f,.32f,.43f),null);
            Box("School yard",new Vector3(25,.1f,39),new Vector3(52,.2f,18),C(.32f,.47f,.29f),grass);
            Box("Football field",new Vector3(-28,.2f,20),new Vector3(48,.3f,28),C(.12f,.38f,.19f),grass);
            Box("Field halfway line",new Vector3(-28,.37f,20),new Vector3(.18f,.03f,25),Color.white,null);
            Box("Goal A",new Vector3(-51,1.2f,20),new Vector3(.25f,2.4f,7),Color.white,null);
            Box("Goal B",new Vector3(-5,1.2f,20),new Vector3(.25f,2.4f,7),Color.white,null);
            Box("Basketball court",new Vector3(-25,.2f,-25),new Vector3(35,.3f,20),C(.65f,.32f,.2f),null);
            Box("Park lawn",new Vector3(28,.08f,-25),new Vector3(35,.16f,20),C(.28f,.44f,.25f),grass);
            for(int i=0;i<5;i++) Tree(new Vector3(12+i*8,0,-35));
            for(int i=0;i<3;i++)
            {
                float x=-45+i*20;
                Box("Apartment block",new Vector3(x,9,48),new Vector3(14,18,12),C(.68f,.67f,.62f),null);
                for(int floor=0;floor<4;floor++)
                    for(int win=0;win<3;win++)
                        Box("Apartment window",new Vector3(x-4+win*4,3+floor*4.2f,41.85f),new Vector3(1.6f,1.8f,.1f),C(.12f,.25f,.34f),null);
            }
        }

        private void BuildLandmark()
        {
            Box("Lookout plaza",new Vector3(0,.15f,5),new Vector3(70,.3f,55),C(.58f,.56f,.5f),concrete);
            for(int i=0;i<5;i++) Box("Lookout stair",new Vector3(0,i*.35f,-28+i*2),new Vector3(14,.25f,2),C(.62f,.6f,.55f),concrete);
            // Original stylized monument silhouette, not a scan or replica asset.
            Cylinder("Monument pedestal",new Vector3(0,2,25),new Vector3(5,4,5),C(.68f,.66f,.6f));
            Box("Monument torso",new Vector3(0,8,25),new Vector3(2.5f,9,2),C(.78f,.77f,.72f),null);
            Sphere("Monument head",new Vector3(0,13.2f,25),new Vector3(2,2,2),C(.78f,.77f,.72f));
            Box("Monument arms",new Vector3(0,10.5f,25),new Vector3(15,1.4f,1.6f),C(.78f,.77f,.72f),null);
            for(int i=0;i<6;i++) Tree(new Vector3(-38+i*15,0,-5));
            Box("Viewpoint",new Vector3(0,.4f,48),new Vector3(42,.8f,12),C(.45f,.43f,.39f),concrete);
        }

        private void Tree(Vector3 p)
        {
            Cylinder("Tree trunk",p+Vector3.up*2,new Vector3(.55f,4,.55f),C(.3f,.19f,.1f));
            Sphere("Tree crown",p+Vector3.up*5,new Vector3(4,4,4),C(.13f,.34f,.16f));
        }
        private void Box(string n,Vector3 p,Vector3 s,Color c,Material m)
        {
            GameObject o=GameObject.CreatePrimitive(PrimitiveType.Cube); o.name=n; o.transform.SetParent(generated,false);
            o.transform.localPosition=p; o.transform.localScale=s; Apply(o,c,m);
        }
        private void Cylinder(string n,Vector3 p,Vector3 s,Color c)
        {
            GameObject o=GameObject.CreatePrimitive(PrimitiveType.Cylinder); o.name=n; o.transform.SetParent(generated,false);
            o.transform.localPosition=p; o.transform.localScale=s; Apply(o,c,null);
        }
        private void Sphere(string n,Vector3 p,Vector3 s,Color c)
        {
            GameObject o=GameObject.CreatePrimitive(PrimitiveType.Sphere); o.name=n; o.transform.SetParent(generated,false);
            o.transform.localPosition=p; o.transform.localScale=s; Apply(o,c,null);
        }
        private static void Apply(GameObject o,Color c,Material m)
        {
            Renderer r=o.GetComponent<Renderer>(); if(r==null)return;
            if(m!=null)r.sharedMaterial=m; else r.material.color=c;
        }
        private float R(float a,float b){return a+(float)rng.NextDouble()*(b-a);}
        private static Color C(float r,float g,float b){return new Color(r,g,b,1);}
    }
}
