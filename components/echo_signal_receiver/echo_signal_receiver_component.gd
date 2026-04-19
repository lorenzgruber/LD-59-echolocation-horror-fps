class_name EchoSignalReceiverComponent extends Node3D

signal echo_signal_received

@onready var area: Area3D = $Area3D;

func _ready() -> void:
	area.area_entered.connect(on_echo_signal_received)


func on_echo_signal_received(_area: Area3D) -> void:
	echo_signal_received.emit()