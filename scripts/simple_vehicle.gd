extends CharacterBody3D
@export var vehicle_name := "Carro"
@export var max_speed := 16.0
@export var acceleration := 10.0
@export var turn_rate := 1.8
var driver: Node3D
var speed := 0.0
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
func _ready() -> void:
 add_to_group("simple_vehicles")
 var paint:=StandardMaterial3D.new()
 paint.albedo_color=Color(0.12,0.28,0.72) if vehicle_name=="Carro" else Color(0.88,0.62,0.12)
 var body:=MeshInstance3D.new()
 var bm:=BoxMesh.new()
 bm.size=Vector3(1.8,0.75,3.3) if vehicle_name=="Carro" else Vector3(0.65,0.65,1.8)
 body.mesh=bm
 body.position.y=0.7
 body.material_override=paint
 add_child(body)
 var cab:=MeshInstance3D.new()
 var cb:=BoxMesh.new()
 cb.size=Vector3(1.4,0.65,1.4)
 cab.mesh=cb
 cab.position=Vector3(0,1.35,-0.2)
 cab.material_override=paint
 add_child(cab)
 var col:=CollisionShape3D.new()
 var shape:=BoxShape3D.new()
 shape.size=Vector3(1.9,1.3,3.4)
 col.shape=shape
 col.position.y=0.7
 add_child(col)
func enter(p: Node3D) -> void:
 driver=p
 p.visible=false
func exit_vehicle() -> void:
 if is_instance_valid(driver):
  driver.visible=true
  driver.global_position=global_position+global_transform.basis.x*2.0+Vector3.UP
 driver=null
 speed=0.0
func _physics_process(delta: float) -> void:
 if not is_instance_valid(driver): return
 var throttle:=Input.get_action_strength("move_forward")-Input.get_action_strength("move_back")
 var steer:=Input.get_action_strength("move_right")-Input.get_action_strength("move_left")
 speed=move_toward(speed,throttle*max_speed,acceleration*delta)
 rotation.y-=steer*turn_rate*delta*clampf(absf(speed)/4.0,0.0,1.0)*signf(speed if speed!=0.0 else 1.0)
 var f:Vector3=-global_transform.basis.z
 velocity.x=f.x*speed
 velocity.z=f.z*speed
 if not is_on_floor(): velocity.y-=gravity*delta
 else: velocity.y=-0.1
 move_and_slide()
 if Input.is_action_just_pressed("interact"): exit_vehicle()
