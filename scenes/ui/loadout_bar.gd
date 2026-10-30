class_name LoadoutBar
extends Control

const OUTLINE := Color("#253047")
const CREAM := Color("#FFF6E0")
const NIGHT := Color("#2E3A55")
const LIGHT := Color("#FFE6A1")
const SLOT_RADIUS := 30.0
const SLOT_GAP := 12.0
const GROUP_GAP := 30.0

var _spells: Array = []
var _augments: Array = []


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE


func refresh(snapshot: Dictionary) -> void:
	_spells = snapshot.spells
	_augments = snapshot.augments
	queue_redraw()


func _draw() -> void:
	var slot := SLOT_RADIUS * 2.0
	var total := slot * 6.0 + SLOT_GAP * 4.0 + GROUP_GAP
	var x := (size.x - total) / 2.0 + SLOT_RADIUS
	var y := size.y / 2.0
	for i in 3:
		_draw_slot(Vector2(x, y), _spells[i] if i < _spells.size() else {}, CREAM)
		x += slot + SLOT_GAP
	x += GROUP_GAP - SLOT_GAP
	for i in 3:
		_draw_slot(Vector2(x, y), _augments[i] if i < _augments.size() else {}, NIGHT)
		x += slot + SLOT_GAP


func _draw_slot(center: Vector2, item: Dictionary, background: Color) -> void:
	if item.is_empty():
		draw_circle(center, SLOT_RADIUS, Color(OUTLINE, 0.35))
		draw_arc(center, SLOT_RADIUS, 0.0, TAU, 32, Color(1, 1, 1, 0.35), 2.5, true)
		return
	var color: Color = item.color
	draw_circle(center, SLOT_RADIUS + 4.0, OUTLINE)
	draw_circle(center, SLOT_RADIUS, background)
	draw_arc(center, SLOT_RADIUS - 3.0, 0.0, TAU, 32, color, 4.0, true)
	SpellIcons.draw(self, item.id, center, SLOT_RADIUS * 1.25)
	var badge := center + Vector2(SLOT_RADIUS * 0.75, SLOT_RADIUS * 0.7)
	draw_circle(badge, 12.0, OUTLINE)
	draw_circle(badge, 9.5, LIGHT)
	var font := get_theme_default_font()
	draw_string(font, badge + Vector2(-10, 5.5), str(item.level), HORIZONTAL_ALIGNMENT_CENTER, 20, 15, OUTLINE)
