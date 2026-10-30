class_name TornadoFx
extends Node2D

const WIND := Color(0.88, 0.96, 1.0)
const OUTLINE := Color("#253047")
const SPEED := 150.0
const DAMAGE_RADIUS := 70.0
const PULL_RADIUS := 170.0
const PULL_FORCE := 900.0
const TICK := 0.3

var spell: Spell
var direction := Vector2.RIGHT
var duration := 3.0
var damage := 6

var _age := 0.0
var _tick := 0.0


static func spawn(parent: Node, caster: Spell, at: Vector2, dir: Vector2, life: float,
		hit_damage: int) -> void:
	var tornado := TornadoFx.new()
	tornado.spell = caster
	tornado.direction = dir
	tornado.duration = life
	tornado.damage = hit_damage
	tornado.top_level = true
	tornado.z_index = 30
	tornado.position = at
	parent.add_child(tornado)


func _physics_process(delta: float) -> void:
	if not is_instance_valid(spell) or not is_instance_valid(spell.player):
		queue_free()
		return
	_age += delta
	if _age >= duration:
		queue_free()
		return

	direction = direction.rotated(sin(_age * 2.5) * 1.6 * delta)
	position += direction * SPEED * delta
	var bounds := spell._arena_bounds().grow(-60.0)
	if position.x < bounds.position.x or position.x > bounds.end.x:
		direction.x = -direction.x
	if position.y < bounds.position.y or position.y > bounds.end.y:
		direction.y = -direction.y
	position = position.clamp(bounds.position, bounds.end)

	_tick -= delta
	var deal_damage := _tick <= 0.0
	if deal_damage:
		_tick = TICK
	for enemy in spell._alive_enemies():
		var distance := global_position.distance_to(enemy.global_position)
		if distance < PULL_RADIUS and enemy.has_method("push"):
			enemy.push(enemy.global_position.direction_to(global_position) * PULL_FORCE * delta)
		if deal_damage and distance < DAMAGE_RADIUS + enemy.hit_radius * 0.5:
			spell._hit(enemy, damage, Vector2.ZERO)
	queue_redraw()


func _draw() -> void:
	var fade := minf(1.0, minf(_age / 0.25, (duration - _age) / 0.4))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.35))
	draw_circle(Vector2.ZERO, 46.0, Color(OUTLINE, 0.2 * fade))
	draw_set_transform(Vector2.ZERO)
	for i in 7:
		var y := -i * 17.0
		var rx := 16.0 + i * 8.5
		var wobble := sin(_age * 9.0 + i * 0.9) * (4.0 + i * 1.5)
		var center := Vector2(wobble, y)
		draw_set_transform(center, 0.0, Vector2(1.0, 0.32))
		draw_circle(Vector2.ZERO, rx, Color(WIND, 0.3 * fade))
		var start := _age * 8.0 + i
		draw_arc(Vector2.ZERO, rx, start, start + PI * 1.3, 24, Color(OUTLINE, 0.55 * fade), 4.0, true)
		draw_arc(Vector2.ZERO, rx - 3.0, start + PI, start + PI * 1.9, 16, Color(1, 1, 1, 0.9 * fade), 3.0, true)
	draw_set_transform(Vector2.ZERO)
