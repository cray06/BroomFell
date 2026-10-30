class_name MagicBolt
extends Area2D
## Projectile magique. Va tout droit, peut perforer les monstres
## ou ricocher vers un autre, et utilise les critiques de la sorcière.

const CORE := Color.WHITE
const OUTLINE := Color("#253047")
const RICOCHET_RANGE := 320.0

@export var speed := 640.0
@export var damage := 10
@export var lifetime := 1.1

var direction := Vector2.RIGHT
## La sorcière : sert à calculer les dégâts (puissance, critiques).
var source: Player
var pierce := 0
var ricochet := 0
var color := Color("#39C9F0")
var size_scale := 1.0

var _age := 0.0
var _done := false
var _hit_ids := {}


func _ready() -> void:
	rotation = direction.angle()
	body_entered.connect(_on_body_entered)
	_add_trail()


func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	_age += delta
	scale = Vector2.ONE * (1.0 + sin(_age * 30.0) * 0.08)
	if _age >= lifetime:
		_vanish()


func _draw() -> void:
	var s := size_scale
	draw_colored_polygon(PackedVector2Array([Vector2(-4, -9) * s, Vector2(-30, 0) * s,
			Vector2(-4, 9) * s]), Color(color, 0.45))
	draw_circle(Vector2.ZERO, 16.0 * s, Color(color, 0.3))
	draw_circle(Vector2.ZERO, 10.0 * s, color)
	draw_arc(Vector2.ZERO, 10.0 * s, 0.0, TAU, 24, OUTLINE, 2.5, true)
	draw_circle(Vector2(2, -2) * s, 4.5 * s, CORE)


func _on_body_entered(body: Node2D) -> void:
	if _done:
		return
	if not body.has_method("take_hit"):
		_finish()
		return
	if body.is_dead or _hit_ids.has(body.get_instance_id()):
		return
	_hit_ids[body.get_instance_id()] = true

	var amount := damage
	var crit := false
	if is_instance_valid(source):
		var roll := source.roll_damage(damage)
		amount = roll.amount
		crit = roll.crit
	body.take_hit(amount, direction, crit)
	Fx.burst(get_parent(), global_position, color, 8, 180.0, 0.35)

	if ricochet > 0:
		var next := _ricochet_target()
		if next != null:
			ricochet -= 1
			direction = global_position.direction_to(Spell.center_of(next))
			rotation = direction.angle()
			_age = minf(_age, lifetime * 0.5)
			return
	if pierce > 0:
		pierce -= 1
		return
	_finish()


func _ricochet_target() -> Node2D:
	var best: Node2D = null
	var best_distance := RICOCHET_RANGE
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.is_dead or _hit_ids.has(enemy.get_instance_id()):
			continue
		var distance := global_position.distance_to(Spell.center_of(enemy))
		if distance < best_distance:
			best = enemy
			best_distance = distance
	return best


func _finish() -> void:
	_done = true
	Fx.burst(get_parent(), global_position, color, 6, 160.0, 0.3)
	queue_free()


func _vanish() -> void:
	_done = true
	set_physics_process(false)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.12)
	tween.tween_callback(queue_free)


func _add_trail() -> void:
	var trail := CPUParticles2D.new()
	trail.local_coords = false
	trail.amount = 18
	trail.lifetime = 0.25
	trail.texture = Fx.dot_texture()
	trail.gravity = Vector2.ZERO
	trail.spread = 15.0
	trail.direction = Vector2.LEFT
	trail.initial_velocity_min = 20.0
	trail.initial_velocity_max = 50.0
	trail.scale_amount_min = 0.25 * size_scale
	trail.scale_amount_max = 0.4 * size_scale
	var shrink := Curve.new()
	shrink.add_point(Vector2(0.0, 1.0))
	shrink.add_point(Vector2(1.0, 0.0))
	trail.scale_amount_curve = shrink
	trail.color = color
	trail.show_behind_parent = true
	add_child(trail)
