extends Node
class_name FootstepComponent

signal footstep;

@export var footstep_distance := 0.5;

var parent: Node3D;
var prev_position: Vector3;
var distance_travel_since_last_step := 0.0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = get_parent()
	assert(parent is Node3D, "Footstep component must be attached to a Node3D.")
	prev_position = parent.global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var current_position := parent.global_position;
	var distance := current_position.distance_to(prev_position);
	prev_position = current_position;
	distance_travel_since_last_step += distance;
	
	if (distance_travel_since_last_step >= footstep_distance):
		emit_signal("footstep");		
		distance_travel_since_last_step = 0.0;