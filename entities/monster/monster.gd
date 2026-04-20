extends CharacterBody3D

enum States {IDLE, PATROL, INVESTIGATE, HUNT_INITIAL, HUNT}
var state: States

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var navigation_update_timer: Timer = $NavigationUpdateTimer
@onready var hunt_timer: Timer = $HuntTimer
@onready var idle_timer: Timer = $IdleTimer
@onready var animation_player: AnimationPlayer = $MonsterInherited/AnimationPlayer
@onready var echo_signal_receiver: EchoSignalReceiverComponent = $EchoSignalReceiverComponent
@onready var footstep_detector: FootstepDetectorComponent = $FootstepDetectorComponent
@onready var player_detection_area: Area3D = $PlayerDetectionArea
@onready var long_scream_player: AudioStreamPlayer3D = $LongScreamAudioPlayer
@onready var short_scream_player: AudioStreamPlayer3D = $ShortScreamAudioPlayer
@onready var line_of_sight_origin: Marker3D = $LineOfSightOrigin
@onready var hunt_light: OmniLight3D = $HuntLight

@export var navigation_manager: MonsterNavigationManager

var current_room: int
var prev_room: int = -1

var last_player_sound_origin: Vector3

var eyes_material : StandardMaterial3D

const WALK_SPEED: float = 2.0
const FAST_WALK_SPEED: float = 3.0
const RUN_SPEED: float = 4.5

const WALK_ANIMATION_SPEED: float = 0.5
const FAST_WALK_ANIMATION_SPEED: float = 0.7
const RUN_ANIMATION_SPEED: float = 1.2 # TODO: adjust this
const IDLE_ANIMATION_SPEED: float = 1.0

func _ready() -> void:
	navigation_update_timer.timeout.connect(set_navigation_target_to_player)
	hunt_timer.timeout.connect(on_hunt_timer_timeout)
	navigation_agent.target_reached.connect(on_navigation_target_reached)
	echo_signal_receiver.echo_signal_received.connect(on_player_sound_detected)
	footstep_detector.footstep_detected.connect(on_player_sound_detected)
	player_detection_area.body_entered.connect(on_player_detection_area_entered)
	eyes_material = (get_node("MonsterInherited/Armature/Skeleton3D/weirdo_low") as MeshInstance3D).get_surface_override_material(1)
	set_state(States.PATROL)
	
func _physics_process(delta: float) -> void:
	if (state == States.IDLE): return;
	
	var next_position := navigation_agent.get_next_path_position()

	var dir_to_target := global_position.direction_to(next_position).normalized()
	var angle := atan2(dir_to_target.x, dir_to_target.z)
	rotation.y = lerp_angle(rotation.y, angle, delta * 3.0)
	
	# get the forward vector
	var direction := transform.basis.z
	var speed := get_move_speed();
	
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
	move_and_slide()
	
func set_navigation_target_to_player() -> void:
	var player_position := Player.instance.global_position
	navigation_agent.target_position = player_position
	debug_log("Setting navigation target to player")

func on_hunt_timer_timeout() -> void:
	if (state != States.HUNT_INITIAL): return
	set_state(States.HUNT)
	
func get_move_speed() -> float:
	if (state == States.PATROL): return WALK_SPEED;
	elif (state == States.INVESTIGATE): return FAST_WALK_SPEED;
	elif (state == States.HUNT_INITIAL or state == States.HUNT): return RUN_SPEED;
	else: return 0;
	
func update_animation_speed() -> void:
	var speed: float;
	if (state == States.PATROL): speed = WALK_ANIMATION_SPEED;
	elif (state == States.INVESTIGATE): speed = FAST_WALK_ANIMATION_SPEED;
	elif (state == States.HUNT_INITIAL or state == States.HUNT): speed = RUN_ANIMATION_SPEED;
	else: speed = IDLE_ANIMATION_SPEED;
	animation_player.speed_scale = speed

func on_player_detection_area_entered(player: Node3D) -> void:
	on_player_sound_detected(player.global_position)
	
func on_player_sound_detected(origin: Vector3) -> void:
	last_player_sound_origin = origin
	var distance_to_player := global_position.distance_to(Player.instance.global_position)
	var initiate_hunt := distance_to_player <= 30.0 and has_line_of_sight_to_player()
	
	if(initiate_hunt and state != States.HUNT_INITIAL and state != States.HUNT):
		await idle_for_seconds(1.5, States.HUNT_INITIAL)
	
	elif (state == States.PATROL or state == States.IDLE):
		await idle_for_seconds(1.5, States.INVESTIGATE)

	elif (state == States.INVESTIGATE or state == States.HUNT):
		navigation_agent.target_position = last_player_sound_origin
	
func has_line_of_sight_to_player() -> bool:
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(line_of_sight_origin.global_position, Player.instance.global_position)
	var result := space_state.intersect_ray(query)
	return result.collider == Player.instance
	
func on_navigation_target_reached() -> void:
	if (state == States.PATROL or state == States.INVESTIGATE or state == States.HUNT):
		idle_for_seconds(1.5, States.PATROL)

func idle_for_seconds(seconds: float, next_state: States) -> void:
	if (idle_timer.is_stopped()):
		idle_timer.stop()
		set_state(States.IDLE)
		idle_timer.start(seconds)
	await idle_timer.timeout
	set_state(next_state)
	
func set_state(_state: States) -> void:
	on_state_exit(state)
	self.state = _state
	on_state_enter(state)
	
func on_state_enter(_state: States) -> void:
	update_animation_speed()
	
	if (_state == States.IDLE):
		debug_log("entered IDLE state")
		set_eyes_glowing(false)
		animation_player.play('Idle', 0.2)
		
	elif (_state == States.PATROL):
		debug_log("entered PATROL state")
		set_eyes_glowing(false)
		animation_player.play('Walk', 0.2)
		current_room = navigation_manager.get_current_room(global_position)
		set_next_patrol_room()
		
	elif (_state == States.INVESTIGATE):
		debug_log("entered INVESTIGATE state")
		set_eyes_glowing(false)
		animation_player.play('Walk')
		navigation_agent.target_position = last_player_sound_origin
		
	elif (_state == States.HUNT_INITIAL):
		debug_log("entered HUNT_INITIAL state")
		set_eyes_glowing(true)	
		animation_player.play('Walk')
		long_scream_player.play()
		navigation_update_timer.start()
		hunt_timer.start()
		
	elif (_state == States.HUNT):
		debug_log("entered HUNT state")
		set_eyes_glowing(true)	
		animation_player.play('Walk')
	
func on_state_exit(_state: States) -> void:
	if (_state == States.HUNT_INITIAL):
		navigation_update_timer.stop()
	
	elif (_state == States.HUNT):
		long_scream_player.play() # TODO: use another sound

func set_eyes_glowing(glowing: bool) -> void:
	var final_emission_strength: float = 3.0 if glowing else 0.0
	var tween := create_tween();
	tween.set_parallel();
	tween.tween_property(eyes_material, "emission_energy_multiplier", final_emission_strength, 0.4).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC);
	tween.tween_property(hunt_light, "light_energy", final_emission_strength, 0.4).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC);

func set_next_patrol_room() -> void:
	var next_room := navigation_manager.get_next_patrol_room(current_room, prev_room)
	debug_log("Setting next patrol room - current: " + str(current_room) + ", next: " + str(next_room) + " prev: " + str(prev_room))
	prev_room = current_room
	current_room = next_room	
	navigation_agent.target_position = navigation_manager.get_room_position(current_room)
	
func debug_log(value: Variant) -> void:
	print("[Monster] " + value)
