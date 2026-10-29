extends Node3D
## Ambientação extra: pedestres, veículos, telhados e detalhes urbanos.

func _ready() -> void:
    _street_details()
    _rooftop_details()
    _vehicles()
    _pedestrians()
    _skyline()
    var services := preload("res://scripts/emergency_services.gd").new()
    services.name = "EmergencyServices"
    add_child(services)

func mat(c: Color, r := 0.82) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = c
    m.roughness = r
    return m

func box(parent: Node3D, size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
    var n := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    n.mesh = mesh
    n.position = pos
    n.material_override = mat(color)
    n.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
    parent.add_child(n)
    return n

func cyl(parent: Node3D, radius: float, height: float, pos: Vector3, color: Color) -> MeshInstance3D:
    var n := MeshInstance3D.new()
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.height = height
    n.mesh = mesh
    n.position = pos
    n.material_override = mat(color)
    parent.add_child(n)
    return n

func _street_details() -> void:
    # Postes, luminárias, faixa de pedestres, lixeiras e abrigo de ônibus.
    for z in range(-42, 48, 12):
        cyl(self, 0.09, 6.2, Vector3(-11.7, 3.1, z), Color(0.16,0.17,0.18))
        box(self, Vector3(1.15,0.12,0.22), Vector3(-11.2,6.1,z), Color(0.95,0.82,0.52))
        box(self, Vector3(0.55,0.85,0.5), Vector3(11.2,0.65,z+3), Color(0.12,0.34,0.19))
    for i in range(9):
        box(self, Vector3(0.75,0.025,4.0), Vector3(-5.2+i*1.3,0.09,18), Color(0.92,0.92,0.88))
    box(self, Vector3(4.5,0.12,1.5), Vector3(12.7,2.6,21), Color(0.16,0.19,0.23))
    for x in [10.6,14.8]:
        box(self, Vector3(0.12,2.5,0.12), Vector3(x,1.35,21), Color(0.15,0.17,0.19))
    box(self, Vector3(4.2,1.7,0.07), Vector3(12.7,1.35,20.25), Color(0.32,0.56,0.65))

func _rooftop_details() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = 24091
    for i in range(18):
        var x := rng.randf_range(-43,-20)
        var z := rng.randf_range(-42,-12)
        var y := rng.randf_range(8,15)
        box(self, Vector3(0.12,1.3,0.12), Vector3(x-0.55,y,z), Color(0.25,0.25,0.26))
        box(self, Vector3(0.12,1.3,0.12), Vector3(x+0.55,y,z), Color(0.25,0.25,0.26))
        cyl(self,0.72,1.15,Vector3(x,y+1.05,z),Color(0.08,0.25,0.65))
        cyl(self,0.74,0.1,Vector3(x,y+1.68,z),Color(0.04,0.17,0.5))
        for side in [-1.0,1.0]:
            cyl(self,0.035,1.25,Vector3(x+side*1.3,y+0.62,z),Color(0.32,0.29,0.26))

func _car(pos: Vector3, color: Color, roof_ladder := false) -> void:
    var root := Node3D.new()
    root.position = pos
    add_child(root)
    box(root,Vector3(1.9,0.62,4.0),Vector3(0,0.65,0),color)
    box(root,Vector3(1.62,0.72,1.9),Vector3(0,1.27,-0.18),Color(0.12,0.2,0.25))
    box(root,Vector3(1.72,0.12,1.82),Vector3(0,1.67,-0.18),color)
    for x in [-0.72,0.72]:
        box(root,Vector3(0.35,0.2,0.06),Vector3(x,0.72,2.02),Color(1.0,0.88,0.56))
        box(root,Vector3(0.35,0.2,0.06),Vector3(x,0.72,-2.02),Color(0.72,0.04,0.03))
        for z in [-1.35,1.35]:
            var wheel := cyl(root,0.37,0.22,Vector3(x*1.34,0.38,z),Color(0.035,0.035,0.04))
            wheel.rotation.z = PI/2
    if roof_ladder:
        for x in [-0.55,0.55]:
            cyl(root,0.035,2.35,Vector3(x,2.12,-0.1),Color(0.65,0.67,0.69))
        for z in [-0.9,-0.3,0.3,0.9]:
            box(root,Vector3(1.12,0.04,0.05),Vector3(0,2.12,z),Color(0.65,0.67,0.69))

func _vehicles() -> void:
    _car(Vector3(-7,0.1,34),Color(0.9,0.92,0.9),true)
    _car(Vector3(8,0.1,38),Color(0.72,0.08,0.06))
    _car(Vector3(15,0.1,-28),Color(0.08,0.28,0.65))
    # Moto de baixa cilindrada.
    var moto := Node3D.new()
    moto.position = Vector3(4,0.1,27)
    add_child(moto)
    for z in [-0.8,0.8]:
        var wheel := cyl(moto,0.34,0.14,Vector3(0,0.42,z),Color(0.025,0.025,0.03))
        wheel.rotation.z = PI/2
    box(moto,Vector3(0.35,0.42,0.85),Vector3(0,0.92,0),Color(0.8,0.08,0.04))
    box(moto,Vector3(0.42,0.13,0.55),Vector3(0,1.2,-0.1),Color(0.08,0.08,0.09))
    # Bicicleta simples.
    var bike := Node3D.new()
    bike.position = Vector3(-13,0.1,23)
    add_child(bike)
    for z in [-0.65,0.65]:
        var wheel := cyl(bike,0.42,0.055,Vector3(0,0.5,z),Color(0.04,0.04,0.045))
        wheel.rotation.z = PI/2
    box(bike,Vector3(0.06,0.8,0.06),Vector3(0,0.85,0),Color(0.85,0.18,0.04))
    box(bike,Vector3(0.06,0.06,0.9),Vector3(0,1.05,0),Color(0.85,0.18,0.04))

func _pedestrians() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = 781
    # Dois NPCs com roupas inspiradas nas referências enviadas.
    _clown_outfit_npc(Vector3(-4.5,0.1,12), Color(0.04,0.20,0.78), Color(0.96,0.96,0.94), false)
    _clown_outfit_npc(Vector3(5.5,0.1,15), Color(0.96,0.16,0.58), Color(1.0,0.92,0.96), true)
    for i in range(12):
        var p := Node3D.new()
        p.position = Vector3(rng.randf_range(-13,13),0.1,rng.randf_range(-18,28))
        var shirts := [Color(0.1,0.25,0.7),Color(0.7,0.12,0.08),Color(0.18,0.42,0.22),Color(0.75,0.62,0.34)]
        box(p,Vector3(0.52,0.78,0.28),Vector3(0,1.05,0),shirts[i%4])
        cyl(p,0.19,0.36,Vector3(0,1.63,0),Color(0.55,0.35,0.24))
        for side in [-1.0,1.0]:
            var arm := box(p,Vector3(0.17,0.72,0.19),Vector3(side*0.3,1.05,0),shirts[i%4])
            arm.name = "LimbArm" + str(int(side))
            var leg := box(p,Vector3(0.18,0.72,0.2),Vector3(side*0.13,0.32,0),Color(0.12,0.13,0.16))
            leg.name = "LimbLeg" + str(int(side))
        p.set_script(preload("res://scripts/pedestrian_ai.gd"))
        add_child(p)

func _clown_outfit_npc(pos: Vector3, main_color: Color, accent: Color, feminine: bool) -> void:
    var p := Node3D.new()
    p.position = pos
    add_child(p)
    var skin := Color(0.38,0.22,0.16) if feminine else Color(0.31,0.18,0.13)
    # Camiseta larga, mangas, bermuda e pernas.
    box(p,Vector3(0.78,0.88,0.34),Vector3(0,1.18,0),main_color)
    for side in [-1.0,1.0]:
        box(p,Vector3(0.27,0.34,0.36),Vector3(side*0.49,1.36,0),accent)
        box(p,Vector3(0.27,0.78,0.28),Vector3(side*0.22,0.48,0),main_color)
        box(p,Vector3(0.16,0.12,0.32),Vector3(side*0.22,0.08,-0.04),Color(0.94,0.91,0.86))
        box(p,Vector3(0.22,0.12,0.42),Vector3(side*0.22,0.02,-0.1),accent)
    box(p,Vector3(0.76,0.46,0.38),Vector3(0,0.68,0),main_color)
    box(p,Vector3(0.035,0.48,0.02),Vector3(0,0.68,-0.205),accent)
    # Estampa frontal estilizada de palhaço (sem copiar uma arte protegida).
    var face := Color(0.96,0.94,0.9)
    box(p,Vector3(0.43,0.28,0.025),Vector3(0,1.12,-0.19),face)
    for side in [-1.0,1.0]:
        box(p,Vector3(0.11,0.09,0.035),Vector3(side*0.12,1.17,-0.215),main_color.darkened(0.35))
    cyl(p,0.075,0.035,Vector3(0,1.08,-0.235),Color(0.9,0.04,0.08))
    # Cabeça, cabelo e braços.
    cyl(p,0.19,0.34,Vector3(0,1.86,0),skin)
    var hair := Color(0.035,0.025,0.02)
    cyl(p,0.195,0.11,Vector3(0,2.03,0),hair)
    for side in [-1.0,1.0]:
        box(p,Vector3(0.15,0.65,0.16),Vector3(side*0.49,1.12,0),skin)
    if feminine:
        # Cabelo comprido nas costas.
        box(p,Vector3(0.38,0.9,0.12),Vector3(0,1.55,0.2),hair)
        box(p,Vector3(0.12,0.65,0.12),Vector3(-0.2,1.45,0.08),hair)
        box(p,Vector3(0.12,0.65,0.12),Vector3(0.2,1.45,0.08),hair)

func _skyline() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = 2026
    for i in range(24):
        var x := rng.randf_range(42,78)
        var z := rng.randf_range(-72,72)
        var h := rng.randf_range(12,34)
        box(self,Vector3(rng.randf_range(7,12),h,rng.randf_range(7,12)),Vector3(x,h*0.5,z),[Color(0.55,0.62,0.68),Color(0.75,0.72,0.65),Color(0.48,0.54,0.6)][i%3])
