class_name GameManager extends Node

@export var keys_container: Node3D
@export var gates_container: Node3D
@export var monster_navigation_manager: MonsterNavigationManager
@export var wall_map: WallMap
@export var player: Player
@export var monster: Monster
@export var exit: Exit

# Scripted events
@export var monster_spawn_marker: Marker3D
@export var monster_spawn_trigger: Area3D
var first_hunt_started: bool = false

var key_1_collected: bool = false
var key_2_collected: bool = false
var key_3_collected: bool = false
var gate_1_opened: bool = false
var gate_2_opened: bool = false
var gate_3_opened: bool = false

static var instance: GameManager

func _ready() -> void:
	instance = self
	wall_map.collected.connect(on_wall_map_collected)
	exit.level_exited.connect(on_level_exited)
	player.death.connect(on_player_death)
	monster_spawn_trigger.body_entered.connect(on_monster_spawn_triggered)
	monster.hunt_started.connect(on_monster_hunt_started)

	var keys := keys_container.get_children()
	for key : Node in keys:
		if (key is not KeyItem): continue
		( key as KeyItem ).key_collected.connect(on_key_collected)
		
	var gates := gates_container.get_children()
	for gate : Node in gates:
		if (gate is not Gate): continue
		( gate as Gate ).gate_opened.connect(on_gate_opened)
		
	await get_tree().create_timer(2.0).timeout
	MainUi.instance.show_level_start_tutorial()

func on_wall_map_collected() -> void:
	player.is_map_unlocked = true
	MainUi.instance.show_map_tutorial()

func on_key_collected(key_type: KeyItem.KeyType) -> void:
	match key_type:
		1: key_1_collected = true
		2: key_2_collected = true
		3: key_3_collected = true
	update_gates()
	update_player_map()

func on_gate_opened(key_type: Gate.KeyType) -> void:
	match key_type:
		1: gate_1_opened = true
		2: gate_2_opened = true
		3: gate_3_opened = true
		
	update_monster_navigation()
	update_player_map()

func update_gates() -> void:
	update_gate(1, key_1_collected)
	update_gate(2, key_2_collected)
	update_gate(3, key_3_collected)

func update_gate(key_type: int, key_collected: bool) -> void:
	var index := gates_container.get_children().find_custom(func (child: Node) -> bool:
		if (child is not Gate): return false
		return ( child as Gate ).key_type == key_type
	)
	if (index < 0): return
	var gate := gates_container.get_child(index) as Gate
	
	if (key_type == KeyItem.KeyType.KEY_3 and key_collected):
		monster.set_scripted_target_room(1)
	
	gate.is_key_collected = key_collected
	
func update_monster_navigation() -> void:
	if(gate_1_opened):
		monster_navigation_manager.connect_area_1_and_2()
		monster.set_scripted_target_room(8)
	if(gate_2_opened):
		monster_navigation_manager.connect_area_2_and_3()
		monster.set_scripted_target_room(16)
	
func update_player_map() -> void:
	player.map.is_key_1_visible = !key_1_collected
	player.map.is_key_2_visible = !key_2_collected
	player.map.is_key_3_visible = !key_3_collected
	player.map.is_lock_1_visible = !gate_1_opened
	player.map.is_lock_2_visible = !gate_2_opened
	player.map.is_lock_3_visible = !gate_3_opened
	
func on_level_exited() -> void:
	MainUi.instance.fade_in_victory_screen()

func on_player_death() -> void:
	MainUi.instance.fade_in_defeat_screen()	

func on_monster_spawn_triggered(_player: Node3D) -> void:
	if (!key_1_collected): return
	monster.global_position = monster_spawn_marker.global_position
	monster.set_scripted_target_room(5)
	monster.use_long_hunt_startup = true

func on_monster_hunt_started() -> void:
	if (first_hunt_started): return
	MainUi.instance.show_monster_tutorial()	
	first_hunt_started = true
