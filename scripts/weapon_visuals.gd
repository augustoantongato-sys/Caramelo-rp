extends Node3D
class_name WeaponVisuals

# Modelos estilizados com volumes arredondados para o Caramelo RP.
# São meshes visuais de jogo; não representam dimensões ou funcionamento reais.

const MAT_DARK := Color(0.075, 0.085, 0.10)
const MAT_STEEL := Color(0.42, 0.46, 0.50)
const MAT_BLACK := Color(0.025, 0.03, 0.035)
const MAT_WOOD := Color(0.25, 0.13, 0.065)
const MAT_BRASS := Color(0.62, 0.43, 0.16)
const MAT_GLASS := Color(0.12, 0.28, 0.42, 0.8)

var model_root: Node3D
var current_index := -1

func _ready() -> void:
    set_weapon(0)

func set_weapon(index: int) -> void:
    var safe_index := clampi(index, 0, 9)
    if safe_index == current_index:
        return
    current_index = safe_index
    if is_instance_valid(model_root):
        model_root.queue_free()
    model_root = Node3D.new()
    model_root.name = "WeaponModel"
    add_child(model_root)
    match current_index:
        0: _build_pistol()
        1: _build_revolver()
        2: _build_sniper()
        3: _build_smg()
        4: _build_rifle()
        5: _build_lmg()
        6: _build_shotgun()
        7: _build_axe()
        8: _build_knife()
        9: _build_handcuffs()

func _material(color: Color, metallic := 0.25, roughness := 0.42) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.metallic = metallic
    mat.roughness = roughness
    return mat

func _sphere(name: String, size: Vector3, pos: Vector3, color: Color, metallic := 0.2) -> MeshInstance3D:
    var mesh := SphereMesh.new()
    mesh.radial_segments = 24
    mesh.rings = 12
    mesh.radius = 0.5
    mesh.height = 1.0
    var part := MeshInstance3D.new()
    part.name = name
    part.mesh = mesh
    part.scale = size
    part.position = pos
    part.material_override = _material(color, metallic)
    model_root.add_child(part)
    return part

func _capsule(name: String, radius: float, height: float, pos: Vector3, color: Color, rot := Vector3.ZERO) -> MeshInstance3D:
    var mesh := CapsuleMesh.new()
    mesh.radius = radius
    mesh.height = maxf(height, radius * 2.0)
    mesh.radial_segments = 16
    mesh.rings = 8
    var part := MeshInstance3D.new()
    part.name = name
    part.mesh = mesh
    part.position = pos
    part.rotation = rot
    part.material_override = _material(color)
    model_root.add_child(part)
    return part

func _barrel(name: String, length: float, radius: float, x: float, y: float, color := MAT_STEEL) -> MeshInstance3D:
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius * 1.04
    mesh.height = length
    mesh.radial_segments = 24
    var part := MeshInstance3D.new()
    part.name = name
    part.mesh = mesh
    part.position = Vector3(x, y, 0)
    part.rotation.z = PI / 2.0
    part.material_override = _material(color, 0.72, 0.3)
    model_root.add_child(part)
    return part

func _build_pistol() -> void:
    _sphere("Ferrolho arredondado", Vector3(0.34, 0.075, 0.075), Vector3(0.02, 0.06, 0), MAT_DARK, 0.65)
    _sphere("Empunhadura", Vector3(0.105, 0.24, 0.075), Vector3(-0.105, -0.075, 0), MAT_BLACK)
    _barrel("Cano", 0.16, 0.018, 0.20, 0.065)
    _sphere("Guarda-mato", Vector3(0.10, 0.012, 0.045), Vector3(0.02, -0.035, 0), MAT_STEEL)
    _sphere("Mira frontal", Vector3(0.025, 0.025, 0.025), Vector3(0.17, 0.105, 0), MAT_STEEL)

func _build_revolver() -> void:
    _sphere("Corpo do revolver", Vector3(0.25, 0.085, 0.075), Vector3(0.015, 0.055, 0), MAT_STEEL, 0.8)
    _sphere("Tambor", Vector3(0.09, 0.10, 0.09), Vector3(0.015, 0.055, 0), MAT_DARK, 0.8)
    _barrel("Cano", 0.23, 0.022, 0.23, 0.07)
    _capsule("Cabo de madeira", 0.045, 0.22, Vector3(-0.12, -0.075, 0), MAT_WOOD, Vector3(0, 0, -0.22))
    _sphere("Cão", Vector3(0.045, 0.055, 0.035), Vector3(-0.08, 0.12, 0), MAT_STEEL)

func _build_sniper() -> void:
    _sphere("Coronha", Vector3(0.30, 0.07, 0.07), Vector3(-0.36, 0.0, 0), MAT_WOOD)
    _sphere("Corpo central", Vector3(0.28, 0.075, 0.07), Vector3(-0.02, 0.045, 0), MAT_DARK, 0.55)
    _barrel("Cano longo", 0.78, 0.018, 0.48, 0.065)
    _sphere("Luneta", Vector3(0.28, 0.055, 0.055), Vector3(-0.03, 0.16, 0), MAT_DARK, 0.7)
    _sphere("Lente", Vector3(0.025, 0.052, 0.052), Vector3(0.12, 0.16, 0), MAT_GLASS, 0.1)
    _capsule("Bipé esquerdo", 0.012, 0.20, Vector3(0.35, -0.09, -0.035), MAT_STEEL)
    _capsule("Bipé direito", 0.012, 0.20, Vector3(0.35, -0.09, 0.035), MAT_STEEL)

