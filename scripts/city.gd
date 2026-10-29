extends Node3D

func _ready() -> void:
    _make_environment()
    _make_city()
    _make_city_landmarks()
    var detail_pack := preload("res://scripts/city_detail_pack.gd").new()
    detail_pack.name = "CityDetailPack"
    add_child(detail_pack)

func _material(color: Color) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    return mat

func _box(parent: Node3D, size: Vector3, pos: Vector3, color: Color, collision := false) -> void:
    var mesh_instance := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    mesh_instance.mesh = mesh
    mesh_instance.position = pos
    mesh_instance.material_override = _material(color)
    parent.add_child(mesh_instance)
    if collision:
        var body := StaticBody3D.new()
        var shape := CollisionShape3D.new()
        var box_shape := BoxShape3D.new()
        box_shape.size = size
        shape.shape = box_shape
        body.position = pos
        body.add_child(shape)
        add_child(body)

func _make_environment() -> void:
    var world := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_SKY
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.55, 0.62, 0.72)
    env.ambient_light_energy = 0.8
    world.environment = env
    add_child(world)
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -30, 0)
    sun.light_energy = 1.2
    add_child(sun)

func _make_city() -> void:
    # Ground and asphalt avenue
    _box(self, Vector3(100, 0.5, 100), Vector3(0, -0.3, 0), Color(0.22, 0.42, 0.24), true)
    _box(self, Vector3(16, 0.12, 100), Vector3(0, 0.02, 0), Color(0.12, 0.12, 0.13), false)
    # Sidewalks
    _box(self, Vector3(4, 0.25, 100), Vector3(-10, 0.08, 0), Color(0.55, 0.53, 0.49), true)
    _box(self, Vector3(4, 0.25, 100), Vector3(10, 0.08, 0), Color(0.55, 0.53, 0.49), true)
    # Buildings along the avenue
    var colors := [Color(0.78,0.62,0.48), Color(0.68,0.72,0.74), Color(0.82,0.76,0.59), Color(0.62,0.66,0.58)]
    for i in range(8):
        var z := -40.0 + float(i) * 11.0
        _box(self, Vector3(10, 7 + float(i % 3) * 2, 8), Vector3(-20, 3.5 + float(i % 3), z), colors[i % colors.size()], true)
        _box(self, Vector3(10, 6 + float(i % 2) * 3, 8), Vector3(20, 3 + float(i % 2) * 1.5, z + 4), colors[(i + 1) % colors.size()], true)
    # Corner bar and grocery store, with colored shop fronts
    _box(self, Vector3(8, 3.5, 7), Vector3(-18, 1.75, 12), Color(0.78, 0.68, 0.48), true)
    _box(self, Vector3(8.1, 0.5, 0.35), Vector3(-18, 3.2, 8.4), Color(0.72, 0.12, 0.08), false)
    _box(self, Vector3(7, 3.5, 7), Vector3(18, 1.75, -12), Color(0.72, 0.75, 0.66), true)
    _box(self, Vector3(7.1, 0.5, 0.35), Vector3(18, 3.2, -15.6), Color(0.12, 0.35, 0.68), false)
    # Community hillside houses
    for row in range(3):
        for col in range(4):
            var p := Vector3(-34 + col * 7, 2.0 + row * 1.7, -22 - row * 7)
            _box(self, Vector3(6, 4, 6), p, colors[(row + col) % colors.size()], true)
    # Simple street lamps
    for z in range(-40, 45, 15):
        _box(self, Vector3(0.18, 5, 0.18), Vector3(-12, 2.5, z), Color(0.12,0.12,0.12), false)
        _box(self, Vector3(1.4, 0.15, 0.3), Vector3(-11.5, 5, z), Color(0.95,0.88,0.65), false)


func _make_city_landmarks() -> void:
    # Equipamentos públicos e comércio para dar identidade ao primeiro bairro.
    _landmark(Vector3(33, 0, 30), "HOSPITAL", Color(0.78, 0.82, 0.81), Color(0.12, 0.55, 0.42))
    _landmark(Vector3(33, 0, -25), "DELEGACIA", Color(0.65, 0.72, 0.78), Color(0.12, 0.28, 0.52))
    _landmark(Vector3(-33, 0, 31), "OFICINA", Color(0.66, 0.58, 0.46), Color(0.9, 0.42, 0.08))
    _landmark(Vector3(-33, 0, -25), "MERCADO", Color(0.78, 0.72, 0.58), Color(0.12, 0.48, 0.22))

func _landmark(center: Vector3, title: String, wall_color: Color, accent: Color) -> void:
    # Prédio térreo com fachada, porta, vitrines e placa legível à distância.
    _box(self, Vector3(12, 6.5, 10), center + Vector3(0, 3.25, 0), wall_color, true)
    _box(self, Vector3(12.5, 0.35, 10.5), center + Vector3(0, 6.65, 0), accent, false)
    _box(self, Vector3(2.0, 2.8, 0.18), center + Vector3(0, 1.45, 5.08), Color(0.16, 0.17, 0.18), false)
    _box(self, Vector3(3.0, 1.7, 0.16), center + Vector3(-3.6, 2.2, 5.1), Color(0.25, 0.48, 0.58), false)
    _box(self, Vector3(3.0, 1.7, 0.16), center + Vector3(3.6, 2.2, 5.1), Color(0.25, 0.48, 0.58), false)
    _box(self, Vector3(12.2, 0.7, 0.28), center + Vector3(0, 5.25, 5.12), accent, false)
    var sign := Label3D.new()
    sign.text = title
    sign.font_size = 48
    sign.outline_size = 8
    sign.modulate = Color(1, 1, 1)
    sign.position = center + Vector3(0, 5.22, 5.32)
    sign.rotation_degrees.y = 180
    sign.pixel_size = 0.012
    add_child(sign)
