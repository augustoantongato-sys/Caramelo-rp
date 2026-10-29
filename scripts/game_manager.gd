extends Node3D

var mission_manager := MissionManager.new()
var hud: CanvasLayer
var message_label: Label
var mission_label: Label
var stats_label: Label
var interaction_hint: Label
var mission_marker: Node3D

func _ready() -> void:
    add_child(mission_manager)
    mission_manager.mission_updated.connect(_on_mission_updated)
    GameState.stats_changed.connect(_refresh_hud)
    GameState.message_changed.connect(_show_message)
    _create_hud()
    _spawn_npcs()
    _create_mission_contact()
    _refresh_hud()

func _process(_delta: float) -> void:
    var player := get_tree().get_first_node_in_group("player")
    if not is_instance_valid(player):
        return
    var near_contact := player.global_position.distance_to(Vector3(5, 0, -8)) < 3.5
    interaction_hint.visible = near_contact
    if near_contact and Input.is_action_just_pressed("interact"):
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
    stats_label.text = "R$ " + str(GameState.money) + "   VIDA: " + str(roundi(GameState.health)) + "%   PROCURADO: " + stars

func _show_message(value: String) -> void:
    message_label.text = value
    get_tree().create_timer(3.5).timeout.connect(func(): message_label.text = "")

func _on_mission_updated(title: String, description: String) -> void:
    mission_label.text = "MISSÃO: " + title + "\n" + description

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
