class_name XpBar
extends Control
## Barre d'XP en haut de l'écran, avec un badge de niveau à gauche.
## Passe en arc-en-ciel animé quand elle est pleine.

const OUTLINE := Color("#253047")
const BADGE := Color("#FFE6A1")
const BADGE_RADIUS := 28.0
const FILL_SHADER := preload("res://scenes/ui/xp_bar.gdshader")

var _target_ratio := 0.0
var _shown_ratio := 0.0
var _rainbow := 0.0
var _fill: ColorRect
var _badge: LevelBadge
var _material: ShaderMaterial


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	_material = ShaderMaterial.new()
	_material.shader = FILL_SHADER
	_fill = ColorRect.new()
	_fill.material = _material
	_fill.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_fill)
	_badge = LevelBadge.new()
	add_child(_badge)
	resized.connect(_layout)
	_layout()


func set_ratio(ratio: float) -> void:
	_target_ratio = clampf(ratio, 0.0, 1.0)


func set_level(level: int) -> void:
	_badge.level = level
	_badge.queue_redraw()
	_badge.scale = Vector2(1.5, 1.5)
	create_tween().tween_property(_badge, "scale", Vector2.ONE, 0.4) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


func set_rainbow(enabled: bool) -> void:
	var tween := create_tween()
	tween.tween_property(self, "_rainbow", 1.0 if enabled else 0.0, 0.25)
	if enabled:
		_shown_ratio = 1.0
		pivot_offset = size / 2.0
		scale = Vector2(1.06, 1.25)
		tween.parallel().tween_property(self, "scale", Vector2.ONE, 0.5) \
			.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	else:
		_shown_ratio = 0.0


func _process(delta: float) -> void:
	_shown_ratio = lerpf(_shown_ratio, _target_ratio, minf(1.0, 10.0 * delta))
	_material.set_shader_parameter("ratio", _shown_ratio)
	_material.set_shader_parameter("rainbow", _rainbow)


func _draw() -> void:
	var frame := StyleBoxFlat.new()
	frame.bg_color = OUTLINE
	frame.set_corner_radius_all(int(size.y / 2.0))
	frame.shadow_color = Color(OUTLINE, 0.35)
	frame.shadow_size = 4
	frame.shadow_offset = Vector2(0, 3)
	draw_style_box(frame, Rect2(Vector2(BADGE_RADIUS, 0), Vector2(size.x - BADGE_RADIUS, size.y)))


func _layout() -> void:
	var left := BADGE_RADIUS * 2.0 - 2.0
	_fill.position = Vector2(left, 6)
	_fill.size = Vector2(size.x - left - 6.0, size.y - 12.0)
	_material.set_shader_parameter("rect_size", _fill.size)
	var diameter := BADGE_RADIUS * 2.0 + 8.0
	_badge.size = Vector2(diameter, diameter)
	_badge.position = Vector2(-4, size.y / 2.0 - diameter / 2.0)
	_badge.pivot_offset = _badge.size / 2.0
	queue_redraw()


## Rond jaune avec le numéro du niveau.
class LevelBadge extends Control:
	var level := 1

	func _ready() -> void:
		mouse_filter = MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var center := size / 2.0
		draw_circle(center, XpBar.BADGE_RADIUS + 4.0, XpBar.OUTLINE)
		draw_circle(center, XpBar.BADGE_RADIUS, XpBar.BADGE)
		draw_circle(center + Vector2(-8, -9), 7.0, Color(1, 1, 1, 0.55))
		var font := get_theme_default_font()
		draw_string(font, center + Vector2(-XpBar.BADGE_RADIUS, -12.0), "NIV",
				HORIZONTAL_ALIGNMENT_CENTER, XpBar.BADGE_RADIUS * 2.0, 13, XpBar.OUTLINE)
		draw_string(font, center + Vector2(-XpBar.BADGE_RADIUS, 15.0), str(level),
				HORIZONTAL_ALIGNMENT_CENTER, XpBar.BADGE_RADIUS * 2.0, 28, XpBar.OUTLINE)
