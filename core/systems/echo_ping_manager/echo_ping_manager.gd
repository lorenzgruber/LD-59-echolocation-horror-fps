extends Node

var echo_geometry_material : ShaderMaterial = load("res://resources/materials/echo_geometry/echolocation_geometry.material");

var echo_pings : Array[EchoPing];
const MAX_ECHO_PINGS := 10; 

var foo : int = 0;

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	var echo_origin : Array[Vector3] = [];
	var echo_radius : Array[float] = [];
	var echo_visibility : Array[float] = [];
	var echo_color : Array[Color] = [];
	
	var dead_ping_indices : Array[int] = [];
	
	for i in echo_pings.size():	
		var echo_ping: EchoPing = echo_pings[i];
		echo_ping.process(delta);
		
		echo_origin.append(echo_ping.origin);
		echo_radius.append(echo_ping.radius);
		echo_visibility.append(echo_ping.visibility);
		echo_color.append(echo_ping.color);
		
		if (echo_ping.emitting == false):
			dead_ping_indices.append(i);
	
	dead_ping_indices.reverse();
	for i in dead_ping_indices:	
		echo_pings.remove_at(i);
	
	echo_geometry_material.set_shader_parameter("echo_origin", echo_origin);
	echo_geometry_material.set_shader_parameter("echo_radius", echo_radius);
	echo_geometry_material.set_shader_parameter("echo_visibility", echo_visibility);
	echo_geometry_material.set_shader_parameter("echo_color", echo_color);

func emit_echo(echo_ping: EchoPing) -> void:
	if (echo_pings.size() >= MAX_ECHO_PINGS):		
		push_warning("Echo ping buffer is full. Dropping oldest ping.")
		echo_pings.pop_front();
		
	echo_pings.append(echo_ping);
	
