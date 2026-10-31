extends Node2D

const GAME_SCENE := "res://scenes/main/main.tscn"
const SLIME_SCENE := preload("res://scenes/enemies/slime/slime.tscn")
const BLUR_SHADER := preload("res://scenes/menu/menu_blur.gdshader")
const OUTLINE := Color("#253047")
const GOLD := Color("#FFE6A1")
const GREEN := Color("#70C95B")
const STONE := Color("#879DA5")
const MAGIC := Color("#39C9F0")
const ARCANE := Color("#A45CDA")
const BACKGROUND_SLIMES := 10
const NAV_HEIGHT := 150.0
const LOGO_SCALE := 0.68

var _leaving := false
var _stage := Vector2i.ZERO
var _viewed_island := 0
var _pages: Array[Control] = []
var _fade: ColorRect
var _island_view: IslandView
var _stage_label: Label
var _play: Button
var _gold: GoldCounter
var _changelog: ChangelogPanel

@onready var arena: Arena = $Arena
@onready var entities: Node2D = $Entities
@onready var camera: Camera2D = $Camera2D
@onready var ui: CanvasLayer = $UI


func _ready() -> void:
	arena.generate(entities)
	camera.position = arena.bounds.get_center()
	_spawn_background_slimes()
	_stage = SaveData.selected_stage()
	if not SaveData.is_stage_unlocked(_stage):
		_stage = Vector2i.ZERO
	_viewed_island = _stage.x
	_build_ui()
	_refresh_stage()


func _spawn_background_slimes() -> void:
	var area := arena.bounds.grow(-120.0)
	for i in BACKGROUND_SLIMES:
		var slime := SLIME_SCENE.instantiate() as Slime
		slime.horde = i % 3 == 0
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

	for tab in NavBar.TABS.size():
		var page := _build_home() if tab == NavBar.HOME_TAB \
				else ComingSoonPage.new(NavBar.TABS[tab].title, NavBar.TABS[tab].id)
		page.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui.add_child(page)
		page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		page.offset_bottom = -NAV_HEIGHT
		page.visible = tab == NavBar.HOME_TAB
		_pages.append(page)

	var nav := NavBar.new()
	ui.add_child(nav)
	nav.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	nav.offset_top = -NAV_HEIGHT
	nav.tab_selected.connect(_show_page)

	_changelog = ChangelogPanel.new()
	ui.add_child(_changelog)

	_fade = ColorRect.new()
	_fade.color = OUTLINE
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(_fade)
	_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	create_tween().tween_property(_fade, "color:a", 0.0, 0.5)


func _build_home() -> Control:
	var home := Control.new()
	_build_top_bar(home)

	var logo := GameLogo.new()
	home.add_child(logo)
	logo.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	logo.offset_top = 112
	logo.offset_bottom = 332
	logo.scale = Vector2.ONE * LOGO_SCALE
	logo.resized.connect(func() -> void: logo.pivot_offset = Vector2(logo.size.x / 2.0, 0.0))

	_island_view = IslandView.new()
	home.add_child(_island_view)
	_island_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_island_view.offset_top = 280
	_island_view.offset_bottom = -280
	_island_view.stage_selected.connect(_on_stage_selected)
	_island_view.show_island(_viewed_island, _stage.y)
	_add_island_arrow(Control.PRESET_CENTER_LEFT, "arrow_left", -1)
	_add_island_arrow(Control.PRESET_CENTER_RIGHT, "arrow_right", 1)

	_stage_label = _make_label("", 30, GOLD)
	home.add_child(_stage_label)
	_stage_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_stage_label.offset_top = -270
	_stage_label.offset_bottom = -220

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 28)
	home.add_child(actions)
	actions.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	actions.offset_top = -210
	actions.offset_bottom = -30

	_play = Button.new()
	_play.custom_minimum_size = Vector2(360, 124)
	_play.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_play.pressed.connect(_on_play_pressed)
	actions.add_child(_play)
	_play.resized.connect(func() -> void: _play.pivot_offset = _play.size / 2.0)
	var pulse := create_tween().set_loops()
	pulse.tween_property(_play, "scale", Vector2(1.05, 1.05), 0.7).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(_play, "scale", Vector2.ONE, 0.7).set_trans(Tween.TRANS_SINE)
	return home


