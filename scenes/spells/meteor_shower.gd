class_name MeteorShower
extends Spell

const COUNT: Array[int] = [1, 2, 2, 3, 4]
const DAMAGE: Array[int] = [25, 25, 35, 35, 50]
const RADIUS: Array[float] = [70.0, 70.0, 85.0, 85.0, 100.0]
const COOLDOWN: Array[float] = [2.8, 2.6, 2.4, 2.2, 1.8]
const RANGE := 620.0
const FALL_TIME := 0.7

var _timer := 0.8


func _physics_process(delta: float) -> void:
	_timer -= delta
	if _timer > 0.0:
		return
	_timer = _cooldown(COOLDOWN[_tier()]) if _cast() else 0.3


func _cast() -> bool:
	var targets: Array[Node2D] = []
	for enemy in _alive_enemies():
		if enemy.global_position.distance_to(player.global_position) < RANGE:
			targets.append(enemy)
	if targets.is_empty():
		return false
	for k in COUNT[_tier()]:
		var enemy: Node2D = targets.pick_random()
		var at := enemy.global_position + Vector2(randf_range(-25, 25), randf_range(-15, 15))
		SpellImpact.spawn(_ground(), self, at, RADIUS[_tier()], FALL_TIME + k * 0.12, DAMAGE[_tier()])
	return true
