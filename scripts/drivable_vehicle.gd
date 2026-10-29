extends CharacterBody3D
class_name CarameloVehicle

@export var max_speed := 22.0
@export var acceleration := 12.0
@export var reverse_speed := 8.0
@export var steering_speed := 1.45
@export var vehicle_label := "Veículo"
var driver: Node3D
var throttle := 0.0
var steer := 0.0
var gravity := 18.0
var wheel_nodes: Array[Node3D] = []

func _ready() -> void:
    add_to_group("drivable_vehicles")
    var shape := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size = Vector3(2.0, 1.3, 4.4)
    shape.shape = box
    shape.position.y = 0.65
    add_child(shape)
    for n in find_children("*", "MeshInstance3D", true, false):
        if n.name.to_lower().contains("wheel"):
            wheel_nodes.append(n)

func _physics_process(delta: float) -> void:
    if driver != null and is_instance_valid(driver):
        var forward := Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
        var turn := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
        throttle = move_toward(throttle, forward, acceleration * delta)
        steer = move_toward(steer, turn, 3.0 * delta)
        var speed_limit := max_speed if throttle >= 0.0 else reverse_speed
        velocity.x = -global_transform.basis.z.x * throttle * speed_limit
        velocity.z = -global_transform.basis.z.z * throttle * speed_limit
        if absf(throttle) > 0.05:
            rotate_y(-steer * steering_speed * delta * clampf(absf(throttle),0.25,1.0) * signf(throttle))
        if Input.is_action_just_pressed("interact"):
            _leave_vehicle()
    else:
        velocity.x = move_toward(velocity.x,0.0,8.0*delta)
        velocity.z = move_toward(velocity.z,0.0,8.0*delta)
    if not is_on_floor():
        velocity.y -= gravity * delta
    else:
        velocity.y = -0.2
    move_and_slide()
    for wheel in wheel_nodes:
        wheel.rotate_x(throttle * delta * 4.0)

func enter_vehicle(who: Node3D) -> void:
    driver = who
    who.set("current_vehicle", self)
    who.visible = false
    GameState.show_message("Você entrou: " + vehicle_label + ". WASD para dirigir; E para sair.")

func _leave_vehicle() -> void:
    if driver == null:
        return
    var who := driver
    driver = null
    who.set("current_vehicle", null)
    who.visible = true
    who.global_position = global_position + global_transform.basis.x * 2.2 + Vector3.UP * 0.3
    who.velocity = Vector3.ZERO
    GameState.show_message("Você saiu do veículo.")
