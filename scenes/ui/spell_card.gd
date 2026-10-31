class_name SpellCard
extends Control

signal picked(card: SpellCard)

const CARD_SIZE := Vector2(196, 340)
const HEADER_HEIGHT := 150.0
const RADIUS := 22
const OUTLINE := Color("#253047")
const CREAM := Color("#FFF6E0")
const PIP_EMPTY := Color("#E9DCC0")
const NIGHT := Color("#2E3A55")
const NIGHT_PIP := Color("#46547A")
const LIGHT := Color("#FFE6A1")
const RIBBON_OVERHANG := 6.0
const TITLE_MAX_SIZE := 24
const TITLE_MIN_SIZE := 15
const SHINE_SHADER := preload("res://scenes/ui/card_shine.gdshader")

var offer: Dictionary

var _index := 0
var _time := 0.0
var _base_y := 0.0
var _interactive := false
var _hovered := false
var _flash := 0.0
var _shine: ColorRect
var _hover_tween: Tween


func setup(card_offer: Dictionary, index: int) -> void:
	offer = card_offer
	_index = index


func _ready() -> void:
	size = CARD_SIZE
	pivot_offset = CARD_SIZE / 2.0
	mouse_filter = MOUSE_FILTER_STOP
	mouse_entered.connect(_on_hover.bind(true))
	mouse_exited.connect(_on_hover.bind(false))

	var shine_material := ShaderMaterial.new()
	shine_material.shader = SHINE_SHADER
	shine_material.set_shader_parameter("rect_size", CARD_SIZE)
	shine_material.set_shader_parameter("radius", float(RADIUS))
	_shine = ColorRect.new()
	_shine.size = CARD_SIZE
	_shine.material = shine_material
	_shine.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_shine)


func _process(delta: float) -> void:
	_time += delta
	if _interactive:
		position.y = _base_y + sin(_time * 2.2 + _index * 1.3) * 5.0
	var sweep := fmod(_time * 0.45 + _index * 0.22, 1.0) * 2.6 - 0.6
	(_shine.material as ShaderMaterial).set_shader_parameter("progress", sweep)
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if not _interactive:
		return
	var mouse := event as InputEventMouseButton
	if mouse and mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		picked.emit(self)


func animate_in(target: Vector2, delay: float) -> void:
	_base_y = target.y
	position = target + Vector2(0, 900)
	rotation = randf_range(-0.35, 0.35)
	scale = Vector2(0.7, 0.7)
	var tween := create_tween().set_parallel()
	tween.tween_property(self, "position", target, 0.55).set_delay(delay) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation", 0.0, 0.55).set_delay(delay) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.55).set_delay(delay) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.chain().tween_callback(func() -> void: _interactive = true)


func animate_chosen() -> void:
	_interactive = false
	_flash = 1.0
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.15) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "_flash", 0.0, 0.3)
	tween.tween_property(self, "position:y", position.y - 80.0, 0.25).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.25)


func animate_discard() -> void:
	_interactive = false
	var tween := create_tween().set_parallel()
	tween.tween_property(self, "position:y", position.y + 600.0, 0.4) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "rotation", randf_range(-0.5, 0.5), 0.4)
	tween.tween_property(self, "modulate:a", 0.0, 0.4)


func _fit_font_size(font: Font, text: String, max_width: float) -> int:
	var font_size := TITLE_MAX_SIZE
	while font_size > TITLE_MIN_SIZE and font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > max_width:
		font_size -= 1
	return font_size


