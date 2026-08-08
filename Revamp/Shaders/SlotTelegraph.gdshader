shader_type canvas_item;

uniform float cone_angle : hint_range(1.0, 180.0) = 60.0;
uniform float max_distance : hint_range(0.1, 1.0) = 1.0;
uniform float edge_softness : hint_range(0.0, 0.2) = 0.05;

uniform float wave_density : hint_range(1.0, 20.0) = 8.0;
uniform float wave_speed : hint_range(0.1, 10.0) = 4.0;
uniform float wave_strength : hint_range(0.0, 1.0) = 0.4;

uniform float intensity : hint_range(0.0, 2.0) = 1.0;
uniform vec4 color : source_color = vec4(1.0, 0.25, 0.25, 1.0);

void fragment() {
    vec2 uv = UV;

    float y = uv.y;
    float x = abs(uv.x - 0.5) * 2.0;

    if (y > max_distance) {
        discard;
    }

    float max_width = y * tan(radians(cone_angle * 0.5));

    float cone_edge = 1.0 - smoothstep(
        max_width - edge_softness,
        max_width,
        x
    );

    float distance_fade = 1.0 - (y / max_distance);

    float wave = sin(
        (y * wave_density - TIME * wave_speed) * TAU
    );

    wave = wave * 0.5 + 0.5;

    float energy = mix(1.0, wave, wave_strength);
    float alpha = cone_edge * distance_fade * energy * intensity;

    COLOR = vec4(
        color.rgb * (1.0 + alpha * 1.5),
        color.a * alpha
    );
}
