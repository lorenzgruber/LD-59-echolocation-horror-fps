class_name MainUi extends CanvasLayer

# Victory screen
@onready var victory_screen_animation_player: AnimationPlayer = $%VicotryScreenAnimationPlayer
@onready var main_menu_button: Button = $%MainMenuButton

# Defeat screen
@onready var defeat_screen_animation_player: AnimationPlayer = $%DefeatScreenAnimationPlayer
@onready var try_again_button: Button = $%TryAgainButton

# Pause overlay
@onready var pause_overlay: Control = $PauseOverlay

static var instance: MainUi

var pausable: bool = true

var capture_mouse: bool:
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
	capture_mouse = true
	
func _input(event: InputEvent) -> void:
	if (Input.is_action_just_pressed("PAUSE")):
		capture_mouse = get_tree().paused
		set_paused(!get_tree().paused)
	
func fade_in_victory_screen() -> void:
	pausable = false
	get_tree().paused = true
	victory_screen_animation_player.play("fade_in")
	
func fade_in_defeat_screen() -> void:
	defeat_screen_animation_player.play("fade_in")

func set_paused(paused: bool) -> void:
	if (!pausable): return
	get_tree().paused = paused
	pause_overlay.visible = paused
