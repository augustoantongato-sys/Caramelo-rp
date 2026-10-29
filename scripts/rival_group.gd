extends Node3D
class_name RivalGroup

@export var group_label := "Grupo rival"
@export var strength := 3
var active := true

func _ready() -> void:
    add_to_group("rival_groups")

func weaken(amount: int = 1) -> void:
    strength = maxi(0, strength - amount)
    if strength == 0:
        active = false
        GameState.reputation += 1
        GameState.show_message("Grupo rival derrotado! Seu respeito aumentou.")
