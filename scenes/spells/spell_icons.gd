class_name SpellIcons
extends RefCounted

const OUTLINE := Color("#253047")
const LIGHT := Color("#FFE6A1")
const FIRE := Color("#FF9138")
const MAGIC := Color("#39C9F0")
const ARCANE := Color("#A45CDA")
const DANGER := Color("#F05B52")
const GREEN := Color("#70C95B")
const GREEN_DARK := Color("#387E55")
const STONE := Color("#879DA5")
const SAND := Color("#E6C58D")
const ICE := Color("#9FE8FF")
const POISON := Color("#9BE15D")


static func draw(ci: CanvasItem, id: String, c: Vector2, s: float) -> void:
	match id:
		"fire_orbs": _flame(ci, c, s)
		"chain_lightning": _bolt(ci, c, s)
		"arcane_nova": _nova(ci, c, s)
		"meteor_shower": _meteor(ci, c, s)
		"broom_boomerang": _broom(ci, c, s)
		"frost_nova": _snowflake(ci, c, s)
		"owl_familiar": _owl(ci, c, s)
		"tornado": _tornado(ci, c, s)
		"poison_trail": _poison(ci, c, s)
		"arcane_beam": _beam(ci, c, s)
		"bounce_bubbles": _bubbles(ci, c, s)
		"multishot": _multishot(ci, c, s)
		"crit": _crit(ci, c, s)
		"fire_rate": _chevrons(ci, c, s)
		"power": _sword(ci, c, s)
		"pierce": _pierce(ci, c, s)
		"ricochet": _ricochet(ci, c, s)
		"back_shot": _back_shot(ci, c, s)
		"speed": _wing(ci, c, s)
		"vitality": _heart(ci, c, s, true)
		"regen": _cross(ci, c, s)
		"vampirism": _drop(ci, c, s, DANGER)
		"focus": _clock(ci, c, s)
		"shield": _shield(ci, c, s)
		"magnet", "pickup_magnet": _magnet(ci, c, s)
		"pickup_bomb": _bomb(ci, c, s)
		"pickup_heart", "heal": _heart(ci, c, s, false)
		"pickup_hourglass": _hourglass(ci, c, s)
		"pickup_rage": _star(ci, c, s)
		"pickup_bubble": _bubble_icon(ci, c, s)
		"pickup_chest": _chest(ci, c, s)
		_: _heart(ci, c, s, false)


static func _w(s: float) -> float:
	return maxf(2.0, s * 0.055)


static func _filled(ci: CanvasItem, points: PackedVector2Array, color: Color, s: float) -> void:
	ci.draw_colored_polygon(points, color)
	var closed := points.duplicate()
	closed.append(points[0])
	ci.draw_polyline(closed, OUTLINE, _w(s), true)


static func _disc(ci: CanvasItem, c: Vector2, r: float, color: Color, s: float) -> void:
	ci.draw_circle(c, r + _w(s) * 0.8, OUTLINE)
	ci.draw_circle(c, r, color)


static func _stroke(ci: CanvasItem, a: Vector2, b: Vector2, width: float, color: Color, s: float) -> void:
	ci.draw_line(a, b, OUTLINE, width + _w(s) * 1.6, true)
	ci.draw_line(a, b, color, width, true)


static func _pts(c: Vector2, s: float, shape: Array) -> PackedVector2Array:
	var points := PackedVector2Array()
	for p in shape:
		points.append(c + p * s)
	return points


static func _ellipse(c: Vector2, rx: float, ry: float, steps: int = 24) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in steps:
		var a := TAU * i / steps
		points.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	return points


static func _teardrop(c: Vector2, height: float, width: float) -> PackedVector2Array:
	var points := PackedVector2Array([c + Vector2(0, -height)])
	var base := c + Vector2(0, height * 0.35)
	for i in 25:
		var angle := deg_to_rad(-30.0 + 240.0 * i / 24.0)
		points.append(base + Vector2(cos(angle), sin(angle)) * width)
	return points


static func _star_points(c: Vector2, outer: float, inner: float, branches: int, rot: float = -PI / 2.0) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in branches * 2:
		var r := outer if i % 2 == 0 else inner
		points.append(c + Vector2.from_angle(rot + PI * i / branches) * r)
	return points


static func _orb(ci: CanvasItem, c: Vector2, r: float, color: Color, s: float) -> void:
	_disc(ci, c, r, color, s)
	ci.draw_circle(c + Vector2(-r, -r) * 0.3, r * 0.35, Color(1, 1, 1, 0.75))


