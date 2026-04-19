shader_type spatial;

uniform vec3[10] echo_origin;
uniform float[10] echo_radius;
uniform float[10] echo_visibility;
uniform vec3[10] echo_color;

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

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	// Convert normal to world space so rotation doesn't break it
    // We use the Model Normal Matrix to handle scaling and rotation correctly
    world_normal = abs(MODEL_NORMAL_MATRIX * NORMAL);
}

void fragment() {
	// 1. Normalize the weights so they always add up to 1.0
    vec3 weights = world_normal / (world_normal.x + world_normal.y + world_normal.z);

    // 2. Sample from three directions using World Position
    // This ensures that even if you move/rotate the wall, the texture stays pinned to the world
    float x_tex = texture(height_map, world_position.zy * height_texture_scale).r;
    float y_tex = texture(height_map, world_position.xz * height_texture_scale).r;
    float z_tex = texture(height_map, world_position.xy * height_texture_scale).r;
    
    // 3. Blend them
    float height_val = (x_tex * weights.x) + (y_tex * weights.y) + (z_tex * weights.z);
	
	for (int i = 0; i < 10; i++) {
		float visibility = echo_visibility[i];
		if (visibility <= 0.0) break;
		vec3 origin = echo_origin[i];
		float radius = echo_radius[i];
		vec3 color = echo_color[i];
		
		float dist = distance(origin, world_position);
		dist = dist - (height_val * height_bump_strength);
	
		float echo_ring_strength = 1.0 - smoothstep(radius - 0.1, radius, dist);
		echo_ring_strength *= smoothstep(radius - echo_ring_width, radius, dist);
		echo_ring_strength *= echo_ring_intensity;
		
		float afterglow_strength = 1.0 - step(radius, dist);
		afterglow_strength *= smoothstep(radius - echo_ring_afterglow_width, radius, dist);
		afterglow_strength *= echo_ring_afterglow_intensity;
		
		float echo_strength = (echo_ring_strength + afterglow_strength) * visibility;
		echo_strength -= (1.0 - height_val) * echo_strength * height_after_glow_affect;
		
		EMISSION = max(EMISSION, color * echo_strength);
	}
	
	ALBEDO = vec3(0);
}
