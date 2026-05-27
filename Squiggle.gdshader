shader_type canvas_item;

uniform float strength : hint_range(0.0, 0.02) = 0.004;
uniform float speed : hint_range(0.0, 20.0) = 6.0;
uniform float amount : hint_range(1.0, 80.0) = 28.0;

void fragment() {
	vec2 uv = UV;

	float t = floor(TIME * speed);

	float wiggle_x = sin((uv.y * amount) + t) * strength;
	float wiggle_y = cos((uv.x * amount) + t * 1.37) * strength;

	vec2 squiggle_uv = uv + vec2(wiggle_x, wiggle_y);

	COLOR = texture(TEXTURE, squiggle_uv) * COLOR;
}