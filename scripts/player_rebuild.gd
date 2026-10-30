extends CharacterBody3D

@export var walk_speed := 5.0
@export var run_speed := 7.5
@export var acceleration := 18.0
@export var jump_force := 4.5
@export var mouse_sensitivity := 0.0025

@onready var pivot: Node3D = $CameraPivot
@onready var spring: SpringArm3D = $CameraPivot/SpringArm3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var yaw := 0.0
var pitch := -0.18
var touch_move := Vector2.ZERO
var touch_look := Vector2.ZERO
var move_touch := -1
var look_touch := -1
var move_origin := Vector2.ZERO

func _ready() -> void:
	add_to_group("player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_sync_camera()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * mouse_sensitivity
		pitch = clampf(pitch - event.relative.y * mouse_sensitivity, -0.85, 0.35)
		_sync_camera()
	elif event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x < get_viewport().get_visible_rect().size.x * 0.48 and move_touch == -1:
				move_touch = event.index
				move_origin = event.position
			else:
				look_touch = event.index
		else:
			if event.index == move_touch:
				move_touch = -1
				touch_move = Vector2.ZERO
			if event.index == look_touch:
				look_touch = -1
	elif event is InputEventScreenDrag:
		if event.index == move_touch:
			touch_move = ((event.position - move_origin) / 75.0).limit_length(1.0)
		elif event.index == look_touch:
			yaw -= event.relative.x * 0.004
			pitch = clampf(pitch - event.relative.y * 0.003, -0.85, 0.35)
			_sync_camera()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.pressed and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _sync_camera() -> void:
	pivot.rotation = Vector3(pitch, yaw, 0.0)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif velocity.y < 0.0:
		velocity.y = -0.1
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if touch_move.length() > 0.08:
		input_vector = touch_move
	var forward := Vector3(-sin(yaw), 0.0, -cos(yaw))
	var right := Vector3(cos(yaw), 0.0, -sin(yaw))
	var direction := (right * input_vector.x + forward * -input_vector.y).normalized()
	var speed := run_speed if Input.is_action_pressed("sprint") else walk_speed
	var target := direction * speed
	velocity.x = move_toward(velocity.x, target.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target.z, acceleration * delta)
	if direction.length_squared() > 0.01:
		rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), 10.0 * delta)
	move_and_slide()
