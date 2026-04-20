class_name FootstepComponent extends Node3D

@export var footstep_distance := 0.5;
@export var footstep_audio_player: AudioStreamPlayer3D
@export var footstep_volume_db: float

@export var footstep_detection_range: float
@export var is_detectable: bool

var parent: Node3D;
var prev_position: Vector3;
var distance_travel_since_last_step := 0.0;

func _ready() -> void:
	parent = get_parent()
	assert(parent is Node3D, "Footstep component must be attached to a Node3D.")
	prev_position = parent.global_position

func _process(delta: float) -> void:
	var current_position := parent.global_position;
	var distance := current_position.distance_to(prev_position);
	prev_position = current_position;
	distance_travel_since_last_step += distance;
	
	if (distance_travel_since_last_step >= footstep_distance):
		play_footstep_sound()
		
func play_footstep_sound() -> void:
	footstep_audio_player.volume_db = footstep_volume_db;
	footstep_audio_player.play();
	distance_travel_since_last_step = 0.0;
	
	if (is_detectable and footstep_detection_range > 0):
		FootstepManager.emit_footstep(parent.global_position, footstep_detection_range)