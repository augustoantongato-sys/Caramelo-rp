extends CharacterBody3D
class_name CarameloNPC

enum Faction { CIVIL, POLICE, CRIMINAL }
@export var faction: Faction = Faction.CIVIL
@export var npc_name: String = "Morador"
@export var health: float = 100.0
@export var move_speed: float = 2.8
@export var attack_range: float = 13.0
@export var attack_damage: float = 8.0

var target: Node3D
var attack_cooldown := 0.0
var home_position: Vector3
var is_arrested := false
var is_dead := false

func _ready() -> void:
    home_position = global_position
    add_to_group("game_npcs")
    if faction == Faction.POLICE:
        add_to_group("police")
    elif faction == Faction.CRIMINAL:
        add_to_group("criminals")
    else:
        add_to_group("civilians")

func _physics_process(delta: float) -> void:
    if is_dead or is_arrested:
        velocity = Vector3.ZERO
        return
    attack_cooldown = maxf(0.0, attack_cooldown - delta)
    if not is_instance_valid(target):
        _find_target()
    if is_instance_valid(target):
        var distance := global_position.distance_to(target.global_position)
        if distance > attack_range * 0.8:
            var direction := (target.global_position - global_position).normalized()
            direction.y = 0.0
            velocity.x = direction.x * move_speed
            velocity.z = direction.z * move_speed
            look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z))
        else:
            velocity.x = move_toward(velocity.x, 0.0, move_speed)
            velocity.z = move_toward(velocity.z, 0.0, move_speed)
            if attack_cooldown <= 0.0:
                _attack_target()
                attack_cooldown = 1.5
    else:
        velocity.x = move_toward(velocity.x, 0.0, move_speed)
        velocity.z = move_toward(velocity.z, 0.0, move_speed)
    if not is_on_floor():
        velocity.y -= 18.0 * delta
    move_and_slide()

func _find_target() -> void:
    var player := get_tree().get_first_node_in_group("player")
    if not is_instance_valid(player):
        return
    if faction == Faction.POLICE and GameState.wanted_level > 0:
        target = player
    elif faction == Faction.CRIMINAL:
        target = player

func _attack_target() -> void:
    if faction == Faction.POLICE and is_instance_valid(target):
        GameState.damage_player(attack_damage)
    elif faction == Faction.CRIMINAL and is_instance_valid(target):
        GameState.damage_player(attack_damage)

func take_damage(amount: float) -> void:
    if is_dead or is_arrested:
        return
    health -= amount
    if health <= 0.0:
        is_dead = true
        if faction == Faction.CIVIL:
            GameState.add_wanted(1)
        queue_free()

func arrest() -> bool:
    if faction != Faction.CRIMINAL or is_dead:
        return false
    is_arrested = true
    velocity = Vector3.ZERO
    GameState.show_message(npc_name + " foi algemado.")
    return true
