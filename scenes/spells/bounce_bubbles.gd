class_name BounceBubbles
extends Spell
## Envoie des bulles qui rebondissent sur les murs de l'arène.

const COUNT: Array[int] = [2, 3, 3, 4, 5]
const DAMAGE: Array[int] = [8, 8, 11, 11, 14]
const COOLDOWN: Array[float] = [3.0, 3.0, 2.6, 2.4, 2.0]

var _timer := 1.2


func _physics_process(delta: float) -> void:
	_timer -= delta
	if _timer > 0.0:
		return
	_timer = _cooldown(COOLDOWN[_tier()])
	var count := COUNT[_tier()]
	var start := randf() * TAU
	for k in count:
		var dir := Vector2.from_angle(start + TAU * k / count)
		Bubble.spawn(_world(), self, player.global_position + Vector2(0, -40), dir, DAMAGE[_tier()])
