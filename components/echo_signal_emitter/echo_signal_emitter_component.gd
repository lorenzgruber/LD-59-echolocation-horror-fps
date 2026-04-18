extends Node3D

@export var echo_geometry_material : ShaderMaterial;

@onready var echo_ping_audio_player: AudioStreamPlayer3D = $EchoPingAudioPlayer
@onready var echo_cooldown_timer: Timer = $EchoCooldownTimer

var echo_origin : Vector3;
var echo_radius : float;
var echo_age : float;
var echo_emitting : bool;

const ECHO_LIFETIME_SECONDS : float = 2.0;
const ECHO_SPEED : float = 10.0;

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if (echo_emitting):
		echo_radius += delta * ECHO_SPEED;
		echo_age += delta / 1000;
		var liftetime_progress := echo_age / ECHO_LIFETIME_SECONDS;
		
		echo_geometry_material.set_shader_parameter("echo_radius", echo_radius);
		echo_geometry_material.set_shader_parameter("echo_lifetime_progress", liftetime_progress);
		
		if (liftetime_progress >= 1.0):
			echo_emitting = false;		

func _input(event: InputEvent) -> void:
	if (Input.is_action_just_pressed("ECHO") and echo_cooldown_timer.is_stopped()):
		echo_origin = global_position;
		echo_geometry_material.set_shader_parameter("echo_origin", echo_origin);
		echo_radius = 0.0;
		echo_age = 0.0;
		echo_emitting = true;
		echo_ping_audio_player.play();
		echo_cooldown_timer.start();
