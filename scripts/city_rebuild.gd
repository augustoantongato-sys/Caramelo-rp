extends Node3D
const VEHICLE_SCRIPT=preload("res://scripts/simple_vehicle.gd")
var mats:Dictionary={}
func _ready()->void:
 _environment()
 _box("Terreno",Vector3(150,1,140),Vector3(0,-0.55,0),Color(0.24,0.42,0.25))
 _box("Avenida",Vector3(14,0.12,130),Vector3(0,0.02,0),Color(0.12,0.13,0.14),false)
 _box("Rua",Vector3(130,0.12,10),Vector3(0,0.02,12),Color(0.12,0.13,0.14),false)
 for x in [-9.0,9.0]: _box("Calcada",Vector3(3,0.2,130),Vector3(x,0.1,0),Color(0.57,0.55,0.51),false)
 _city()
 _favela()
 _park()
 _christ()
 _vehicles()
 _street()
func _mat(c:Color)->StandardMaterial3D:
 var k:=c.to_html()
 if mats.has(k): return mats[k]
 var m:=StandardMaterial3D.new()
 m.albedo_color=c
 m.roughness=0.9
 mats[k]=m
 return m
func _box(n:String,s:Vector3,p:Vector3,c:Color,solid:=true)->void:
 var b:=StaticBody3D.new()
 b.name=n
 b.position=p
 var mi:=MeshInstance3D.new()
 var mesh:=BoxMesh.new()
 mesh.size=s
 mi.mesh=mesh
 mi.material_override=_mat(c)
 b.add_child(mi)
 if solid:
  var cs:=CollisionShape3D.new()
  var sh:=BoxShape3D.new()
  sh.size=s
  cs.shape=sh
  b.add_child(cs)
 add_child(b)
func _building(p:Vector3,s:Vector3,c:Color,n:String)->void:
 _box(n,s,p+Vector3.UP*s.y*0.5,c)
 _box(n+" telhado",Vector3(s.x+0.2,0.2,s.z+0.2),p+Vector3.UP*(s.y+0.1),Color(0.2,0.2,0.21),false)
func _environment()->void:
 var w:=WorldEnvironment.new()
 var e:=Environment.new()
 e.background_mode=Environment.BG_SKY
 e.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
 e.ambient_light_color=Color(0.65,0.7,0.8)
 e.ambient_light_energy=0.8
 w.environment=e
 add_child(w)
 var sun:=DirectionalLight3D.new()
 sun.rotation_degrees=Vector3(-48,-32,0)
 sun.light_energy=1.1
 add_child(sun)
func _city()->void:
 var colors=[Color(0.77,0.69,0.58),Color(0.58,0.68,0.72),Color(0.77,0.58,0.47)]
 for i in range(4):
  var z:float=-40.0+float(i)*20.0
  _building(Vector3(-24,0,z),Vector3(12,9+(i%2)*3,12),colors[i%3],"Predio")
  _building(Vector3(24,0,z+7),Vector3(12,7+(i%2)*3,12),colors[(i+1)%3],"Predio")
  _building(Vector3(42,0,-35+float(i)*20),Vector3(13,5,12),Color(0.82,0.78,0.68),"Casa moderna")
 _building(Vector3(-20,0,22),Vector3(12,5,10),Color(0.78,0.68,0.48),"Mercado")
func _favela()->void:
 var colors=[Color(0.76,0.52,0.38),Color(0.78,0.72,0.58),Color(0.48,0.62,0.67)]
 for row in range(3):
  for col in range(4):
   var p:=Vector3(-57+col*8,row*1.8,-36+row*9)
   var h:=4.0+float((row+col)%2)
   _building(p,Vector3(6,h,6),colors[(row+col)%3],"Casa comunidade")
   _box("Caixa d agua",Vector3(1.3,1,1.3),p+Vector3(0,h+0.6,0),Color(0.12,0.22,0.28),false)
func _park()->void:
 _box("Campo de futebol",Vector3(30,0.15,20),Vector3(43,0.08,45),Color(0.14,0.42,0.17),false)
 _building(Vector3(35,0,66),Vector3(16,5,10),Color(0.78,0.76,0.64),"Escola")
 _box("Quadra",Vector3(20,0.15,14),Vector3(-39,0.08,53),Color(0.22,0.32,0.46),false)
func _christ()->void:
 _box("Morro mirante",Vector3(27,4,24),Vector3(57,2,-52),Color(0.3,0.48,0.28))
 var stone:=Color(0.82,0.82,0.78)
 _box("Cristo corpo",Vector3(2.2,7,1.6),Vector3(57,9,-52),stone,false)
 _box("Cristo cabeca",Vector3(1.7,1.7,1.7),Vector3(57,13.2,-52),stone,false)
 _box("Cristo bracos",Vector3(10,1.3,1.4),Vector3(57,10.8,-52),stone,false)
 _box("Cristo base",Vector3(5,2,5),Vector3(57,5,-52),Color(0.67,0.67,0.63))
func _vehicles()->void:
 _spawn("Carro",Vector3(4,0.8,7),18.0)
 _spawn("Moto",Vector3(8,0.8,7),15.0)
 _spawn("Bicicleta",Vector3(12,0.8,7),9.0)
func _spawn(kind:String,p:Vector3,spd:float)->void:
 var v:=CharacterBody3D.new()
 v.set_script(VEHICLE_SCRIPT)
 v.set("vehicle_name",kind)
 v.set("max_speed",spd)
 v.position=p
 add_child(v)
func _street()->void:
 for z in range(-50,60,20):
  _box("Poste",Vector3(0.18,5,0.18),Vector3(-11,2.5,float(z)),Color(0.15,0.15,0.16),false)
  _box("Luz",Vector3(1.1,0.12,0.25),Vector3(-10.5,4.9,float(z)),Color(1,0.88,0.68),false)