func _build_smg() -> void:
    _sphere("Receptor compacto", Vector3(0.30, 0.075, 0.075), Vector3(0.02, 0.045, 0), MAT_DARK, 0.65)
    _barrel("Cano", 0.26, 0.018, 0.30, 0.06)
    _sphere("Carregador", Vector3(0.07, 0.18, 0.06), Vector3(-0.02, -0.09, 0), MAT_BLACK)
    _capsule("Empunhadura", 0.035, 0.16, Vector3(-0.12, -0.075, 0), MAT_BLACK, Vector3(0, 0, -0.12))
    _sphere("Coronha", Vector3(0.18, 0.035, 0.04), Vector3(-0.30, 0.02, 0), MAT_BLACK)

func _build_rifle() -> void:
    _sphere("Receptor superior", Vector3(0.34, 0.075, 0.075), Vector3(0.03, 0.05, 0), MAT_DARK, 0.65)
    _sphere("Guarda-mao", Vector3(0.25, 0.06, 0.065), Vector3(0.35, 0.045, 0), MAT_BLACK)
    _barrel("Cano", 0.43, 0.016, 0.66, 0.06)
    _sphere("Coronha", Vector3(0.22, 0.065, 0.06), Vector3(-0.34, 0.025, 0), MAT_BLACK)
    _sphere("Carregador curvo", Vector3(0.075, 0.19, 0.06), Vector3(-0.02, -0.10, 0), MAT_BLACK)
    _sphere("Mira óptica", Vector3(0.10, 0.045, 0.045), Vector3(0.02, 0.14, 0), MAT_STEEL, 0.7)

func _build_lmg() -> void:
    _sphere("Caixa da arma", Vector3(0.42, 0.10, 0.085), Vector3(0.02, 0.06, 0), MAT_DARK, 0.7)
    _barrel("Cano pesado", 0.52, 0.027, 0.48, 0.075)
    _sphere("Coronha", Vector3(0.25, 0.075, 0.07), Vector3(-0.38, 0.025, 0), MAT_BLACK)
    _sphere("Caixa de munição", Vector3(0.16, 0.12, 0.09), Vector3(0.0, -0.09, 0), MAT_STEEL, 0.65)
    _capsule("Bipé", 0.014, 0.20, Vector3(0.38, -0.08, 0), MAT_STEEL)

func _build_shotgun() -> void:
    _sphere("Corpo", Vector3(0.34, 0.07, 0.07), Vector3(0.0, 0.04, 0), MAT_DARK, 0.5)
    _barrel("Cano", 0.55, 0.025, 0.45, 0.075)
    _sphere("Coronha de madeira", Vector3(0.29, 0.075, 0.065), Vector3(-0.36, 0.015, 0), MAT_WOOD)
    _sphere("Guarda-mao pump", Vector3(0.17, 0.055, 0.06), Vector3(0.28, -0.005, 0), MAT_WOOD)
    _barrel("Tubo inferior", 0.42, 0.016, 0.38, 0.025, MAT_STEEL)

func _build_axe() -> void:
    _capsule("Cabo", 0.025, 0.72, Vector3(0, 0, 0), MAT_WOOD, Vector3(0, 0, PI / 2.0))
    _sphere("Cabeça", Vector3(0.16, 0.14, 0.055), Vector3(0.35, 0.0, 0), MAT_STEEL, 0.85)
    _sphere("Lâmina", Vector3(0.10, 0.22, 0.035), Vector3(0.43, 0.0, 0), MAT_STEEL, 0.9)

func _build_knife() -> void:
    _sphere("Lâmina", Vector3(0.25, 0.025, 0.025), Vector3(0.16, 0.025, 0), MAT_STEEL, 0.9)
    _sphere("Guarda", Vector3(0.025, 0.075, 0.04), Vector3(-0.01, 0.02, 0), MAT_DARK, 0.6)
    _capsule("Cabo", 0.025, 0.17, Vector3(-0.11, 0.0, 0), MAT_BLACK, Vector3(0, 0, PI / 2.0))

func _build_handcuffs() -> void:
    for side in [-1.0, 1.0]:
        var ring := MeshInstance3D.new()
        var mesh := TorusMesh.new()
        mesh.inner_radius = 0.045
        mesh.outer_radius = 0.058
        mesh.rings = 16
        mesh.ring_segments = 24
        ring.mesh = mesh
        ring.position = Vector3(0, side * 0.075, 0)
        ring.rotation.x = PI / 2.0
        ring.material_override = _material(MAT_STEEL, 0.85, 0.25)
        model_root.add_child(ring)
    _sphere("Corrente", Vector3(0.11, 0.018, 0.018), Vector3(0, 0, 0), MAT_STEEL, 0.85)
