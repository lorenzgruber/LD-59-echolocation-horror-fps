class_name MainUi extends CanvasLayer

signal start_game_pressed
signal try_again_pressed
signal main_menu_pressed

# Title screen
@onready var title_screen_container: Control = $TitleScreen
@onready var title_screen_animation_player: AnimationPlayer = $%TitleScreenAnimationPlayer
@onready var start_game_button: Button = $%StartGameButton
@onready var quite_game_button: Button = $%QuitButton
@onready var toggle_fullscreen_button_1: Button = $%ToggleFullscreenButton1

# Victory screen
@onready var victory_screen_container: Control = $VictoryScreen
@onready var victory_screen_animation_player: AnimationPlayer = $%VicotryScreenAnimationPlayer
@onready var main_menu_button: Button = $%MainMenuButton

# Defeat screen
@onready var defeat_screen_container: Control = $DefeatScreen
@onready var defeat_screen_animation_player: AnimationPlayer = $%DefeatScreenAnimationPlayer
@onready var try_again_button: Button = $%TryAgainButton

# Pause overlay
@onready var pause_overlay: Control = $PauseOverlay
@onready var toggle_fullscreen_button_2: Button = $%ToggleFullscreenButton2

#Screen transition
@onready var screen_transition_animation_player: AnimationPlayer = $%ScreenTransitionAnimationPlayer

# Tutorial overlays
@onready var tutorial_overlays_container: Control = $TutorialOverlays
@onready var tutorial_echo_signal_hint: Control = $%EchoSignalHint
@onready var tutorial_movement_hint: Control = $%MovementHint
@onready var tutorial_map_hint_1: Control = $%MapHint
@onready var tutorial_map_hint_2: Control = $%MapHint2
@onready var tutorial_run_hint: Control = $%RunHint
@onready var tutorial_sneak_hint: Control = $%SneakHint
@onready var tutorial_hiding_hint: Control = $%HidingHint
var tutorial_tween: Tween

static var instance: MainUi

var pausable: bool = false

var capture_mouse: bool = false:
	get:
		return capture_mouse
	set(value):
		capture_mouse = value
		if (value):
			DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
		else:
			DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)

func _ready() -> void:
	instance = self
	capture_mouse = false
	start_game_button.pressed.connect(on_start_game_pressed)
	quite_game_button.pressed.connect(on_quit_pressed)
	try_again_button.pressed.connect(on_try_again_pressed)
	main_menu_button.pressed.connect(on_main_menu_pressed)
	toggle_fullscreen_button_1.pressed.connect(toggle_fullscreen)
	toggle_fullscreen_button_2.pressed.connect(toggle_fullscreen)
	
func _input(event: InputEvent) -> void:
	if (Input.is_action_just_pressed("PAUSE")):
		capture_mouse = get_tree().paused
		set_paused(!get_tree().paused)
	
func setup_main_level() -> void:
	pausable = true
	capture_mouse = true
	title_screen_container.visible = false
	victory_screen_container.visible = false
	defeat_screen_container.visible = false
	tutorial_overlays_container.visible = true

func setup_title_screen() -> void:
	pausable = false
	capture_mouse = false
	title_screen_container.visible = false
	victory_screen_container.visible = false
	defeat_screen_container.visible = false
	tutorial_overlays_container.visible = false

func show_level_start_tutorial() -> void:
	display_tutorial_hint(tutorial_echo_signal_hint)
	await tutorial_tween.finished
	display_tutorial_hint(tutorial_movement_hint)

func show_map_tutorial() -> void:
	display_tutorial_hint(tutorial_map_hint_1)
	await tutorial_tween.finished
	display_tutorial_hint(tutorial_map_hint_2)
	
func show_monster_tutorial() -> void:
	display_tutorial_hint(tutorial_run_hint)
	await tutorial_tween.finished
	display_tutorial_hint(tutorial_sneak_hint)
	await tutorial_tween.finished
	display_tutorial_hint(tutorial_hiding_hint)
		
func fade_in_title_screen() -> void: 
	AmbientSoundManager.instance.transition_master_bus_volume()
	AmbientSoundManager.instance.transition_ambience_bus_volume()
	title_screen_animation_player.play("fade_in")
	
func fade_in_victory_screen() -> void:
	pausable = false
	get_tree().paused = true
	capture_mouse = false
	AmbientSoundManager.instance.transition_ambience_bus_volume(0.0, -60.0, 3.0)
	victory_screen_animation_player.play("fade_in")
	
func fade_in_defeat_screen() -> void:
	tutorial_overlays_container.visible = false
	defeat_screen_animation_player.play("fade_in")
	await defeat_screen_animation_player.animation_finished
	pausable = false
	get_tree().paused = true
	capture_mouse = false

func set_paused(paused: bool) -> void:
	if (paused and !pausable): return
	get_tree().paused = paused
	pause_overlay.visible = paused


func on_start_game_pressed() -> void:
	start_game_pressed.emit()

func on_try_again_pressed() -> void:
	try_again_pressed.emit()

func on_main_menu_pressed() -> void:
	main_menu_pressed.emit()
	
	
func fade_in_screen_transition() -> void:
	screen_transition_animation_player.play("fade_in")
	
func fade_out_screen_transition() -> void:
	screen_transition_animation_player.play("fade_out")

func display_tutorial_hint(hint: Control) -> void:
	hide_tutorial_hints()
	if (tutorial_tween != null): tutorial_tween.kill()
	tutorial_tween = create_tween()
	
	hint.modulate = Color.TRANSPARENT
	hint.visible = true
	
	tutorial_tween.tween_property(hint, "modulate:a", 1.0, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tutorial_tween.tween_interval(5.0)
	tutorial_tween.tween_property(hint, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tutorial_tween.tween_property(hint, "visible", false, 0)

func hide_tutorial_hints() -> void:
	tutorial_echo_signal_hint.visible = false
	tutorial_movement_hint.visible = false
	tutorial_map_hint_1.visible = false
	tutorial_map_hint_2.visible = false
	tutorial_run_hint.visible = false
	tutorial_sneak_hint.visible = false
	tutorial_hiding_hint.visible = false

func toggle_fullscreen() -> void:
	var mode := DisplayServer.window_get_mode()
	var is_window: bool = mode != DisplayServer.WINDOW_MODE_FULLSCREEN
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if is_window else DisplayServer.WINDOW_MODE_WINDOWED)

func on_quit_pressed() -> void:
	get_tree().quit()
