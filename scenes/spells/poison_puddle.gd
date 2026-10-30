class_name PoisonPuddle
extends Node2D

const POISON := Color("#9BE15D")
const POISON_DARK := Color("#5DA83A")
const FLATTEN := 0.6
const TICK := 0.5

var spell: Spell
var radius := 45.0
var duration := 2.5
var damage := 4

var _age := 0.0
var _tick := 0.2
var _seed := 0.0


static func spawn(parent: Node, caster: Spell, at: Vector2, size: float, life: float,
		hit_damage: int) -> void:
	var puddle := PoisonPuddle.new()
	puddle.spell = caster
	puddle.radius = size
	puddle.duration = life
	puddle.damage = hit_damage
	puddle.position = at
	puddle._seed = randf() * TAU
	parent.add_child(puddle)


func _process(delta: float) -> void:
	_age += delta
	if _age >= duration or not is_instance_valid(spell):
		queue_free()
		return
	_tick -= delta
	if _tick <= 0.0:
		_tick = TICK
		for enemy in spell._alive_enemies():
			var offset := enemy.global_position - global_position
			if Vector2(offset.x, offset.y / FLATTEN).length() <= radius + enemy.hit_radius * 0.4:
				spell._hit(enemy, damage, Vector2.ZERO)
	queue_redraw()


func _draw() -> void:
	var grow := minf(1.0, _age / 0.2)
	var fade := minf(1.0, (duration - _age) / 0.4)
	var r := radius * grow
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, FLATTEN))
	draw_circle(Vector2.ZERO, r, Color(POISON_DARK, 0.45 * fade))
	draw_circle(Vector2(-r * 0.15, -r * 0.1), r * 0.75, Color(POISON, 0.45 * fade))
	draw_set_transform(Vector2.ZERO)
	for i in 3:
		var phase := fmod(_age * 1.3 + i * 0.33 + _seed, 1.0)
		var at := Vector2(cos(_seed + i * 2.1), sin(_seed + i * 2.1) * FLATTEN) * r * 0.5
		draw_arc(at + Vector2(0, -phase * 8.0), 3.0 + phase * 4.0, 0.0, TAU, 12,
				Color(POISON.lightened(0.4), (1.0 - phase) * fade), 2.0, true)
