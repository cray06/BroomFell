class_name BossBar
extends Control
## Barre de vie du boss, sous le score.

const OUTLINE := Color("#253047")
const TRACK := Color("#3A4763")
const FILL := Color("#F05B52")
const LAG := Color("#FFE6A1")
const BAR_TOP := 38.0
const BAR_HEIGHT := 24.0

var _title := ""
var _ratio := 1.0
var _lag_ratio := 1.0:
	set(value):
		_lag_ratio = value
		queue_redraw()
var _lag_tween: Tween
var _health: HealthComponent


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	hide()


func open(title: String, health: HealthComponent) -> void:
	_title = title
	_ratio = 1.0
	_lag_ratio = 1.0
	_health = health
	health.health_changed.connect(_on_health_changed)
	show()
	modulate.a = 0.0
	pivot_offset = size / 2.0
	scale = Vector2(0.6, 0.6)
	var tween := create_tween().set_parallel()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	tween.tween_property(self, "scale", Vector2.ONE, 0.5) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func close() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	tween.tween_callback(hide)


func _on_health_changed(current: int, maximum: int) -> void:
	_ratio = float(current) / maximum
	queue_redraw()
	if _lag_tween:
		_lag_tween.kill()
	_lag_tween = create_tween()
	_lag_tween.tween_interval(0.3)
	_lag_tween.tween_property(self, "_lag_ratio", _ratio, 0.35)


func _draw() -> void:
	var font := get_theme_default_font()
	draw_string_outline(font, Vector2(0, 28), _title, HORIZONTAL_ALIGNMENT_CENTER, size.x, 28, 12, OUTLINE)
	draw_string(font, Vector2(0, 28), _title, HORIZONTAL_ALIGNMENT_CENTER, size.x, 28, LAG)

	var bar := Rect2(0, BAR_TOP, size.x, BAR_HEIGHT)
	var frame := StyleBoxFlat.new()
	frame.bg_color = OUTLINE
	frame.set_corner_radius_all(int(BAR_HEIGHT / 2.0) + 5)
	draw_style_box(frame, bar.grow(5.0))
	_draw_fill(bar, 1.0, TRACK)
	_draw_fill(bar, _lag_ratio, LAG)
	_draw_fill(bar, _ratio, FILL)
	_draw_fill(Rect2(bar.position, Vector2(bar.size.x, BAR_HEIGHT * 0.4)), _ratio, Color(1, 1, 1, 0.25))
	# Repère de mi-vie (le boss s'énerve).
	var mid := bar.position.x + bar.size.x / 2.0
	draw_line(Vector2(mid, bar.position.y), Vector2(mid, bar.end.y), Color(OUTLINE, 0.6), 3.0)


func _draw_fill(bar: Rect2, ratio: float, color: Color) -> void:
	var width := bar.size.x * ratio
	if width < 1.0:
		return
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(int(minf(bar.size.y, width) / 2.0))
	draw_style_box(style, Rect2(bar.position, Vector2(width, bar.size.y)))
