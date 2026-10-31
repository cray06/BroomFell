class_name Fx
extends RefCounted

const OUTLINE := Color("#253047")
const LIGHT := Color("#FFE6A1")
const CRIT := Color("#FF9138")

static var _dot_texture: Texture2D
static var _shrink_curve: Curve


static func dot_texture() -> Texture2D:
	if _dot_texture == null:
		var gradient := Gradient.new()
		gradient.offsets = PackedFloat32Array([0.0, 0.8, 1.0])
		gradient.colors = PackedColorArray([Color.WHITE, Color.WHITE, Color(1, 1, 1, 0)])
		var texture := GradientTexture2D.new()
		texture.gradient = gradient
		texture.fill = GradientTexture2D.FILL_RADIAL
		texture.fill_from = Vector2(0.5, 0.5)
		texture.fill_to = Vector2(0.5, 0.0)
		texture.width = 32
		texture.height = 32
		_dot_texture = texture
	return _dot_texture


static func shrink_curve() -> Curve:
	if _shrink_curve == null:
		_shrink_curve = Curve.new()
		_shrink_curve.add_point(Vector2(0.0, 1.0))
		_shrink_curve.add_point(Vector2(1.0, 0.0))
	return _shrink_curve


static func burst(parent: Node, at: Vector2, color: Color, amount: int = 12,
		speed: float = 220.0, size: float = 0.45) -> void:
	var particles := CPUParticles2D.new()
	particles.one_shot = true
	particles.emitting = false
	particles.amount = amount
	particles.lifetime = 0.45
	particles.explosiveness = 1.0
	particles.texture = dot_texture()
	particles.spread = 180.0
	particles.gravity = Vector2.ZERO
	particles.initial_velocity_min = speed * 0.4
	particles.initial_velocity_max = speed
	particles.damping_min = speed * 1.2
	particles.damping_max = speed * 1.8
	particles.scale_amount_min = size * 0.5
	particles.scale_amount_max = size
	particles.scale_amount_curve = shrink_curve()
	particles.color = color
	particles.z_index = 50
	parent.add_child(particles)
	particles.global_position = at
	particles.finished.connect(particles.queue_free)
	particles.emitting = true


static func damage_number(parent: Node, at: Vector2, amount: int, color: Color = LIGHT,
		crit: bool = false) -> void:
	if crit:
		popup_text(parent, at, "%d!" % amount, CRIT, 40)
	else:
		popup_text(parent, at, str(amount), color, 30)


static func popup_text(parent: Node, at: Vector2, text: String, color: Color, font_size: int = 34) -> void:
	var box := Vector2(maxf(80.0, text.length() * font_size * 0.65), font_size + 16.0)
	var label := Label.new()
	label.text = text
	var settings := LabelSettings.new()
	settings.font_size = font_size
	settings.font_color = color
	settings.outline_size = int(font_size / 3.0)
	settings.outline_color = OUTLINE
	label.label_settings = settings
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = box
	label.pivot_offset = box / 2.0
	label.z_index = 100
	parent.add_child(label)
	label.global_position = at - box / 2.0
	label.scale = Vector2(0.4, 0.4)

	var tween := label.create_tween()
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.1) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector2.ONE, 0.1)
	tween.parallel().tween_property(label, "position:y", label.position.y - 50.0, 0.6) \
		.set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.25).set_delay(0.35)
	tween.tween_callback(label.queue_free)
