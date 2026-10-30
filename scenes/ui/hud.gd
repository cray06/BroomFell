class_name Hud
extends CanvasLayer

const OUTLINE := Color("#253047")
const GOLD := Color("#FFE6A1")

var xp_bar: XpBar
var boss_bar: BossBar
var banner: Banner
var loadout: LoadoutBar
var level_up: LevelUpScreen
var game_over: GameOverScreen

var _score_label: Label
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

	_score_label = Label.new()
	_score_label.text = "Score : 0"
	_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var settings := LabelSettings.new()
	settings.font_size = 36
	settings.font_color = GOLD
	settings.outline_size = 12
	settings.outline_color = OUTLINE
	_score_label.label_settings = settings
	add_child(_score_label)
	_score_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_score_label.offset_top = 78
	_score_label.offset_bottom = 128

	boss_bar = BossBar.new()
	add_child(boss_bar)
	boss_bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	boss_bar.offset_left = 60
	boss_bar.offset_right = -60
	boss_bar.offset_top = 130
	boss_bar.offset_bottom = 200

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

	game_over = GameOverScreen.new()
	add_child(game_over)
	game_over.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func set_score(score: int) -> void:
	_score_label.text = "Score : %d" % score
	_score_label.pivot_offset = _score_label.size / 2.0
	_score_label.scale = Vector2(1.25, 1.25)
	create_tween().tween_property(_score_label, "scale", Vector2.ONE, 0.3) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func flash(color: Color, duration: float = 0.4) -> void:
	_flash.color = Color(color, 0.75)
	create_tween().tween_property(_flash, "color:a", 0.0, duration)
