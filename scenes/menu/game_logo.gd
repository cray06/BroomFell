class_name GameLogo
extends Control

const TITLE := "BroomFell"
const SUBTITLE := "Un roguelike magique"
const OUTLINE := Color("#253047")
const GOLD := Color("#FFE6A1")
const FIRE := Color("#FF9138")
const TITLE_SIZE := 112
const SPARKLES: Array[Vector3] = [
	Vector3(0.12, 40, 0.0), Vector3(0.88, 60, 1.4), Vector3(0.2, 170, 2.6),
	Vector3(0.82, 160, 3.7), Vector3(0.5, 10, 5.0), Vector3(0.05, 110, 4.2),
]

var _time := 0.0


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var font := get_theme_default_font()
	var baseline := Vector2(0, 140 + sin(_time * 1.6) * 5.0)
	var w := size.x

	for depth in [12, 9, 6, 3]:
		draw_string_outline(font, baseline + Vector2(0, depth), TITLE, HORIZONTAL_ALIGNMENT_CENTER, w,
				TITLE_SIZE, 28, OUTLINE)
	draw_string_outline(font, baseline, TITLE, HORIZONTAL_ALIGNMENT_CENTER, w, TITLE_SIZE, 28, OUTLINE)
	draw_string(font, baseline + Vector2(0, 7), TITLE, HORIZONTAL_ALIGNMENT_CENTER, w, TITLE_SIZE, FIRE)
	draw_string(font, baseline + Vector2(0, -3), TITLE, HORIZONTAL_ALIGNMENT_CENTER, w, TITLE_SIZE, Color.WHITE)
	draw_string(font, baseline, TITLE, HORIZONTAL_ALIGNMENT_CENTER, w, TITLE_SIZE, GOLD)

	var subtitle_at := baseline + Vector2(0, 62)
	draw_string_outline(font, subtitle_at, SUBTITLE, HORIZONTAL_ALIGNMENT_CENTER, w, 30, 12, OUTLINE)
	draw_string(font, subtitle_at, SUBTITLE, HORIZONTAL_ALIGNMENT_CENTER, w, 30, Color.WHITE)

	for spark in SPARKLES:
		var twinkle := maxf(0.0, sin(_time * 2.5 + spark.z))
		var r := 4.0 + twinkle * 10.0
		var c := Vector2(spark.x * w, spark.y)
		var color := Color(GOLD, 0.3 + 0.7 * twinkle)
		draw_colored_polygon(PackedVector2Array([c + Vector2(0, -r), c + Vector2(r * 0.25, 0),
				c + Vector2(0, r), c + Vector2(-r * 0.25, 0)]), color)
		draw_colored_polygon(PackedVector2Array([c + Vector2(-r, 0), c + Vector2(0, -r * 0.25),
				c + Vector2(r, 0), c + Vector2(0, r * 0.25)]), color)