func _build_top_bar(home: Control) -> void:
	_gold = GoldCounter.new()
	home.add_child(_gold)
	_gold.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_gold.offset_left = -318
	_gold.offset_right = -114
	_gold.offset_top = 40
	_gold.offset_bottom = 112

	var changelog := IconButton.new("scroll", MAGIC, Vector2(84, 84))
	home.add_child(changelog)
	changelog.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	changelog.offset_left = -102
	changelog.offset_right = -18
	changelog.offset_top = 34
	changelog.offset_bottom = 118
	changelog.pressed.connect(_open_changelog)

	var version := _make_label(Changelog.current_version(), 20, Color(1, 1, 1, 0.7))
	home.add_child(version)
	version.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	version.offset_left = -102
	version.offset_right = -18
	version.offset_top = 122
	version.offset_bottom = 150


func _add_island_arrow(preset: Control.LayoutPreset, icon: String, direction: int) -> void:
	var arrow := IconButton.new(icon, ARCANE, Vector2(76, 76))
	_island_view.add_child(arrow)
	arrow.set_anchors_and_offsets_preset(preset)
	var side := 14.0 if direction < 0 else -90.0
	arrow.offset_left = side
	arrow.offset_right = side + 76.0
	arrow.offset_top = -38
	arrow.offset_bottom = 38
	arrow.pressed.connect(_change_island.bind(direction))


func _open_changelog() -> void:
	_changelog.open()


func _show_page(index: int) -> void:
	for tab in _pages.size():
		_pages[tab].visible = tab == index
	var page := _pages[index]
	page.modulate.a = 0.0
	page.position.y = 30.0
	var tween := create_tween().set_parallel()
	tween.tween_property(page, "modulate:a", 1.0, 0.18)
	tween.tween_property(page, "position:y", 0.0, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _change_island(direction: int) -> void:
	_viewed_island = wrapi(_viewed_island + direction, 0, WorldMap.island_count())
	var stage := _stage.y if _viewed_island == _stage.x else _last_unlocked_stage(_viewed_island)
	_island_view.show_island(_viewed_island, stage, direction)
	if WorldMap.is_playable(_viewed_island):
		_select_stage(Vector2i(_viewed_island, stage))
	_refresh_stage()


func _last_unlocked_stage(island: int) -> int:
	return mini(SaveData.cleared_stages(island), WorldMap.STAGES_PER_ISLAND - 1)


func _select_stage(stage: Vector2i) -> void:
	_stage = stage
	SaveData.select_stage(stage)
	_island_view.selected = stage.y


func _refresh_stage() -> void:
	var playable := WorldMap.is_playable(_viewed_island)
	if playable:
		_stage_label.text = "Niveau %s · %s" % [WorldMap.stage_label(_stage), WorldMap.stage_name(_stage)]
	else:
		_stage_label.text = "Cette île arrive bientôt !"
	_play.text = "Jouer" if playable else "Bientôt"
	_play.disabled = not playable
	UiStyle.style_button(_play, GREEN if playable else STONE, 52)


func _on_stage_selected(stage: Vector2i) -> void:
	if not SaveData.is_stage_unlocked(stage):
		var previous := Vector2i(stage.x, stage.y - 1)
		_stage_label.text = "Bats le Roi Gluant du niveau %s !" % WorldMap.stage_label(previous)
		return
	_select_stage(stage)
	_refresh_stage()


func _make_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var settings := LabelSettings.new()
	settings.font_size = font_size
	settings.font_color = color
	settings.outline_size = int(font_size / 3.0)
	settings.outline_color = OUTLINE
	label.label_settings = settings
	return label


func _on_play_pressed() -> void:
	if _leaving or not SaveData.is_stage_unlocked(_stage):
		return
	_leaving = true
	var tween := create_tween()
	tween.tween_property(_play, "scale", Vector2(0.9, 0.9), 0.06)
	tween.tween_property(_play, "scale", Vector2(1.1, 1.1), 0.12)
	tween.tween_property(_fade, "color:a", 1.0, 0.35)
	tween.tween_callback(func() -> void: get_tree().change_scene_to_file(GAME_SCENE))
