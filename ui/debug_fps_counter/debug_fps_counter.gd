extends Control

@onready var label: Label = $MarginContainer/Label

func _process(delta: float) -> void:
	label.text = str(int(Engine.get_frames_per_second()))
