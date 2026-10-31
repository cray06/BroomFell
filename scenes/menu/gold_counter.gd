class_name GoldCounter
extends Control

const OUTLINE := Color("#253047")
const PANEL := Color("#3A4766")
const GOLD := Color("#FFE6A1")

var _amount := 0
var _panel_style: StyleBoxFlat


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	_panel_style = StyleBoxFlat.new()
	_panel_style.bg_color = Color(PANEL, 0.92)
	_panel_style.border_color = OUTLINE
	_panel_style.set_border_width_all(4)
	_panel_style.set_corner_radius_all(22)
	set_amount(SaveData.gold(), false)


func set_amount(amount: int, animated: bool = true) -> void:
	_amount = amount
	queue_redraw()
	if animated:
		pivot_offset = size / 2.0
		var tween := create_tween()
		tween.tween_property(self, "scale", Vector2(1.18, 1.18), 0.08)
		tween.tween_property(self, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _draw() -> void:
	var half := size.y / 2.0
	draw_style_box(_panel_style, Rect2(Vector2(half, 8), Vector2(size.x - half, size.y - 16)))
	MenuIcons.draw(self, "coin", Vector2(half, half), size.y * 0.95)
	var font := get_theme_default_font()
	var at := Vector2(size.y + 2.0, half + 11.0)
	var width := size.x - size.y - 14.0
	var text := str(_amount)
	draw_string_outline(font, at, text, HORIZONTAL_ALIGNMENT_RIGHT, width, 30, 10, OUTLINE)
	draw_string(font, at, text, HORIZONTAL_ALIGNMENT_RIGHT, width, 30, GOLD)
