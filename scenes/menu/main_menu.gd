extends Node2D
## Page d'accueil : logo, sorcière qui vole, boutons Jouer / Quitter,
## meilleur score. Le décor du jeu tourne en fond, flouté.

const GAME_SCENE := "res://scenes/main/main.tscn"
const SLIME_SCENE := preload("res://scenes/enemies/slime/slime.tscn")
const WITCH := preload("res://assets/sprites/characters/witch.svg")
const BLUR_SHADER := preload("res://scenes/menu/menu_blur.gdshader")
const OUTLINE := Color("#253047")
const GOLD := Color("#FFE6A1")
const GREEN := Color("#70C95B")
const DANGER := Color("#F05B52")
const MAGIC := Color("#39C9F0")
const BACKGROUND_SLIMES := 10
const VERSION := "v0.1"

var _time := 0.0
var _leaving := false
var _witch: Sprite2D
var _fade: ColorRect

@onready var arena: Arena = $Arena
@onready var entities: Node2D = $Entities
@onready var camera: Camera2D = $Camera2D
@onready var ui: CanvasLayer = $UI


func _ready() -> void:
	arena.generate(entities)
	camera.position = arena.bounds.get_center()
	_spawn_background_slimes()
	_build_ui()


func _process(delta: float) -> void:
	_time += delta
	if _witch:
		var view := get_viewport_rect().size
		_witch.position = Vector2(view.x / 2.0 + sin(_time * 0.8) * 60.0, 250.0 + sin(_time * 2.0) * 14.0)
		_witch.rotation = -0.12 + sin(_time * 2.0) * 0.06


func _spawn_background_slimes() -> void:
	for i in BACKGROUND_SLIMES:
		var slime := SLIME_SCENE.instantiate() as Slime
		slime.horde = i % 3 == 0
		var area := arena.bounds.grow(-120.0)
		slime.position = Vector2(randf_range(area.position.x, area.end.x), randf_range(area.position.y, area.end.y))
		entities.add_child(slime)
		slime.health_bar.hide()


func _build_ui() -> void:
	var blur := ColorRect.new()
	var blur_material := ShaderMaterial.new()
	blur_material.shader = BLUR_SHADER
	blur.material = blur_material
	blur.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(blur)
	blur.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Sorcière sur son balai, avec une traînée d'étincelles.
	_witch = Sprite2D.new()
	_witch.texture = WITCH
	_witch.scale = Vector2(1.5, 1.5)
	ui.add_child(_witch)
	var trail := CPUParticles2D.new()
	trail.amount = 40
	trail.lifetime = 0.9
	trail.texture = Fx.dot_texture()
	trail.position = Vector2(30, 40)
	trail.direction = Vector2(1, 0.4)
	trail.spread = 25.0
	trail.gravity = Vector2(0, 30)
	trail.initial_velocity_min = 60.0
	trail.initial_velocity_max = 140.0
	trail.scale_amount_min = 0.15
	trail.scale_amount_max = 0.35
	var shrink := Curve.new()
	shrink.add_point(Vector2(0.0, 1.0))
	shrink.add_point(Vector2(1.0, 0.0))
	trail.scale_amount_curve = shrink
	var colors := Gradient.new()
	colors.colors = PackedColorArray([GOLD, MAGIC])
	trail.color_ramp = colors
	trail.show_behind_parent = true
	_witch.add_child(trail)

	var logo := GameLogo.new()
	ui.add_child(logo)
	logo.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	logo.offset_top = 340
	logo.offset_bottom = 560

	var buttons := VBoxContainer.new()
	buttons.add_theme_constant_override("separation", 26)
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	ui.add_child(buttons)
	buttons.set_anchors_preset(Control.PRESET_CENTER)
	buttons.anchor_top = 0.55
	buttons.anchor_bottom = 0.55
	buttons.offset_left = -190
	buttons.offset_right = 190
	buttons.offset_top = 0
	buttons.offset_bottom = 230

	var play := _make_button("Jouer", GREEN, 52, Vector2(380, 120))
	play.pressed.connect(_on_play_pressed.bind(play))
	buttons.add_child(play)
	var quit := _make_button("Quitter", DANGER, 34, Vector2(300, 84))
	quit.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	quit.pressed.connect(_on_quit_pressed)
	buttons.add_child(quit)

	var best := _make_label("Meilleur score : %d" % SaveData.best_score(), 32, GOLD)
	ui.add_child(best)
	best.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	best.offset_top = -190
	best.offset_bottom = -140

	var version := _make_label(VERSION, 20, Color(1, 1, 1, 0.6))
	ui.add_child(version)
	version.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	version.offset_top = -60
	version.offset_bottom = -24

	# Fondu d'ouverture.
	_fade = ColorRect.new()
	_fade.color = OUTLINE
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(_fade)
	_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	create_tween().tween_property(_fade, "color:a", 0.0, 0.5)

	# Le bouton Jouer respire pour attirer l'œil.
	play.resized.connect(func() -> void: play.pivot_offset = play.size / 2.0)
	var pulse := create_tween().set_loops()
	pulse.tween_property(play, "scale", Vector2(1.05, 1.05), 0.7).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(play, "scale", Vector2.ONE, 0.7).set_trans(Tween.TRANS_SINE)


func _make_button(text: String, color: Color, font_size: int, min_size: Vector2) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = min_size
	UiStyle.style_button(button, color, font_size)
	return button


func _make_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var settings := LabelSettings.new()
	settings.font_size = font_size
	settings.font_color = color
	settings.outline_size = int(font_size / 3.0)
	settings.outline_color = OUTLINE
	label.label_settings = settings
	return label


func _on_play_pressed(button: Button) -> void:
	if _leaving:
		return
	_leaving = true
	var tween := create_tween()
	tween.tween_property(button, "scale", Vector2(0.9, 0.9), 0.06)
	tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.12)
	tween.tween_property(_fade, "color:a", 1.0, 0.35)
	tween.tween_callback(func() -> void: get_tree().change_scene_to_file(GAME_SCENE))


func _on_quit_pressed() -> void:
	get_tree().quit()
