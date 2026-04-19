extends Node3D

@onready var interactable_component: InteractableComponent = $%InteractableComponent;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable_component.interacted.connect(on_interacted)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func on_interacted() -> void:
	print("Key interacted with")