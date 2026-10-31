class_name GameOverScreen
extends Control

signal restart_requested
signal menu_requested

const OUTLINE := Color("#253047")
const CREAM := Color("#FFF6E0")
const DANGER := Color("#F05B52")
const GOLD := Color("#FFE6A1")
const GREEN := Color("#70C95B")
const STONE := Color("#879DA5")
const WITCH := preload("res://assets/sprites/characters/witch.svg")

var _dim := 0.0
var _panel: PanelContainer
var _score_label: Label
var _level_label: Label
var _record_label: Label


func _ready() -> void:
	hide()
	mouse_filter = MOUSE_FILTER_STOP
	_build()


func open(score: int, level: int, new_record: bool, previous_best: int) -> void:
	_score_label.text = "Score : %d" % score
	_level_label.text = "Niveau atteint : %d" % level
	if new_record:
		_record_label.text = "NOUVEAU RECORD !"
		_record_label.label_settings.font_color = GREEN
	else:
		_record_label.text = "Meilleur score : %d" % previous_best
		_record_label.label_settings.font_color = GOLD
	show()
	create_tween().tween_property(self, "_dim", 0.8, 0.3)
	await get_tree().process_frame
	_panel.pivot_offset = _panel.size / 2.0
	_panel.scale = Vector2(0.4, 0.4)
	_panel.modulate.a = 0.0
	var tween := create_tween().set_parallel()
	tween.tween_property(_panel, "scale", Vector2.ONE, 0.5) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_panel, "modulate:a", 1.0, 0.2)


func _process(_delta: float) -> void:
	if visible:
		queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(OUTLINE, _dim))


func _build() -> void:
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	center.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(center)

	_panel = PanelContainer.new()
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = CREAM
	panel_style.border_color = OUTLINE
	panel_style.set_border_width_all(6)
	panel_style.set_corner_radius_all(30)
	panel_style.shadow_color = Color(DANGER, 0.45)
	panel_style.shadow_size = 18
	panel_style.set_content_margin_all(36)
	_panel.add_theme_stylebox_override("panel", panel_style)
	_panel.custom_minimum_size = Vector2(500, 0)
	center.add_child(_panel)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	_panel.add_child(column)

	var witch := TextureRect.new()
	witch.texture = WITCH
	witch.custom_minimum_size = Vector2(0, 150)
	witch.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	witch.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	witch.modulate = Color(0.75, 0.75, 0.85)
	column.add_child(witch)

	column.add_child(_label("DÉFAITE", 64, DANGER, 16))
	_score_label = _label("Score : 0", 40, GOLD, 12)
	column.add_child(_score_label)
	_level_label = _label("Niveau atteint : 1", 26, OUTLINE, 0)
	column.add_child(_level_label)

	_record_label = _label("", 28, GOLD, 10)
	column.add_child(_record_label)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	column.add_child(spacer)

	var replay := Button.new()
	replay.text = "Rejouer"
	replay.custom_minimum_size = Vector2(0, 84)
	UiStyle.style_button(replay, GREEN, 38)
	replay.pressed.connect(_on_button.bind(restart_requested))
	column.add_child(replay)

	var menu := Button.new()
	menu.text = "Menu"
	menu.custom_minimum_size = Vector2(0, 66)
	UiStyle.style_button(menu, STONE, 30)
	menu.pressed.connect(_on_button.bind(menu_requested))
	column.add_child(menu)


func _on_button(action: Signal) -> void:
	action.emit()


func _label(text: String, font_size: int, color: Color, outline: int) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var settings := LabelSettings.new()
	settings.font_size = font_size
	settings.font_color = color
	settings.outline_size = outline
	settings.outline_color = OUTLINE
	label.label_settings = settings
	return label
