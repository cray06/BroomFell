class_name PoisonTrail
extends Spell
## La sorcière laisse derrière elle des flaques de poison.

const DURATION: Array[float] = [2.0, 2.5, 3.0, 3.5, 4.0]
const DAMAGE: Array[int] = [3, 4, 5, 6, 8]
const RADIUS: Array[float] = [40.0, 45.0, 50.0, 55.0, 60.0]
const MOVING_INTERVAL := 0.22
const STILL_INTERVAL := 0.7

var _timer := 0.0


func _physics_process(delta: float) -> void:
	_timer -= delta
	if _timer > 0.0:
		return
	var moving := player.velocity.length() > 30.0
	_timer = MOVING_INTERVAL if moving else STILL_INTERVAL
	PoisonPuddle.spawn(_ground(), self, player.global_position, RADIUS[_tier()],
			DURATION[_tier()], DAMAGE[_tier()])
