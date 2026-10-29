extends Node3D

const GROUND := Color("#777b70")
const ROAD := Color("#292c31")
const SIDEWALK := Color("#b7b2a7")
const COLORS := [Color("#d5c5a7"), Color("#b6a18b"), Color("#d9d4c8"), Color("#aeb9b5"), Color("#c68f70"), Color("#8f999e")]

func _ready() -> void:
	_build_environment()
	_box("Chao", Vector3(0, -0.35, 0), Vector3(180, 0.6, 180), GROUND)
	_build_roads()
	_build_city_blocks()
	_build_hill_community()
	_build_landmarks()

func _build_environment() -> void:
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = Sky.new()
	env.sky.sky_material = ProceduralSkyMaterial.new()
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#b9c9df")
	env.ambient_light_energy = 0.65
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world.environment = env
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -32, 0)
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	add_child(sun)

func _box(label: String, pos: Vector3, size: Vector3, color: Color) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.88
	var visual := MeshInstance3D.new()
	visual.name = label
	visual.mesh = mesh
	visual.material_override = material
	visual.position = pos
	add_child(visual)
	var body := StaticBody3D.new()
	body.position = pos
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	add_child(body)

func _build_roads() -> void:
	_box("Avenida", Vector3(0, 0.01, 0), Vector3(18, 0.08, 180), ROAD)
	_box("Rua transversal", Vector3(0, 0.02, -38), Vector3(180, 0.08, 12), ROAD)
	_box("Calcada oeste", Vector3(-10, 0.12, 0), Vector3(2, 0.24, 180), SIDEWALK)
	_box("Calcada leste", Vector3(10, 0.12, 0), Vector3(2, 0.24, 180), SIDEWALK)
	for z in range(-82, 86, 8):
		_box("Faixa", Vector3(0, 0.07, z), Vector3(0.22, 0.025, 4), Color("#e8dfb4"))

func _build_city_blocks() -> void:
	for side in [-1, 1]:
		for i in range(7):
			var z := -70.0 + float(i) * 21.0
			var x := float(side) * (23.0 + float(i % 2) * 7.0)
			var h := 8.0 + float((i * 7) % 5) * 2.4
			_box("Predio", Vector3(x, h * 0.5, z), Vector3(13, h, 15), COLORS[i % COLORS.size()])
			_box("Telhado", Vector3(x, h + 0.18, z), Vector3(13.4, 0.35, 15.4), Color("#57534e"))
			_box("Vitrine", Vector3(x, 1.2, z + 7.65), Vector3(7, 2.2, 0.18), Color("#435b63"))

func _build_hill_community() -> void:
	for row in range(5):
		for col in range(7):
			var x := -65.0 + float(col) * 9.0
			var z := -58.0 + float(row) * 10.0
			var h := 4.0 + float((row + col) % 3) * 1.2
			var y := float(row) * 3.0 + h * 0.5
			var house_colors := [Color("#d78b68"), Color("#e0c47c"), Color("#8da6a0"), Color("#c9c2b5")]
			_box("Casa comunidade", Vector3(x, y, z), Vector3(7.4, h, 7.4), house_colors[(row + col) % 4])
			_box("Laje", Vector3(x, y + h * 0.5 + 0.15, z), Vector3(7.7, 0.3, 7.7), Color("#777777"))
			if (row + col) % 3 == 0:
				_box("Caixa d agua", Vector3(x + 1.8, y + h * 0.5 + 1.25, z), Vector3(1.5, 1.8, 1.5), Color("#315f78"))

func _build_landmarks() -> void:
	_box("Campo", Vector3(48, 0.12, 48), Vector3(32, 0.24, 22), Color("#427b45"))
	_box("Escola", Vector3(55, 3.0, -52), Vector3(25, 6, 18), Color("#e5d5ad"))
	_box("Quadra", Vector3(55, 0.1, -32), Vector3(25, 0.2, 14), Color("#547d91"))
