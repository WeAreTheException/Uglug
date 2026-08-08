shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float spiral_turns : hint_range(1.0, 10.0) = 4.0;
uniform float edge_softness : hint_range(0.001, 0.1) = 0.015;
uniform bool reverse = false;

void fragment() {
	vec2 p = UV - vec2(0.5);

	// Correct for widescreen aspect ratio.
	float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	p.x *= aspect;

	float radius = length(p);
	float angle = atan(p.y, p.x);

	// Convert angle into roughly 0.0 -> 1.0.
	float angle_normalized = angle / TAU + 0.5;

	// Procedural spiral.
	float spiral_value = fract(
		angle_normalized
		+ radius * spiral_turns
	);

	float current_progress = progress;

	if (reverse) {
		current_progress = 1.0 - current_progress;
	}

	float mask = smoothstep(
		current_progress - edge_softness,
		current_progress + edge_softness,
		spiral_value
	);

	mask = 1.0 - mask;

	// Guarantee clean fully-visible / fully-black endpoints.
	if (current_progress <= 0.0) {
		mask = 0.0;
	}

	if (current_progress >= 1.0) {
		mask = 1.0;
	}

	COLOR = vec4(0.0, 0.0, 0.0, mask);
}