extends CharacterBody3D

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var navigation_update_timer: Timer = $NavigationUpdateTimer

const WALK_SPEED: float = 3.0

func _ready() -> void:
	navigation_update_timer.timeout.connect(update_navigation_target)
	
func _physics_process(delta: float) -> void:
	var next_position := navigation_agent.get_next_path_position()

	var dir_to_target := global_position.direction_to(next_position).normalized()
	var angle := atan2(dir_to_target.x, dir_to_target.z)
	rotation.y = lerp_angle(rotation.y, angle, delta * 3.0)
	
	# get the forward vector
	var direction := transform.basis.z
	
	velocity.x = direction.x * WALK_SPEED
	velocity.z = direction.z * WALK_SPEED
	
	move_and_slide()
	
	
func update_navigation_target() -> void:
	var player_position := Player.instance.global_position
	navigation_agent.target_position = player_position
	print("Updating navigation target to: " + str(player_position));
