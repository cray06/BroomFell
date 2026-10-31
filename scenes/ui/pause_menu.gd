class_name PauseMenu
extends Control

signal resume_requested
signal menu_requested

const OUTLINE := Color("#253047")
const CREAM := Color("#FFF6E0")
const MAGIC := Color("#39C9F0")
const GREEN := Color("#70C95B")
const DANGER := Color("#F05B52")

var _dim := 0.0
var _panel: PanelContainer


func _ready() -> void:
	hide()
	mouse_filter = MOUSE_FILTER_STOP
	_build()


func open() -> void:
	show()
	_dim = 0.0
	create_tween().tween_property(self, "_dim", 0.7, 0.2)
	await get_tree().process_frame
	_panel.pivot_offset = _panel.size / 2.0
	_panel.scale = Vector2(0.6, 0.6)
	var tween := create_tween()
	tween.tween_property(_panel, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func close() -> void:
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_resume()


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
	var style := StyleBoxFlat.new()
	style.bg_color = CREAM
	style.border_color = OUTLINE
	style.set_border_width_all(6)
	style.set_corner_radius_all(30)
	style.shadow_color = Color(MAGIC, 0.4)
	style.shadow_size = 18
	style.set_content_margin_all(36)
	_panel.add_theme_stylebox_override("panel", style)
	_panel.custom_minimum_size = Vector2(460, 0)
	center.add_child(_panel)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 22)
	_panel.add_child(column)

	var title := Label.new()
	title.text = "PAUSE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var settings := LabelSettings.new()
	settings.font_size = 64
	settings.font_color = MAGIC
	settings.outline_size = 16
	settings.outline_color = OUTLINE
	title.label_settings = settings
	column.add_child(title)

	column.add_child(_button("Continuer", GREEN, 40, 92, _on_resume))
	column.add_child(_button("Quitter vers le menu", DANGER, 28, 72, _on_menu))


func _button(text: String, color: Color, font_size: int, height: float, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, height)
	UiStyle.style_button(button, color, font_size)
	button.pressed.connect(action)
	return button


func _on_resume() -> void:
	resume_requested.emit()


func _on_menu() -> void:
	menu_requested.emit()
