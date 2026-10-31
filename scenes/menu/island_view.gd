class_name IslandView
extends Control

signal stage_selected(stage: Vector2i)

const WITCH := preload("res://assets/sprites/characters/witch.svg")
const OUTLINE := Color("#253047")
const WATER := Color("#39C9F0")
const SAND := Color("#E6C58D")
const ROCK := Color("#879DA5")
const LIGHT := Color("#FFE6A1")
const FIRE := Color("#FF9138")
const GREEN := Color("#70C95B")
const TREE_DARK := Color("#387E55")
const TRUNK := Color("#B0703A")
const BASE_SIZE := Vector2(780, 420)
const STAGE_POINTS: Array[Vector2] = [Vector2(-170, 40), Vector2(10, -40), Vector2(175, 30)]
const TREES: Array[Vector3] = [
	Vector3(-215, -45, 1.0), Vector3(-110, -80, 0.8), Vector3(105, -95, 0.9),
	Vector3(225, -35, 0.75), Vector3(-60, 95, 0.7), Vector3(95, 100, 0.85),
]
const ROCKS: Array[Vector2] = [Vector2(-250, 40), Vector2(-20, 70), Vector2(250, 60)]
const STAGE_RADIUS := 40.0
const TOUCH_RADIUS := 62.0

var island := 0
var selected := 0

var _time := 0.0
var _swap := 1.0


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_STOP


func _process(delta: float) -> void:
	_time += delta
	modulate.a = _swap
	queue_redraw()


func show_island(index: int, stage: int, direction: int = 0) -> void:
	island = index
	selected = stage
	if direction != 0:
		_swap = 0.0
		create_tween().tween_property(self, "_swap", 1.0, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _gui_input(event: InputEvent) -> void:
	var press := event as InputEventMouseButton
	if press == null or not press.pressed or press.button_index != MOUSE_BUTTON_LEFT:
		return
	for stage in WorldMap.STAGES_PER_ISLAND:
		if press.position.distance_to(_stage_position(stage)) < TOUCH_RADIUS * _scale():
			stage_selected.emit(Vector2i(island, stage))
			accept_event()
			return


func _scale() -> float:
	return minf(size.x / BASE_SIZE.x, size.y / BASE_SIZE.y)


func _center() -> Vector2:
	return size / 2.0 + Vector2(0, 30.0 * _scale())


func _stage_position(stage: int) -> Vector2:
	return _center() + STAGE_POINTS[stage] * _scale()


func _draw() -> void:
	var data := WorldMap.island(island)
	var playable: bool = data.playable
	var k := _scale() * lerpf(0.85, 1.0, _swap)
	var center := _center() + Vector2(0, sin(_time * 1.2) * 4.0 * k)

	_draw_water(center, k)
	_draw_ground(center, k, data.ground, data.ground_dark, playable)
	for tree in TREES:
		_draw_tree(center + Vector2(tree.x, tree.y) * k, tree.z * k, playable)
	for rock in ROCKS:
		_draw_rock(center + rock * k, k)
	if playable:
		_draw_path(k)
		for stage in WorldMap.STAGES_PER_ISLAND:
			_draw_stage(stage, k)
	else:
		_draw_locked(center, k)
	_draw_title(data.name, k)


func _draw_water(center: Vector2, k: float) -> void:
	for ring in 3:
		var phase := fmod(_time * 0.35 + ring / 3.0, 1.0)
		var radius := (300.0 + phase * 60.0) * k
		draw_set_transform(center + Vector2(0, 50) * k, 0.0, Vector2(1.0, 0.42))
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 64, Color(Color.WHITE, 0.35 * (1.0 - phase)), 4.0 * k, true)
	draw_set_transform(center + Vector2(0, 60) * k, 0.0, Vector2(1.0, 0.42))
	draw_circle(Vector2.ZERO, 300.0 * k, Color(WATER, 0.35))
	draw_set_transform(Vector2.ZERO)


func _draw_ground(center: Vector2, k: float, ground: Color, ground_dark: Color, playable: bool) -> void:
	var tint := Color.WHITE if playable else Color(0.55, 0.6, 0.7)
	_ellipse(center + Vector2(0, 66) * k, Vector2(282, 120) * k, Color(OUTLINE, 0.3))
	_ellipse(center + Vector2(0, 42) * k, Vector2(278, 118) * k, OUTLINE)
	_ellipse(center + Vector2(0, 40) * k, Vector2(272, 112) * k, (ground_dark * tint).darkened(0.15))
	_ellipse(center + Vector2(0, 8) * k, Vector2(278, 124) * k, OUTLINE)
	_ellipse(center + Vector2(0, 8) * k, Vector2(272, 118) * k, SAND * tint)
	_ellipse(center, Vector2(250, 104) * k, ground * tint)
	_ellipse(center + Vector2(-60, -30) * k, Vector2(120, 40) * k, (ground * tint).lightened(0.18))


