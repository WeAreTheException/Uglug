shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;

uniform float grain_amount : hint_range(0.0, 0.25) = 0.035;
uniform float grain_size : hint_range(0.5, 8.0) = 1.5;
uniform float grain_speed : hint_range(0.0, 60.0) = 24.0;


float random_noise(vec2 position, float seed) {
	return fract(
		sin(dot(position, vec2(12.9898, 78.233)) + seed)
		* 43758.5453
	);
}


void fragment() {
	vec4 screen_color = texture(screen_texture, SCREEN_UV);

	vec2 pixel_position = SCREEN_UV / SCREEN_PIXEL_SIZE;
	vec2 grain_position = floor(pixel_position / grain_size);

	float animation_frame = floor(TIME * grain_speed);

	float noise = random_noise(grain_position, animation_frame);
	noise = noise * 2.0 - 1.0;

	screen_color.rgb += noise * grain_amount;

	COLOR = vec4(
		clamp(screen_color.rgb, vec3(0.0), vec3(1.0)),
		screen_color.a
	);
}