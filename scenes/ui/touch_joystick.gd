class_name TouchJoystick
extends Control
## Joystick flottant : il apparaît là où le doigt touche l'écran.
## Sur PC, le clic souris fonctionne aussi (émulation tactile activée).

const BASE_COLOR := Color(0.145, 0.188, 0.278, 0.35)
const RING_COLOR := Color(1, 1, 1, 0.5)
const KNOB_COLOR := Color("#FFE6A1")
const OUTLINE := Color("#253047")

@export var radius := 90.0
@export var knob_radius := 38.0
@export_range(0.0, 1.0) var dead_zone := 0.15

## Direction de -1 à 1 sur chaque axe. Vector2.ZERO si on ne touche pas.
var output := Vector2.ZERO

var _touch_index := -1
var _origin := Vector2.ZERO
var _knob := Vector2.ZERO


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE


func _notification(what: int) -> void:
	# Le jeu se met en pause (montée de niveau) : on relâche le joystick.
	if what == NOTIFICATION_PAUSED:
		_touch_index = -1
		output = Vector2.ZERO
		queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed and _touch_index == -1:
			_touch_index = touch.index
			_origin = touch.position
			_knob = _origin
			output = Vector2.ZERO
			queue_redraw()
		elif not touch.pressed and touch.index == _touch_index:
			_touch_index = -1
			output = Vector2.ZERO
			queue_redraw()
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.index != _touch_index:
			return
		var offset := (drag.position - _origin).limit_length(radius)
		_knob = _origin + offset
		output = offset / radius
		if output.length() < dead_zone:
			output = Vector2.ZERO
		queue_redraw()


func _draw() -> void:
	if _touch_index == -1:
		return
	draw_circle(_origin, radius, BASE_COLOR)
	draw_arc(_origin, radius, 0.0, TAU, 48, RING_COLOR, 4.0, true)
	draw_circle(_knob, knob_radius, KNOB_COLOR)
	draw_arc(_knob, knob_radius, 0.0, TAU, 32, OUTLINE, 4.0, true)
