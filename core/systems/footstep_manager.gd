extends Node3D

var footstep_collider_container: Node3D;

const FOOTSTEP_COLLIDER_TIME := 0.1

func _ready() -> void:
	footstep_collider_container = Node3D.new();
	add_child(footstep_collider_container);


func emit_footstep(origin: Vector3, detection_range: float) -> void:
	var sphere := SphereShape3D.new();
	sphere.radius = detection_range;
	
	var collision_shape := CollisionShape3D.new();
	collision_shape.shape = sphere;
	
	var area := Area3D.new();
	area.add_child(collision_shape);
	area.collision_layer = int(pow(2, Constants.CollisionLayers.FOOTSTEP - 1));
	area.collision_mask = 0;
	
	footstep_collider_container.add_child(area);
	area.global_position = origin;
	
	await get_tree().create_timer(FOOTSTEP_COLLIDER_TIME).timeout;
	area.queue_free();
	