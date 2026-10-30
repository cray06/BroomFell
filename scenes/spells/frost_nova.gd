class_name FrostNova
extends Spell
## Onde de givre qui gèle les monstres autour de la sorcière.

const RADIUS: Array[float] = [150.0, 170.0, 190.0, 210.0, 240.0]
const FREEZE: Array[float] = [1.5, 1.8, 2.0, 2.3, 2.6]
const DAMAGE: Array[int] = [5, 6, 8, 10, 12]
const COOLDOWN: Array[float] = [4.5, 4.2, 4.0, 3.6, 3.2]
const ICE := Color("#9FE8FF")

var _timer := 1.5


func _physics_process(delta: float) -> void:
	_timer -= delta
	if _timer > 0.0:
		return
	_timer = _cooldown(COOLDOWN[_tier()])
	var center := player.global_position
	var radius := RADIUS[_tier()]
	NovaFx.spawn(_world(), center, radius, ICE)
	Fx.burst(_world(), center + Vector2(0, -30), ICE, 20, 300.0, 0.4)
	Fx.burst(_world(), center + Vector2(0, -30), Color.WHITE, 10, 220.0, 0.3)
	for enemy in _alive_enemies():
		if center.distance_to(enemy.global_position) <= radius + enemy.hit_radius * 0.5:
			_hit(enemy, DAMAGE[_tier()], center.direction_to(enemy.global_position))
			if not enemy.is_dead:
				enemy.freeze(FREEZE[_tier()])