static func _flame(ci: CanvasItem, c: Vector2, s: float) -> void:
	_filled(ci, _teardrop(c + Vector2(0, s * 0.05), s * 0.5, s * 0.3), FIRE, s)
	ci.draw_colored_polygon(_teardrop(c + Vector2(0, s * 0.18), s * 0.3, s * 0.17), LIGHT)


static func _bolt(ci: CanvasItem, c: Vector2, s: float) -> void:
	_filled(ci, _pts(c, s, [Vector2(0.10, -0.50), Vector2(-0.24, 0.05), Vector2(0.0, 0.05),
			Vector2(-0.14, 0.50), Vector2(0.28, -0.10), Vector2(0.04, -0.10), Vector2(0.24, -0.50)]), LIGHT, s)


static func _nova(ci: CanvasItem, c: Vector2, s: float) -> void:
	ci.draw_arc(c, s * 0.46, 0.0, TAU, 48, OUTLINE, s * 0.1, true)
	ci.draw_arc(c, s * 0.46, 0.0, TAU, 48, Color.WHITE, s * 0.045, true)
	ci.draw_arc(c, s * 0.33, 0.0, TAU, 48, Color(1, 1, 1, 0.6), s * 0.035, true)
	_disc(ci, c, s * 0.22, ARCANE.lightened(0.15), s)
	ci.draw_colored_polygon(_star_points(c, s * 0.16, s * 0.04, 4), LIGHT)


static func _meteor(ci: CanvasItem, c: Vector2, s: float) -> void:
	var head := c + Vector2(s * 0.12, s * 0.12)
	for i in 3:
		var offset := Vector2(-0.12 + i * 0.12, -0.02 - i * 0.04) * s
		_stroke(ci, head + offset, head + offset + Vector2(-0.38, -0.38) * s, s * 0.07, FIRE, s)
	_disc(ci, head, s * 0.22, FIRE, s)
	ci.draw_circle(head + Vector2(-0.05, -0.05) * s, s * 0.1, LIGHT)


static func _broom(ci: CanvasItem, c: Vector2, s: float) -> void:
	_stroke(ci, c + Vector2(-0.42, -0.42) * s, c + Vector2(0.1, 0.1) * s, s * 0.09, SAND, s)
	_filled(ci, _pts(c, s, [Vector2(0.02, 0.18), Vector2(0.18, 0.02), Vector2(0.46, 0.3),
			Vector2(0.3, 0.46)]), LIGHT, s)
	_stroke(ci, c + Vector2(0.03, 0.17) * s, c + Vector2(0.17, 0.03) * s, s * 0.07, ARCANE, s)


static func _snowflake(ci: CanvasItem, c: Vector2, s: float) -> void:
	for i in 3:
		var dir := Vector2.from_angle(PI * i / 3.0)
		_stroke(ci, c - dir * s * 0.44, c + dir * s * 0.44, s * 0.08, ICE, s)
	for i in 6:
		var dir := Vector2.from_angle(PI * i / 3.0)
		var mid := c + dir * s * 0.28
		ci.draw_line(mid, mid + dir.rotated(0.8) * s * 0.13, Color.WHITE, s * 0.05, true)
		ci.draw_line(mid, mid + dir.rotated(-0.8) * s * 0.13, Color.WHITE, s * 0.05, true)
	_disc(ci, c, s * 0.08, Color.WHITE, s)


static func _owl(ci: CanvasItem, c: Vector2, s: float) -> void:
	for ear in [-1.0, 1.0]:
		_filled(ci, _pts(c, s, [Vector2(0.18 * ear, -0.22), Vector2(0.34 * ear, -0.48), Vector2(0.04 * ear, -0.3)]), STONE, s)
	_disc(ci, c, s * 0.36, STONE, s)
	ci.draw_circle(c + Vector2(0, 0.14) * s, s * 0.2, SAND)
	for eye in [-1.0, 1.0]:
		_disc(ci, c + Vector2(0.15 * eye, -0.08) * s, s * 0.12, LIGHT, s)
		ci.draw_circle(c + Vector2(0.15 * eye, -0.08) * s, s * 0.055, OUTLINE)
	ci.draw_colored_polygon(_pts(c, s, [Vector2(-0.06, 0.02), Vector2(0.06, 0.02), Vector2(0, 0.14)]), FIRE)


