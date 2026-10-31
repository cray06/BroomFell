class_name BroomBoomerang
extends Spell

const COUNT: Array[int] = [1, 1, 2, 2, 3]
const DAMAGE: Array[int] = [10, 14, 14, 18, 22]
const COOLDOWN: Array[float] = [2.0, 1.8, 1.8, 1.5, 1.3]
const SPREAD := 0.7

var _timer := 0.6


func _physics_process(delta: float) -> void:
	_timer -= delta
	if _timer > 0.0:
		return
	_timer = _cooldown(COOLDOWN[_tier()])
	var count := COUNT[_tier()]
	for k in count:
		var dir := player.aim.rotated((k - (count - 1) / 2.0) * SPREAD)
		FlyingBroom.spawn(_world(), self, dir, DAMAGE[_tier()])
