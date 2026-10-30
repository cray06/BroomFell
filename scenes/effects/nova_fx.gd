class_name NovaFx
extends Node2D

const ARCANE := Color("#A45CDA")
const DURATION := 0.35

var max_radius := 150.0
var color := ARCANE
var _t := 0.0


static func spawn(parent: Node, at: Vector2, radius: float, ring_color: Color = ARCANE) -> void:
	var fx := NovaFx.new()
	fx.max_radius = radius
	fx.color = ring_color
	fx.top_level = true
	fx.z_index = 40
	fx.position = at
	parent.add_child(fx)


func _process(delta: float) -> void:
	_t += delta / DURATION
	if _t >= 1.0:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var eased := 1.0 - pow(1.0 - _t, 3.0)
	var radius := max_radius * eased
	var alpha := 1.0 - _t
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.7))
	draw_circle(Vector2.ZERO, radius, Color(color, 0.2 * alpha))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 64, Color(color, alpha), 12.0 * (1.0 - _t) + 2.0, true)
	draw_arc(Vector2.ZERO, radius * 0.9, 0.0, TAU, 64, Color(1, 1, 1, 0.6 * alpha), 3.0, true)
