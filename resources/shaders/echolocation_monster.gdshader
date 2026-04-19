shader_type spatial;

global uniform sampler2D echo_ping_data;
global uniform int echo_ping_count;

//uniform sampler2D echo_ping_data;
//uniform int echo_ping_count;

uniform vec3 echo_color : source_color;

uniform float echo_ring_width : hint_range(0.0, 10.0, 0.1) = 1.0;
uniform float echo_ring_intensity : hint_range(0.0, 10.0, 0.01) = 1.0;

uniform float echo_ring_afterglow_width : hint_range(0.0, 100.0, 0.1) = 10.0;
uniform float echo_ring_afterglow_intensity : hint_range(0.0, 10.0, 0.01) = 1.0;

uniform sampler2D height_map;
uniform float height_bump_strength : hint_range(0.0, 5.0, 0.01) = 0.1;
uniform float height_texture_scale : hint_range(0.0, 5.0, 0.01) = 0.2;
uniform float height_after_glow_affect : hint_range(0.0, 1.0, 0.01) = 0.7;

varying vec3 world_position;
varying vec3 world_normal;

#include "echolocation_shared.gdshaderinc"

void vertex() {
	world_position = get_world_position(MODEL_MATRIX, VERTEX);
	world_normal = get_world_normal(MODEL_NORMAL_MATRIX, NORMAL);
}

void fragment() {
	float height_val = get_height_val(world_normal, height_map, world_position, height_texture_scale);
	
	for (int i = 0; i < echo_ping_count; i++) {
		vec4 origin_and_radius = texelFetch(echo_ping_data, ivec2(i, 0), 0);
		float alpha = texelFetch(echo_ping_data, ivec2(i, 1), 0).a;
		vec4 color = vec4(echo_color, alpha);
		vec3 origin = origin_and_radius.rgb;
		float radius = origin_and_radius.a;
		
		EMISSION = get_emission(
			origin, 
			world_position,
			height_val,
			height_bump_strength,
			radius,
			echo_ring_width,
			echo_ring_intensity,
			echo_ring_afterglow_width,
			echo_ring_afterglow_intensity,
			color,
			height_after_glow_affect,
			EMISSION
		);
	}
	
	ALBEDO = vec3(0);
}
