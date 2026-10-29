extends Node

signal stats_changed
signal message_changed(text: String)

var money: int = 2500
var health: float = 100.0
var max_health: float = 100.0
var wanted_level: int = 0
var reputation: int = 0
var inventory: Dictionary = {"faca": 1, "algema": 1}
var current_mission: String = ""
var mission_reward: int = 0

func add_money(amount: int) -> void:
    money = maxi(0, money + amount)
    stats_changed.emit()

func damage_player(amount: float) -> void:
    health = clampf(health - amount, 0.0, max_health)
    stats_changed.emit()
    if health <= 0.0:
        show_message("Você foi nocauteado! Voltando para casa...")
        await get_tree().create_timer(2.0).timeout
        health = max_health
        wanted_level = 0
        stats_changed.emit()

func heal_player(amount: float) -> void:
    health = clampf(health + amount, 0.0, max_health)
    stats_changed.emit()

func add_wanted(amount: int = 1) -> void:
    wanted_level = clampi(wanted_level + amount, 0, 5)
    stats_changed.emit()

func reduce_wanted() -> void:
    wanted_level = maxi(0, wanted_level - 1)
    stats_changed.emit()

func show_message(text: String) -> void:
    message_changed.emit(text)
