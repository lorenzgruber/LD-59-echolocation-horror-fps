class_name WallMap extends Node3D

signal collected

@onready var interactable_component: InteractableComponent = $InteractableComponent

func _ready() -> void:
	interactable_component.interacted.connect(on_interacted)
	
func on_interacted() -> void:
	collected.emit()	
	queue_free()