static func _tornado(ci: CanvasItem, c: Vector2, s: float) -> void:
	for i in 5:
		var y := (0.36 - i * 0.18) * s
		var rx := (0.12 + i * 0.08) * s
		var center := c + Vector2(sin(i * 1.3) * s * 0.05, y)
		var ring := _ellipse(center, rx, rx * 0.35)
		ci.draw_colored_polygon(ring, Color(0.9, 0.97, 1.0))
		ring.append(ring[0])
		ci.draw_polyline(ring, OUTLINE, _w(s), true)


static func _poison(ci: CanvasItem, c: Vector2, s: float) -> void:
	_drop(ci, c + Vector2(0, -0.04) * s, s * 0.9, POISON)
	_disc(ci, c + Vector2(0.3, 0.32) * s, s * 0.07, POISON, s)
	_disc(ci, c + Vector2(-0.32, 0.28) * s, s * 0.05, POISON, s)


static func _beam(ci: CanvasItem, c: Vector2, s: float) -> void:
	var a := c + Vector2(-0.38, 0.38) * s
	var b := c + Vector2(0.42, -0.42) * s
	ci.draw_line(a, b, Color(MAGIC, 0.4), s * 0.3, true)
	_stroke(ci, a, b, s * 0.12, MAGIC, s)
	ci.draw_line(a, b, Color.WHITE, s * 0.04, true)
	_orb(ci, a, s * 0.14, MAGIC, s)


static func _bubbles(ci: CanvasItem, c: Vector2, s: float) -> void:
	for spot in [Vector3(-0.12, 0.12, 0.26), Vector3(0.24, -0.16, 0.18), Vector3(0.28, 0.3, 0.12)]:
		var at := c + Vector2(spot.x, spot.y) * s
		var r: float = spot.z * s
		ci.draw_circle(at, r, Color(ICE, 0.45))
		ci.draw_arc(at, r, 0.0, TAU, 32, OUTLINE, _w(s), true)
		ci.draw_arc(at, r * 0.7, deg_to_rad(200), deg_to_rad(260), 10, Color.WHITE, _w(s), true)


static func _mini_bolt(ci: CanvasItem, from: Vector2, to: Vector2, s: float, color: Color) -> void:
	ci.draw_line(from, to, Color(color, 0.5), s * 0.08, true)
	_orb(ci, to, s * 0.1, color, s)


static func _multishot(ci: CanvasItem, c: Vector2, s: float) -> void:
	var base := c + Vector2(0, 0.38) * s
	for angle in [-0.45, 0.0, 0.45]:
		var dir := Vector2.UP.rotated(angle)
		_mini_bolt(ci, base, base + dir * s * 0.7, s, MAGIC)


static func _crit(ci: CanvasItem, c: Vector2, s: float) -> void:
	_filled(ci, _star_points(c, s * 0.48, s * 0.22, 8), DANGER, s)
	_filled(ci, _star_points(c, s * 0.26, s * 0.12, 8, -PI / 2.0 + PI / 8.0), LIGHT, s)


static func _chevrons(ci: CanvasItem, c: Vector2, s: float) -> void:
	for i in 2:
		var x := (-0.2 + i * 0.28) * s
		var pts := PackedVector2Array([c + Vector2(x - 0.12 * s, -0.32 * s), c + Vector2(x + 0.14 * s, 0),
				c + Vector2(x - 0.12 * s, 0.32 * s)])
		ci.draw_polyline(pts, OUTLINE, s * 0.2, true)
		ci.draw_polyline(pts, FIRE, s * 0.11, true)


static func _sword(ci: CanvasItem, c: Vector2, s: float) -> void:
	_filled(ci, _pts(c, s, [Vector2(-0.07, 0.12), Vector2(-0.07, -0.36), Vector2(0, -0.5),
			Vector2(0.07, -0.36), Vector2(0.07, 0.12)]), Color.WHITE, s)
	_stroke(ci, c + Vector2(-0.24, 0.16) * s, c + Vector2(0.24, 0.16) * s, s * 0.08, LIGHT, s)
	_stroke(ci, c + Vector2(0, 0.2) * s, c + Vector2(0, 0.42) * s, s * 0.08, ARCANE, s)


static func _pierce(ci: CanvasItem, c: Vector2, s: float) -> void:
	_disc(ci, c, s * 0.2, GREEN, s)
	_stroke(ci, c + Vector2(-0.46, 0.0) * s, c + Vector2(0.3, 0.0) * s, s * 0.07, LIGHT, s)
	_filled(ci, _pts(c, s, [Vector2(0.28, -0.14), Vector2(0.48, 0), Vector2(0.28, 0.14)]), LIGHT, s)


