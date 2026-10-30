class_name LightningFx
extends Node2D

const GLOW := Color("#39C9F0")
const BOLT := Color("#FFE6A1")
const DURATION := 0.3

var _anchors := PackedVector2Array()
var _path := PackedVector2Array()
var _rejag_timer := 0.0


static func spawn(parent: Node, points: PackedVector2Array) -> void:
	var fx := LightningFx.new()
	fx._anchors = points
	fx.top_level = true
	fx.z_index = 60
	parent.add_child(fx)


func _ready() -> void:
	_path = _jagged(_anchors)
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, DURATION).set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free)


func _process(delta: float) -> void:
	_rejag_timer -= delta
	if _rejag_timer <= 0.0:
		_rejag_timer = 0.05
		_path = _jagged(_anchors)
		queue_redraw()


func _draw() -> void:
	draw_polyline(_path, Color(GLOW, 0.35), 16.0, true)
	draw_polyline(_path, GLOW, 8.0, true)
	draw_polyline(_path, BOLT, 4.0, true)
	draw_polyline(_path, Color.WHITE, 1.5, true)


func _jagged(points: PackedVector2Array) -> PackedVector2Array:
	var out := PackedVector2Array([points[0]])
	for i in range(1, points.size()):
		var a := points[i - 1]
		var b := points[i]
		var normal := a.direction_to(b).orthogonal()
		var steps := maxi(2, int(a.distance_to(b) / 24.0))
		for s in range(1, steps):
			out.append(a.lerp(b, float(s) / steps) + normal * randf_range(-14.0, 14.0))
		out.append(b)
	return out
