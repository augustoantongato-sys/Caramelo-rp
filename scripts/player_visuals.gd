extends Node3D
## Modelo procedural de personagem com braços e pernas animados.

var left_arm: Node3D
var right_arm: Node3D
var left_leg: Node3D
var right_leg: Node3D
var weapon: MeshInstance3D
var walk_time := 0.0

func _mat(c: Color) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = c
    m.roughness = 0.88
    return m

func _capsule(parent: Node3D, radius: float, height: float, pos: Vector3, color: Color) -> MeshInstance3D:
    var n := MeshInstance3D.new()
    var mesh := CapsuleMesh.new()
    mesh.radius = radius
    mesh.height = height
    n.mesh = mesh
    n.position = pos
    n.material_override = _mat(color)
    parent.add_child(n)
    return n

func _ready() -> void:
    _capsule(self,0.31,0.82,Vector3(0,1.08,0),Color(0.12,0.2,0.32))
    _capsule(self,0.19,0.38,Vector3(0,1.72,0),Color(0.58,0.38,0.27))
    var cap := MeshInstance3D.new()
    var cap_mesh := SphereMesh.new()
    cap_mesh.radius = 0.205
    cap_mesh.height = 0.12
    cap.mesh = cap_mesh
    cap.position = Vector3(0,1.91,0)
    cap.material_override = _mat(Color(0.08,0.08,0.09))
    add_child(cap)
    left_arm = _limb(Vector3(-0.37,1.37,0),Color(0.58,0.38,0.27))
    right_arm = _limb(Vector3(0.37,1.37,0),Color(0.58,0.38,0.27))
    left_leg = _limb(Vector3(-0.16,0.72,0),Color(0.09,0.1,0.13))
    right_leg = _limb(Vector3(0.16,0.72,0),Color(0.09,0.1,0.13))
    weapon = MeshInstance3D.new()
    var gun := BoxMesh.new()
    gun.size = Vector3(0.09,0.12,0.34)
    weapon.mesh = gun
    weapon.position = Vector3(0,-0.46,-0.23)
    weapon.material_override = _mat(Color(0.075,0.08,0.09))
    right_arm.add_child(weapon)
    weapon.visible = false

func _limb(pos: Vector3, color: Color) -> Node3D:
    var pivot := Node3D.new()
    pivot.position = pos
    add_child(pivot)
    _capsule(pivot,0.12,0.72,Vector3(0,-0.32,0),color)
    return pivot

func set_weapon_visible(value: bool) -> void:
    weapon.visible = value

func animate_motion(speed: float, aiming: bool, has_weapon: bool, delta: float) -> void:
    walk_time += delta * (9.0 if speed > 5.5 else 6.0)
    var swing := sin(walk_time) * 0.62 * clampf(speed/7.5,0.0,1.0)
    left_leg.rotation.x = swing
    right_leg.rotation.x = -swing
    if aiming and has_weapon:
        right_arm.rotation.x = -1.15
        right_arm.rotation.z = -0.12
        left_arm.rotation.x = -0.78
        left_arm.rotation.z = 0.16
    else:
        right_arm.rotation.x = -swing*0.55
        right_arm.rotation.z = 0.0
        left_arm.rotation.x = swing*0.55
        left_arm.rotation.z = 0.0
