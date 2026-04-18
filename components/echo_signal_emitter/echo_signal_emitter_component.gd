class_name EchoSignalEmitterComponent extends Node3D 

@export var echo_ping_audio_player: AudioStreamPlayer3D
@export var echo_ping_radius: float
@export var echo_ping_visibility: float

func emit_echo() -> void:
	var echo_ping := EchoPing.new(global_position, echo_ping_radius, echo_ping_visibility, get_tree());
	EchoPingManager.emit_echo(echo_ping);
	echo_ping_audio_player.play();