static func _ricochet(ci: CanvasItem, c: Vector2, s: float) -> void:
	var path := _pts(c, s, [Vector2(-0.42, 0.3), Vector2(-0.1, -0.3), Vector2(0.14, 0.24), Vector2(0.36, -0.2)])
	ci.draw_polyline(path, OUTLINE, s * 0.16, true)
	ci.draw_polyline(path, MAGIC, s * 0.08, true)
	_filled(ci, _pts(c, s, [Vector2(0.24, -0.26), Vector2(0.46, -0.38), Vector2(0.42, -0.12)]), MAGIC, s)


static func _back_shot(ci: CanvasItem, c: Vector2, s: float) -> void:
	_mini_bolt(ci, c, c + Vector2(0, -0.4) * s, s, MAGIC)
	_mini_bolt(ci, c, c + Vector2(0, 0.4) * s, s, FIRE)
	_disc(ci, c, s * 0.08, Color.WHITE, s)


static func _wing(ci: CanvasItem, c: Vector2, s: float) -> void:
	for i in 3:
		var y := (-0.22 + i * 0.18) * s
		_stroke(ci, c + Vector2(-0.44, y), c + Vector2(-0.18, y), s * 0.05, Color.WHITE, s)
	var feathers := _pts(c, s, [Vector2(-0.1, 0.3), Vector2(0.0, -0.36), Vector2(0.46, -0.3),
			Vector2(0.36, -0.12), Vector2(0.42, 0.02), Vector2(0.28, 0.12), Vector2(0.3, 0.26)])
	_filled(ci, feathers, MAGIC.lightened(0.3), s)


static func _heart(ci: CanvasItem, c: Vector2, s: float, with_plus: bool) -> void:
	var points := PackedVector2Array()
	for i in 48:
		var t := TAU * i / 48.0
		var x := 16.0 * pow(sin(t), 3)
		var y := -(13.0 * cos(t) - 5.0 * cos(2 * t) - 2.0 * cos(3 * t) - cos(4 * t))
		points.append(c + Vector2(x, y - 6.0) * s / 34.0)
	_filled(ci, points, DANGER, s)
	ci.draw_circle(c + Vector2(-s * 0.16, -s * 0.12), s * 0.07, Color(1, 1, 1, 0.8))
	if with_plus:
		_stroke(ci, c + Vector2(0.28, 0.12) * s, c + Vector2(0.28, 0.44) * s, s * 0.09, GREEN, s)
		_stroke(ci, c + Vector2(0.12, 0.28) * s, c + Vector2(0.44, 0.28) * s, s * 0.09, GREEN, s)


static func _cross(ci: CanvasItem, c: Vector2, s: float) -> void:
	_filled(ci, _pts(c, s, [Vector2(-0.12, -0.42), Vector2(0.12, -0.42), Vector2(0.12, -0.12),
			Vector2(0.42, -0.12), Vector2(0.42, 0.12), Vector2(0.12, 0.12), Vector2(0.12, 0.42),
			Vector2(-0.12, 0.42), Vector2(-0.12, 0.12), Vector2(-0.42, 0.12), Vector2(-0.42, -0.12),
			Vector2(-0.12, -0.12)]), GREEN, s)


static func _drop(ci: CanvasItem, c: Vector2, s: float, color: Color) -> void:
	var points := _teardrop(c + Vector2(0, s * 0.02), s * 0.46, s * 0.28)
	_filled(ci, points, color, s)
	ci.draw_circle(c + Vector2(-0.1, 0.06) * s, s * 0.07, Color(1, 1, 1, 0.75))


static func _clock(ci: CanvasItem, c: Vector2, s: float) -> void:
	_disc(ci, c, s * 0.4, Color.WHITE, s)
	ci.draw_arc(c, s * 0.4, -PI / 2.0, PI * 0.2, 24, ARCANE, s * 0.08, true)
	_stroke(ci, c, c + Vector2(0, -0.26) * s, s * 0.05, OUTLINE, s)
	_stroke(ci, c, c + Vector2(0.18, 0.06) * s, s * 0.05, OUTLINE, s)
	ci.draw_circle(c, s * 0.05, OUTLINE)


