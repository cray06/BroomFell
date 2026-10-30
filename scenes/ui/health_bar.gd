class_name HealthBar
extends Node2D

const OUTLINE := Color("#253047")
const BACK := Color("#3A4763")
const LAG := Color("#FFE6A1")

@export var bar_size := Vector2(60, 10)
@export var fill_color := Color("#F05B52")

var _ratio := 1.0
var _lag_ratio := 1.0:
	set(value):
		_lag_ratio = value
		queue_redraw()
var _lag_tween: Tween


func set_ratio(ratio: float) -> void:
	_ratio = clampf(ratio, 0.0, 1.0)
	queue_redraw()
	if _lag_tween:
		_lag_tween.kill()
	_lag_tween = create_tween()
	_lag_tween.tween_interval(0.25)
	_lag_tween.tween_property(self, "_lag_ratio", _ratio, 0.3)


func _draw() -> void:
	var rect := Rect2(-bar_size / 2.0, bar_size)
	draw_rect(rect.grow(3.0), OUTLINE)
	draw_rect(rect, BACK)
	draw_rect(Rect2(rect.position, Vector2(rect.size.x * _lag_ratio, rect.size.y)), LAG)
	var fill_rect := Rect2(rect.position, Vector2(rect.size.x * _ratio, rect.size.y))
	draw_rect(fill_rect, fill_color)
	draw_rect(Rect2(fill_rect.position, Vector2(fill_rect.size.x, rect.size.y * 0.35)), fill_color.lightened(0.3))
