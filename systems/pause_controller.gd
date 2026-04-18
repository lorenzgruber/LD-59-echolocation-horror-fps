extends Node

func _ready() -> void:
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if (Input.is_action_just_pressed("PAUSE")):
		get_tree().paused = !get_tree().paused
		if (get_tree().paused):
			DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
		else:
			DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
