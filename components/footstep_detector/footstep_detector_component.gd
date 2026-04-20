class_name FootstepDetectorComponent extends Node3D

signal footstep_detected(origin: Vector3)

@onready var area: Area3D = $Area3D;

func _ready() -> void:
	area.area_entered.connect(on_footstep_detected)
	
func on_footstep_detected(_area: Area3D) -> void:
	footstep_detected.emit(_area.global_position)