func _on_hover(entered: bool) -> void:
	_hovered = entered and _interactive
	if _hover_tween:
		_hover_tween.kill()
	if not _interactive:
		return
	_hover_tween = create_tween()
	_hover_tween.tween_property(self, "scale", Vector2.ONE * (1.07 if entered else 1.0), 0.15) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _draw() -> void:
	var color: Color = offer.color
	var w := size.x
	var glow := 0.5 + 0.5 * sin(_time * 3.0 + _index)
	var font := get_theme_default_font()
	var is_augment: bool = offer.get("kind", "spell") == "augment"
	var body_color := NIGHT if is_augment else CREAM
	var text_color := CREAM if is_augment else OUTLINE

	var frame := StyleBoxFlat.new()
	frame.bg_color = body_color
	frame.border_color = OUTLINE
	frame.set_border_width_all(5)
	frame.set_corner_radius_all(RADIUS)
	frame.shadow_color = Color(color, 0.35 + 0.3 * glow)
	frame.shadow_size = int(10.0 + 10.0 * glow) + (8 if _hovered else 0)
	frame.shadow_offset = Vector2(0, 4)
	draw_style_box(frame, Rect2(Vector2.ZERO, size))
	if is_augment:
		var inner := StyleBoxFlat.new()
		inner.draw_center = false
		inner.border_color = Color(LIGHT, 0.7)
		inner.set_border_width_all(2)
		inner.set_corner_radius_all(RADIUS - 8)
		draw_style_box(inner, Rect2(Vector2(10, 10), size - Vector2(20, 20)))

	var header := StyleBoxFlat.new()
	header.bg_color = color
	header.corner_radius_top_left = RADIUS - 5
	header.corner_radius_top_right = RADIUS - 5
	draw_style_box(header, Rect2(5, 5, w - 10, HEADER_HEIGHT))
	var icon_center := Vector2(w / 2.0, 78)
	draw_circle(icon_center, 62.0, Color(1, 1, 1, 0.12))
	draw_circle(icon_center, 47.0, Color(1, 1, 1, 0.2))
	_draw_sparkles()
	SpellIcons.draw(self, offer.id, icon_center, 88.0)

	var badge_text := "NOUVEAU !" if offer.level == 0 else "NIV. %d" % (offer.level + 1)
	if offer.max_level == 0:
		badge_text = "BONUS"
	_draw_badge(font, badge_text)
	if offer.max_level > 0:
		_draw_kind_tag(font, "AUGMENT" if is_augment else "SORT", is_augment)

	var o := RIBBON_OVERHANG
	var ribbon := PackedVector2Array([
		Vector2(-o, 136), Vector2(w + o, 136), Vector2(w - 4, 158),
		Vector2(w + o, 180), Vector2(-o, 180), Vector2(4, 158),
	])
	draw_colored_polygon(ribbon, color.darkened(0.25))
	draw_colored_polygon(PackedVector2Array([Vector2(-o, 136), Vector2(w + o, 136),
			Vector2(w + o - 4, 145), Vector2(4 - o, 145)]), Color(1, 1, 1, 0.18))
	ribbon.append(ribbon[0])
	draw_polyline(ribbon, OUTLINE, 4.0, true)
	var title_size := _fit_font_size(font, offer.title, w - 24.0)
	draw_string_outline(font, Vector2(0, 167), offer.title, HORIZONTAL_ALIGNMENT_CENTER, w,
			title_size, 9, OUTLINE)
	draw_string(font, Vector2(0, 167), offer.title, HORIZONTAL_ALIGNMENT_CENTER, w,
			title_size, Color.WHITE)

	var max_level: int = offer.max_level
	for k in max_level:
		var at := Vector2(w / 2.0 + (k - (max_level - 1) / 2.0) * 24.0, 206)
		var r := 8.0
		var fill := NIGHT_PIP if is_augment else PIP_EMPTY
		if k < offer.level:
			fill = color
		elif k == offer.level:
			fill = LIGHT
			r = 8.0 + glow * 2.5
			draw_circle(at, r + 6.0, Color(LIGHT, 0.35 * glow))
		var pip := PackedVector2Array([at + Vector2(0, -r), at + Vector2(r, 0),
				at + Vector2(0, r), at + Vector2(-r, 0)])
		draw_colored_polygon(pip, fill)
		pip.append(pip[0])
		draw_polyline(pip, OUTLINE, 2.5, true)

	var text_top := 250.0 if max_level > 0 else 230.0
	draw_multiline_string(font, Vector2(16, text_top), offer.description,
			HORIZONTAL_ALIGNMENT_CENTER, w - 32, 19, 4, text_color)

	if _flash > 0.0:
		var flash := StyleBoxFlat.new()
		flash.bg_color = Color(1, 1, 1, _flash)
		flash.set_corner_radius_all(RADIUS)
		draw_style_box(flash, Rect2(Vector2.ZERO, size))


func _draw_badge(font: Font, text: String) -> void:
	var text_width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x
	var pill := StyleBoxFlat.new()
	pill.bg_color = LIGHT
	pill.border_color = OUTLINE
	pill.set_border_width_all(3)
	pill.set_corner_radius_all(12)
	draw_set_transform(Vector2(-6, -8), -0.12)
	draw_style_box(pill, Rect2(0, 0, text_width + 22, 28))
	draw_string(font, Vector2(11, 20), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, OUTLINE)
	draw_set_transform(Vector2.ZERO)


func _draw_kind_tag(font: Font, text: String, is_augment: bool) -> void:
	var text_width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
	var pill := StyleBoxFlat.new()
	pill.bg_color = NIGHT if is_augment else CREAM
	pill.border_color = OUTLINE
	pill.set_border_width_all(3)
	pill.set_corner_radius_all(10)
	var width := text_width + 18
	draw_set_transform(Vector2(size.x - width + 6, -6), 0.1)
	draw_style_box(pill, Rect2(0, 0, width, 24))
	draw_string(font, Vector2(9, 17), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13,
			LIGHT if is_augment else OUTLINE)
	draw_set_transform(Vector2.ZERO)


func _draw_sparkles() -> void:
	var spots: Array[Vector3] = [
		Vector3(34, 40, 0.0), Vector3(170, 32, 1.7), Vector3(160, 118, 3.1), Vector3(40, 112, 4.4),
	]
	for spot in spots:
		var twinkle := maxf(0.0, sin(_time * 3.5 + spot.z))
		var r := 3.0 + twinkle * 5.0
		var c := Vector2(spot.x, spot.y)
		draw_colored_polygon(PackedVector2Array([c + Vector2(0, -r), c + Vector2(r * 0.3, 0),
				c + Vector2(0, r), c + Vector2(-r * 0.3, 0)]), Color(1, 1, 1, 0.4 + 0.5 * twinkle))
		draw_colored_polygon(PackedVector2Array([c + Vector2(-r, 0), c + Vector2(0, -r * 0.3),
				c + Vector2(r, 0), c + Vector2(0, r * 0.3)]), Color(1, 1, 1, 0.4 + 0.5 * twinkle))
