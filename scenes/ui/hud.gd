class_name Hud
extends CanvasLayer

const OUTLINE := Color("#253047")
const GOLD := Color("#FFE6A1")
const WARNING := Color("#FF9138")
const DANGER := Color("#F05B52")
const PAUSE_COLOR := Color("#A45CDA")
const WARNING_SECONDS := 60.0

var xp_bar: XpBar
var boss_bar: BossBar
var banner: Banner
var loadout: LoadoutBar
var level_up: LevelUpScreen
var game_over: GameOverScreen
var pause_menu: PauseMenu
var pause_button: IconButton

var _score_label: Label
var _clock_label: Label
var _clock_text := ""
var _flash: ColorRect

@onready var joystick: TouchJoystick = $Joystick


func _ready() -> void:
	xp_bar = XpBar.new()
	add_child(xp_bar)
	xp_bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	xp_bar.offset_left = 28
	xp_bar.offset_right = -24
	xp_bar.offset_top = 30
	xp_bar.offset_bottom = 66

	_clock_label = _make_label(46, Color.WHITE, 14)
	add_child(_clock_label)
	_clock_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_clock_label.offset_top = 72
	_clock_label.offset_bottom = 126

	_score_label = _make_label(28, GOLD, 10)
	_score_label.text = "Score : 0"
	add_child(_score_label)
	_score_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_score_label.offset_top = 124
	_score_label.offset_bottom = 162

	pause_button = IconButton.new("pause", PAUSE_COLOR, Vector2(72, 72))
	add_child(pause_button)
	pause_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	pause_button.offset_left = -96
	pause_button.offset_right = -24
	pause_button.offset_top = 80
	pause_button.offset_bottom = 152

	boss_bar = BossBar.new()
	add_child(boss_bar)
	boss_bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	boss_bar.offset_left = 60
	boss_bar.offset_right = -60
	boss_bar.offset_top = 166
	boss_bar.offset_bottom = 236

	loadout = LoadoutBar.new()
	add_child(loadout)
	loadout.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	loadout.offset_top = -110
	loadout.offset_bottom = -24

	_flash = ColorRect.new()
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash.color = Color(1, 1, 1, 0)
	add_child(_flash)
	_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	banner = Banner.new()
	add_child(banner)
	banner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	level_up = LevelUpScreen.new()
	add_child(level_up)
	level_up.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	pause_menu = PauseMenu.new()
	add_child(pause_menu)
	pause_menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	game_over = GameOverScreen.new()
	add_child(game_over)
	game_over.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func set_score(score: int) -> void:
	_score_label.text = "Score : %d" % score
	_score_label.pivot_offset = _score_label.size / 2.0
	_score_label.scale = Vector2(1.25, 1.25)
	create_tween().tween_property(_score_label, "scale", Vector2.ONE, 0.3) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func set_clock(seconds: float, phase: WaveDirector.Phase) -> void:
	var text := _format_clock(seconds)
	if text != _clock_text:
		_clock_text = text
		_clock_label.text = text
	var color := Color.WHITE
	if phase != WaveDirector.Phase.WAVES:
		color = DANGER
	elif seconds <= WARNING_SECONDS:
		color = WARNING
	if _clock_label.label_settings.font_color != color:
		_clock_label.label_settings.font_color = color


func flash(color: Color, duration: float = 0.4) -> void:
	_flash.color = Color(color, 0.75)
	create_tween().tween_property(_flash, "color:a", 0.0, duration)


static func _format_clock(seconds: float) -> String:
	var total := int(ceilf(seconds)) if seconds >= 0.0 else int(floorf(-seconds))
	var prefix := "-" if seconds < 0.0 and total > 0 else ""
	return "%s%d:%02d" % [prefix, total / 60, total % 60]


func _make_label(font_size: int, color: Color, outline: int) -> Label:
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var settings := LabelSettings.new()
	settings.font_size = font_size
	settings.font_color = color
	settings.outline_size = outline
	settings.outline_color = OUTLINE
	label.label_settings = settings
	return label
