class_name Player extends CharacterBody3D

@onready var camera_pivot: Node3D = $CameraPivot
@onready var echo_ping_emitter: EchoSignalEmitterComponent = $%EchoPingEmitter
@onready var echo_cooldown_timer: Timer = $%EchoPingCooldownTimer

@onready var footstep_component: FootstepComponent = $%FootstepComponent
@onready var footstep_audio_player: AudioStreamPlayer3D = $%FootstepAudioPlayer
@onready var left_foot_echo_emitter: EchoSignalEmitterComponent = $%LeftFootEchoEmitter
@onready var right_foot_echo_emitter: EchoSignalEmitterComponent = $%RightFootEchoEmitter

var is_running: bool = false
var is_sneaking: bool = false
var is_prev_step_left: bool = false
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
	footstep_component.footstep.connect(on_footstep)
	base_step_volume = footstep_audio_player.volume_linear
	instance = self

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("LEFT", "RIGHT", "FORWARD", "BACKWARD")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var speed := WALK_SPEED;
	if is_running: speed = RUN_SPEED
	elif is_sneaking: speed = SNEAK_SPEED
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		

	move_and_slide()
	
func _input(event: InputEvent) -> void:
	is_running = Input.is_action_pressed("RUN")
	is_sneaking = Input.is_action_pressed("SNEAK") and !is_running
	
	if (Input.is_action_just_pressed("ECHO") and echo_cooldown_timer.is_stopped()):
		echo_ping_emitter.emit_echo()
		echo_cooldown_timer.start()
	
	if (event is InputEventMouseMotion):
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera_pivot.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		var camera_rotation_x: float = clamp(camera_pivot.rotation_degrees.x, -CAMERA_MAX_X_ANGLE, CAMERA_MAX_X_ANGLE)
		camera_pivot.rotation_degrees.x = camera_rotation_x
		
func on_footstep() -> void:
	var volume := get_step_volume_db()
	footstep_audio_player.set_volume_db(volume)
	footstep_audio_player.play()
	
# TODO: foodsteps echos disabled for now
#	var radius := get_step_echo_radius()
#	right_foot_echo_emitter.echo_ping_radius = radius
#	left_foot_echo_emitter.echo_ping_radius = radius
	
#	if (is_prev_step_left): right_foot_echo_emitter.emit_echo()
#	else: left_foot_echo_emitter.emit_echo()
		
	is_prev_step_left = !is_prev_step_left
	
func get_step_volume_db() -> float:
	var percent := WALK_STEP_VOLUME_PERCENT
	if is_running: percent = RUN_STEP_VOLUME_PERCENT
	elif is_sneaking: percent = SNEAK_STEP_VOLUME_PERCENT
	
	return linear_to_db( base_step_volume * (percent / 100) )

#func get_step_echo_radius() -> float: 
#	var radius := WALK_STEP_ECHO_RADIUS
#	if is_running: radius = RUN_STEP_ECHO_RADIUS
#	elif is_sneaking: radius = SNEAK_STEP_ECHO_RADIUS
#	
#	return radius;