func _draw_tree(at: Vector2, k: float, playable: bool) -> void:
	var tint := Color.WHITE if playable else Color(0.55, 0.6, 0.7)
	_ellipse(at + Vector2(0, 6) * k, Vector2(28, 10) * k, Color(OUTLINE, 0.25))
	draw_rect(Rect2(at + Vector2(-7, -22) * k, Vector2(14, 26) * k), OUTLINE)
	draw_rect(Rect2(at + Vector2(-4, -20) * k, Vector2(8, 22) * k), TRUNK * tint)
	draw_circle(at + Vector2(0, -44) * k, 33.0 * k, OUTLINE)
	draw_circle(at + Vector2(0, -44) * k, 29.0 * k, TREE_DARK * tint)
	draw_circle(at + Vector2(-6, -50) * k, 20.0 * k, GREEN * tint)


func _draw_rock(at: Vector2, k: float) -> void:
	_ellipse(at, Vector2(20, 13) * k, OUTLINE)
	_ellipse(at + Vector2(0, -1) * k, Vector2(16, 9) * k, ROCK)


func _draw_path(k: float) -> void:
	for stage in WorldMap.STAGES_PER_ISLAND - 1:
		var from := _stage_position(stage)
		var to := _stage_position(stage + 1)
		var bend := (from + to) / 2.0 + Vector2(0, 40) * k
		var dots := 9
		for d in range(1, dots):
			var t := float(d) / dots
			var point := from.lerp(bend, t).lerp(bend.lerp(to, t), t)
			draw_circle(point, 6.0 * k, OUTLINE)
			draw_circle(point, 3.5 * k, LIGHT)


func _draw_stage(stage: int, k: float) -> void:
	var at := _stage_position(stage)
	var key := Vector2i(island, stage)
	var unlocked := SaveData.is_stage_unlocked(key)
	var cleared := stage < SaveData.cleared_stages(island)
	var is_selected := stage == selected
	var radius := STAGE_RADIUS * k
	var color := GREEN if cleared else (FIRE if unlocked else ROCK)

	if is_selected:
		var pulse := 0.5 + 0.5 * sin(_time * 4.0)
		draw_circle(at, radius + (12.0 + pulse * 8.0) * k, Color(LIGHT, 0.35))
	_ellipse(at + Vector2(0, 10) * k, Vector2(radius, radius * 0.75), OUTLINE)
	draw_circle(at, radius + 4.0 * k, OUTLINE)
	draw_circle(at, radius, color)
	draw_circle(at + Vector2(-10, -10) * k, radius * 0.35, Color(Color.WHITE, 0.3))

	if unlocked:
		var font := get_theme_default_font()
		var font_size := int(38 * k)
		var baseline := at + Vector2(-radius, font_size * 0.36)
		var text := str(stage + 1)
		draw_string_outline(font, baseline, text, HORIZONTAL_ALIGNMENT_CENTER, radius * 2.0, font_size, int(12 * k), OUTLINE)
		draw_string(font, baseline, text, HORIZONTAL_ALIGNMENT_CENTER, radius * 2.0, font_size, Color.WHITE)
	else:
		MenuIcons.draw(self, "lock", at, radius * 1.3)

	if is_selected:
		var hop := absf(sin(_time * 3.0)) * 10.0 * k
		var witch_size := Vector2(96, 96) * k
		draw_texture_rect(WITCH, Rect2(at + Vector2(-48, -132) * k - Vector2(0, hop), witch_size), false)


func _draw_locked(center: Vector2, k: float) -> void:
	MenuIcons.draw(self, "lock", center + Vector2(0, -30) * k, 110.0 * k)
	var font := get_theme_default_font()
	var font_size := int(48 * k)
	var ribbon := Rect2(center + Vector2(-150, 34) * k, Vector2(300, 66) * k)
	draw_rect(ribbon.grow(4.0 * k), OUTLINE)
	draw_rect(ribbon, Color("#3A4766"))
	var baseline := center + Vector2(-size.x / 2.0, 84 * k)
	draw_string_outline(font, baseline, "À VENIR", HORIZONTAL_ALIGNMENT_CENTER, size.x, font_size, int(16 * k), OUTLINE)
	draw_string(font, baseline, "À VENIR", HORIZONTAL_ALIGNMENT_CENTER, size.x, font_size, LIGHT)


func _draw_title(title: String, k: float) -> void:
	var font := get_theme_default_font()
	var font_size := int(40 * maxf(k, 0.8))
	var label := "Île %d · %s" % [island + 1, title]
	var baseline := Vector2(0, font_size)
	draw_string_outline(font, baseline, label, HORIZONTAL_ALIGNMENT_CENTER, size.x, font_size, 14, OUTLINE)
	draw_string(font, baseline, label, HORIZONTAL_ALIGNMENT_CENTER, size.x, font_size, Color.WHITE)


func _ellipse(at: Vector2, radii: Vector2, color: Color) -> void:
	draw_set_transform(at, 0.0, Vector2(1.0, radii.y / radii.x))
	draw_circle(Vector2.ZERO, radii.x, color)
	draw_set_transform(Vector2.ZERO)
