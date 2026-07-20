shader_type canvas_item;

uniform vec4 color_gap : source_color = vec4(0.25, 0.25, 0.25, 0.0);
uniform vec4 color_stripe : source_color = vec4(1.0, 0.75, 0.0, 1.0);

uniform sampler2D stripe_gradient;

uniform float divisions = 8.0;
uniform float speed = 0.1;
uniform float angle = 0.7854;

uniform float stripe_width : hint_range(0.01, 1.0) = 0.5;

void fragment() {
	// Preserve the RichTextLabel character shape.
	vec4 text_texture = texture(TEXTURE, UV);

	// Rotate and animate UVs.
	float w = cos(angle) * UV.x + sin(angle) * UV.y;
	w -= TIME * speed;

	float pattern = fract(w * divisions);
	float stripe_uv = pattern / stripe_width;
	float inside_stripe = step(pattern, stripe_width);

	float gradient_alpha = texture(
		stripe_gradient,
		vec2(clamp(stripe_uv, 0.0, 1.0), 0.5)
	).r;

	float stripe_mask = inside_stripe * gradient_alpha;

	vec4 shine_color = mix(
		color_gap,
		color_stripe,
		stripe_mask
	);

	// Keep the shader inside the visible text.
	COLOR = shine_color;
	COLOR.a *= text_texture.a;
}