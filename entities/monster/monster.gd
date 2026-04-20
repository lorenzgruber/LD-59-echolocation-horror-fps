extends CharacterBody3D

enum States {IDLE, PATROL, INVESTIGATE, HUNT}
var state: States

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var navigation_update_timer: Timer = $NavigationUpdateTimer
@onready var idle_timer: Timer = $IdleTimer
@onready var animation_player: AnimationPlayer = $MonsterInherited/AnimationPlayer
@onready var echo_signal_receiver: EchoSignalReceiverComponent = $EchoSignalReceiverComponent
@onready var long_scream_player: AudioStreamPlayer3D = $LongScreamAudioPlayer
@onready var short_scream_player: AudioStreamPlayer3D = $ShortScreamAudioPlayer

@export var navigation_manager: MonsterNavigationManager

var current_room: int
var prev_room: int = -1

var eyes_material : StandardMaterial3D

const WALK_SPEED: float = 2.0
const RUN_SPEED: float = 4.5

const WALK_ANIMATION_SPEED: float = 0.5
const RUN_ANIMATION_SPEED: float = 1.2 # TODO: adjust this

func _ready() -> void:
#	navigation_update_timer.timeout.connect(update_navigation_target)
	navigation_agent.target_reached.connect(on_navigation_target_reached)
	echo_signal_receiver.echo_signal_received.connect(on_echo_signal_received)
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
	
func update_navigation_target() -> void:
	var player_position := Player.instance.global_position
	navigation_agent.target_position = player_position
	
func get_move_speed() -> float:
	if (state == States.PATROL): return WALK_SPEED;
	else: return RUN_SPEED;
	
func update_animation_speed() -> void:
	var speed: float;
	if (state == States.PATROL): speed = WALK_ANIMATION_SPEED;
	else: speed = RUN_ANIMATION_SPEED;
	animation_player.speed_scale = speed
	
func on_echo_signal_received() -> void:
	pass
#	if (state == States.PATROL):
#		await idle_for_seconds(1.5)
		
	
func on_navigation_target_reached() -> void:
	if (state == States.PATROL):
		idle_for_seconds(1.5, States.PATROL)

func idle_for_seconds(seconds: float, next_state: States) -> void:
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
		print("entered IDLE state")
		set_eyes_glowing(false)
		animation_player.play('Idle', 0.2)
		
	if (_state == States.PATROL):
		print("entered PATROL state")
		set_eyes_glowing(false)
		animation_player.play('Walk', 0.2)
		current_room = navigation_manager.get_current_room(global_position)
		set_next_patrol_room()
		
	if (_state == States.INVESTIGATE):
		print("entered INVESTIGATE state")
		set_eyes_glowing(false)
		animation_player.play('Walk')
		
	if (_state == States.HUNT):
		print("entered HUNT state")
		set_eyes_glowing(true)	
		animation_player.play('Walk')
		long_scream_player.play()
	
func on_state_exit(_state: States) -> void:
	pass

func set_eyes_glowing(glowing: bool) -> void:
	var final_emission_strength: float = 3.0 if glowing else 0.0
	var tween := create_tween();
	tween.tween_property(eyes_material, "emission_energy_multiplier", final_emission_strength, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK);

func set_next_patrol_room() -> void:
	var next_room := navigation_manager.get_next_patrol_room(current_room, prev_room)
	print("Setting next patrol room - current: " + str(current_room) + ", next: " + str(next_room) + " prev: " + str(prev_room))
	prev_room = current_room
	current_room = next_room	
	navigation_agent.target_position = navigation_manager.get_room_position(current_room)
	
