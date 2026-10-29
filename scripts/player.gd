extends CharacterBody3D

@export var walk_speed := 5.0
@export var sprint_speed := 8.0
@export var jump_velocity := 4.5
@export var mouse_sensitivity := 0.003
@export var firearm_damage := 45.0
@export var knife_damage := 35.0

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var shot_cooldown := 0.0

func _ready() -> void:
    add_to_group("player")
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * mouse_sensitivity)
        camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
        camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-55), deg_to_rad(35))
    if event.is_action_pressed("ui_cancel"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    if event is InputEventMouseButton and event.pressed and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
    shot_cooldown = maxf(0.0, shot_cooldown - delta)
    if not is_on_floor():
        velocity.y -= gravity * delta
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity

    var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    var speed := sprint_speed if Input.is_action_pressed("sprint") else walk_speed
    if direction:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
    else:
        velocity.x = move_toward(velocity.x, 0, walk_speed)
        velocity.z = move_toward(velocity.z, 0, walk_speed)
    move_and_slide()

    if Input.is_action_just_pressed("shoot"):
        _use_firearm()
    if Input.is_action_just_pressed("melee"):
        _use_knife()
    if Input.is_action_just_pressed("arrest"):
        _use_handcuffs()

func _use_firearm() -> void:
    if shot_cooldown > 0.0:
        return
    shot_cooldown = 0.35
    var from := camera.global_position
    var to := from + (-camera.global_transform.basis.z * 65.0)
    var query := PhysicsRayQueryParameters3D.create(from, to)
    query.exclude = [self]
    var hit := get_world_3d().direct_space_state.intersect_ray(query)
    if hit and hit.collider is CarameloNPC:
        hit.collider.take_damage(firearm_damage)
        GameState.add_wanted(1)
        GameState.show_message("Disparo efetuado. A polícia foi alertada!")
    else:
        GameState.show_message("Você disparou.")

func _use_knife() -> void:
    var target := _nearest_npc(2.2)
    if target:
        target.take_damage(knife_damage)
        GameState.add_wanted(1)
        GameState.show_message("Ataque corpo a corpo.")
    else:
        GameState.show_message("Ninguém está perto o suficiente.")

func _use_handcuffs() -> void:
    var target := _nearest_npc(2.5)
    if target and target.faction == CarameloNPC.Faction.CRIMINAL:
        if target.arrest():
            GameState.add_money(150)
            GameState.reduce_wanted()
    else:
        GameState.show_message("Aproxime-se de um suspeito para algemá-lo.")

func _nearest_npc(max_distance: float) -> CarameloNPC:
    var nearest: CarameloNPC
    var best_distance := max_distance
    for node in get_tree().get_nodes_in_group("game_npcs"):
        if not node is CarameloNPC or node.is_dead or node.is_arrested:
            continue
        var distance := global_position.distance_to(node.global_position)
        if distance < best_distance:
            best_distance = distance
            nearest = node
    return nearest
