extends Node

@export var keys_container: Node3D
@export var gates_container: Node3D

var key_1_collected: bool = false
var key_2_collected: bool = false
var key_3_collected: bool = false

func _ready() -> void:
	var children := keys_container.get_children()
	for child : Node in children:
		if (child is not KeyItem): continue
		( child as KeyItem ).key_collected.connect(on_key_collected)

func _process(delta: float) -> void:
	pass

func on_key_collected(key_type: int) -> void:
	match key_type:
		1: key_1_collected = true
		2: key_2_collected = true
		3: key_3_collected = true
		
	update_gates()

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
	
