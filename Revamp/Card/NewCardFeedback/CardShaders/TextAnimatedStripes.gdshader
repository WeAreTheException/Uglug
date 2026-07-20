shader_type canvas_item;

uniform vec4 color_gap : source_color = vec4(0.0, 0.0, 0.0, 0.0);
uniform vec4 color_stripe : source_color = vec4(1.0, 0.82, 0.35, 0.45);

uniform bool animate_automatically = true;

uniform float shine_progress : hint_range(0.0, 1.0) = 0.0;
uniform float shine_speed : hint_range(-5.0, 5.0) = -0.35;

uniform float stripe_width : hint_range(0.01, 0.5) = 0.16;
uniform float softness : hint_range(0.001, 0.3) = 0.08;
uniform float alpha_strength : hint_range(0.0, 1.0) = 0.45;

// Adjust these to match where the visible text sits inside the label.
uniform float travel_top : hint_range(0.0, 1.0) = 0.15;
uniform float travel_bottom : hint_range(0.0, 1.0) = 0.85;

void fragment() {
    vec4 text_sample = texture(TEXTURE, UV);
    float text_alpha = text_sample.a;

    float active_progress = shine_progress;

    if (animate_automatically) {
        float loop_progress = fract(TIME * abs(shine_speed));

        if (shine_speed < 0.0) {
            active_progress = 1.0 - loop_progress;
        } else {
            active_progress = loop_progress;
        }
    }

    float line_position = UV.y;
    float stripe_extent = stripe_width + softness;

    float stripe_center = mix(
        travel_top - stripe_extent,
        travel_bottom + stripe_extent,
        active_progress
    );

    float distance_from_stripe = abs(line_position - stripe_center);

    float stripe_mask = 1.0 - smoothstep(
        stripe_width,
        stripe_width + softness,
        distance_from_stripe
    );

    vec4 final_color = mix(
        color_gap,
        color_stripe,
        stripe_mask
    );

    COLOR.rgb = final_color.rgb;
    COLOR.a = text_alpha * final_color.a * alpha_strength;
}