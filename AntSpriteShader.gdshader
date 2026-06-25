shader_type canvas_item;

uniform vec2 r_displacement = vec2(3.0, 0.0);
uniform vec2 g_displacement = vec2(0.0, 0.0);
uniform vec2 b_displacement = vec2(-3.0, 0.0);

uniform float alpha_multiplier : hint_range(0.0, 1.0, 0.01) = 1.0;

void fragment()
{
	vec2 pixel_size = TEXTURE_PIXEL_SIZE;

	float r = texture(TEXTURE, UV + pixel_size * r_displacement).r;
	float g = texture(TEXTURE, UV + pixel_size * g_displacement).g;
	float b = texture(TEXTURE, UV + pixel_size * b_displacement).b;

	float a = texture(TEXTURE, UV).a * alpha_multiplier;

	COLOR = vec4(r, g, b, a);
}