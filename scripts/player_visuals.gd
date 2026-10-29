extends Node3D
## Personagem procedural com balanço de membros suavizado.

var left_arm: Node3D
var right_arm: Node3D
var left_leg: Node3D
var right_leg: Node3D
var weapon: MeshInstance3D
var walk_time := 0.0
var gait_blend := 0.0
var body_mesh: MeshInstance3D

func _mat(color: Color) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.88
    return material

func _capsule(parent: Node3D, radius: float, height: float, pos: Vector3, color: Color) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    var mesh := CapsuleMesh.new()
    mesh.radius = radius
    mesh.height = height
    node.mesh = mesh
    node.position = pos
    node.material_override = _mat(color)
    parent.add_child(node)
    return node

func _ready() -> void:
    body_mesh = _capsule(self, 0.31, 0.82, Vector3(0, 1.08, 0), Color(0.12, 0.2, 0.32))
    _capsule(self, 0.19, 0.38, Vector3(0, 1.72, 0), Color(0.58, 0.38, 0.27))
    var cap := MeshInstance3D.new()
    var cap_mesh := SphereMesh.new()
    cap_mesh.radius = 0.205
    cap_mesh.height = 0.12
    cap.mesh = cap_mesh
    cap.position = Vector3(0, 1.91, 0)
    cap.material_override = _mat(Color(0.08, 0.08, 0.09))
    add_child(cap)
    left_arm = _limb(Vector3(-0.37, 1.37, 0), Color(0.58, 0.38, 0.27))
    right_arm = _limb(Vector3(0.37, 1.37, 0), Color(0.58, 0.38, 0.27))
    left_leg = _limb(Vector3(-0.16, 0.72, 0), Color(0.09, 0.1, 0.13))
    right_leg = _limb(Vector3(0.16, 0.72, 0), Color(0.09, 0.1, 0.13))
    weapon = MeshInstance3D.new()
    var gun := BoxMesh.new()
    gun.size = Vector3(0.09, 0.12, 0.34)
    weapon.mesh = gun
    weapon.position = Vector3(0, -0.46, -0.23)
    weapon.material_override = _mat(Color(0.075, 0.08, 0.09))
    right_arm.add_child(weapon)
    weapon.visible = false

func _limb(pos: Vector3, color: Color) -> Node3D:
    var pivot := Node3D.new()
    pivot.position = pos
    add_child(pivot)
    _capsule(pivot, 0.12, 0.72, Vector3(0, -0.32, 0), color)
    return pivot

func set_weapon_visible(value: bool) -> void:
    if is_instance_valid(weapon):
        weapon.visible = value

func animate_motion(speed: float, aiming: bool, has_weapon: bool, delta: float) -> void:
    var target_blend := clampf(speed / 4.8, 0.0, 1.0)
    gait_blend = move_toward(gait_blend, target_blend, delta * 5.5)
    var gait_rate := lerpf(5.0, 10.5, clampf(speed / 7.2, 0.0, 1.0))
    walk_time += delta * gait_rate
    var stride := sin(walk_time) * 0.48 * gait_blend
    var arm_stride := sin(walk_time + PI) * 0.34 * gait_blend

    left_leg.rotation.x = lerpf(left_leg.rotation.x, stride, minf(1.0, delta * 12.0))
    right_leg.rotation.x = lerpf(right_leg.rotation.x, -stride, minf(1.0, delta * 12.0))

    if aiming and has_weapon:
        right_arm.rotation.x = lerpf(right_arm.rotation.x, -1.05, minf(1.0, delta * 9.0))
        right_arm.rotation.z = lerpf(right_arm.rotation.z, -0.12, minf(1.0, delta * 9.0))
        left_arm.rotation.x = lerpf(left_arm.rotation.x, -0.72, minf(1.0, delta * 9.0))
        left_arm.rotation.z = lerpf(left_arm.rotation.z, 0.14, minf(1.0, delta * 9.0))
    else:
        right_arm.rotation.x = lerpf(right_arm.rotation.x, arm_stride, minf(1.0, delta * 10.0))
        right_arm.rotation.z = lerpf(right_arm.rotation.z, 0.0, minf(1.0, delta * 10.0))
        left_arm.rotation.x = lerpf(left_arm.rotation.x, -arm_stride, minf(1.0, delta * 10.0))
        left_arm.rotation.z = lerpf(left_arm.rotation.z, 0.0, minf(1.0, delta * 10.0))

    if is_instance_valid(body_mesh):
        body_mesh.position.y = lerpf(body_mesh.position.y, 1.08 + absf(stride) * 0.035, minf(1.0, delta * 10.0))
