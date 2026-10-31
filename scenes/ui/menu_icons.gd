class_name MenuIcons
extends RefCounted

const OUTLINE := Color("#253047")
const LIGHT := Color("#FFE6A1")
const GOLD := Color("#FFC94A")
const FIRE := Color("#FF9138")
const MAGIC := Color("#39C9F0")
const ARCANE := Color("#A45CDA")
const ARCANE_DARK := Color("#7E3FB0")
const DANGER := Color("#F05B52")
const GREEN := Color("#70C95B")
const SAND := Color("#E6C58D")
const WOOD := Color("#B0703A")
const WOOD_LIGHT := Color("#C98A4B")
const PAPER := Color("#FFF3D6")
const STONE := Color("#879DA5")
const ICON_DIR := "res://assets/ui/icons/"
const TEXTURE_FILL := 0.95

static var _textures := {}


static func draw(ci: CanvasItem, id: String, c: Vector2, s: float) -> void:
	var texture := texture_for(id)
	if texture:
		var scale := s * TEXTURE_FILL / maxf(texture.get_width(), texture.get_height())
		var rect_size := texture.get_size() * scale
		ci.draw_texture_rect(texture, Rect2(c - rect_size / 2.0, rect_size), false)
		return
	match id:
		"shop": _shop(ci, c, s)
		"inventory": _inventory(ci, c, s)
		"home": _home(ci, c, s)
		"hero": _hero(ci, c, s)
		"spells": _spells(ci, c, s)
		"scroll": _scroll(ci, c, s)
		"coin": _coin(ci, c, s)
		"lock": _lock(ci, c, s)
		"arrow_left": _chevron(ci, c, s, -1.0)
		"arrow_right": _chevron(ci, c, s, 1.0)
		"close": _close(ci, c, s)
		"pause": _pause(ci, c, s)


static func texture_for(id: String) -> Texture2D:
	if not _textures.has(id):
		var path := ICON_DIR + id + ".png"
		_textures[id] = load(path) if ResourceLoader.exists(path) else null
	return _textures[id]


static func _w(s: float) -> float:
	return clampf(s * 0.07, 2.5, 6.0)


static func _pts(c: Vector2, s: float, shape: Array) -> PackedVector2Array:
	var points := PackedVector2Array()
	for p: Vector2 in shape:
		points.append(c + p * s)
	return points


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


static func _shop(ci: CanvasItem, c: Vector2, s: float) -> void:
	_filled(ci, _pts(c, s, [Vector2(-0.14, -0.22), Vector2(-0.24, -0.42), Vector2(0.0, -0.34),
			Vector2(0.24, -0.42), Vector2(0.14, -0.22)]), SAND, s)
	_disc(ci, c + Vector2(0.0, 0.1) * s, s * 0.34, SAND, s)
	ci.draw_circle(c + Vector2(-0.12, 0.0) * s, s * 0.1, Color(Color.WHITE, 0.35))
	_stroke(ci, c + Vector2(-0.16, -0.22) * s, c + Vector2(0.16, -0.22) * s, s * 0.07, FIRE, s)
	_coin(ci, c + Vector2(0.0, 0.14) * s, s * 0.44)


static func _inventory(ci: CanvasItem, c: Vector2, s: float) -> void:
	_stroke(ci, c + Vector2(-0.16, -0.3) * s, c + Vector2(0.16, -0.3) * s, s * 0.07, WOOD, s)
	_filled(ci, _pts(c, s, [Vector2(-0.34, -0.22), Vector2(0.34, -0.22), Vector2(0.38, 0.38),
			Vector2(-0.38, 0.38)]), WOOD_LIGHT, s)
	_filled(ci, _pts(c, s, [Vector2(-0.34, -0.22), Vector2(0.34, -0.22), Vector2(0.3, 0.06),
			Vector2(-0.3, 0.06)]), WOOD, s)
	_filled(ci, _pts(c, s, [Vector2(-0.2, 0.14), Vector2(0.2, 0.14), Vector2(0.2, 0.3),
			Vector2(-0.2, 0.3)]), WOOD, s)
	_disc(ci, c + Vector2(0.0, 0.06) * s, s * 0.06, GOLD, s)


static func _home(ci: CanvasItem, c: Vector2, s: float) -> void:
	_filled(ci, _pts(c, s, [Vector2(-0.3, -0.02), Vector2(0.3, -0.02), Vector2(0.3, 0.38),
			Vector2(-0.3, 0.38)]), SAND, s)
	_filled(ci, _pts(c, s, [Vector2(0.0, -0.42), Vector2(0.44, 0.02), Vector2(-0.44, 0.02)]), DANGER, s)
	_filled(ci, _pts(c, s, [Vector2(-0.09, 0.14), Vector2(0.09, 0.14), Vector2(0.09, 0.38),
			Vector2(-0.09, 0.38)]), WOOD, s)


