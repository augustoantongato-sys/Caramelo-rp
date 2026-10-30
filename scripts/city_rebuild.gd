extends Node3D

var mats: Dictionary = {}

func _ready() -> void:
	_build_environment()
	_build_ground()
	_build_roads()
	_build_center()
	_build_favela()
	_build_residential()
	_build_park()
	_build_street_details()

func _mat(color: Color) -> StandardMaterial3D:
	var key := color.to_html()
	if mats.has(key):
		return mats[key]
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.92
	mats[key] = material
	return material

func _box(parent: Node3D, label: String, size: Vector3, pos: Vector3, color: Color, solid := true) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = label
	body.position = pos
	var mesh := MeshInstance3D.new()
	var shape_mesh := BoxMesh.new()
	shape_mesh.size = size
	mesh.mesh = shape_mesh
	mesh.material_override = _mat(color)
	body.add_child(mesh)
	if solid:
		var collision := CollisionShape3D.new()
		var box_shape := BoxShape3D.new()
		box_shape.size = size
		collision.shape = box_shape
		body.add_child(collision)
	parent.add_child(body)
	return body

func _build_environment() -> void:
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.62, 0.68, 0.78)
	env.ambient_light_energy = 0.75
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world.environment = env
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -32, 0)
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	add_child(sun)

func _build_ground() -> void:
	_box(self, "Terreno", Vector3(180, 1, 160), Vector3(0, -0.55, 0), Color(0.24, 0.42, 0.25))

func _build_roads() -> void:
	_box(self, "Avenida principal", Vector3(15, 0.12, 150), Vector3(0, 0.02, 0), Color(0.12, 0.13, 0.14), false)
	_box(self, "Rua transversal", Vector3(160, 0.12, 12), Vector3(0, 0.03, 12), Color(0.12, 0.13, 0.14), false)
	for x in [-10.0, 10.0]:
		_box(self, "Calcada", Vector3(3, 0.22, 150), Vector3(x, 0.12, 0), Color(0.56, 0.55, 0.51), false)
	for z in [-55.0, -35.0, -15.0, 35.0, 55.0]:
		_box(self, "Faixa de pedestre", Vector3(0.8, 0.025, 5), Vector3(0, 0.095, z), Color(0.9, 0.9, 0.84), false)

func _building(pos: Vector3, size: Vector3, color: Color, name: String) -> void:
	_box(self, name, size, pos + Vector3.UP * size.y * 0.5, color)
	_box(self, name + " telhado", Vector3(size.x + 0.25, 0.25, size.z + 0.25), pos + Vector3.UP * (size.y + 0.12), Color(0.22, 0.22, 0.23), false)

func _build_center() -> void:
	var colors := [Color(0.72,0.68,0.59), Color(0.56,0.65,0.69), Color(0.76,0.58,0.46), Color(0.66,0.7,0.62)]
	for i in range(5):
		var z := -48.0 + float(i) * 19.0
		_building(Vector3(-25, 0, z), Vector3(12, 9 + float(i % 3) * 3, 12), colors[i % colors.size()], "Predio centro %d" % i)
		_building(Vector3(25, 0, z + 7), Vector3(12, 7 + float(i % 2) * 4, 12), colors[(i + 1) % colors.size()], "Predio comercial %d" % i)
	_building(Vector3(-19, 0, 20), Vector3(12, 5, 10), Color(0.78,0.69,0.49), "Mercado do bairro")
	_box(self, "Placa mercado", Vector3(8, 1, 0.25), Vector3(-19, 4.5, 14.85), Color(0.08,0.35,0.19), false)
	var sign := Label3D.new()
	sign.text = "MERCADO"
	sign.font_size = 48
	sign.position = Vector3(-19, 4.5, 14.65)
	sign.rotation.y = PI
	sign.modulate = Color.WHITE
	add_child(sign)

func _build_favela() -> void:
	var colors := [Color(0.72,0.48,0.34), Color(0.78,0.72,0.56), Color(0.46,0.58,0.63), Color(0.76,0.68,0.62)]
	for row in range(4):
		for col in range(5):
			var p := Vector3(-63.0 + float(col) * 9.0, 0, -42.0 + float(row) * 9.0)
			var h := 4.0 + float((row + col) % 3)
			_building(p + Vector3(0, float(row) * 2.2, 0), Vector3(7, h, 7), colors[(row + col) % colors.size()], "Casa comunidade")
			_box(self, "Caixa d agua", Vector3(1.5, 1.1, 1.5), p + Vector3(0, float(row) * 2.2 + h + 0.7, 0), Color(0.12,0.22,0.28), false)

func _build_residential() -> void:
	for i in range(6):
		var z := -42.0 + float(i) * 16.0
		_building(Vector3(48, 0, z), Vector3(12, 5, 11), Color(0.78,0.72,0.62), "Casa residencial")
		_building(Vector3(67, 0, z + 7), Vector3(12, 6, 11), Color(0.65,0.72,0.68), "Casa residencial")

func _build_park() -> void:
	_box(self, "Campo gramado", Vector3(34, 0.18, 22), Vector3(46, 0.08, 48), Color(0.16,0.42,0.18), false)
	for x in [-1.0, 1.0]:
		_box(self, "Trave", Vector3(0.25, 2.4, 0.25), Vector3(46 + x * 15, 1.3, 48), Color.WHITE, false)
	_box(self, "Quadra", Vector3(24, 0.16, 16), Vector3(-42, 0.08, 55), Color(0.22,0.3,0.42), false)
	_building(Vector3(25, 0, 65), Vector3(18, 6, 10), Color(0.72,0.72,0.68), "Escola municipal")

func _build_street_details() -> void:
	for z in range(-60, 70, 20):
		_box(self, "Poste", Vector3(0.18, 5.5, 0.18), Vector3(-12, 2.75, float(z)), Color(0.16,0.16,0.17), false)
		_box(self, "Luminaria", Vector3(1.2, 0.12, 0.25), Vector3(-11.5, 5.35, float(z)), Color(0.95,0.85,0.62), false)
