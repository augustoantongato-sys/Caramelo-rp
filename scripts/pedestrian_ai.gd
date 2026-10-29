extends Node3D
## IA simples de pedestre: patrulha em rota curta, pausa e animação procedural.

@export var move_speed := 1.15
@export var patrol_distance := 3.5
var origin: Vector3
var direction := 1.0
var phase := 0.0
var pause_timer := 0.0
var limbs: Array[Node3D] = []

func _ready() -> void:
    origin = position
    for n in find_children("*","MeshInstance3D",true,false):
        if n.name.begins_with("Limb"):
            limbs.append(n)

func _process(delta: float) -> void:
    phase += delta * (5.0 if pause_timer <= 0.0 else 1.2)
    if pause_timer > 0.0:
        pause_timer -= delta
    else:
        position.x += direction * move_speed * delta
        if absf(position.x-origin.x) >= patrol_distance:
            direction *= -1.0
            pause_timer = randf_range(0.5,1.8)
        rotation.y = PI/2.0 if direction > 0.0 else -PI/2.0
    for i in range(limbs.size()):
        var limb := limbs[i]
        if is_instance_valid(limb):
            limb.rotation.x = sin(phase + (PI if i % 2 == 0 else 0.0)) * (0.42 if pause_timer <= 0.0 else 0.06)
