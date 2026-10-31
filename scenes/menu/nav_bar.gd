class_name NavBar
extends Control

signal tab_selected(index: int)

const OUTLINE := Color("#253047")
const PANEL := Color("#3A4766")
const ACTIVE := Color("#A45CDA")
const TABS: Array[Dictionary] = [
	{"id": "shop", "title": "Boutique"},
	{"id": "inventory", "title": "Inventaire"},
	{"id": "home", "title": "Accueil"},
	{"id": "hero", "title": "Héros"},
	{"id": "spells", "title": "Grimoire"},
]
const HOME_TAB := 2

var current := HOME_TAB

var _lift: Array[float] = []
var _panel_style: StyleBoxFlat
var _active_style: StyleBoxFlat


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_STOP
	for tab in TABS.size():
		_lift.append(1.0 if tab == current else 0.0)
	_panel_style = _box(PANEL, 0)
	_panel_style.corner_radius_top_left = 30
	_panel_style.corner_radius_top_right = 30
	_active_style = _box(ACTIVE, 22)


func _process(delta: float) -> void:
	var weight := minf(1.0, 14.0 * delta)
	for tab in TABS.size():
		_lift[tab] = lerpf(_lift[tab], 1.0 if tab == current else 0.0, weight)
	queue_redraw()


func select(index: int) -> void:
	if index == current:
		return
	current = index
	tab_selected.emit(index)


func _gui_input(event: InputEvent) -> void:
	var press := event as InputEventMouseButton
	if press == null or not press.pressed or press.button_index != MOUSE_BUTTON_LEFT:
		return
	accept_event()
	select(clampi(int(press.position.x / _tab_width()), 0, TABS.size() - 1))


func _tab_width() -> float:
	return size.x / TABS.size()


func _draw() -> void:
	draw_style_box(_panel_style, Rect2(Vector2(-6, 0), size + Vector2(12, 12)))
	var font := get_theme_default_font()
	var width := _tab_width()
	for tab in TABS.size():
		var lift := _lift[tab]
		var center := Vector2(width * (tab + 0.5), size.y * 0.42 - lift * 26.0)
		if lift > 0.02:
			var box_size := Vector2(width - 10.0, size.y * 0.8) * lerpf(0.7, 1.0, lift)
			draw_style_box(_active_style, Rect2(center - box_size / 2.0 + Vector2(0, 12), box_size))
		MenuIcons.draw(self, TABS[tab].id, center, lerpf(58.0, 76.0, lift))
		var title: String = TABS[tab].title
		var baseline := Vector2(width * tab, size.y * 0.9 - lift * 14.0)
		var color := Color.WHITE if lift > 0.5 else Color(1, 1, 1, 0.6)
		draw_string_outline(font, baseline, title, HORIZONTAL_ALIGNMENT_CENTER, width, 20, 8, OUTLINE)
		draw_string(font, baseline, title, HORIZONTAL_ALIGNMENT_CENTER, width, 20, color)


func _box(color: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = OUTLINE
	style.set_border_width_all(4)
	style.set_corner_radius_all(radius)
	return style
