class_name Player extends CharacterBody3D

signal death

enum States {WALK, RUN, SNEAK, MAP, DEATH}
var state: States = States.WALK

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = %Camera
@onready var echo_ping_emitter: EchoSignalEmitterComponent = $%EchoPingEmitter
@onready var echo_cooldown_timer: Timer = $%EchoPingCooldownTimer
@onready var footstep_component: FootstepComponent = $FootstepComponent
@onready var hurt_area: Area3D = $HurtArea
@onready var footstep_audio_player: AudioStreamPlayer3D = $%FootstepAudioPlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var map: Map = $%Map

@export var is_map_unlocked: bool = false
@export var monster: Monster

var base_step_volume: float = 0.0

const WALK_SPEED: float = 3.0
const WALK_STEP_VOLUME_PERCENT: float = 100
const WALK_STEP_RANGE: float = 5.0

const RUN_SPEED: float = 6.0
const RUN_STEP_VOLUME_PERCENT: float = 250
const RUN_STEP_RANGE: float = 12.0;

const SNEAK_SPEED: float = 1.0
const SNEAK_STEP_VOLUME_PERCENT: float = 10
const SNEAK_STEP_RANGE: float = 0.0

const MOUSE_SENSITIVITY: float = 0.001;
const CAMERA_MAX_X_ANGLE: float = 45;

func _ready() -> void:
	hurt_area.area_entered.connect(on_hurt_area_entered)
	base_step_volume = footstep_audio_player.volume_linear
	set_state(States.WALK)

func _physics_process(delta: float) -> void:
	if (state == States.MAP or state == States.DEATH): return;

	var input_dir := Input.get_vector("LEFT", "RIGHT", "FORWARD", "BACKWARD")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var speed : = get_move_speed();
	
	var camera_target_height: float;
	if (state == States.SNEAK): camera_target_height = -0.6
	else: camera_target_height = 0
	camera.position.y = lerp(camera.position.y, camera_target_height, delta * 5.0)
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	
func _input(event: InputEvent) -> void:
	if(is_map_unlocked and Input.is_action_pressed("MAP") and state != States.MAP):
		set_state( States.MAP)
		
	if(is_map_unlocked and Input.is_action_just_released("MAP") and state == States.MAP):
		set_state( States.WALK)
		
	if (Input.is_action_pressed("RUN") and state == States.WALK):
		set_state( States.RUN)
		
	if (Input.is_action_pressed("SNEAK") and state == States.WALK):
		set_state( States.SNEAK)
		
	if ((Input.is_action_just_released("RUN") and state == States.RUN) or (Input.is_action_just_released("SNEAK") and state == States.SNEAK)):	
		set_state( States.WALK)
	
	if (Input.is_action_just_pressed("ECHO") and echo_cooldown_timer.is_stopped()):
		echo_ping_emitter.emit_echo()
		echo_cooldown_timer.start()
	
	# handle camera movement
	if (event is InputEventMouseMotion and state != States.DEATH):
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera_pivot.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		var camera_rotation_x: float = clamp(camera_pivot.rotation_degrees.x, -CAMERA_MAX_X_ANGLE, CAMERA_MAX_X_ANGLE)
		camera_pivot.rotation_degrees.x = camera_rotation_x
		map.player_rotation = rotation_degrees.y
	
func on_hurt_area_entered(_area: Area3D) -> void:
	debug_log("player was hurt")
	set_state(States.DEATH)

func set_state(_state: States) -> void:
	if(state == States.DEATH): return
	
	on_state_exited(state)
	self.state = _state
	on_state_entered(_state)
	update_footstep_volume()
	update_footstep_range()

func on_state_entered(_state: States) -> void:
	debug_log( "entering state: " + str(_state))
	
	if (_state == States.DEATH):
		play_death_animation()
	
	elif (_state == States.MAP):
		map.player_position = global_position
		animation_player.play("open_map")
	
func on_state_exited(_state: States) -> void:
	debug_log( "exiting state: " + str(_state))
	if (_state == States.MAP):
		animation_player.play("close_map")
		
func get_move_speed() -> float:
	if (state == States.WALK): return WALK_SPEED;
	elif (state == States.RUN): return RUN_SPEED
	elif (state == States.SNEAK): return SNEAK_SPEED
	else: return 0
		
func update_footstep_volume() -> void:
	var percent: float;
	if (state == States.WALK): percent = WALK_STEP_VOLUME_PERCENT;
	elif (state == States.RUN): percent = RUN_STEP_VOLUME_PERCENT;
	else: percent = SNEAK_STEP_VOLUME_PERCENT;
	var volume_db := linear_to_db( base_step_volume * (percent / 100))
	footstep_component.footstep_volume_db = volume_db;
	
func update_footstep_range() -> void:
	var step_range: float;
	if (state == States.WALK): step_range = WALK_STEP_RANGE;
	elif (state == States.RUN): step_range = RUN_STEP_RANGE;
	else: step_range = SNEAK_STEP_RANGE;
	footstep_component.footstep_detection_range = step_range;
	
func play_death_animation() -> void:
	var tween := create_tween()
	tween.set_parallel()
	
	var dir_to_monster := global_position.direction_to(monster.global_position)
	var y_angle := atan2(dir_to_monster.x, dir_to_monster.z) + PI
	var x_angle := deg_to_rad(15.0)
	var y_position := camera_pivot.position.y - 0.5
	
	tween.tween_property(self, "rotation:y", y_angle, Constants.DEATH_ANIMATION_DURATION).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(camera_pivot, "rotation:x", x_angle, Constants.DEATH_ANIMATION_DURATION).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(camera_pivot, "position:y", y_position, Constants.DEATH_ANIMATION_DURATION).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.chain()
	
	tween.tween_interval(0.5)
	tween.chain()
	tween.tween_callback(func() -> void: death.emit())
	
	
func debug_log(value: Variant) -> void:
	print("[Player] " + value)
