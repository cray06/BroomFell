class_name Bubble
extends Node2D
## Bulle qui traverse les monstres et rebondit sur les murs.

const COLOR := Color("#7FD8F5")
const OUTLINE := Color("#253047")
const SPEED := 380.0
const RADIUS := 18.0
const LIFETIME := 4.0
const HIT_COOLDOWN := 0.4

var spell: Spell
var velocity := Vector2.ZERO
var damage := 8

var _age := 0.0
var _cooldowns := {}


static func spawn(parent: Node, caster: Spell, at: Vector2, dir: Vector2, hit_damage: int) -> void:
	var bubble := Bubble.new()
	bubble.spell = caster
	bubble.velocity = dir * SPEED
	bubble.damage = hit_damage
	bubble.top_level = true
	bubble.z_index = 45
	bubble.position = at
	parent.add_child(bubble)


func _physics_process(delta: float) -> void:
	if not is_instance_valid(spell) or not is_instance_valid(spell.player):
		queue_free()
		return
	_age += delta
	if _age >= LIFETIME:
		Fx.burst(get_parent(), global_position, COLOR, 8, 160.0, 0.3)
		queue_free()
		return

	position += velocity * delta
	var bounds := spell._arena_bounds().grow(-RADIUS)
	if position.x < bounds.position.x or position.x > bounds.end.x:
		velocity.x = -velocity.x
	if position.y < bounds.position.y or position.y > bounds.end.y:
		velocity.y = -velocity.y
	position = position.clamp(bounds.position, bounds.end)

	for id in _cooldowns.keys():
		_cooldowns[id] -= delta
		if _cooldowns[id] <= 0.0:
			_cooldowns.erase(id)
	for enemy in spell._alive_enemies():
		var id := enemy.get_instance_id()
		if _cooldowns.has(id):
			continue
		if global_position.distance_to(Spell.center_of(enemy)) < RADIUS + enemy.hit_radius:
			_cooldowns[id] = HIT_COOLDOWN
			spell._hit(enemy, damage, velocity.normalized())
			Fx.burst(get_parent(), global_position, COLOR, 5, 140.0, 0.3)
	queue_redraw()


func _draw() -> void:
	var wobble := Vector2(1.0 + sin(_age * 9.0) * 0.06, 1.0 - sin(_age * 9.0) * 0.06)
	draw_set_transform(Vector2.ZERO, 0.0, wobble)
	draw_circle(Vector2.ZERO, RADIUS, Color(COLOR, 0.35))
	draw_arc(Vector2.ZERO, RADIUS, 0.0, TAU, 32, OUTLINE, 3.0, true)
	draw_arc(Vector2.ZERO, RADIUS - 3.0, 0.0, TAU, 32, Color(COLOR, 0.9), 2.0, true)
	draw_arc(Vector2.ZERO, RADIUS - 6.0, deg_to_rad(200), deg_to_rad(260), 10, Color.WHITE, 3.0, true)
	draw_circle(Vector2(6, -8), 2.5, Color.WHITE)
