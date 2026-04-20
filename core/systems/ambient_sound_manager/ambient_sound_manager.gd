class_name AmbientSoundManager extends Node

@onready var dark_ambience_player: AudioStreamPlayer = $DarkAmbiencePlayer

static var instance: AmbientSoundManager

func _ready() -> void:
	instance = self
#	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -60.0)
	
func fade_out_ambient_sound(duration: float = 4.0) -> void:
	var tween := create_tween()
	tween.tween_property(dark_ambience_player, "volume_db", -60, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


func transition_master_bus_volume(from: float = -60.0, to: float = 0.0, duration: float = 5.0) -> void:
	var tween := create_tween()
	tween.tween_method(func (volume_db: float) -> void: 
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume_db),
		from, to, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		
func transition_level_bus_volume(from: float = -60.0, to: float = 0.0, duration: float = 5.0) -> void:
	var tween := create_tween()
	tween.tween_method(func (volume_db: float) -> void: 
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Level"), volume_db),
		from, to, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
