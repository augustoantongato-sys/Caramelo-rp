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
var weapon_visuals: Node3D
var selected_weapon := 0
var character_visuals: Node3D
var current_vehicle: Node3D = null
var hud: CanvasLayer
var magazine_size := 12
var ammo_in_magazine := 12
var reserve_ammo := 72
var is_reloading := false
var reload_duration := 1.25
var weapon_display_name := "PISTOLA"

func _ready() -> void:
    add_to_group("player")
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    if has_node("Body"):
        $Body.visible = false
    var character_script = preload("res://scripts/player_visuals.gd")
    character_visuals = character_script.new()
    character_visuals.name = "CharacterVisuals"
    add_child(character_visuals)
    _create_weapon_visuals()
    character_visuals.call("set_weapon_visible", true)
    var mobile_script = preload("res://scripts/mobile_controls.gd")
    var mobile_ui = mobile_script.new()
    get_tree().root.add_child.call_deferred(mobile_ui)
    hud = preload("res://scripts/game_hud.gd").new()
    get_tree().root.add_child.call_deferred(hud)
    _update_ammo_hud()

func _create_weapon_visuals() -> void:
    var visuals_script = preload("res://scripts/weapon_visuals.gd")
    weapon_visuals = visuals_script.new()
    weapon_visuals.name = "WeaponVisuals"
    add_child(weapon_visuals)
    # Posicionamento aproximado da mão direita; ainda não há esqueleto/animação de braços.
    weapon_visuals.position = Vector3(0.38, 1.08, -0.32)
    weapon_visuals.rotation.y = PI / 2.0
    weapon_visuals.scale = Vector3(0.62, 0.62, 0.62)

func _select_weapon(index: int) -> void:
    selected_weapon = clampi(index, 0, 9)
    if is_instance_valid(weapon_visuals):
        weapon_visuals.call("set_weapon", selected_weapon)
    var weapon_names := [
        "Pistola", "Revólver", "Rifle de precisão", "Submetralhadora",
        "Fuzil", "Metralhadora", "Espingarda", "Machado", "Faca", "Algemas"
    ]
    if is_instance_valid(character_visuals):
        character_visuals.call("set_weapon_visible", selected_weapon <= 6)
    weapon_display_name = weapon_names[selected_weapon]
    GameState.show_message("Equipado: " + weapon_names[selected_weapon])
    _update_ammo_hud()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        match event.keycode:
            KEY_4: _select_weapon(0)
            KEY_5: _select_weapon(1)
            KEY_6: _select_weapon(2)
            KEY_7: _select_weapon(3)
            KEY_8: _select_weapon(4)
            KEY_9: _select_weapon(5)
            KEY_0: _select_weapon(6)
            KEY_Z: _select_weapon(7)
            KEY_X: _select_weapon(8)
            KEY_C: _select_weapon(9)
            KEY_R: _reload_weapon()
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        _rotate_camera(event.relative)
    if event is InputEventScreenDrag:
        # Arraste na tela para girar a câmera no Android.
        if event.position.x > get_viewport().get_visible_rect().size.x * 0.32:
            _rotate_camera(event.relative)
    if event.is_action_pressed("ui_cancel"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    if event is InputEventMouseButton and event.pressed and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _rotate_camera(relative: Vector2) -> void:
    rotate_y(-relative.x * mouse_sensitivity)
    camera_pivot.rotate_x(-relative.y * mouse_sensitivity)
    camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-55), deg_to_rad(35))

func _physics_process(delta: float) -> void:
    if is_instance_valid(current_vehicle):
        global_position = current_vehicle.global_position + Vector3.UP * 1.35
        velocity = Vector3.ZERO
        return
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
    if is_instance_valid(character_visuals):
        character_visuals.call("animate_motion", Vector2(velocity.x, velocity.z).length(), Input.is_action_pressed("shoot"), selected_weapon <= 6, delta)

    if Input.is_action_just_pressed("interact"):
        _try_enter_vehicle()
    if Input.is_action_just_pressed("reload"):
        _reload_weapon()
    if Input.is_action_just_pressed("shoot"):
        _use_firearm()
    if Input.is_action_just_pressed("melee"):
        _use_knife()
    if Input.is_action_just_pressed("arrest"):
        _use_handcuffs()

func _use_firearm() -> void:
    if is_reloading or selected_weapon > 6:
        return
    if shot_cooldown > 0.0:
        return
    if ammo_in_magazine <= 0:
        GameState.show_message("Sem munição no carregador. Aperte R para recarregar.")
        return
    ammo_in_magazine -= 1
    _update_ammo_hud()
    shot_cooldown = 0.22 if selected_weapon in [3,4,5] else 0.42
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

func _try_enter_vehicle() -> void:
    var nearest: Node3D
    var best := 3.8
    for v in get_tree().get_nodes_in_group("drivable_vehicles"):
        if not v is Node3D:
            continue
        if v.get("driver") != null:
            continue
        var d := global_position.distance_to(v.global_position)
        if d < best:
            best = d
            nearest = v
    if nearest:
        nearest.call("enter_vehicle", self)
    else:
        GameState.show_message("Chegue perto de um veículo e aperte E para entrar.")

func _update_ammo_hud() -> void:
    if is_instance_valid(hud):
        hud.call("set_ammo", ammo_in_magazine, reserve_ammo, weapon_display_name)

func _reload_weapon() -> void:
    if is_reloading or selected_weapon > 6 or ammo_in_magazine >= magazine_size or reserve_ammo <= 0:
        return
    is_reloading = true
    GameState.show_message("Recarregando...")
    await get_tree().create_timer(reload_duration).timeout
    var needed := magazine_size - ammo_in_magazine
    var loaded := mini(needed, reserve_ammo)
    ammo_in_magazine += loaded
    reserve_ammo -= loaded
    is_reloading = false
    _update_ammo_hud()
    GameState.show_message("Arma recarregada.")
