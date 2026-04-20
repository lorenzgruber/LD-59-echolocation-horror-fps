class_name AmbientSoundManager extends Node

@onready var dark_ambience_player: AudioStreamPlayer = $DarkAmbiencePlayer

static var instance: AmbientSoundManager

func _ready() -> void:
	instance = self
	
func fade_out_ambient_sound(duration: float = 4.0) -> void:
	var tween := create_tween()
	tween.tween_property(dark_ambience_player, "volume_db", -60, 1.0)
