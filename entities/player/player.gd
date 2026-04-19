class_name Player extends CharacterBody3D

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = %Camera
@onready var echo_ping_emitter: EchoSignalEmitterComponent = $%EchoPingEmitter
@onready var echo_cooldown_timer: Timer = $%EchoPingCooldownTimer

@onready var footstep_component: FootstepComponent = $FootstepComponent
@onready var footstep_audio_player: AudioStreamPlayer3D = $%FootstepAudioPlayer

enum States {WALK, RUN, SNEAK}
var state: States = States.WALK

var base_step_volume: float = 0.0

const WALK_SPEED: float = 3.0
const WALK_STEP_VOLUME_PERCENT: float = 100
const WALK_STEP_ECHO_RADIUS: float = 2.5;

const RUN_SPEED: float = 6.0
const RUN_STEP_VOLUME_PERCENT: float = 250
const RUN_STEP_ECHO_RADIUS: float = 4.5;

const SNEAK_SPEED: float = 1.0
const SNEAK_STEP_VOLUME_PERCENT: float = 10
const SNEAK_STEP_ECHO_RADIUS: float = 0.0;

const MOUSE_SENSITIVITY: float = 0.001;
const CAMERA_MAX_X_ANGLE: float = 45;

static var instance: Player = null

func _ready() -> void:
	base_step_volume = footstep_audio_player.volume_linear
	update_footstep_volume()
	instance = self

func _physics_process(delta: float) -> void:
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
	if (Input.is_action_pressed("RUN") and state == States.WALK):
		set_state( States.RUN)
	
	if (Input.is_action_pressed("SNEAK") and state == States.WALK):
		set_state( States.SNEAK)
		
	if ( (Input.is_action_just_released("RUN") and state == States.RUN) or (Input.is_action_just_released("SNEAK") and state == States.SNEAK)):	
		set_state( States.WALK)
	
	if (Input.is_action_just_pressed("ECHO") and echo_cooldown_timer.is_stopped()):
		echo_ping_emitter.emit_echo()
		echo_cooldown_timer.start()
	
	if (event is InputEventMouseMotion):
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera_pivot.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		var camera_rotation_x: float = clamp(camera_pivot.rotation_degrees.x, -CAMERA_MAX_X_ANGLE, CAMERA_MAX_X_ANGLE)
		camera_pivot.rotation_degrees.x = camera_rotation_x

func set_state(_state: States) -> void:
	self.state = _state
	update_footstep_volume()
		
func get_move_speed() -> float:
	if (state == States.WALK): return WALK_SPEED;
	elif (state == States.RUN): return RUN_SPEED
	else: return SNEAK_SPEED
		
func update_footstep_volume() -> void:
	var percent: float;
	if (state == States.WALK): percent = WALK_STEP_VOLUME_PERCENT;
	elif (state == States.RUN): percent = RUN_STEP_VOLUME_PERCENT;
	else: percent = SNEAK_STEP_VOLUME_PERCENT;
	var volume_db := linear_to_db( base_step_volume * (percent / 100))
	footstep_component.footstep_volume_db = volume_db
