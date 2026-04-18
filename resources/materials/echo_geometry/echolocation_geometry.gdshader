shader_type spatial;

uniform vec3[10] echo_origin;
uniform float[10] echo_radius;
uniform float[10] echo_visibility;
uniform vec3[10] echo_color;

uniform float echo_ring_width : hint_range(0.0, 10.0, 0.1) = 1.0;
uniform float echo_ring_intensity : hint_range(0.0, 10.0, 0.01) = 1.0;

uniform float echo_ring_afterglow_width : hint_range(0.0, 100.0, 0.1) = 10.0;
uniform float echo_ring_afterglow_intensity : hint_range(0.0, 10.0, 0.01) = 1.0;

varying vec3 world_position;

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	
	for (int i = 0; i < 10; i++) {
		float visibility = echo_visibility[i];
		if (visibility <= 0.0) break;
		vec3 origin = echo_origin[i];
		float radius = echo_radius[i];
		vec3 color = echo_color[i];
		
		float dist = distance(origin, world_position);
	
		float echo_ring_strength = 1.0 - smoothstep(radius - 0.1, radius, dist);
		echo_ring_strength *= smoothstep(radius - echo_ring_width, radius, dist);
		echo_ring_strength *= echo_ring_intensity;
		
		float afterglow_strength = 1.0 - step(radius, dist);
		afterglow_strength *= smoothstep(radius - echo_ring_afterglow_width, radius, dist);
		afterglow_strength *= echo_ring_afterglow_intensity;
		
		float echo_strength = (echo_ring_strength + afterglow_strength) * visibility;
		
		EMISSION = max(EMISSION, color * echo_strength);
	}
	
	ALBEDO = vec3(0);
}
