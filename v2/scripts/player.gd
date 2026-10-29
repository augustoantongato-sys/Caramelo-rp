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
var look_finger := -1
var move_finger := -1
var camera_pivot: Node3D

func _ready() -> void:
	_create_character()
	_create_camera()
	_create_mobile_hud()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _create_character() -> void:
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.38
	capsule.height = 1.65
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("#b8794d")
	var visual := MeshInstance3D.new()
	visual.name = "Personagem_provisorio"
	visual.mesh = capsule
	visual.material_override = material
	visual.position.y = 0.92
	add_child(visual)

func _create_camera() -> void:
	camera_pivot = Node3D.new()
	camera_pivot.position.y = 1.45
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
	title.text = "CARAMELO RP  •  TESTE DE CIDADE"
	title.position = Vector2(24, 18)
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color.WHITE)
	layer.add_child(title)
	var hint := Label.new()
	hint.text = "Arraste a esquerda para andar • Arraste a direita para olhar • Shift para correr"
	hint.position = Vector2(24, 52)
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
			touch_move = (event.relative / 90.0).limit_length(1.0)

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
