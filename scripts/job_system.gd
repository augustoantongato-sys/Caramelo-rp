extends Node
class_name CarameloJobSystem

signal job_changed(title: String, description: String)
signal job_finished(message: String)

var active_job := -1
var completed_jobs: Dictionary = {}
var job_points: Array[Dictionary] = []
var destination_marker: MeshInstance3D
var destination_label: Label3D
var check_timer := 0.0

func _ready() -> void:
    job_points = [
        {"name":"ENTREGADOR","description":"Pegue a encomenda e leve até a casa no morro.","start":Vector3(-12,0,-4),"finish":Vector3(-30,0,-27),"reward":280,"color":Color(0.95,0.62,0.12)},
        {"name":"MOTORISTA","description":"Faça uma corrida até o ponto de ônibus da avenida.","start":Vector3(12,0,20),"finish":Vector3(0,0,-36),"reward":420,"color":Color(0.15,0.55,0.9)},
        {"name":"MECÂNICO","description":"Leve as ferramentas até a oficina da comunidade.","start":Vector3(18,0,-12),"finish":Vector3(-25,0,15),"reward":500,"color":Color(0.85,0.28,0.12)},
        {"name":"SERVIÇOS URBANOS","description":"Recolha os materiais no ponto de serviço.","start":Vector3(-18,0,24),"finish":Vector3(25,0,28),"reward":320,"color":Color(0.2,0.68,0.38)}
    ]
    _create_job_markers()

func _process(delta: float) -> void:
    if active_job < 0:
        return
    check_timer += delta
    if check_timer < 0.2:
        return
    check_timer = 0.0
    var player := get_tree().get_first_node_in_group("player")
    if not is_instance_valid(player):
        return
    var job: Dictionary = job_points[active_job]
    if player.global_position.distance_to(job.finish + Vector3.UP) < 3.2:
        _finish_job()

func _create_job_markers() -> void:
    for i in range(job_points.size()):
        var job: Dictionary = job_points[i]
        var marker := MeshInstance3D.new()
        var mesh := CylinderMesh.new()
        mesh.top_radius = 0.72
        mesh.bottom_radius = 0.72
        mesh.height = 0.16
        marker.mesh = mesh
        marker.position = job.start + Vector3.UP * 0.12
        var material := StandardMaterial3D.new()
        material.albedo_color = job.color
        material.emission_enabled = true
        material.emission = job.color * 0.35
        marker.material_override = material
        add_child(marker)
        var sign := Label3D.new()
        sign.text = "TRABALHO\n" + job.name
        sign.position = job.start + Vector3(0,2.1,0)
        sign.font_size = 48
        sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        sign.modulate = job.color
        add_child(sign)
    destination_marker = MeshInstance3D.new()
    var target_mesh := CylinderMesh.new()
    target_mesh.top_radius = 0.9
    target_mesh.bottom_radius = 0.9
    target_mesh.height = 0.18
    destination_marker.mesh = target_mesh
    destination_marker.visible = false
    var target_material := StandardMaterial3D.new()
    target_material.albedo_color = Color(0.2,1.0,0.35)
    target_material.emission_enabled = true
    target_material.emission = Color(0.1,0.8,0.2)
    destination_marker.material_override = target_material
    add_child(destination_marker)
    destination_label = Label3D.new()
    destination_label.text = "DESTINO"
    destination_label.font_size = 56
    destination_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    destination_label.modulate = Color(0.3,1.0,0.45)
    destination_label.visible = false
    add_child(destination_label)

func get_nearby_job(player_position: Vector3) -> int:
    if active_job >= 0:
        return -1
    var closest := -1
    var best_distance := 3.5
    for i in range(job_points.size()):
        if completed_jobs.get(i, 0) >= 5:
            continue
        var distance: float = player_position.distance_to(job_points[i].start + Vector3.UP)
        if distance < best_distance:
            best_distance = distance
            closest = i
    return closest

func start_job(index: int) -> void:
    if index < 0 or index >= job_points.size() or active_job >= 0:
        return
    active_job = index
    check_timer = 0.0
    var job: Dictionary = job_points[index]
    destination_marker.position = job.finish + Vector3.UP * 0.12
    destination_marker.visible = true
    destination_label.position = job.finish + Vector3(0,2.1,0)
    destination_label.visible = true
    job_changed.emit(job.name, job.description + " Recompensa: R$ " + str(job.reward))
    GameState.show_message("Trabalho iniciado: " + job.name + ". Siga o marcador verde.")

func _finish_job() -> void:
    var job: Dictionary = job_points[active_job]
    GameState.add_money(int(job.reward))
    GameState.reputation += 1
    completed_jobs[active_job] = int(completed_jobs.get(active_job, 0)) + 1
    destination_marker.visible = false
    destination_label.visible = false
    job_finished.emit("Trabalho concluído: +" + str(job.reward) + " reais. Respeito +1.")
    GameState.show_message("Pagamento recebido: R$ " + str(job.reward))
    active_job = -1

func get_active_job_data() -> Dictionary:
    if active_job < 0:
        return {}
    return job_points[active_job].duplicate(true)
