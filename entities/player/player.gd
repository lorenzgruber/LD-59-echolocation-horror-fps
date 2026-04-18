extends CharacterBody3D

@onready var camera_pivot: Node3D = $CameraPivot
@onready var footstep_component: FootstepComponent = $FootstepComponent
@onready var footstep_audio_player: AudioStreamPlayer3D = $FootstepAudioPlayer

const SPEED: float = 3.0
const MOUSE_SENSITIVITY: float = 0.001;

func _ready() -> void:
	footstep_component.footstep.connect(on_footstep)

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("LEFT", "RIGHT", "FORWARD", "BACKWARD")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
func _input(event: InputEvent) -> void:
	if (event is InputEventMouseMotion):
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera_pivot.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		
		
func on_footstep() -> void:
	footstep_audio_player.play()