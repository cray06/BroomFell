class_name ComingSoonPage
extends Control

const OUTLINE := Color("#253047")
const PANEL := Color("#3A4766")
const LIGHT := Color("#FFE6A1")

var title := ""
var icon_id := ""

var _time := 0.0
var _panel_style: StyleBoxFlat


func _init(page_title: String = "", page_icon: String = "") -> void:
	title = page_title
	icon_id = page_icon


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	_panel_style = StyleBoxFlat.new()
	_panel_style.bg_color = Color(PANEL, 0.92)
	_panel_style.border_color = OUTLINE
	_panel_style.set_border_width_all(5)
	_panel_style.set_corner_radius_all(36)
	_panel_style.shadow_color = Color(OUTLINE, 0.45)
	_panel_style.shadow_offset = Vector2(0, 8)


func _process(delta: float) -> void:
	if is_visible_in_tree():
		_time += delta
		queue_redraw()


func _draw() -> void:
	var font := get_theme_default_font()
	var panel := Rect2(Vector2(40, size.y * 0.2), Vector2(size.x - 80, size.y * 0.5))
	draw_style_box(_panel_style, panel)
	_text(font, Vector2(0, panel.position.y + 76), title, 54, Color.WHITE)
	var icon_at := panel.get_center() + Vector2(0, -10 + sin(_time * 2.0) * 8.0)
	MenuIcons.draw(self, icon_id, icon_at, 170.0)
	var pulse := 1.0 + sin(_time * 3.0) * 0.04
	_text(font, Vector2(0, panel.end.y - 90), "À VENIR", int(64 * pulse), LIGHT)
	_text(font, Vector2(0, panel.end.y - 40), "Cette section arrive bientôt !", 26, Color(1, 1, 1, 0.75))


func _text(font: Font, baseline: Vector2, text: String, font_size: int, color: Color) -> void:
	draw_string_outline(font, baseline, text, HORIZONTAL_ALIGNMENT_CENTER, size.x, font_size, int(font_size / 3.0), OUTLINE)
	draw_string(font, baseline, text, HORIZONTAL_ALIGNMENT_CENTER, size.x, font_size, color)
