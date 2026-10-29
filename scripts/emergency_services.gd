extends Node3D
## Serviços públicos e emergência do Caramelo RP.
## Modelos 3D procedurais de cenário: polícia, bombeiros e saúde.

func _ready() -> void:
    _spawn_vehicles()
    _spawn_people()

func _mat(c: Color, rough := 0.78) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = c
    m.roughness = rough
    return m

func _box(p: Node3D, size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
    var n := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    n.mesh = mesh
    n.position = pos
    n.material_override = _mat(color)
    n.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
    p.add_child(n)
    return n

func _cyl(p: Node3D, radius: float, height: float, pos: Vector3, color: Color) -> MeshInstance3D:
    var n := MeshInstance3D.new()
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.height = height
    n.mesh = mesh
    n.position = pos
    n.material_override = _mat(color)
    p.add_child(n)
    return n

func _wheel(p: Node3D, x: float, z: float, radius := 0.42) -> void:
    var w := _cyl(p, radius, 0.22, Vector3(x, radius, z), Color(0.025,0.027,0.03))
    w.name = "VehicleWheel"
    w.rotation.z = PI / 2.0
    var hub := _cyl(p, radius * 0.48, 0.235, Vector3(x, radius, z), Color(0.48,0.5,0.52))
    hub.name = "WheelHub"
    hub.rotation.z = PI / 2.0

func _lightbar(p: Node3D, y: float, z: float, blue := true) -> void:
    _box(p, Vector3(1.15,0.09,0.22), Vector3(0,y,z), Color(0.12,0.12,0.14))
    _box(p, Vector3(0.48,0.13,0.2), Vector3(-0.29,y+0.08,z), Color(0.9,0.035,0.025))
    _box(p, Vector3(0.48,0.13,0.2), Vector3(0.29,y+0.08,z), Color(0.03,0.2,0.95) if blue else Color(0.95,0.82,0.12))

func _sedan(p: Node3D, police := true) -> void:
    var blue := Color(0.015,0.32,0.78)
    var white := Color(0.88,0.9,0.9)
    _box(p,Vector3(2.05,0.62,4.45),Vector3(0,0.78,0),white if police else Color(0.12,0.15,0.18))
    _box(p,Vector3(1.82,0.78,2.05),Vector3(0,1.43,-0.15),Color(0.08,0.13,0.17))
    _box(p,Vector3(1.95,0.18,2.2),Vector3(0,1.88,-0.15),blue if police else Color(0.12,0.15,0.18))
    if police:
        _box(p,Vector3(2.07,0.34,1.65),Vector3(0,0.85,0.0),blue)
        _box(p,Vector3(0.025,0.16,1.1),Vector3(0,0.87,-0.84),white)
        _lightbar(p,2.0,-0.1)
        _box(p,Vector3(0.8,0.08,0.04),Vector3(0,1.02,-2.24),Color(0.04,0.04,0.04))
    else:
        _box(p,Vector3(1.95,0.22,0.28),Vector3(0,0.84,-2.25),Color(0.85,0.03,0.03))
    for x in [-0.92,0.92]:
        for z in [-1.48,1.48]:
            _wheel(p,x,z,0.39)
    for x in [-0.7,0.7]:
        _box(p,Vector3(0.38,0.18,0.05),Vector3(x,0.82,-2.25),Color(1.0,0.9,0.65))

func _armored(p: Node3D, van := false) -> void:
    var dark := Color(0.075,0.09,0.1)
    var length := 5.1 if van else 4.5
    _box(p,Vector3(2.5,1.15,length),Vector3(0,1.0,0),dark)
    _box(p,Vector3(2.28,1.0,length*0.72),Vector3(0,2.0,0.05),Color(0.11,0.13,0.14))
    _box(p,Vector3(2.35,0.18,length*0.8),Vector3(0,2.58,0.05),Color(0.045,0.055,0.06))
    for side in [-1.0,1.0]:
        for z in [-1.55,0.0,1.55]:
            _box(p,Vector3(0.035,0.38,0.68),Vector3(side*1.16,2.05,z),Color(0.025,0.03,0.035))
        for z in [-1.65,1.65]:
            _wheel(p,side*1.27,z,0.57)
    for z in [-length*0.5,length*0.5]:
        _box(p,Vector3(2.5,0.32,0.22),Vector3(0,0.65,z),Color(0.025,0.03,0.035))
    _lightbar(p,2.7,-0.25)

func _fire_engine(p: Node3D, compact := false) -> void:
    var red := Color(0.78,0.035,0.025)
    var len := 5.6 if compact else 7.0
    _box(p,Vector3(2.45,1.35,len),Vector3(0,1.15,0.2),red)
    _box(p,Vector3(2.35,1.45,2.0),Vector3(0,2.05,-2.0),red)
    _box(p,Vector3(2.05,0.72,1.15),Vector3(0,2.2,-2.02),Color(0.1,0.15,0.18))
    for side in [-1.0,1.0]:
        _box(p,Vector3(0.045,0.13,len*0.75),Vector3(side*1.24,1.15,0.25),Color(0.93,0.91,0.78))
        for z in [-2.1,1.8]:
            _wheel(p,side*1.28,z,0.52)
        for z in [-0.9,0.1,1.0]:
            _box(p,Vector3(0.05,0.62,0.06),Vector3(side*1.27,1.55,z),Color(0.48,0.5,0.52))
    _lightbar(p,2.95,-2.0,false)
    # Escada de salvamento no teto
    _box(p,Vector3(0.12,0.12,len*0.75),Vector3(-0.48,2.95,0.25),Color(0.58,0.6,0.62))
    _box(p,Vector3(0.12,0.12,len*0.75),Vector3(0.48,2.95,0.25),Color(0.58,0.6,0.62))
    for z in range(-2,4):
        _box(p,Vector3(1.0,0.08,0.07),Vector3(0,2.95,float(z)*0.65),Color(0.58,0.6,0.62))

func _ambulance(p: Node3D) -> void:
    _box(p,Vector3(2.15,2.0,4.9),Vector3(0,1.25,0),Color(0.91,0.92,0.89))
    _box(p,Vector3(1.92,0.9,1.2),Vector3(0,2.72,-1.48),Color(0.08,0.15,0.18))
    _box(p,Vector3(2.17,0.32,4.92),Vector3(0,0.42,0),Color(0.78,0.035,0.045))
    _box(p,Vector3(0.18,0.58,0.06),Vector3(0,1.65,-2.48),Color(0.05,0.3,0.75))
    _box(p,Vector3(0.08,0.55,0.06),Vector3(0,1.65,-2.52),Color(0.9,0.92,0.9))
    _box(p,Vector3(1.4,0.32,0.06),Vector3(0,1.65,-2.53),Color(0.9,0.92,0.9))
    _box(p,Vector3(1.15,0.12,0.18),Vector3(0,2.32,0.0),Color(0.8,0.03,0.04))
    _lightbar(p,2.38,-0.1,false)
    for x in [-0.92,0.92]:
        for z in [-1.65,1.65]:
            _wheel(p,x,z,0.4)

func _place_vehicle(pos: Vector3, kind: String) -> void:
    var p := CharacterBody3D.new()
    p.set_script(preload("res://scripts/drivable_vehicle.gd"))
    p.position = pos
    p.vehicle_label = {
        "police":"Viatura policial", "armored_suv":"SUV blindada",
        "armored_van":"Van blindada", "fire":"Caminhão de bombeiros",
        "fire_compact":"Caminhão de bombeiros compacto", "ambulance":"Ambulância SAMU"
    }.get(kind,"Veículo")
    add_child(p)
    match kind:
        "police": _sedan(p,true)
        "armored_suv": _armored(p,false)
        "armored_van": _armored(p,true)
        "fire": _fire_engine(p,false)
        "fire_compact": _fire_engine(p,true)
        "ambulance": _ambulance(p)

func _spawn_vehicles() -> void:
    _place_vehicle(Vector3(-6.7,0.08,-37.0),"police")
    _place_vehicle(Vector3(6.8,0.08,-36.0),"armored_suv")
    _place_vehicle(Vector3(-6.8,0.08,-23.0),"fire")
    _place_vehicle(Vector3(6.8,0.08,-22.0),"ambulance")
    _place_vehicle(Vector3(15.0,0.08,-38.0),"armored_van")
    _place_vehicle(Vector3(15.0,0.08,-24.0),"fire_compact")

func _person(pos: Vector3, role: String) -> void:
    var p := Node3D.new()
    p.position = pos
    add_child(p)
    var skin := Color(0.45,0.29,0.21)
    var uniform := Color(0.055,0.065,0.07)
    if role == "bombeiro":
        uniform = Color(0.68,0.57,0.42)
    elif role == "saude":
        uniform = Color(0.9,0.91,0.88)
    _box(p,Vector3(0.62,0.86,0.32),Vector3(0,1.15,0),uniform)
    _cyl(p,0.19,0.36,Vector3(0,1.8,0),skin)
    for side in [-1.0,1.0]:
        var arm := _box(p,Vector3(0.2,0.78,0.22),Vector3(side*0.39,1.12,0),uniform)
        arm.name = "LimbArm" + str(int(side))
        var leg := _box(p,Vector3(0.23,0.78,0.25),Vector3(side*0.18,0.42,0),Color(0.045,0.05,0.055))
        leg.name = "LimbLeg" + str(int(side))
    var ai := preload("res://scripts/pedestrian_ai.gd").new()
    p.add_child(ai)
    if role == "policia":
        _cyl(p,0.22,0.12,Vector3(0,2.02,0),Color(0.025,0.03,0.035))
        _box(p,Vector3(0.22,0.16,0.08),Vector3(0,1.25,-0.19),Color(0.58,0.48,0.18))
    elif role == "bombeiro":
        _cyl(p,0.25,0.2,Vector3(0,2.02,0),Color(0.85,0.055,0.025))
        _box(p,Vector3(0.68,0.1,0.36),Vector3(0,1.42,0),Color(0.95,0.83,0.12))
        _box(p,Vector3(0.36,0.6,0.18),Vector3(0,1.28,0.23),Color(0.24,0.26,0.27))
    else:
        _box(p,Vector3(0.68,0.1,0.36),Vector3(0,1.42,0),Color(0.05,0.34,0.78))
        _box(p,Vector3(0.13,0.48,0.04),Vector3(0,1.2,-0.19),Color(0.05,0.34,0.78))

func _spawn_people() -> void:
    _person(Vector3(-3.8,0.08,-29.0),"policia")
    _person(Vector3(-2.7,0.08,-29.0),"policia")
    _person(Vector3(3.0,0.08,-17.0),"bombeiro")
    _person(Vector3(4.0,0.08,-17.0),"bombeiro")
    _person(Vector3(11.0,0.08,-17.0),"saude")
    _person(Vector3(12.0,0.08,-17.0),"saude")
