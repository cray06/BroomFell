shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float blur_amount : hint_range(0.0, 5.0) = 2.5;
uniform vec4 tint : source_color = vec4(0.145, 0.188, 0.278, 0.4);

void fragment() {
	vec3 background = textureLod(screen_texture, SCREEN_UV, blur_amount).rgb;
	COLOR = vec4(mix(background, tint.rgb, tint.a), 1.0);
}
