class_name Banner
extends Control

const OUTLINE := Color("#253047")
const BAND_HEIGHT := 120.0
const STRIPE := 44.0

var _band := 0.0:
	set(value):
		_band = value
		queue_redraw()
var _color := Color.WHITE
var _stripe_offset := 0.0
var _label: Label
var _tween: Tween


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var settings := LabelSettings.new()
	settings.font_size = 46
	settings.font_color = Color.WHITE
	settings.outline_size = 16
	settings.outline_color = OUTLINE
	_label.label_settings = settings
	_label.modulate.a = 0.0
	add_child(_label)


func show_banner(text: String, color: Color) -> void:
	_color = color
	_label.text = text
	_label.label_settings.font_color = color.lightened(0.55)
	_label.size = Vector2(size.x, BAND_HEIGHT)
	_label.position = Vector2(size.x, _band_center() - BAND_HEIGHT / 2.0)
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "_band", 1.0, 0.2).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(_label, "position:x", 0.0, 0.4) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(_label, "modulate:a", 1.0, 0.15)
	_tween.tween_interval(1.5)
	_tween.tween_property(_label, "position:x", -size.x, 0.3).set_ease(Tween.EASE_IN)
	_tween.parallel().tween_property(self, "_band", 0.0, 0.3).set_delay(0.1)


func _process(delta: float) -> void:
	if _band <= 0.0:
		return
	_stripe_offset = fmod(_stripe_offset + delta * 90.0, STRIPE)
	queue_redraw()


func _draw() -> void:
	if _band <= 0.0:
		return
	var height := BAND_HEIGHT * _band
	var top := _band_center() - height / 2.0
	var bottom := top + height
	draw_rect(Rect2(0, top, size.x, height), Color(OUTLINE, 0.88))
	var slant := height * 0.45
	var x := -STRIPE * 2.0 + _stripe_offset
	while x < size.x + STRIPE:
		draw_colored_polygon(PackedVector2Array([Vector2(x, top), Vector2(x + STRIPE / 2.0, top),
				Vector2(x + STRIPE / 2.0 - slant, bottom), Vector2(x - slant, bottom)]),
				Color(_color, 0.3))
		x += STRIPE
	draw_line(Vector2(0, top), Vector2(size.x, top), _color, 6.0)
	draw_line(Vector2(0, bottom), Vector2(size.x, bottom), _color, 6.0)


func _band_center() -> float:
	return size.y * 0.3
