extends Node3D

var echo_pings : Array[EchoPing] = [];
var data_texture_src_image : Image;
var data_texture : ImageTexture;

var echo_ping_collider_container: Node3D;
var echo_ping_colliders: Dictionary[EchoPing, Area3D] = {}

const MAX_ECHO_PINGS := 50; 

func _ready() -> void:
	# create a RGBF texture with 2 pixels per echo ping
	# 1. pixel = origin vector (X,Y,Z) and radius
	# 2. pixel = color (R,G,B,A)
	data_texture_src_image = Image.create(MAX_ECHO_PINGS, 2, false, Image.FORMAT_RGBAF);
	data_texture = ImageTexture.create_from_image(data_texture_src_image);
	RenderingServer.global_shader_parameter_set("echo_ping_data", data_texture);
	
	# setup collider container
	echo_ping_collider_container = Node3D.new();
	add_child(echo_ping_collider_container);

func _process(delta: float) -> void:
	RenderingServer.global_shader_parameter_set("echo_ping_count", echo_pings.size());
	
	var dead_ping_indices : Array[int] = [];

	for i in echo_pings.size():	
		var echo_ping: EchoPing = echo_pings[i];
		
		echo_ping.process(delta);
		
		data_texture_src_image.set_pixel(i, 0, Color(echo_ping.origin.x, echo_ping.origin.y, echo_ping.origin.z, echo_ping.radius));
		data_texture_src_image.set_pixel(i, 1, Color(echo_ping.color.r, echo_ping.color.g, echo_ping.color.b, echo_ping.visibility));
		
		var echo_ping_collider: Variant = echo_ping_colliders.get(echo_ping);
		if (echo_ping_collider != null and echo_ping.radius > 0):
			echo_ping_collider.get_child(0).get_shape().set_radius(echo_ping.radius);
		
		if (echo_ping.emitting == false):
			dead_ping_indices.append(i);
			
	dead_ping_indices.reverse();
	for i in dead_ping_indices:	
		remove_echo_ping_at(i)

	data_texture.update(data_texture_src_image);	

func emit_echo(echo_ping: EchoPing) -> void:
	if (echo_pings.size() >= MAX_ECHO_PINGS):		
		push_warning("Echo ping buffer is full. Dropping oldest ping.")
		remove_echo_ping_at(0)

	if(echo_ping.is_reactive):
		var echo_ping_collider := get_echo_ping_collider();	
		echo_ping_collider_container.add_child(echo_ping_collider);
		echo_ping_collider.global_position = echo_ping.origin;
		echo_ping_colliders.set(echo_ping, echo_ping_collider);
	
	echo_pings.append(echo_ping);

func get_echo_ping_collider() -> Area3D:
	var sphere := SphereShape3D.new();
	sphere.radius = 0.001;
	
	var collision_shape := CollisionShape3D.new();
	collision_shape.shape = sphere;
	
	var area := Area3D.new();
	area.add_child(collision_shape);
	area.collision_layer = int(pow(2, Constants.CollisionLayers.ECHO_SIGNAL - 1));
	area.collision_mask = 0;
	return area;
	
func remove_echo_ping_at(index: int) -> void:
	var echo_ping := echo_pings[index];
	
	var echo_ping_collider: Variant = echo_ping_colliders.get(echo_ping);
	if (echo_ping_collider != null):
		echo_ping_collider.queue_free();
		echo_ping_colliders.erase(echo_ping);
		
	echo_pings.remove_at(index);
	
func _input(event: InputEvent) -> void:
	if (Input.is_action_just_pressed("DEBUG_SAVE_ECHO_DATA_TEXTURE")):
		var path := "res://echo_signal_data.exr"
		data_texture_src_image.save_exr(path, false);
		print("Saving echo data texture to: " + path)
