class_name KeyItem extends Node3D

enum KeyType {KEY_1 = 1, KEY_2 = 2, KEY_3 = 3}

signal key_collected(key_type: KeyType)

@onready var echo_signal_emitter: EchoSignalEmitterComponent = $%EchoPingEmitter
@onready var interactable_component: InteractableComponent = $%InteractableComponent;
@onready var mesh: CSGMesh3D = $%Mesh
@onready var sphere_light: OmniLight3D = $%Mesh/OmniLight3D
@onready var particles: GPUParticles3D = $%GPUParticles3D

@export var key_type: KeyType = KeyType.KEY_1

const key_1_mesh: Mesh = preload("res://resources/meshes/key_1_mesh.tres")
const key_2_mesh: Mesh = preload("res://resources/meshes/key_2_mesh.tres")
const key_3_mesh: Mesh = preload("res://resources/meshes/key_3_mesh.tres")

func _ready() -> void:
	interactable_component.interacted.connect(on_interacted)
	var color := get_color()
	mesh.material.emission = color
	sphere_light.light_color = color
	particles.draw_pass_1.material.emission = color
	echo_signal_emitter.echo_ping_color = get_echo_ping_color()
	setup_mesh()
	
func on_interacted() -> void:
	key_collected.emit(key_type)
	# TODO: add vfx/sfx
	queue_free()
	
func get_color() -> Color:
	match key_type:	
		KeyType.KEY_1: return Constants.KEY_ECHO_COLOR_1
		KeyType.KEY_2: return Constants.KEY_ECHO_COLOR_2
		KeyType.KEY_3: return Constants.KEY_ECHO_COLOR_3
		_: return Constants.KEY_ECHO_COLOR_1
			
func get_echo_ping_color() -> EchoSignalEmitterComponent.EchoPingColor:
	match key_type:
		KeyType.KEY_1: return EchoSignalEmitterComponent.EchoPingColor.KEY_1
		KeyType.KEY_2: return EchoSignalEmitterComponent.EchoPingColor.KEY_2
		KeyType.KEY_3: return EchoSignalEmitterComponent.EchoPingColor.KEY_3
		_: return EchoSignalEmitterComponent.EchoPingColor.KEY_1

func setup_mesh() -> void:
	match key_type:
		KeyType.KEY_1: mesh.mesh = key_1_mesh
		KeyType.KEY_2: mesh.mesh = key_2_mesh
		KeyType.KEY_3: mesh.mesh = key_3_mesh
