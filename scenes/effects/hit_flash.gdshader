shader_type canvas_item;

// Teinte le sprite d'une couleur unie (flash blanc quand il est touché).
uniform vec4 flash_color : source_color = vec4(1.0);
uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;
// 1 = inverse rouge et vert (slime vert -> slime rouge, contours intacts).
uniform float swap_red_green : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 base = texture(TEXTURE, UV) * COLOR;
	base.rgb = mix(base.rgb, base.grb, swap_red_green);
	COLOR = vec4(mix(base.rgb, flash_color.rgb, flash_amount), base.a);
}
