class_name EchoSignalReceiverComponent extends Node3D

signal echo_signal_received(origin: Vector3)

@onready var area: Area3D = $Area3D;

@export var enabled: bool = true

func _ready() -> void:
	area.area_entered.connect(on_echo_signal_received)

func on_echo_signal_received(_area: Area3D) -> void:
	if(!enabled): return
	echo_signal_received.emit(_area.global_position)