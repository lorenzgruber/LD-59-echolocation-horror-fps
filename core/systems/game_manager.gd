extends Node

@export var keys_container: Node3D
@export var gates_container: Node3D
@export var monster_navigation_manager: MonsterNavigationManager
@export var wall_map: WallMap
@export var player: Player
@export var exit: Exit

var key_1_collected: bool = false
var key_2_collected: bool = false
var key_3_collected: bool = false
var gate_1_opened: bool = false
var gate_2_opened: bool = false
var gate_3_opened: bool = false

func _ready() -> void:
	wall_map.collected.connect(on_wall_map_collected)
	exit.level_exited.connect(on_level_exited)
	player.death.connect(on_player_death)

	var keys := keys_container.get_children()
	for key : Node in keys:
		if (key is not KeyItem): continue
		( key as KeyItem ).key_collected.connect(on_key_collected)
		
	var gates := gates_container.get_children()
	for gate : Node in gates:
		if (gate is not Gate): continue
		( gate as Gate ).gate_opened.connect(on_gate_opened)

func on_wall_map_collected() -> void:
	player.is_map_unlocked = true

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
	gate.is_key_collected = key_collected
	
func update_monster_navigation() -> void:
	if(gate_1_opened):
		monster_navigation_manager.connect_area_1_and_2()
	if(gate_2_opened):
		monster_navigation_manager.connect_area_2_and_3()
	

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
