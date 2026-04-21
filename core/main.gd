extends Node

@onready var main_ui: MainUi = $MainUi
@onready var ambient_sound_manager: AmbientSoundManager = $AmbientSoundManager
@onready var screen_space_shader_manager: ScreenSpaceShaderManager = $ScreenSpaceShaderManager

@onready var active_level_container: Node = $ActiveLevel

@export var debug_mode: bool = false

var title_screen_level_scene: PackedScene = preload("res://scenes/title_screen_background.tscn")
var main_level_scene: PackedScene = preload("res://scenes/main_level.tscn")

var title_screen_level: Node = title_screen_level_scene.instantiate()
var main_level: Node

func _ready() -> void:
	main_ui.start_game_pressed.connect(on_start_game)
	main_ui.try_again_pressed.connect(on_restart_game)
	main_ui.main_menu_pressed.connect(on_back_to_main_menu)
	
	if (!debug_mode):
		ambient_sound_manager.init_master_volume()
		main_ui.fade_in_title_screen()
		active_level_container.add_child(title_screen_level)
	
	else:
		main_ui.setup_main_level()
		main_level = main_level_scene.instantiate()	
		active_level_container.add_child(main_level)

func on_start_game() -> void:
	ambient_sound_manager.transition_level_bus_volume(0.0, -60.0, 3.0)
	main_ui.fade_in_screen_transition()
	await main_ui.screen_transition_animation_player.animation_finished
	title_screen_level.queue_free()
	main_ui.setup_main_level()
	main_level = main_level_scene.instantiate()	
	active_level_container.add_child(main_level)
	main_ui.fade_out_screen_transition()
	ambient_sound_manager.transition_level_bus_volume(-60.0, 0.0, 3.0)
	
func on_restart_game() -> void:
	main_ui.fade_in_screen_transition()
	await main_ui.screen_transition_animation_player.animation_finished
	active_level_container.remove_child(main_level)
	main_level.queue_free()
	main_ui.setup_main_level()
	main_ui.set_paused(false)
	main_level = main_level_scene.instantiate()	
	active_level_container.add_child(main_level)
	main_ui.fade_out_screen_transition()
	
func on_back_to_main_menu() -> void:
	main_ui.fade_in_screen_transition()
	await main_ui.screen_transition_animation_player.animation_finished
	active_level_container.remove_child(main_level)
	main_level.queue_free()
	main_ui.setup_title_screen()
	main_ui.set_paused(false)
	title_screen_level = title_screen_level_scene.instantiate()	
	active_level_container.add_child(title_screen_level)
	main_ui.fade_out_screen_transition()
	main_ui.fade_in_title_screen()
