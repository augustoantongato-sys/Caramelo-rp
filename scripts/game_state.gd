extends Node

signal stats_changed
signal message_changed(text: String)

const SAVE_PATH := "user://caramelo_rp_save.cfg"

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

func save_progress(player_position: Vector3, apartment_is_owned: bool, mission_index: int, completed_missions: Dictionary, active_job: int, completed_jobs: Dictionary) -> bool:
    var config := ConfigFile.new()
    config.set_value("player", "money", money)
    config.set_value("player", "health", health)
    config.set_value("player", "wanted_level", wanted_level)
    config.set_value("player", "reputation", reputation)
    config.set_value("player", "position", player_position)
    config.set_value("player", "inventory", inventory)
    config.set_value("world", "apartment_owned", apartment_is_owned)
    config.set_value("missions", "active_index", mission_index)
    config.set_value("missions", "completed", completed_missions)
    config.set_value("jobs", "active_job", active_job)
    config.set_value("jobs", "completed_jobs", completed_jobs)
    var error := config.save(SAVE_PATH)
    if error == OK:
        show_message("Progresso salvo com sucesso!")
        return true
    show_message("Não foi possível salvar. Código: " + str(error))
    return false

func load_progress() -> Dictionary:
    var config := ConfigFile.new()
    var error := config.load(SAVE_PATH)
    if error != OK:
        show_message("Nenhum progresso salvo encontrado.")
        return {}
    money = int(config.get_value("player", "money", 2500))
    health = clampf(float(config.get_value("player", "health", 100.0)), 0.0, max_health)
    wanted_level = clampi(int(config.get_value("player", "wanted_level", 0)), 0, 5)
    reputation = int(config.get_value("player", "reputation", 0))
    inventory = config.get_value("player", "inventory", {"faca": 1, "algema": 1})
    stats_changed.emit()
    show_message("Progresso carregado!")
    return {
        "position": config.get_value("player", "position", Vector3(0, 1.2, 8)),
        "apartment_owned": bool(config.get_value("world", "apartment_owned", false)),
        "active_index": int(config.get_value("missions", "active_index", -1)),
        "completed": config.get_value("missions", "completed", {}),
        "active_job": int(config.get_value("jobs", "active_job", -1)),
        "completed_jobs": config.get_value("jobs", "completed_jobs", {})
    }
