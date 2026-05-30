shader_type canvas_item;

uniform vec2 position = vec2(0.5, 0.5);
uniform float radius = 0.0;
uniform float borderWidth = 0.02;
uniform float burnMult = 0.135;
uniform sampler2D noiseTexture;
uniform vec4 burnColor : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	COLOR = texture(TEXTURE, UV);

	float dist = length(position - UV) + texture(noiseTexture, UV).b * burnMult;

	float burned = float(dist < radius);
	float border = float(dist < radius + borderWidth);

	COLOR.rgb = mix(COLOR.rgb, burnColor.rgb, border);
	COLOR.a = mix(COLOR.a, burnColor.a, burned);
}