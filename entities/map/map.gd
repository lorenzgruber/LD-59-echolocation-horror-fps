class_name Map extends Node3D

@onready var base: MeshInstance3D = $BaseTexture
@onready var outline: MeshInstance3D = $OutlineTexture
@onready var key_1: MeshInstance3D = $Key_1
@onready var key_2: MeshInstance3D = $Key_2
@onready var key_3: MeshInstance3D = $Key_3
@onready var lock_1: MeshInstance3D = $Lock_1
@onready var lock_2: MeshInstance3D = $Lock_2
@onready var lock_3: MeshInstance3D = $Lock_3
@onready var player_marker: Node3D = $PlayerMarker
@onready var player_marker_base: MeshInstance3D = $PlayerMarker/PlayerMarkerBase
@onready var player_marker_outline: MeshInstance3D = $PlayerMarker/PlayerMarkerOutline

@onready var echo_signal_receiver: EchoSignalReceiverComponent = $EchoSignalReceiverComponent

@export var is_key_1_visible: bool = true:
	get:
		return is_key_1_visible
	set(value):
		is_key_1_visible = value
		key_1.visible = value
		
@export var is_key_2_visible: bool = true:
	get:
		return is_key_2_visible
	set(value):
		is_key_2_visible = value
		key_2.visible = value
		
@export var is_key_3_visible: bool = true:
	get:
		return is_key_3_visible
	set(value):
		is_key_3_visible = value
		key_3.visible = value

@export var is_lock_1_visible: bool = true:
	get:
		return is_lock_1_visible
	set(value):
		is_lock_1_visible = value
		lock_1.visible = value
		
@export var is_lock_2_visible: bool = true:
	get:
		return is_lock_2_visible
	set(value):
		is_lock_2_visible = value
		lock_2.visible = value

@export var is_lock_3_visible: bool = true:
	get:
		return is_lock_3_visible
	set(value):
		is_lock_3_visible = value
		lock_3.visible = value

@export var is_echo_reactive: bool = false:
	get:
		return is_echo_reactive
	set(value):
		is_echo_reactive = value
		if (echo_signal_receiver != null):
			echo_signal_receiver.enabled = value
	
@export var show_player_marker: bool = false
			
@export var player_position: Vector3:
	get:
		return player_position
	set(value):
		player_position = value
		update_player_marker()
		
@export var player_rotation: float:
	get:
		return player_rotation
	set(value):
		player_rotation = value
		update_player_marker()

var tween: Tween

const SCALE_FACTOR := 168.410041841

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	echo_signal_receiver.echo_signal_received.connect(on_echo_signal_received)
	player_marker.visible = show_player_marker
	tween = create_tween()
	set_emission_strength(0.0, 0.05, 0.0, 0.0, tween)
	
func on_echo_signal_received(_origin: Vector3) -> void:
	if (tween != null): tween.kill()	
	tween = create_tween()
	tween.set_parallel()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
	var fade_in_time := 0.3
	var fade_out_time := 5.0
	var emission_strength_on := 1.0 
	var emission_strength_player_on := 3.0 
	var emission_strength_off := 0.0
	var emission_strength_icons_off := 0.05
	
	set_emission_strength(emission_strength_on, emission_strength_on, emission_strength_player_on, fade_in_time, tween)
	tween.chain()
	tween.tween_interval(3.0)
	tween.chain()
	set_emission_strength(emission_strength_off, emission_strength_icons_off, emission_strength_off, fade_out_time, tween)

func set_emission_strength(strength_map: float, strength_icons: float, strength_player: float, time: float, _tween: Tween) -> void:
	_tween.tween_property(base.get_surface_override_material(0), "emission_energy_multiplier", strength_map, time)
	_tween.tween_property(outline.get_surface_override_material(0), "emission_energy_multiplier", strength_map, time)
	_tween.tween_property(key_1.get_surface_override_material(0), "emission_energy_multiplier", strength_icons, time)
	_tween.tween_property(key_2.get_surface_override_material(0), "emission_energy_multiplier", strength_icons, time)
	_tween.tween_property(key_3.get_surface_override_material(0), "emission_energy_multiplier", strength_icons, time)
	_tween.tween_property(lock_1.get_surface_override_material(0), "emission_energy_multiplier", strength_icons, time)
	_tween.tween_property(lock_2.get_surface_override_material(0), "emission_energy_multiplier", strength_icons, time)
	_tween.tween_property(lock_3.get_surface_override_material(0), "emission_energy_multiplier", strength_icons, time)
	_tween.tween_property(player_marker_base.get_surface_override_material(0), "emission_energy_multiplier", strength_player, time)
	_tween.tween_property(player_marker_outline.get_surface_override_material(0), "emission_energy_multiplier", strength_player, time)


func update_player_marker() -> void:
	player_marker.rotation_degrees.z = player_rotation
	player_marker.position.x = player_position.x / SCALE_FACTOR
	player_marker.position.y = -player_position.z / SCALE_FACTOR