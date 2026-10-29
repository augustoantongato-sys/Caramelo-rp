extends Node3D

var mission_manager := MissionManager.new()
var territory_manager := TerritoryManager.new()
var job_system := CarameloJobSystem.new()
var hud: CanvasLayer
var message_label: Label
var mission_label: Label
var stats_label: Label
var interaction_hint: Label
var mission_marker: Node3D
var starter_home_door := Vector3(-35, 0, 30)
var apartment_door := Vector3(34, 0, 30)
var starter_home_owned := true
var apartment_owned := false
var inside_property := false

func _ready() -> void:
    add_to_group("game_manager")
    add_child(mission_manager)
    add_child(territory_manager)
    add_child(job_system)
    mission_manager.mission_updated.connect(_on_mission_updated)
    job_system.job_changed.connect(_on_job_changed)
    job_system.job_finished.connect(_on_job_finished)
    GameState.stats_changed.connect(_refresh_hud)
    GameState.message_changed.connect(_show_message)
    _create_hud()
    _spawn_npcs()
    _create_mission_contact()
    _create_management_signs()
    _create_properties()
    _refresh_hud()
    _restore_saved_progress()

func save_progress() -> void:
    var player := get_tree().get_first_node_in_group("player")
    if not is_instance_valid(player):
        GameState.show_message("Não foi possível localizar o personagem.")
        return
    GameState.save_progress(player.global_position, apartment_owned, mission_manager.active_index, mission_manager.completed, job_system.active_job, job_system.completed_jobs)

func load_progress() -> void:
    var saved := GameState.load_progress()
    if saved.is_empty():
        return
    var player := get_tree().get_first_node_in_group("player")
    if is_instance_valid(player):
        player.global_position = saved.get("position", Vector3(0, 1.2, 8))
        player.velocity = Vector3.ZERO
    apartment_owned = saved.get("apartment_owned", false)
    mission_manager.completed = saved.get("completed", {})
    job_system.completed_jobs = saved.get("completed_jobs", {})
    var saved_job: int = int(saved.get("active_job", -1))
    if saved_job >= 0 and saved_job < job_system.job_points.size():
        job_system.start_job(saved_job)
    mission_manager.active_index = saved.get("active_index", -1)
    if mission_manager.active_index >= 0 and mission_manager.active_index < mission_manager.missions.size():
        var mission: Dictionary = mission_manager.missions[mission_manager.active_index]
        GameState.current_mission = mission.title
        GameState.mission_reward = int(mission.reward)
        mission_manager.mission_updated.emit(mission.title, mission.description)
    else:
        mission_manager.active_index = -1
        GameState.current_mission = ""
    _refresh_hud()

func _restore_saved_progress() -> void:
    var config := ConfigFile.new()
    if config.load(GameState.SAVE_PATH) == OK:
        load_progress()

func _process(_delta: float) -> void:
    var player := get_tree().get_first_node_in_group("player")
    if not is_instance_valid(player):
        return
    var near_contact := player.global_position.distance_to(Vector3(5, 0, -8)) < 3.5
    var nearby_job := job_system.get_nearby_job(player.global_position)
    var has_active_job := job_system.active_job >= 0
    var near_management := player.global_position.distance_to(Vector3(-4, 0, -12)) < 4.0
    if near_management and Input.is_action_just_pressed("hire_security"):
        territory_manager.recruit("seguranca")
    if near_management and Input.is_action_just_pressed("hire_vendor"):
        territory_manager.recruit("vendedores")
    if near_management and Input.is_action_just_pressed("hire_scout"):
        territory_manager.recruit("olheiros")
    if Input.is_action_just_pressed("conquer_area"):
        territory_manager.conquer("Morro do Caramelo")
    var near_starter := player.global_position.distance_to(starter_home_door) < 3.0
    var near_apartment := player.global_position.distance_to(apartment_door) < 3.0
    interaction_hint.visible = near_contact or near_starter or near_apartment or inside_property or near_management or nearby_job >= 0 or has_active_job
    if has_active_job:
        interaction_hint.text = "TRABALHO ATIVO: siga o marcador verde"
    elif nearby_job >= 0:
        interaction_hint.text = "[E] Começar trabalho: " + str(job_system.job_points[nearby_job].name)
    elif inside_property:
        interaction_hint.text = "[E] Sair da casa"
    elif near_starter:
        interaction_hint.text = "[E] Entrar na sua casa"
    elif near_apartment:
        interaction_hint.text = "[E] Comprar apartamento (R$ 8.000)" if not apartment_owned else "[E] Entrar no apartamento"
    else:
        interaction_hint.text = "[E] Falar com o contato / missão"
    if Input.is_action_just_pressed("interact"):
        if nearby_job >= 0 and not has_active_job:
            job_system.start_job(nearby_job)
        elif inside_property:
            _leave_property(player)
        elif near_starter:
            _enter_property(player, starter_home_door, "casa")
        elif near_apartment:
            if not apartment_owned:
                if GameState.money >= 8000:
                    GameState.add_money(-8000)
                    apartment_owned = true
                    GameState.show_message("Apartamento comprado! Agora ele é seu.")
                else:
                    GameState.show_message("Dinheiro insuficiente. Você precisa de R$ 8.000.")
            else:
                _enter_property(player, apartment_door, "apartamento")
        elif near_contact:
            if mission_manager.active_index == -1:
                mission_manager.start_next_mission()
            else:
                mission_manager.complete_active_mission()

