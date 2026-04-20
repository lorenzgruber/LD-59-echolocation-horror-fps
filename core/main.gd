extends Node

@onready var main_ui: MainUi = $MainUi
@onready var ambient_sound_manager: AmbientSoundManager = $AmbientSoundManager
@onready var screen_space_shader_manager: ScreenSpaceShaderManager = $ScreenSpaceShaderManager

@onready var active_level_container: Node = $ActiveLevel

@export var debug_mode: bool = false

var title_screen_level: Node = preload("res://scenes/title_screen_background.tscn").instantiate()
var main_level: Node = preload("res://scenes/main_level.tscn").instantiate()

func _ready() -> void:
	if (!debug_mode):
		main_ui.fade_in_title_screen()
		main_ui.start_game_pressed.connect(on_start_game)
		active_level_container.add_child(title_screen_level)
	
	else:
		main_ui.setup_main_level()
		active_level_container.add_child(main_level)

func on_start_game() -> void:
	ambient_sound_manager.transition_level_bus_volume(0.0, -60.0, 3.0)
	main_ui.fade_in_screen_transition()
	await main_ui.screen_transition_animation_player.animation_finished
	title_screen_level.queue_free()
	main_ui.setup_main_level()
	active_level_container.add_child(main_level)
	main_ui.fade_out_screen_transition()
	ambient_sound_manager.transition_level_bus_volume(-60.0, 0.0, 3.0)
	
