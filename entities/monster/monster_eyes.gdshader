shader_type spatial;

uniform vec3 pupil_color : source_color;

void fragment() {
	ALBEDO = vec3(0);
	EMISSION = pupil_color.rgb;
}
