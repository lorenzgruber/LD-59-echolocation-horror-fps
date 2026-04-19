class_name EchoSignalEmitterComponent extends Node3D 

enum EchoPingColor {PLAYER, KEY, MONSTER}

@export var echo_ping_audio_player: AudioStreamPlayer3D
@export var echo_ping_radius: float
@export var echo_ping_visibility: float
@export var echo_ping_color: EchoPingColor = EchoPingColor.PLAYER
@export var echo_ping_is_reactive: bool = false

func emit_echo() -> void:
	var echo_ping := EchoPing.new(global_position, echo_ping_radius, echo_ping_visibility, get_echo_ping_color(), echo_ping_is_reactive, get_tree());
	EchoPingManager.emit_echo(echo_ping);
	echo_ping_audio_player.play();

func get_echo_ping_color() -> Color: 
	match echo_ping_color:
		EchoPingColor.KEY: return Constants.KEY_ECHO_COLOR
		EchoPingColor.MONSTER: return Constants.MONSTER_ECHO_COLOR
		EchoPingColor.PLAYER: return Constants.PLAYER_ECHO_COLOR
		_: return Constants.PLAYER_ECHO_COLOR
