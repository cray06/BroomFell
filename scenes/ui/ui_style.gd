class_name UiStyle
extends RefCounted

const OUTLINE := Color("#253047")


static func style_button(button: Button, color: Color, font_size: int = 38) -> void:
	button.add_theme_stylebox_override("normal", _box(color))
	button.add_theme_stylebox_override("hover", _box(color.lightened(0.15)))
	button.add_theme_stylebox_override("pressed", _box(color.darkened(0.25)))
	button.add_theme_stylebox_override("disabled", _box(color.darkened(0.15)))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		button.add_theme_color_override(state, Color.WHITE)
	button.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.7))
	button.add_theme_color_override("font_outline_color", OUTLINE)
	button.add_theme_constant_override("outline_size", 12)
	button.add_theme_font_size_override("font_size", font_size)


static func _box(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = OUTLINE
	style.set_border_width_all(5)
	style.set_corner_radius_all(22)
	style.shadow_color = Color(OUTLINE, 0.5)
	style.shadow_offset = Vector2(0, 6)
	style.set_content_margin_all(12)
	return style
