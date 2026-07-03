shader_type canvas_item;

group_uniforms Sway;

// The amplitude of the wave.
uniform float waveAmplitude : hint_range(0.0, 1.0) = 0.033;

// If true corrects the vertices to adjust for the UV displacement.
uniform bool correctVertex = true;

// The frequency of the wave.
uniform float waveFrequency : hint_range(0.0, 100.0) = 0.0;

// If true the texture waves vertically, otherwise horizontally.
uniform bool verticalWave = true;

// If true the sprite will deform to match the waves, otherwise we keep the background color clamped.
uniform bool keepTransparency = true;

// If true the TIME constant is used, otherwise progress is used to move the wave.
uniform bool useTime = true;

// If useTime is true then use this as a multiplier for the wave speed.
uniform float waveSpeed : hint_range(0.0, 100.0) = 1.0;

// If useTime is false then use this as a multiplier for the wave progress.
uniform float progress : hint_range(0.0, 1.0) = 0.0;

// How much of the left or top half of the texture is modified.
uniform float firstHalf : hint_range(0.0, 1.0) = 0.5;

// How much of the right or bottom half of the texture is modified.
uniform float secondHalf : hint_range(0.0, 1.0) = 0.5;

// Keeps one half stuck. Useful for things like flags.
uniform bool freezeFirstHalf = false;

// Keeps one half stuck. Useful for things like flags.
uniform bool freezeSecondHalf = false;


group_uniforms ChromaticAberration;

uniform vec2 r_displacement = vec2(3.0, 0.0);
uniform vec2 g_displacement = vec2(0.0, 0.0);
uniform vec2 b_displacement = vec2(-3.0, 0.0);

uniform float alpha_multiplier : hint_range(0.0, 1.0, 0.01) = 1.0;


group_uniforms;


void vertex() {
	if (correctVertex) {
		if (verticalWave) {
			VERTEX = vec2(VERTEX.x, VERTEX.y * (1.0 + waveAmplitude));
		} else {
			VERTEX = vec2(VERTEX.x * (1.0 + waveAmplitude), VERTEX.y);
		}
	}
}


vec2 get_swayed_uv(vec2 source_uv, vec2 texture_pixel_size) {
	vec2 uv = source_uv;

	float waveUv = verticalWave ? uv.x : uv.y;
	float againstWaveUv = verticalWave ? uv.y : uv.x;

	bool should_wave = againstWaveUv < firstHalf || againstWaveUv > 1.0 - secondHalf;

	if (!should_wave) {
		return uv;
	}

	float freezeFactor = 1.0;

	if (freezeFirstHalf) {
		freezeFactor = waveUv;
	} else if (freezeSecondHalf) {
		freezeFactor = 1.0 - waveUv;
	}

	float wave = 0.0;

	if (useTime) {
		wave = freezeFactor * sin(waveUv * waveFrequency + TIME * waveSpeed) * (waveAmplitude / 4.0);
	} else {
		wave = freezeFactor * sin(waveUv * waveFrequency + progress * 2.0 * PI) * (waveAmplitude / 4.0);
	}

	vec2 aspect = vec2(texture_pixel_size.x / texture_pixel_size.y, 1.0);
	vec2 center = 0.5 * aspect;

	uv -= center;

	if (verticalWave) {
		uv.y += wave;
		uv.y += uv.y * waveAmplitude;
	} else {
		uv.x += wave;
		uv.x += uv.x * waveAmplitude;
	}

	uv += center;

	return clamp(uv, vec2(0.0), vec2(1.0));
}


void fragment() {
	vec2 pixel_size = TEXTURE_PIXEL_SIZE;
	vec2 swayed_uv = get_swayed_uv(UV, pixel_size);

	float againstWaveUv = verticalWave ? swayed_uv.y : swayed_uv.x;

	bool should_hide_transparency = false;

	if (keepTransparency) {
		if (againstWaveUv <= 0.0 || againstWaveUv >= 1.0) {
			should_hide_transparency = true;
		}
	}

	if (should_hide_transparency) {
		COLOR = vec4(0.0);
	} else {
		float r = texture(TEXTURE, swayed_uv + pixel_size * r_displacement).r;
		float g = texture(TEXTURE, swayed_uv + pixel_size * g_displacement).g;
		float b = texture(TEXTURE, swayed_uv + pixel_size * b_displacement).b;

		float a = texture(TEXTURE, swayed_uv).a * alpha_multiplier;

		COLOR = vec4(r, g, b, a);
	}
}