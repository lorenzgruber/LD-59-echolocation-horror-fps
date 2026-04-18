extends Node3D

@onready var echo_ping_audio_player: AudioStreamPlayer3D = $EchoPingAudioPlayer
@onready var echo_cooldown_timer: Timer = $EchoCooldownTimer

func _input(event: InputEvent) -> void:
	if (Input.is_action_just_pressed("ECHO") and echo_cooldown_timer.is_stopped()):
		var echo_ping := EchoPing.new(global_position, 50.0);
		EchoPingManager.emit_echo(echo_ping);
		echo_ping_audio_player.play();
		echo_cooldown_timer.start();
