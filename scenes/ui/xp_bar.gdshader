shader_type canvas_item;

uniform float ratio = 0.0;
uniform float rainbow = 0.0;
uniform vec2 rect_size = vec2(600.0, 24.0);
uniform vec4 fill_color : source_color = vec4(0.643, 0.361, 0.855, 1.0);
uniform vec4 track_color : source_color = vec4(0.227, 0.278, 0.388, 1.0);

vec3 hue(float h) {
	return clamp(abs(mod(h * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
}

float rounded_box(vec2 p, vec2 half_size, float r) {
	vec2 q = abs(p) - half_size + vec2(r);
	return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

void fragment() {
	vec2 p = UV * rect_size;
	float d = rounded_box(p - rect_size * 0.5, rect_size * 0.5, rect_size.y * 0.5);
	float mask = clamp(0.5 - d, 0.0, 1.0);

	float top_light = step(UV.y, 0.38);
	vec3 fill = mix(fill_color.rgb, vec3(1.0), top_light * 0.25);

	vec3 rb = hue(fract(UV.x * 1.2 - TIME * 0.8));
	rb = mix(rb, vec3(1.0), 0.15 + top_light * 0.3);
	float sweep_x = fract(TIME * 0.7) * 1.6 - 0.3;
	float sweep = 1.0 - smoothstep(0.0, 0.05, abs(UV.x - sweep_x + (UV.y - 0.5) * 0.08));
	rb += sweep * 0.6;

	fill = mix(fill, rb, rainbow);
	float filled = step(UV.x, max(ratio, rainbow));
	COLOR = vec4(mix(track_color.rgb, fill, filled), mask);
}
