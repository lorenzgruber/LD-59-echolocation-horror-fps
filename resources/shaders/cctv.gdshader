shader_type canvas_item;

uniform sampler2D distort_noise : hint_default_black, repeat_enable;

uniform int scanline_count : hint_range(0, 200) = 100; // amount of scanlines on the screen
uniform float scanline_speed : hint_range(0, 50.0) = 5.0; // scrolling speed of the scanlines
uniform float scanline_alpha : hint_range(0, 1.0) = 1.0; // opacity of the scanlines

uniform sampler2D noise_overlay : hint_default_black, repeat_enable; // texture for the noise overlay
uniform float noise_strength : hint_range(0, 0.1) = 0.01; // strength of the noise overlay

uniform float brightness : hint_range(0, 1.0, 0.1) = 0.6; // modifies the overall brigthness of the final color
uniform vec3 color_multiplier = vec3(0.4, 0.3, 1.0); // modifies the RGB channels of the final color, default = blue

uniform float alpha : hint_range(0.0, 1.0) = 1.0; // opacity of the entire shader effect

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

vec2 uv_curve(vec2 uv)
{
	uv = (uv - 0.5) * 2.0;

	uv.x *= 1.0 + pow(abs(uv.y) / 3.0, 2.0);
	uv.y *= 1.0 + pow(abs(uv.x) / 3.0, 2.0);

	uv /= 1.2;

	uv = (uv/2.0) + 0.5;
	return uv;
}

void fragment() {
	vec4 alpha_vec = vec4(vec3(1.0), alpha);
	vec2 uv = SCREEN_UV;
	vec2 curved_uv = uv_curve(SCREEN_UV);

    // Here we sample a noise texture and use each of its color channels to shift the UV of the screen texture
    // Additionally we also shift the UV downward over time to get a scrolling distortion effect.
	vec2 distort_scroll_UV = SCREEN_UV - vec2(0, TIME * scanline_speed * 0.005);
	vec4 distort_col = texture(distort_noise, distort_scroll_UV);
	vec2 distort_offset = vec2(distort_col.r, distort_col.g) * distort_col.b * 0.01;

	// Here we shift the RGB color channels in different directions to achieve a chromatic aberration effect
	vec2 scale = vec2(textureSize(SCREEN_TEXTURE, 1));
	float dist_to_center = distance(SCREEN_UV, vec2(0.5)) * 2.0;
	vec2 UV_r = SCREEN_UV - vec2(1, 0) / scale * dist_to_center;
	vec2 UV_g = SCREEN_UV - vec2(3, -5) / scale * dist_to_center;
	vec2 UV_b = SCREEN_UV - vec2(0, 0) / scale * dist_to_center;
	float distort_r = texture(SCREEN_TEXTURE, UV_r).r;
	float distort_g = texture(SCREEN_TEXTURE, UV_g).g;
	float distort_b = texture(SCREEN_TEXTURE, UV_b).b;

	// We get the final color by merging the RGB values back into one color.
    vec4 blurred_col = vec4(distort_r, distort_g, distort_b, 1.0);

	// Here we stack noise textures moving in different directions to get "random" moving noise which we overlay with the screen color.
	vec4 noise_col_1 = texture(noise_overlay, UV + vec2(0.05, 0.05) * TIME) * noise_strength;
	vec4 noise_col_2 = texture(noise_overlay, UV + vec2(-0.05, 0.05) * TIME) * noise_strength;
	vec4 noise_col_3 = texture(noise_overlay, UV + vec2(0.05, -0.05) * TIME) * noise_strength;
	vec4 noise_col_4 = texture(noise_overlay, UV + vec2(-0.05, -0.05) * TIME) * noise_strength;
	vec4 noise_col = noise_col_1 + noise_col_2 + noise_col_3 + noise_col_4;

	blurred_col.rgb *= brightness;
	blurred_col.rgb *= color_multiplier;

	// scanline effect from: https://godotshaders.com/shader/retro-tv-shader/
	float s = sin(uv_curve(SCREEN_UV).y * float(scanline_count) * PI * 2.0 - TIME * scanline_speed);
	s = (s * 0.5 + 0.5) * 0.9 + 0.1;
	vec4 scan_line = vec4(vec3(pow(s, 0.25 * scanline_alpha)), 1.0);

	COLOR = blurred_col * scan_line * alpha_vec + noise_col;
}