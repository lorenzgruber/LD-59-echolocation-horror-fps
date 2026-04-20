class_name Exit extends Node3D

signal level_exited

@onready var interactable_component: InteractableComponent = $InteractableComponent

func _ready() -> void:
	interactable_component.interacted.connect(on_interacted)

func on_interacted() -> void:
	level_exited.emit()