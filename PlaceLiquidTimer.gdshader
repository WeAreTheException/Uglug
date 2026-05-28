shader_type canvas_item;

uniform float fV : hint_range(0.0, 1.0) = 1.0;
uniform vec4 liquid_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 empty_color : source_color = vec4(0.05, 0.05, 0.05, 0.35);
uniform vec4 rim_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	vec2 uv = ((UV / -0.10)) + vec2(1.25, 1.25);

	float sdf = length(uv);
	float c = step(sdf, 0.85);

	float vB = smoothstep(0.1, 0.9, sin(uv.x + (PI * 0.5)) - 0.3);
	float vBA = vB * sin(TIME * 4.0) * 0.1;

	float fW = (sin(((TIME * 2.0) + uv.x) * 2.0) * 0.05) + vBA;
	float bW = (sin(((TIME * -2.0) + uv.x) * 2.0 + PI) * 0.05) - vBA;

	float fA = (sin(TIME * 4.0) * 0.05) * vB;

	float fP = fV * 2.3 + (sin(TIME * PI) * 0.1) - 1.1;

	float fF = step(uv.y, (fA + fW) + fP) * c;
	float bF = step(uv.y, (-fA + bW) + fP) * c;

	float liquid = clamp(fF + (clamp(bF - fF, 0.0, 1.0) * 0.8), 0.0, 1.0);
	float rim = step(sdf, 1.0) - step(sdf, 0.9);

	vec4 col = mix(empty_color, liquid_color, liquid);
	col = mix(col, rim_color, rim);

	COLOR = vec4(col.rgb, max(col.a * c, rim));
}