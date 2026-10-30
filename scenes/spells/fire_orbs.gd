class_name FireOrbs
extends Spell

const COUNT: Array[int] = [2, 3, 3, 4, 5]
const DAMAGE: Array[int] = [6, 6, 9, 9, 12]
const SPEED: Array[float] = [3.0, 3.0, 3.2, 3.8, 4.0]
const ORBIT: Array[float] = [78.0, 78.0, 82.0, 86.0, 100.0]

const HIT_COOLDOWN := 0.45
const ORB_RADIUS := 14.0
const FIRE := Color("#FF9138")
const CORE := Color("#FFE6A1")
const OUTLINE := Color("#253047")

var _angle := 0.0
var _time := 0.0
var _cooldowns := {}


func _ready() -> void:
	position = Vector2(0, -30)


func _physics_process(delta: float) -> void:
	_time += delta
	_angle = wrapf(_angle + SPEED[_tier()] * delta, 0.0, TAU)
	for id in _cooldowns.keys():
		_cooldowns[id] -= delta
		if _cooldowns[id] <= 0.0:
			_cooldowns.erase(id)

	var orbs := _orb_positions()
	for enemy in _alive_enemies():
		var id := enemy.get_instance_id()
		if _cooldowns.has(id):
			continue
		var center := center_of(enemy)
		for orb in orbs:
			var orb_global := global_position + orb
			if orb_global.distance_to(center) < ORB_RADIUS + enemy.hit_radius:
				_cooldowns[id] = HIT_COOLDOWN
				_hit(enemy, DAMAGE[_tier()], global_position.direction_to(center))
				Fx.burst(_world(), orb_global, FIRE, 6, 150.0, 0.35)
				break
	queue_redraw()


func _draw() -> void:
	var orbs := _orb_positions()
	for k in orbs.size():
		var at := orbs[k]
		var flicker := 1.0 + sin(_time * 20.0 + k * 1.7) * 0.12
		draw_circle(at, 21.0 * flicker, Color(FIRE, 0.3))
		draw_circle(at, ORB_RADIUS, FIRE)
		draw_arc(at, ORB_RADIUS, 0.0, TAU, 24, OUTLINE, 3.0, true)
		draw_circle(at + Vector2(-3, -3), 6.0 * flicker, CORE)


func _orb_positions() -> PackedVector2Array:
	var count := COUNT[_tier()]
	var radius := ORBIT[_tier()]
	var points := PackedVector2Array()
	for k in count:
		var dir := Vector2.from_angle(_angle + TAU * k / count)
		points.append(Vector2(dir.x * radius, dir.y * radius * 0.75))
	return points
