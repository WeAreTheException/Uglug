shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 secondary_color : source_color = vec4(0.25, 0.6, 1.0, 1.0);

uniform float color_speed : hint_range(0.0, 5.0) = 0.8;
uniform float color_scale : hint_range(0.1, 10.0) = 2.0;

uniform float pulse_speed : hint_range(0.0, 10.0) = 2.0;
uniform float pulse_strength : hint_range(0.0, 1.0) = 0.15;

uniform float shimmer_speed : hint_range(0.0, 10.0) = 1.5;
uniform float shimmer_width : hint_range(0.01, 1.0) = 0.15;
uniform float shimmer_strength : hint_range(0.0, 3.0) = 0.5;


void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	float color_wave = sin(
		(UV.x + UV.y) * color_scale
		+ TIME * color_speed
	);

	color_wave = color_wave * 0.5 + 0.5;

	vec3 animated_color = mix(
		outline_color.rgb,
		secondary_color.rgb,
		color_wave
	);

	float pulse = sin(TIME * pulse_speed) * 0.5 + 0.5;
	pulse = mix(1.0, 1.0 + pulse_strength, pulse);

	float shimmer_position = fract(
		TIME * shimmer_speed * 0.2
	);

	float shimmer_distance = abs(
		(UV.x + UV.y) * 0.5
		- shimmer_position
	);

	float shimmer = 1.0 - smoothstep(
		0.0,
		shimmer_width,
		shimmer_distance
	);

	animated_color *= pulse;
	animated_color += shimmer * shimmer_strength;

	float final_alpha = tex.a
		* outline_color.a
		* secondary_color.a;

	COLOR = vec4(
		animated_color,
		final_alpha
	);
}