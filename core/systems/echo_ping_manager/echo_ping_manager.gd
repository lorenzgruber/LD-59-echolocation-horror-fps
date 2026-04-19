extends Node

var echo_pings : Array[EchoPing];
const MAX_ECHO_PINGS := 10; 

var data_texture_src_image : Image;
var data_texture : ImageTexture;

func _ready() -> void:
	# create a RGBF texture with 2 pixels per echo ping
	# 1. pixel = origin vector (X,Y,Z) and radius
	# 2. pixel = color (R,G,B,A)
	data_texture_src_image = Image.create(MAX_ECHO_PINGS, 2, false, Image.FORMAT_RGBAF);
	data_texture = ImageTexture.create_from_image(data_texture_src_image);
	RenderingServer.global_shader_parameter_set("echo_ping_data", data_texture);

func _process(delta: float) -> void:
	RenderingServer.global_shader_parameter_set("echo_ping_count", echo_pings.size());
	
	var dead_ping_indices : Array[int] = [];

	for i in echo_pings.size():	
		var echo_ping: EchoPing = echo_pings[i];
		echo_ping.process(delta);
		
		data_texture_src_image.set_pixel(i, 0, Color(echo_ping.origin.x, echo_ping.origin.y, echo_ping.origin.z, echo_ping.radius));
		data_texture_src_image.set_pixel(i, 1, Color(echo_ping.color.r, echo_ping.color.g, echo_ping.color.b, echo_ping.visibility));
		
		if (echo_ping.emitting == false):
			dead_ping_indices.append(i);
			
	dead_ping_indices.reverse();
	for i in dead_ping_indices:	
		echo_pings.remove_at(i);

	data_texture.update(data_texture_src_image);	

func emit_echo(echo_ping: EchoPing) -> void:
	if (echo_pings.size() >= MAX_ECHO_PINGS):		
		push_warning("Echo ping buffer is full. Dropping oldest ping.")
		echo_pings.pop_front();
		
	echo_pings.append(echo_ping);
