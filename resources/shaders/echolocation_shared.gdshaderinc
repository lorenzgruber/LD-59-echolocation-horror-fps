vec3 get_world_position(mat4 _MODEL_MATRIX, vec3 _VERTEX) {
	return (_MODEL_MATRIX * vec4(_VERTEX, 1.0)).xyz;
}

vec3 get_world_normal(mat3 _MODEL_NORMAL_MATRIX, vec3 _NORMAL) {
	return abs(_MODEL_NORMAL_MATRIX * _NORMAL);
}

float get_height_val(vec3 _world_normal, sampler2D _height_map, vec3 _world_position, float _height_texture_scale) {
	// 1. Normalize the weights so they always add up to 1.0
    vec3 weights = _world_normal / (_world_normal.x + _world_normal.y + _world_normal.z);

    // 2. Sample from three directions using World Position
    // This ensures that even if you move/rotate the wall, the texture stays pinned to the world
    float x_tex = texture(_height_map, _world_position.zy * _height_texture_scale).r;
    float y_tex = texture(_height_map, _world_position.xz * _height_texture_scale).r;
    float z_tex = texture(_height_map, _world_position.xy * _height_texture_scale).r;
    
    // 3. Blend them
    return (x_tex * weights.x) + (y_tex * weights.y) + (z_tex * weights.z);
}

vec3 get_emission(
		vec3 _origin, 
		vec3 _world_position,
		float _height_val,
		float _height_bump_strength,
		float _radius,
		float _echo_ring_width,
		float _echo_ring_intensity,
		float _echo_ring_afterglow_width,
		float _echo_ring_afterglow_intensity,
		vec4 _color,
		float _height_after_glow_affect,
		vec3 _EMISSION
	) {
	float dist = distance(_origin, _world_position);
	dist = dist - (_height_val * _height_bump_strength);

	float echo_ring_strength = 1.0 - smoothstep(_radius - 0.1, _radius, dist);
	echo_ring_strength *= smoothstep(_radius - _echo_ring_width, _radius, dist);
	echo_ring_strength *= _echo_ring_intensity;
	
	float afterglow_strength = 1.0 - step(_radius, dist);
	afterglow_strength *= smoothstep(_radius - _echo_ring_afterglow_width, _radius, dist);
	afterglow_strength *= _echo_ring_afterglow_intensity;
	
	float echo_strength = (echo_ring_strength + afterglow_strength) * _color.a;
	echo_strength -= (1.0 - _height_val) * echo_strength * _height_after_glow_affect;
	
	return max(_EMISSION, _color.rgb * echo_strength);
}