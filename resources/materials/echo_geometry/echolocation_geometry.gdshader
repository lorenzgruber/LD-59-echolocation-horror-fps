shader_type spatial;

// Access the global variables we defined
uniform vec3 echo_origin;
uniform float echo_radius : hint_range(0.0, 100.0, 0.1) = 0.0;
uniform float echo_visibility : hint_range(0.0, 1.0, 0.01) = 0.0;

uniform float echo_ring_width : hint_range(0.0, 10.0, 0.1) = 1.0;
uniform vec3 echo_ring_color : source_color;
uniform float echo_ring_intensity : hint_range(0.0, 10.0, 0.01) = 1.0;

uniform float echo_ring_afterglow_width : hint_range(0.0, 100.0, 0.1) = 10.0;
uniform float echo_ring_afterglow_intensity : hint_range(0.0, 10.0, 0.01) = 1.0;

varying vec3 world_position;

void vertex() {
    // Get the world position of the vertex to calculate distance in the fragment tip
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float dist = distance(echo_origin, world_position);
	
	float echo_ring_strength = 1.0 - smoothstep(echo_radius - 0.1, echo_radius, dist);
	echo_ring_strength *= smoothstep(echo_radius - echo_ring_width, echo_radius, dist);
	echo_ring_strength *= echo_ring_intensity;
	
	float afterglow_strength = 1.0 - step(echo_radius, dist);
	afterglow_strength *= smoothstep(echo_radius - echo_ring_afterglow_width, echo_radius, dist);
	afterglow_strength *= echo_ring_afterglow_intensity;
	
	float echo_strength = echo_ring_strength + afterglow_strength;
	
	ALBEDO = vec3(0);
	EMISSION = vec3(echo_ring_color) * echo_strength * echo_visibility;
}
