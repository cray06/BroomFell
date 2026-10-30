class_name SpellImpact
extends Node2D
## Météore : une zone orange se dessine au sol, puis le météore s'écrase
## et blesse les monstres dans la zone.

const FIRE := Color("#FF9138")
const LIGHT := Color("#FFE6A1")
const OUTLINE := Color("#253047")
const FLATTEN := 0.7
const FALL_HEIGHT := 600.0

var spell: Spell
var radius := 80.0
var delay := 0.7
var damage := 25

var _t := 0.0
var _meteor: Meteor


static func spawn(parent: Node, caster: Spell, at: Vector2, zone_radius: float, wait: float,
		hit_damage: int) -> void:
	var impact := SpellImpact.new()
	impact.spell = caster
	impact.radius = zone_radius
	impact.delay = wait
	impact.damage = hit_damage
	impact.position = at
	parent.add_child(impact)


func _ready() -> void:
	_meteor = Meteor.new()
	_meteor.impact = self
	_meteor.z_index = 60
	add_child(_meteor)


func progress() -> float:
	return clampf(_t / delay, 0.0, 1.0)


func _process(delta: float) -> void:
	_t += delta
	if _t >= delay:
		_explode()
		return
	queue_redraw()
	_meteor.queue_redraw()


func _draw() -> void:
	var p := progress()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, FLATTEN))
	draw_circle(Vector2.ZERO, radius, Color(FIRE, 0.12))
	draw_circle(Vector2.ZERO, radius * p, Color(FIRE, 0.22))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, Color(FIRE, 0.7), 3.0, true)


func _explode() -> void:
	if is_instance_valid(spell) and is_instance_valid(spell.player):
		for enemy in spell._alive_enemies():
			var offset := enemy.global_position - global_position
			if Vector2(offset.x, offset.y / FLATTEN).length() <= radius + enemy.hit_radius * 0.5:
				spell._hit(enemy, damage, offset.normalized())
	NovaFx.spawn(get_parent(), global_position, radius * 1.15, FIRE)
	Fx.burst(get_parent(), global_position + Vector2(0, -10), FIRE, 18, 320.0, 0.5)
	Fx.burst(get_parent(), global_position + Vector2(0, -10), LIGHT, 8, 240.0, 0.35)
	get_tree().call_group("camera", "shake", 4.0)
	queue_free()


## Boule de feu qui tombe du ciel, dessinée au-dessus des personnages.
class Meteor extends Node2D:
	var impact: SpellImpact

	func _draw() -> void:
		var p := impact.progress()
		var fall := p * p
		var center := Vector2(-140.0 * (1.0 - fall), -SpellImpact.FALL_HEIGHT * (1.0 - fall))
		var trail_dir := Vector2(-0.23, -1.0).normalized()
		for i in 5:
			var t := float(i + 1)
			draw_circle(center + trail_dir * t * 14.0, 16.0 - t * 2.5,
					Color(SpellImpact.FIRE, 0.5 - t * 0.08))
		draw_circle(center, 20.0, SpellImpact.OUTLINE)
		draw_circle(center, 16.0, SpellImpact.FIRE)
		draw_circle(center + Vector2(-4, -4), 7.0, SpellImpact.LIGHT)
