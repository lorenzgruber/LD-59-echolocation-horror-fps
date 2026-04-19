class_name Gate extends Node3D

enum KeyType {KEY_1 = 1, KEY_2 = 2, KEY_3 = 3}

@onready var interactable_component: InteractableComponent = $%InteractableComponent
@onready var echo_signal_receiver: EchoSignalReceiverComponent = $%EchoSignalReceiverComponent
@onready var key_symbol: MeshInstance3D = $%KeySymbol
@onready var key_symbol_light: OmniLight3D = $%KeySymbol/OmniLight3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var key_type: KeyType = KeyType.KEY_1

@export var is_key_collected: bool = false:
	get:
		return is_key_collected
	set(value):
		is_key_collected = value
		update_interactable_component()

var tween: Tween

func _ready() -> void:
	interactable_component.interacted.connect(on_interacted)
	echo_signal_receiver.echo_signal_received.connect(on_echo_signal_received)
	var color := get_color()
	key_symbol.get_surface_override_material(0).emission = color
	key_symbol_light.light_color = color
	update_interactable_component()

func on_interacted() -> void:
	if (!is_key_collected): return
	open_gate()
	
func on_echo_signal_received() -> void:
	print("Echo signal received by gate")
	if (tween != null): tween.kill()
	tween = create_tween()
	tween.set_parallel()
	
	tween.tween_property(key_symbol.get_surface_override_material(0), "emission_energy_multiplier", 1.0, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(key_symbol_light, "light_energy", 1.0, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.chain()
	
	tween.tween_interval(5)
	tween.chain()
	
	tween.tween_property(key_symbol.get_surface_override_material(0), "emission_energy_multiplier", 0.0, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(key_symbol_light, "light_energy", 0.0, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
func open_gate() -> void:
	print("Gate opened")
	animation_player.play("open")
	echo_signal_receiver.enabled = false

func update_interactable_component() -> void:
	if (interactable_component == null): return
	interactable_component.enabled = is_key_collected
	
func get_color() -> Color:
	match key_type:	
		KeyType.KEY_1:
			return Constants.KEY_ECHO_COLOR_1
		KeyType.KEY_2:
			return Constants.KEY_ECHO_COLOR_2
		KeyType.KEY_3:
			return Constants.KEY_ECHO_COLOR_3
		_:
			return Constants.KEY_ECHO_COLOR_3
