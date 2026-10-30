class_name ArcaneBeam
extends Spell

const BEAMS: Array[int] = [1, 1, 2, 2, 3]
const LENGTH: Array[float] = [200.0, 240.0, 240.0, 280.0, 300.0]
const DAMAGE: Array[int] = [5, 6, 7, 8, 10]
const ROTATION_SPEED := 1.7
const HIT_COOLDOWN := 0.35
const BEAM_WIDTH := 18.0
const GLOW := Color("#39C9F0")
const OUTLINE := Color("#253047")

var _angle := 0.0
var _time := 0.0
var _cooldowns := {}


func _ready() -> void:
	position = Vector2(0, -40)


func _physics_process(delta: float) -> void:
	_time += delta
	_angle = wrapf(_angle + ROTATION_SPEED * delta, 0.0, TAU)
	for id in _cooldowns.keys():
		_cooldowns[id] -= delta
		if _cooldowns[id] <= 0.0:
			_cooldowns.erase(id)

	var origin := global_position
	for end in _beam_ends():
		var tip := origin + end
		for enemy in _alive_enemies():
			var id := enemy.get_instance_id()
			if _cooldowns.has(id):
				continue
			var center := Spell.center_of(enemy)
			var closest := Geometry2D.get_closest_point_to_segment(center, origin, tip)
			if closest.distance_to(center) < BEAM_WIDTH + enemy.hit_radius * 0.6:
				_cooldowns[id] = _cooldown(HIT_COOLDOWN)
				_hit(enemy, DAMAGE[_tier()], end.normalized())
	queue_redraw()


func _draw() -> void:
	var flicker := 1.0 + sin(_time * 40.0) * 0.12
	for end in _beam_ends():
		draw_line(Vector2.ZERO, end, Color(GLOW, 0.3), 26.0 * flicker, true)
		draw_line(Vector2.ZERO, end, GLOW, 11.0, true)
		draw_line(Vector2.ZERO, end, Color.WHITE, 4.0, true)
		draw_circle(end, 10.0 * flicker, Color(GLOW, 0.5))
		draw_circle(end, 5.0, Color.WHITE)
	draw_circle(Vector2.ZERO, 13.0, OUTLINE)
	draw_circle(Vector2.ZERO, 10.0, GLOW)
	draw_circle(Vector2(-3, -3), 4.0, Color.WHITE)


func _beam_ends() -> PackedVector2Array:
	var count := BEAMS[_tier()]
	var length := LENGTH[_tier()]
	var ends := PackedVector2Array()
	for k in count:
		var dir := Vector2.from_angle(_angle + TAU * k / count)
		ends.append(Vector2(dir.x * length, dir.y * length * 0.75))
	return ends
