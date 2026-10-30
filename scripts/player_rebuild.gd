extends CharacterBody3D
@export var walk_speed := 5.0
@export var run_speed := 7.0
@export var acceleration := 18.0
@export var jump_force := 4.5
@export var mouse_sensitivity := 0.0025
@onready var pivot: Node3D = $CameraPivot
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var yaw := 0.0
var pitch := -0.18
var touch_move := Vector2.ZERO
var move_touch := -1
var look_touch := -1
var move_origin := Vector2.ZERO
var current_vehicle: CharacterBody3D
var weapon_index := 0
var weapon_names := ["PISTOLA", "FACA", "MACHADO"]
var attack_cooldown := 0.0
func _ready() -> void:
 add_to_group("player")
 Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
 _sync_camera()
func _unhandled_input(event: InputEvent) -> void:
 if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
  yaw -= event.relative.x * mouse_sensitivity
  pitch = clampf(pitch-event.relative.y*mouse_sensitivity,-0.85,0.35)
  _sync_camera()
 elif event is InputEventScreenTouch:
  if event.pressed:
   if event.position.x < get_viewport().get_visible_rect().size.x*0.48 and move_touch == -1:
    move_touch=event.index
    move_origin=event.position
   else: look_touch=event.index
  else:
   if event.index==move_touch:
    move_touch=-1
    touch_move=Vector2.ZERO
   if event.index==look_touch: look_touch=-1
 elif event is InputEventScreenDrag:
  if event.index==move_touch: touch_move=((event.position-move_origin)/75.0).limit_length(1.0)
  elif event.index==look_touch:
   yaw-=event.relative.x*0.004
   pitch=clampf(pitch-event.relative.y*0.003,-0.85,0.35)
   _sync_camera()
 elif event is InputEventKey and event.pressed:
  if event.keycode==KEY_ESCAPE: Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
  elif event.keycode==KEY_1: _select_weapon(0)
  elif event.keycode==KEY_2: _select_weapon(1)
  elif event.keycode==KEY_3: _select_weapon(2)
 elif event is InputEventMouseButton and event.pressed and Input.mouse_mode==Input.MOUSE_MODE_VISIBLE:
  Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
func _select_weapon(index: int) -> void:
 weapon_index=index
 GameState.show_message("Equipado: "+weapon_names[index])
func _sync_camera() -> void:
 pivot.rotation=Vector3(pitch,yaw-rotation.y,0.0)
func _physics_process(delta: float) -> void:
 attack_cooldown=maxf(0.0,attack_cooldown-delta)
 if is_instance_valid(current_vehicle):
  if Input.is_action_just_pressed("interact"):
   current_vehicle.call("exit_vehicle")
   current_vehicle=null
  return
 if not is_on_floor(): velocity.y-=gravity*delta
 elif velocity.y<0.0: velocity.y=-0.1
 if Input.is_action_just_pressed("jump") and is_on_floor(): velocity.y=jump_force
 var iv:=Input.get_vector("move_left","move_right","move_forward","move_back")
 if touch_move.length()>0.08: iv=touch_move
 var f:=Vector3(-sin(yaw),0.0,-cos(yaw))
 var r:=Vector3(cos(yaw),0.0,-sin(yaw))
 var dir:=(r*iv.x+f*-iv.y).normalized()
 var spd:=run_speed if Input.is_action_pressed("sprint") else walk_speed
 velocity.x=move_toward(velocity.x,dir.x*spd,acceleration*delta)
 velocity.z=move_toward(velocity.z,dir.z*spd,acceleration*delta)
 if dir.length_squared()>0.01: rotation.y=lerp_angle(rotation.y,atan2(-dir.x,-dir.z),10.0*delta)
 _sync_camera()
 move_and_slide()
 if Input.is_action_just_pressed("interact"): _try_enter_vehicle()
 if Input.is_action_just_pressed("shoot") or Input.is_action_just_pressed("melee"): _attack()
func _try_enter_vehicle() -> void:
 var nearest: Node3D
 var best:=4.0
 for v in get_tree().get_nodes_in_group("simple_vehicles"):
  var d:=global_position.distance_to(v.global_position)
  if d<best and v.get("driver")==null:
   best=d
   nearest=v
 if nearest:
  current_vehicle=nearest
  nearest.call("enter",self)
  GameState.show_message("Dirigindo "+str(nearest.get("vehicle_name"))+" — E para sair")
func _attack() -> void:
 if attack_cooldown>0.0: return
 attack_cooldown=0.45
 if weapon_index==0:
  var cam: Camera3D=$CameraPivot/SpringArm3D/Camera3D
  var query:=PhysicsRayQueryParameters3D.create(cam.global_position,cam.global_position-cam.global_transform.basis.z*55.0)
  query.exclude=[self]
  get_world_3d().direct_space_state.intersect_ray(query)
  GameState.show_message("Pistola disparou")
 else: GameState.show_message("Golpe com "+weapon_names[weapon_index].to_lower())
