shader_type canvas_item;

uniform vec4 color_gap : source_color = vec4(0.0, 0.0, 0.0, 0.0);
uniform vec4 color_stripe : source_color = vec4(1.0, 0.82, 0.35, 0.45);

uniform float shine_progress : hint_range(0.0, 1.0) = 0.0;
uniform float stripe_width : hint_range(0.01, 0.5) = 0.16;
uniform float softness : hint_range(0.001, 0.3) = 0.08;
uniform float alpha_strength : hint_range(0.0, 1.0) = 0.45;

void fragment() {
	vec4 text_sample = texture(TEXTURE, UV);
	float text_alpha = text_sample.a;

	// 0.0 = top of text, 1.0 = bottom of text.
	float line_position = UV.y;

	// Starts above the text and travels downward.
	float stripe_center = mix(-stripe_width, 1.0 + stripe_width, shine_progress);

	float distance_from_stripe = abs(line_position - stripe_center);

	float stripe_mask = 1.0 - smoothstep(
		stripe_width,
		stripe_width + softness,
		distance_from_stripe
	);

	vec4 final_color = mix(color_gap, color_stripe, stripe_mask);

	COLOR.rgb = final_color.rgb;
	COLOR.a = text_alpha * final_color.a * alpha_strength;
}