static func _hero(ci: CanvasItem, c: Vector2, s: float) -> void:
	ci.draw_set_transform(c + Vector2(0, 0.24) * s, 0.0, Vector2(1.0, 0.32))
	ci.draw_circle(Vector2.ZERO, s * 0.46, OUTLINE)
	ci.draw_circle(Vector2.ZERO, s * 0.4, ARCANE)
	ci.draw_set_transform(Vector2.ZERO)
	_filled(ci, _pts(c, s, [Vector2(-0.24, 0.24), Vector2(-0.12, -0.12), Vector2(-0.18, -0.44),
			Vector2(0.06, -0.2), Vector2(0.24, 0.24)]), ARCANE, s)
	_stroke(ci, c + Vector2(-0.22, 0.12) * s, c + Vector2(0.22, 0.12) * s, s * 0.08, MAGIC, s)
	_filled(ci, _pts(c, s, [Vector2(0.28, -0.42), Vector2(0.44, -0.22), Vector2(0.34, -0.22),
			Vector2(0.34, -0.06), Vector2(0.22, -0.06), Vector2(0.22, -0.22), Vector2(0.12, -0.22)]), GREEN, s)


static func _spells(ci: CanvasItem, c: Vector2, s: float) -> void:
	_filled(ci, _pts(c, s, [Vector2(-0.32, -0.36), Vector2(0.3, -0.36), Vector2(0.3, 0.38),
			Vector2(-0.32, 0.38)]), ARCANE, s)
	_filled(ci, _pts(c, s, [Vector2(0.3, 0.26), Vector2(0.38, 0.26), Vector2(0.38, 0.42),
			Vector2(-0.24, 0.42), Vector2(-0.32, 0.38)]), PAPER, s)
	_stroke(ci, c + Vector2(-0.22, -0.34) * s, c + Vector2(-0.22, 0.36) * s, s * 0.05, ARCANE_DARK, s)
	_star(ci, c + Vector2(0.04, -0.02) * s, s * 0.18, LIGHT, s)


static func _scroll(ci: CanvasItem, c: Vector2, s: float) -> void:
	_filled(ci, _pts(c, s, [Vector2(-0.26, -0.36), Vector2(0.3, -0.36), Vector2(0.3, 0.36),
			Vector2(-0.26, 0.36)]), PAPER, s)
	_disc(ci, c + Vector2(-0.28, -0.36) * s, s * 0.08, SAND, s)
	_disc(ci, c + Vector2(0.32, 0.36) * s, s * 0.08, SAND, s)
	for row in 3:
		var y := -0.16 + row * 0.16
		ci.draw_line(c + Vector2(-0.14, y) * s, c + Vector2(0.18, y) * s, STONE, s * 0.06, true)


static func _coin(ci: CanvasItem, c: Vector2, s: float) -> void:
	_disc(ci, c, s * 0.36, GOLD, s)
	ci.draw_circle(c, s * 0.24, LIGHT)
	ci.draw_circle(c, s * 0.16, GOLD)


static func _lock(ci: CanvasItem, c: Vector2, s: float) -> void:
	ci.draw_arc(c + Vector2(0, -0.08) * s, s * 0.2, PI, TAU, 16, OUTLINE, s * 0.16, true)
	ci.draw_arc(c + Vector2(0, -0.08) * s, s * 0.2, PI, TAU, 16, STONE, s * 0.07, true)
	_filled(ci, _pts(c, s, [Vector2(-0.3, -0.06), Vector2(0.3, -0.06), Vector2(0.3, 0.36),
			Vector2(-0.3, 0.36)]), GOLD, s)
	ci.draw_circle(c + Vector2(0, 0.12) * s, s * 0.06, OUTLINE)


static func _chevron(ci: CanvasItem, c: Vector2, s: float, side: float) -> void:
	var tip := c + Vector2(0.18 * side, 0) * s
	var top := c + Vector2(-0.14 * side, -0.3) * s
	var bottom := c + Vector2(-0.14 * side, 0.3) * s
	ci.draw_polyline(PackedVector2Array([top, tip, bottom]), OUTLINE, s * 0.24, true)
	ci.draw_polyline(PackedVector2Array([top, tip, bottom]), Color.WHITE, s * 0.12, true)


static func _close(ci: CanvasItem, c: Vector2, s: float) -> void:
	_stroke(ci, c + Vector2(-0.24, -0.24) * s, c + Vector2(0.24, 0.24) * s, s * 0.12, Color.WHITE, s)
	_stroke(ci, c + Vector2(0.24, -0.24) * s, c + Vector2(-0.24, 0.24) * s, s * 0.12, Color.WHITE, s)


static func _pause(ci: CanvasItem, c: Vector2, s: float) -> void:
	for side in [-1.0, 1.0]:
		var bar := Rect2(c + Vector2(side * 0.14 - 0.07, -0.26) * s, Vector2(0.14, 0.52) * s)
		ci.draw_rect(bar.grow(_w(s) * 0.8), OUTLINE)
		ci.draw_rect(bar, Color.WHITE)


static func _star(ci: CanvasItem, c: Vector2, r: float, color: Color, s: float) -> void:
	var points := PackedVector2Array()
	for k in 10:
		var radius := r if k % 2 == 0 else r * 0.45
		points.append(c + Vector2.from_angle(-PI / 2.0 + k * PI / 5.0) * radius)
	_filled(ci, points, color, s)
