class_name BossBullet
extends Node2D
## Boule de bave tirée par le boss. Blesse la sorcière au contact.

const DANGER := Color("#F05B52")
const GOO := Color("#A45CDA")
const OUTLINE := Color("#253047")
const RADIUS := 13.0
const LIFETIME := 3.5
## Centre du corps de la sorcière par rapport à ses pieds.
const PLAYER_CENTER := Vector2(0, -20)
const PLAYER_RADIUS := 22.0

var velocity := Vector2.ZERO
var damage := 12
var target: Player

var _age := 0.0


static func spawn(parent: Node, at: Vector2, initial_velocity: Vector2, victim: Player,
		hit_damage: int) -> void:
	var bullet := BossBullet.new()
	bullet.velocity = initial_velocity
	bullet.target = victim
	bullet.damage = hit_damage
	bullet.top_level = true
	bullet.z_index = 55
	bullet.position = at
	parent.add_child(bullet)


func _physics_process(delta: float) -> void:
	_age += delta
	position += velocity * delta
	if _age >= LIFETIME:
		queue_free()
		return
	if is_instance_valid(target) and not target.is_dead:
		if global_position.distance_to(target.global_position + PLAYER_CENTER) < RADIUS + PLAYER_RADIUS:
			target.take_damage(damage, global_position - velocity.normalized() * 40.0)
			Fx.burst(get_parent(), global_position, GOO, 8, 180.0, 0.35)
			queue_free()
			return
	queue_redraw()


func _draw() -> void:
	var pulse := 1.0 + sin(_age * 18.0) * 0.1
	var fade := clampf((LIFETIME - _age) / 0.4, 0.0, 1.0)
	modulate.a = fade
	draw_circle(Vector2.ZERO, RADIUS * 1.7 * pulse, Color(GOO, 0.35))
	draw_circle(Vector2.ZERO, RADIUS + 3.0, OUTLINE)
	draw_circle(Vector2.ZERO, RADIUS, DANGER)
	draw_circle(Vector2(-4, -4), RADIUS * 0.4, Color(1, 1, 1, 0.7))