static func _shield(ci: CanvasItem, c: Vector2, s: float) -> void:
	_filled(ci, _pts(c, s, [Vector2(0, -0.46), Vector2(0.38, -0.32), Vector2(0.34, 0.08),
			Vector2(0, 0.46), Vector2(-0.34, 0.08), Vector2(-0.38, -0.32)]), MAGIC, s)
	ci.draw_colored_polygon(_pts(c, s, [Vector2(0, -0.32), Vector2(0.24, -0.22), Vector2(0.22, 0.04),
			Vector2(0, 0.3)]), Color(1, 1, 1, 0.4))


static func _magnet(ci: CanvasItem, c: Vector2, s: float) -> void:
	var r := s * 0.28
	ci.draw_arc(c, r, 0.0, PI, 24, OUTLINE, s * 0.3, true)
	ci.draw_arc(c, r, 0.0, PI, 24, DANGER, s * 0.2, true)
	for side in [-1.0, 1.0]:
		var top := c + Vector2(r * side, 0)
		_stroke(ci, top + Vector2(0, -s * 0.28), top, s * 0.2, DANGER, s)
		_stroke(ci, top + Vector2(0, -s * 0.38), top + Vector2(0, -s * 0.24), s * 0.2, Color.WHITE, s)


static func _bomb(ci: CanvasItem, c: Vector2, s: float) -> void:
	_stroke(ci, c + Vector2(0.12, -0.24) * s, c + Vector2(0.28, -0.42) * s, s * 0.06, SAND, s)
	_disc(ci, c + Vector2(0, 0.08) * s, s * 0.34, Color("#3A4763"), s)
	ci.draw_circle(c + Vector2(-0.12, -0.04) * s, s * 0.08, Color(1, 1, 1, 0.5))
	ci.draw_colored_polygon(_star_points(c + Vector2(0.3, -0.44) * s, s * 0.14, s * 0.05, 5), FIRE)


static func _hourglass(ci: CanvasItem, c: Vector2, s: float) -> void:
	_filled(ci, _pts(c, s, [Vector2(-0.28, -0.4), Vector2(0.28, -0.4), Vector2(0.04, 0),
			Vector2(0.28, 0.4), Vector2(-0.28, 0.4), Vector2(-0.04, 0)]), ICE, s)
	ci.draw_colored_polygon(_pts(c, s, [Vector2(-0.18, 0.34), Vector2(0.18, 0.34), Vector2(0, 0.12)]), SAND)
	_stroke(ci, c + Vector2(-0.36, -0.42) * s, c + Vector2(0.36, -0.42) * s, s * 0.07, SAND, s)
	_stroke(ci, c + Vector2(-0.36, 0.42) * s, c + Vector2(0.36, 0.42) * s, s * 0.07, SAND, s)


static func _star(ci: CanvasItem, c: Vector2, s: float) -> void:
	_filled(ci, _star_points(c, s * 0.48, s * 0.22, 5), LIGHT, s)
	ci.draw_colored_polygon(_star_points(c, s * 0.22, s * 0.1, 5), FIRE)


static func _bubble_icon(ci: CanvasItem, c: Vector2, s: float) -> void:
	ci.draw_circle(c, s * 0.42, Color(LIGHT, 0.5))
	ci.draw_arc(c, s * 0.42, 0.0, TAU, 32, OUTLINE, _w(s), true)
	ci.draw_arc(c, s * 0.3, deg_to_rad(200), deg_to_rad(260), 12, Color.WHITE, s * 0.07, true)
	ci.draw_colored_polygon(_star_points(c + Vector2(0.06, 0.06) * s, s * 0.14, s * 0.05, 4), Color.WHITE)


static func _chest(ci: CanvasItem, c: Vector2, s: float) -> void:
	_filled(ci, _pts(c, s, [Vector2(-0.42, -0.06), Vector2(0.42, -0.06), Vector2(0.42, 0.38),
			Vector2(-0.42, 0.38)]), Color("#B0703A"), s)
	_filled(ci, _pts(c, s, [Vector2(-0.42, -0.06), Vector2(-0.36, -0.32), Vector2(0.36, -0.32),
			Vector2(0.42, -0.06)]), Color("#C98A4B"), s)
	_stroke(ci, c + Vector2(-0.42, 0.06) * s, c + Vector2(0.42, 0.06) * s, s * 0.06, LIGHT, s)
	_disc(ci, c + Vector2(0, 0.06) * s, s * 0.08, LIGHT, s)