func _create_hud() -> void:
    hud = CanvasLayer.new()
    add_child(hud)
    stats_label = Label.new()
    stats_label.position = Vector2(22, 18)
    stats_label.add_theme_font_size_override("font_size", 22)
    hud.add_child(stats_label)
    mission_label = Label.new()
    mission_label.position = Vector2(22, 94)
    mission_label.size = Vector2(500, 70)
    mission_label.add_theme_font_size_override("font_size", 17)
    hud.add_child(mission_label)
    message_label = Label.new()
    message_label.position = Vector2(22, 650)
    message_label.add_theme_font_size_override("font_size", 19)
    message_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
    hud.add_child(message_label)
    interaction_hint = Label.new()
    interaction_hint.text = "[E] Falar com o contato / concluir missão"
    interaction_hint.position = Vector2(420, 600)
    interaction_hint.add_theme_font_size_override("font_size", 18)
    interaction_hint.visible = false
    hud.add_child(interaction_hint)

func _refresh_hud() -> void:
    if not is_instance_valid(stats_label):
        return
    var stars := "★".repeat(GameState.wanted_level)
    stats_label.text = "R$ " + str(GameState.money) + "   VIDA: " + str(roundi(GameState.health)) + "%   RESPEITO: " + str(GameState.reputation) + "   PROCURADO: " + stars

func _show_message(value: String) -> void:
    message_label.text = value
    get_tree().create_timer(3.5).timeout.connect(func(): message_label.text = "")

func _on_mission_updated(title: String, description: String) -> void:
    mission_label.text = "MISSÃO: " + title + "\n" + description

func _on_job_changed(title: String, description: String) -> void:
    mission_label.text = "TRABALHO: " + title + "\n" + description

func _on_job_finished(message: String) -> void:
    mission_label.text = "TRABALHO CONCLUÍDO\n" + message

func _spawn_npcs() -> void:
    _spawn_npc(Vector3(8, 1, -5), CarameloNPC.Faction.POLICE, "Policial")
    _spawn_npc(Vector3(-8, 1, 4), CarameloNPC.Faction.CRIMINAL, "Suspeito")
    _spawn_npc(Vector3(12, 1, 12), CarameloNPC.Faction.CIVIL, "Morador")
    _spawn_npc(Vector3(-16, 1, -15), CarameloNPC.Faction.POLICE, "Policial")

func _spawn_npc(pos: Vector3, faction: CarameloNPC.Faction, label: String) -> void:
    var npc := CharacterBody3D.new()
    npc.set_script(load("res://scripts/npc.gd"))
    npc.faction = faction
    npc.npc_name = label
    npc.position = pos
    var shape := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.35
    capsule.height = 1.7
    shape.shape = capsule
    shape.position.y = 0.85
    npc.add_child(shape)
    var visual := MeshInstance3D.new()
    var mesh := CapsuleMesh.new()
    mesh.radius = 0.35
    mesh.height = 1.7
    visual.mesh = mesh
    visual.position.y = 0.85
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.12, 0.25, 0.8) if faction == CarameloNPC.Faction.POLICE else (Color(0.55, 0.12, 0.1) if faction == CarameloNPC.Faction.CRIMINAL else Color(0.7, 0.58, 0.38))
    visual.material_override = material
    npc.add_child(visual)
    add_child(npc)

