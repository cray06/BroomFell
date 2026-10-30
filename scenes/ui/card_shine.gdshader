shader_type canvas_item;

// Reflet diagonal qui balaie une carte aux coins arrondis.
uniform vec2 rect_size = vec2(200.0, 330.0);
uniform float radius = 22.0;
uniform float inset = 5.0;
uniform float progress = -1.0;

float rounded_box(vec2 p, vec2 half_size, float r) {
	vec2 q = abs(p) - half_size + vec2(r);
	return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

void fragment() {
	vec2 p = UV * rect_size - rect_size * 0.5;
	float d = rounded_box(p, rect_size * 0.5 - vec2(inset), radius - inset);
	float inside = clamp(0.5 - d, 0.0, 1.0);
	float x = UV.x + (1.0 - UV.y) * 0.35;
	float band = 1.0 - smoothstep(0.0, 0.07, abs(x - progress));
	float thin = 1.0 - smoothstep(0.0, 0.015, abs(x - progress - 0.11));
	COLOR = vec4(1.0, 1.0, 1.0, (band * 0.4 + thin * 0.3) * inside);
}
