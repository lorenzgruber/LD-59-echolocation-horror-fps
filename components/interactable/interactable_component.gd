class_name InteractableComponent extends Node3D

signal interacted

@onready var area: Area3D = $Area3D
@onready var label: Label = $%Label
@onready var key_prompt: Control = $%KeyPrompt
@onready var label_container: Container = $%LabelContainer
@onready var label_quad_mesh: MeshInstance3D = $LabelQuadMesh
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var label_text: String:
	get:
		return label_text
	set(value):
		label_text = value
		update_label_text()
		
@export var disabled_text: String = "Disabled":
	get:
		return disabled_text
	set(value):
		disabled_text = value
		update_label_text()
		
@export var enabled: bool = true:
	get:
		return enabled
	set(value):
		enabled = value
		update_label_text()
	

var is_in_range: bool = false;
var was_interacted_with: bool = false;

func _ready() -> void:
	area.body_entered.connect(on_body_entered)
	area.body_exited.connect(on_body_exited)
	update_label_text()

func _input(event: InputEvent) -> void:
	if (Input.is_action_just_pressed("INTERACT") and is_in_range and !was_interacted_with and enabled):
		animation_player.play('interact')
		emit_signal("interacted")
		was_interacted_with = true
		
func on_body_entered(body: Node3D) -> void:
	if (was_interacted_with): return;
	is_in_range = true
	animation_player.play('fade_in')
	print("in range")
	
func on_body_exited(body: Node3D) -> void:
	if (was_interacted_with): return;
	is_in_range = false
	animation_player.play('fade_out')
	print("out of range")

func update_label_text() -> void:
	if (label == null): return
	label.text = label_text if enabled else disabled_text
	key_prompt.visible = enabled
