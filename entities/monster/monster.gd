extends CharacterBody3D

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var navigation_update_timer: Timer = $NavigationUpdateTimer
@onready var animation_player: AnimationPlayer = $MonsterInherited/AnimationPlayer
@onready var echo_signal_receiver: EchoSignalReceiverComponent = $EchoSignalReceiverComponent

var eyes_material : StandardMaterial3D

enum States {PATROL, HUNT}
var state: States

const WALK_SPEED: float = 1.0
const RUN_SPEED: float = 3.0

const WALK_ANIMATION_SPEED: float = 0.3
const RUN_ANIMATION_SPEED: float = 1.0

func _ready() -> void:
	navigation_update_timer.timeout.connect(update_navigation_target)
	echo_signal_receiver.echo_signal_received.connect(on_echo_signal_received)
	eyes_material = (get_node("MonsterInherited/Armature/Skeleton3D/weirdo_low") as MeshInstance3D).get_surface_override_material(1)
	set_state(States.PATROL)
	
func _physics_process(delta: float) -> void:
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
	print("Echo signal received by monster")
	if (state == States.PATROL): set_state(States.HUNT)
	
func set_state(_state: States) -> void:
	on_state_exit(state)
	self.state = _state
	on_state_enter(state)
	
func on_state_enter(_state: States) -> void:
	update_animation_speed()
	if (_state == States.PATROL):
		set_eyes_glowing(false)	
	if (_state == States.HUNT):
		set_eyes_glowing(true)	
	
func on_state_exit(_state: States) -> void:
	pass

func set_eyes_glowing(glowing: bool) -> void:
	var final_color: Color = Constants.MONSTER_ECHO_COLOR if glowing else Color.BLACK
	var tween := create_tween();
	tween.tween_property(eyes_material, "emission", final_color, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK);
