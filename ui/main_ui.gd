class_name MainUi extends CanvasLayer

signal start_game_pressed

# Title screen
@onready var title_screen_container: Control = $TitleScreen
@onready var title_screen_animation_player: AnimationPlayer = $%TitleScreenAnimationPlayer
@onready var start_game_button: Button = $%StartGameButton

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

#Screen transition
@onready var screen_transition_animation_player: AnimationPlayer = $%ScreenTransitionAnimationPlayer

# Tutorial overlays
@onready var tutorial_echo_signal_hint: Control = $%EchoSignalHint
@onready var tutorial_movement_hint: Control = $%MovementHint
@onready var tutorial_map_hint_1: Control = $%MapHint
@onready var tutorial_map_hint_2: Control = $%MapHint2

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

func show_level_start_tutorial() -> void:
	var echo_signal_tween := display_tutorial_hint(tutorial_echo_signal_hint)
	await echo_signal_tween.finished
	display_tutorial_hint(tutorial_movement_hint)

func show_map_tutorial() -> void:
	var map_hint_1_tween := display_tutorial_hint(tutorial_map_hint_1)
	await map_hint_1_tween.finished
	display_tutorial_hint(tutorial_map_hint_2)
		
func fade_in_title_screen() -> void: 
	AmbientSoundManager.instance.transition_master_bus_volume()
	title_screen_animation_player.play("fade_in")
	
func fade_in_victory_screen() -> void:
	pausable = false
	get_tree().paused = true
	capture_mouse = false
	AmbientSoundManager.instance.fade_out_ambient_sound()
	victory_screen_animation_player.play("fade_in")
	
func fade_in_defeat_screen() -> void:
	defeat_screen_animation_player.play("fade_in")
	await defeat_screen_animation_player.animation_finished
	pausable = false
	get_tree().paused = true
	capture_mouse = false

func set_paused(paused: bool) -> void:
	if (!pausable): return
	get_tree().paused = paused
	pause_overlay.visible = paused


func on_start_game_pressed() -> void:
	start_game_pressed.emit()
	
func fade_in_screen_transition() -> void:
	screen_transition_animation_player.play("fade_in")
	
func fade_out_screen_transition() -> void:
	screen_transition_animation_player.play("fade_out")

func display_tutorial_hint(hint: Control) -> Tween:
	var tween := create_tween()
	
	hint.modulate = Color.TRANSPARENT
	hint.visible = true
	
	tween.tween_property(hint, "modulate:a", 1.0, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_interval(5.0)
	tween.tween_property(hint, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(hint, "visible", false, 0)
	return tween
