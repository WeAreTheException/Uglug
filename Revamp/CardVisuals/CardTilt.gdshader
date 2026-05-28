shader_type canvas_item;

uniform vec2 rect_size = vec2(144.0, 216.0);

// Camera FOV
uniform float fov : hint_range(1, 179) = 90.0;

uniform bool cull_back = true;

uniform float y_rot : hint_range(-360.0, 360.0) = 0.0;
uniform float x_rot : hint_range(-360.0, 360.0) = 0.0;

// At 0, image keeps original size.
// At 1, shrinks to avoid clipping during rotation.
uniform float inset : hint_range(0.0, 1.0) = 0.0;

varying flat vec2 offset;
varying vec3 projection;


void vertex() {
	float sin_y = sin(y_rot * PI / 180.0);
	float cos_y = cos(y_rot * PI / 180.0);

	float sin_x = sin(x_rot * PI / 180.0);
	float cos_x = cos(x_rot * PI / 180.0);

	mat3 rotation;

	rotation[0][0] = cos_y;
	rotation[0][1] = 0.0;
	rotation[0][2] = -sin_y;

	rotation[1][0] = sin_y * sin_x;
	rotation[1][1] = cos_x;
	rotation[1][2] = cos_y * sin_x;

	rotation[2][0] = sin_y * cos_x;
	rotation[2][1] = -sin_x;
	rotation[2][2] = cos_y * cos_x;

	float tangent = tan(fov * PI / 360.0);

	projection = rotation * vec3(UV - 0.5, 0.5 / tangent);

	float scale = (0.5 / tangent) + 0.5;

	projection.xy *= scale * rotation[2].z;

	offset = scale * rotation[2].xy;

	VERTEX += (UV - 0.5) * rect_size * tangent * (1.0 - inset);
}


void fragment() {
	if (cull_back && projection.z <= 0.0) {
		discard;
	}

	vec2 uv = (projection.xy / projection.z).xy - offset;

	COLOR = texture(TEXTURE, uv + 0.5);

	COLOR.a *= step(max(abs(uv.x), abs(uv.y)), 0.5);
}