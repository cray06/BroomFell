class_name Tornado
extends Spell
## Lance des tornades qui se baladent, aspirent et blessent les monstres.

const COUNT: Array[int] = [1, 1, 1, 2, 2]
const DURATION: Array[float] = [3.0, 3.5, 4.0, 4.5, 5.0]
const DAMAGE: Array[int] = [6, 7, 8, 10, 12]
const COOLDOWN: Array[float] = [5.0, 4.8, 4.5, 4.2, 4.0]

var _timer := 1.0


func _physics_process(delta: float) -> void:
	_timer -= delta
	if _timer > 0.0:
		return
	_timer = _cooldown(COOLDOWN[_tier()])
	for k in COUNT[_tier()]:
		var dir := player.facing.rotated(randf_range(-0.6, 0.6) + k * PI)
		TornadoFx.spawn(_world(), self, player.global_position + dir * 60.0, dir,
				DURATION[_tier()], DAMAGE[_tier()])
