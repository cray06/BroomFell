class_name ChainLightning
extends Spell

const COOLDOWN: Array[float] = [2.2, 2.1, 2.0, 1.6, 1.2]
const BOUNCES: Array[int] = [1, 2, 2, 3, 3]
const DAMAGE: Array[int] = [12, 12, 17, 17, 24]

const RANGE := 460.0
const BOUNCE_RANGE := 240.0
const SPARK := Color("#FFE6A1")

var _timer := 0.5


func _physics_process(delta: float) -> void:
	_timer -= delta
	if _timer > 0.0:
		return
	_timer = _cooldown(COOLDOWN[_tier()]) if _strike() else 0.2


func _strike() -> bool:
	var enemies := _alive_enemies()
	var origin := player.global_position + Vector2(0, -46)
	var current := _nearest_enemy(enemies, origin, RANGE)
	if current == null:
		return false

	var points := PackedVector2Array([origin])
	var targets: Array[Node2D] = []
	while current != null and targets.size() <= BOUNCES[_tier()]:
		targets.append(current)
		enemies.erase(current)
		points.append(center_of(current))
		current = _nearest_enemy(enemies, points[-1], BOUNCE_RANGE)

	LightningFx.spawn(_world(), points)
	for k in targets.size():
		Fx.burst(_world(), points[k + 1], SPARK, 8, 220.0, 0.35)
		_hit(targets[k], DAMAGE[_tier()], points[k].direction_to(points[k + 1]))
	return true
