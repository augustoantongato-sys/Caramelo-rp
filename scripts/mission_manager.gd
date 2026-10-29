extends Node
class_name MissionManager

signal mission_updated(title: String, description: String)

var missions: Array[Dictionary] = [
    {"title":"Entrega na comunidade", "description":"Leve a encomenda até o ponto marcado na favela.", "reward":350, "kind":"delivery"},
    {"title":"Recuperar a bicicleta", "description":"Encontre a bicicleta perdida perto do mercadinho.", "reward":500, "kind":"search"},
    {"title":"Fuga da viatura", "description":"Despiste a polícia e chegue ao esconderijo.", "reward":800, "kind":"escape"},
    {"title":"Trabalho no mercadinho", "description":"Ajude o comerciante e receba pelo serviço.", "reward":250, "kind":"job"}
]
var active_index := -1
var completed := {}

func start_next_mission() -> void:
    for i in range(missions.size()):
        if not completed.has(i):
            active_index = i
            var mission: Dictionary = missions[i]
            GameState.current_mission = mission.title
            GameState.mission_reward = int(mission.reward)
            mission_updated.emit(mission.title, mission.description)
            GameState.show_message("Missão iniciada: " + mission.title)
            return
    GameState.show_message("Você concluiu todas as missões disponíveis!")

func complete_active_mission() -> void:
    if active_index < 0:
        GameState.show_message("Nenhuma missão ativa.")
        return
    var mission: Dictionary = missions[active_index]
    GameState.add_money(int(mission.reward))
    completed[active_index] = true
    GameState.show_message("Missão concluída! +R$ " + str(mission.reward))
    active_index = -1
    GameState.current_mission = ""
    mission_updated.emit("Sem missão", "Procure o próximo contato na cidade.")
