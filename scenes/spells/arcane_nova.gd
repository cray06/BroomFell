class_name ArcaneNova
extends Spell
## Onde de choc autour de la sorcière qui blesse et repousse les monstres.

const COOLDOWN: Array[float] = [3.2, 3.2, 3.0, 2.2, 2.0]
const RADIUS: Array[float] = [140.0, 175.0, 175.0, 185.0, 230.0]
const DAMAGE: Array[int] = [10, 10, 15, 15, 20]

const ARCANE := Color("#A45CDA")

var _timer := 1.0


func _physics_process(delta: float) -> void:
	_timer -= delta
	if _timer > 0.0:
		return
	_timer = _cooldown(COOLDOWN[_tier()])
	_pulse()


func _pulse() -> void:
	var center := player.global_position
	var radius := RADIUS[_tier()]
	NovaFx.spawn(_world(), center, radius)
	Fx.burst(_world(), center + Vector2(0, -30), ARCANE, 16, 260.0, 0.4)
	for enemy in _alive_enemies():
		if center.distance_to(enemy.global_position) <= radius + enemy.hit_radius * 0.5:
			_hit(enemy, DAMAGE[_tier()], center.direction_to(enemy.global_position))
