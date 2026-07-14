shader_type canvas_item;

uniform vec4 force_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float force_amount : hint_range(0.0, 1.0) = 0.0;

uniform float strength : hint_range(0.0, 0.02) = 0.004;
uniform float speed : hint_range(0.0, 20.0) = 6.0;
uniform float amount : hint_range(1.0, 80.0) = 28.0;

void fragment() {
	vec2 uv = UV;

	float t = floor(TIME * speed);

	float wiggle_x = sin((uv.y * amount) + t) * strength;
	float wiggle_y = cos((uv.x * amount) + t * 1.37) * strength;

	vec2 squiggle_uv = uv + vec2(wiggle_x, wiggle_y);

	vec4 tex_color = texture(TEXTURE, squiggle_uv) * COLOR;
	vec4 colored = vec4(force_color.rgb, tex_color.a);

	COLOR = mix(tex_color, colored, force_amount);
}