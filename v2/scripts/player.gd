extends CharacterBody3D

@export var walk_speed := 5.0
@export var run_speed := 8.0
@export var acceleration := 18.0
@export var turn_speed := 10.0
@export var mouse_sensitivity := 0.0025

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var camera_yaw := 0.0
var camera_pitch := -0.18
var touch_move := Vector2.ZERO
var move_finger := -1
var look_finger := -1
var move_origin := Vector2.ZERO
var camera_pivot: Node3D

func _ready() -> void:
	_create_character()
	_create_camera()
	_create_mobile_hud()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _part(parent: Node3D, part_name: String, mesh: PrimitiveMesh, pos: Vector3, color: Color, scale_value: Vector3 = Vector3.ONE) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.82
	var node := MeshInstance3D.new()
	node.name = part_name
	node.mesh = mesh
	node.material_override = material
	node.position = pos
	node.scale = scale_value
	parent.add_child(node)

func _create_character() -> void:
	var shirt := Color("#d39a43")
	var pants := Color("#303b4c")
	var skin := Color("#a96f4c")
	var shoes := Color("#202124")
	var torso := CapsuleMesh.new()
	torso.radius = 0.29
	torso.height = 0.85
	_part(self, "Camiseta_caramele", torso, Vector3(0, 1.12, 0), shirt)
	var head := SphereMesh.new()
	head.radius = 0.19
	head.height = 0.38
	_part(self, "Cabeca", head, Vector3(0, 1.78, 0), skin)
	var hair := SphereMesh.new()
	hair.radius = 0.195
	hair.height = 0.18
	_part(self, "Cabelo", hair, Vector3(0, 1.91, 0), Color("#211b18"), Vector3(1, 0.55, 1))
	var arm_mesh := CapsuleMesh.new()
	arm_mesh.radius = 0.105
	arm_mesh.height = 0.62
	_part(self, "Braco_esquerdo", arm_mesh, Vector3(-0.36, 1.15, 0), shirt, Vector3(1, 1, 0.9))
	_part(self, "Braco_direito", arm_mesh, Vector3(0.36, 1.15, 0), shirt, Vector3(1, 1, 0.9))
	var leg_mesh := CapsuleMesh.new()
	leg_mesh.radius = 0.13
	leg_mesh.height = 0.72
	_part(self, "Calca_esquerda", leg_mesh, Vector3(-0.16, 0.48, 0), pants)
	_part(self, "Calca_direita", leg_mesh, Vector3(0.16, 0.48, 0), pants)
	var foot := BoxMesh.new()
	foot.size = Vector3(0.25, 0.13, 0.38)
	_part(self, "Tenis_esquerdo", foot, Vector3(-0.16, 0.12, -0.04), shoes)
	_part(self, "Tenis_direito", foot, Vector3(0.16, 0.12, -0.04), shoes)

func _create_camera() -> void:
	camera_pivot = Node3D.new()
	camera_pivot.position.y = 1.5
	add_child(camera_pivot)
	var arm := SpringArm3D.new()
	arm.spring_length = 5.2
	arm.margin = 0.2
	camera_pivot.add_child(arm)
	var camera := Camera3D.new()
	camera.current = true
	arm.add_child(camera)
	camera_pivot.rotation.x = camera_pitch

func _create_mobile_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "ControlesMobile"
	add_child(layer)
	var title := Label.new()
	title.text = "CARAMELO RP"
	title.position = Vector2(24, 18)
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color.WHITE)
	layer.add_child(title)
	var hint := Label.new()
	hint.text = "ESQUERDA: MOVIMENTO  •  DIREITA: CÂMERA  •  SHIFT: CORRER"
	hint.position = Vector2(24, 54)
	hint.add_theme_font_size_override("font_size", 15)
	hint.add_theme_color_override("font_color", Color("#eeeeee"))
	layer.add_child(hint)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_rotate_camera(event.relative)
	elif event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x < get_viewport().get_visible_rect().size.x * 0.48:
				move_finger = event.index
				move_origin = event.position
				touch_move = Vector2.ZERO
			else:
				look_finger = event.index
		else:
			if event.index == move_finger:
				move_finger = -1
				touch_move = Vector2.ZERO
			if event.index == look_finger:
				look_finger = -1
	elif event is InputEventScreenDrag:
		if event.index == look_finger:
			_rotate_camera(event.relative * 1.3)
		elif event.index == move_finger:
			touch_move = ((event.position - move_origin) / 75.0).limit_length(1.0)

func _rotate_camera(relative: Vector2) -> void:
	camera_yaw -= relative.x * mouse_sensitivity
	camera_pitch = clampf(camera_pitch - relative.y * mouse_sensitivity, -0.65, 0.35)
	camera_pivot.rotation = Vector3(camera_pitch, camera_yaw - rotation.y, 0)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = -0.1
	var keyboard := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var input_dir := keyboard if keyboard.length() > 0.05 else touch_move
	var forward := Vector3(-sin(camera_yaw), 0, -cos(camera_yaw))
	var right := Vector3(cos(camera_yaw), 0, -sin(camera_yaw))
	var direction := (right * input_dir.x + forward * -input_dir.y).normalized()
	var speed := run_speed if Input.is_action_pressed("sprint") else walk_speed
	var target := direction * speed
	velocity.x = move_toward(velocity.x, target.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target.z, acceleration * delta)
	if direction.length_squared() > 0.01:
		rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), minf(1.0, turn_speed * delta))
	camera_pivot.rotation.y = camera_yaw - rotation.y
	move_and_slide()
