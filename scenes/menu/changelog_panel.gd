class_name ChangelogPanel
extends Control

const OUTLINE := Color("#253047")
const PANEL := Color("#3A4766")
const CARD := Color("#2E3A55")
const LIGHT := Color("#FFE6A1")
const MAGIC := Color("#39C9F0")
const DANGER := Color("#F05B52")

var _window: PanelContainer


func _ready() -> void:
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_STOP
	hide()

	var dim := ColorRect.new()
	dim.color = Color(OUTLINE, 0.7)
	dim.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(dim)
	dim.set_anchors_and_offsets_preset(PRESET_FULL_RECT)

	_window = PanelContainer.new()
	_window.add_theme_stylebox_override("panel", _box(PANEL, 36, 24))
	add_child(_window)
	_window.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_window.offset_left = 36
	_window.offset_right = -36
	_window.offset_top = 140
	_window.offset_bottom = -180

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 18)
	_window.add_child(layout)

	var header := HBoxContainer.new()
	layout.add_child(header)
	var title := _label("Nouveautés", 50, LIGHT)
	title.size_flags_horizontal = SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	header.add_child(title)
	var close := IconButton.new("close", DANGER, Vector2(72, 72))
	close.pressed.connect(close_panel)
	header.add_child(close)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	layout.add_child(scroll)
	var entries := VBoxContainer.new()
	entries.size_flags_horizontal = SIZE_EXPAND_FILL
	entries.add_theme_constant_override("separation", 20)
	scroll.add_child(entries)
	for entry in Changelog.ENTRIES:
		entries.add_child(_entry_card(entry))


func open() -> void:
	show()
	modulate.a = 0.0
	_window.pivot_offset = _window.size / 2.0
	_window.scale = Vector2(0.85, 0.85)
	var tween := create_tween().set_parallel()
	tween.tween_property(self, "modulate:a", 1.0, 0.15)
	tween.tween_property(_window, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func close_panel() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.12)
	tween.tween_callback(hide)


func _entry_card(entry: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _box(CARD, 24, 18))
	var lines := VBoxContainer.new()
	lines.add_theme_constant_override("separation", 8)
	card.add_child(lines)

	var heading := _label("%s  ·  %s" % [entry.version, entry.date], 34, MAGIC)
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	lines.add_child(heading)
	for change: String in entry.changes:
		var line := _label("•  " + change, 24, Color.WHITE)
		line.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lines.add_child(line)
	return card


func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	var settings := LabelSettings.new()
	settings.font_size = font_size
	settings.font_color = color
	settings.outline_size = int(font_size / 3.0)
	settings.outline_color = OUTLINE
	label.label_settings = settings
	return label


func _box(color: Color, radius: int, margin: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = OUTLINE
	style.set_border_width_all(5)
	style.set_corner_radius_all(radius)
	style.set_content_margin_all(margin)
	return style