func _create_mission_contact() -> void:
    var marker := MeshInstance3D.new()
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.55
    mesh.bottom_radius = 0.55
    mesh.height = 0.12
    marker.mesh = mesh
    marker.position = Vector3(5, 0.12, -8)
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.95, 0.75, 0.1)
    material.emission_enabled = true
    material.emission = Color(0.6, 0.35, 0.0)
    marker.material_override = material
    add_child(marker)

func _create_properties() -> void:
    _create_building(starter_home_door, Color(0.72, 0.57, 0.39), "SUA CASA")
    _create_building(apartment_door, Color(0.62, 0.67, 0.72), "APARTAMENTO À VENDA")

func _create_building(door: Vector3, tint: Color, _label: String) -> void:
    var building := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = Vector3(8, 5, 7)
    building.mesh = mesh
    building.position = door + Vector3(0, 2.5, 0)
    var material := StandardMaterial3D.new()
    material.albedo_color = tint
    building.material_override = material
    add_child(building)
    var marker := MeshInstance3D.new()
    var marker_mesh := BoxMesh.new()
    marker_mesh.size = Vector3(1.2, 2.1, 0.12)
    marker.mesh = marker_mesh
    marker.position = door + Vector3(0, 1.05, -3.56)
    var door_material := StandardMaterial3D.new()
    door_material.albedo_color = Color(0.22, 0.12, 0.07)
    marker.material_override = door_material
    add_child(marker)

func _enter_property(player: Node3D, _door: Vector3, property_name: String) -> void:
    inside_property = true
    player.global_position = Vector3(70, 1.2, 0)
    _build_interior()
    GameState.show_message("Você entrou na " + property_name + ".")

func _build_interior() -> void:
    if has_node("PropertyInterior"):
        return
    var room := Node3D.new()
    room.name = "PropertyInterior"
    add_child(room)
    _add_room_box(room, Vector3(12, 0.3, 12), Vector3(70, -0.15, 0), Color(0.55, 0.48, 0.38))
    _add_room_box(room, Vector3(12, 3, 0.25), Vector3(70, 1.5, -6), Color(0.86, 0.82, 0.72))
    _add_room_box(room, Vector3(12, 3, 0.25), Vector3(70, 1.5, 6), Color(0.86, 0.82, 0.72))
    _add_room_box(room, Vector3(0.25, 3, 12), Vector3(64, 1.5, 0), Color(0.86, 0.82, 0.72))
    _add_room_box(room, Vector3(0.25, 3, 12), Vector3(76, 1.5, 0), Color(0.86, 0.82, 0.72))
    _add_room_box(room, Vector3(2.2, 0.5, 3.2), Vector3(73, 0.45, -2), Color(0.25, 0.18, 0.13))
    _add_room_box(room, Vector3(2.4, 0.45, 1.2), Vector3(67, 0.6, 2), Color(0.3, 0.22, 0.15))

func _add_room_box(parent: Node3D, size: Vector3, pos: Vector3, tint: Color) -> void:
    var item := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    item.mesh = mesh
    item.position = pos
    var material := StandardMaterial3D.new()
    material.albedo_color = tint
    item.material_override = material
    parent.add_child(item)
    var body := StaticBody3D.new()
    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = size
    collision.shape = shape
    body.position = pos
    body.add_child(collision)
    parent.add_child(body)

func _leave_property(player: Node3D) -> void:
    inside_property = false
    player.global_position = starter_home_door + Vector3(0, 1.2, 4)
    GameState.show_message("Você saiu da propriedade.")

func _create_management_signs() -> void:
    _create_sign(Vector3(-4, 1.0, -12), "BASE DA EQUIPE")
    _create_sign(Vector3(14, 1.0, -12), "PONTO DE CONQUISTA")

func _create_sign(pos: Vector3, _caption: String) -> void:
    var marker := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = Vector3(1.2, 2.0, 0.2)
    marker.mesh = mesh
    marker.position = pos
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.85, 0.55, 0.12)
    marker.material_override = mat
    add_child(marker)
