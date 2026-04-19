extends CharacterBody3D

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var navigation_update_timer: Timer = $NavigationUpdateTimer
@onready var animation_player: AnimationPlayer = $MonsterInherited/AnimationPlayer

enum States {WALK, RUN}
var state: States = States.WALK

const WALK_SPEED: float = 1.0
const RUN_SPEED: float = 3.0

const WALK_ANIMATION_SPEED: float = 0.3
const RUN_ANIMATION_SPEED: float = 1.0

func _ready() -> void:
	navigation_update_timer.timeout.connect(update_navigation_target)
	update_animation_speed()
	
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
	if (state == States.WALK): return WALK_SPEED;
	else: return RUN_SPEED;
	
func update_animation_speed() -> void:
	var speed: float;
	if (state == States.WALK): speed = WALK_ANIMATION_SPEED;
	else: speed = RUN_ANIMATION_SPEED;
	animation_player.speed_scale = speed
	
