shader_type canvas_item;

uniform vec4 color_gap : source_color = vec4(0.0, 0.0, 0.0, 0.0);
uniform vec4 color_stripe : source_color = vec4(1.0, 0.85, 0.1, 1.0);

uniform float divisions = 8.0;
uniform float speed = 0.05;
uniform float angle = 1.0;

uniform float stripe_width : hint_range(0.01, 1.0) = 1.0;
uniform float alpha_strength : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 text_sample = texture(TEXTURE, UV);
	float text_alpha = text_sample.a;

	float w = cos(angle) * UV.x + sin(angle) * UV.y;
	w -= TIME * speed;

	float pattern = fract(w * divisions);

	float inside_stripe = step(pattern, stripe_width);
	float stripe_uv = clamp(pattern / stripe_width, 0.0, 1.0);

	float soft_edge = smoothstep(1.0, 0.0, stripe_uv);
	float stripe_mask = inside_stripe * soft_edge;

	vec4 stripe_color = mix(
		color_gap,
		color_stripe,
		stripe_mask
	);

	COLOR.rgb = stripe_color.rgb;
	COLOR.a = text_alpha * stripe_color.a * alpha_strength;
}