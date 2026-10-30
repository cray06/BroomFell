class_name XpOrb
extends Node2D
## Petite gemme d'XP lâchée par un monstre. Elle est aspirée
## quand la sorcière passe à proximité.

signal collected(value: int)

const GEM := Color("#A45CDA")
const OUTLINE := Color("#253047")
const MAGNET_RADIUS := 170.0
const PICKUP_RADIUS := 26.0
const BODY_HEIGHT := Vector2(0, -30)

@export var value := 1

## Fourni par la scène principale.
var target: Player

var _velocity := Vector2.ZERO
var _magnetized := false
var _age := 0.0


func _ready() -> void:
	add_to_group("xp_orbs")


func launch(initial_velocity: Vector2) -> void:
	_velocity = initial_velocity


## Aspirée immédiatement (objet Aimant).
func attract() -> void:
	_magnetized = true


func _physics_process(delta: float) -> void:
	_age += delta
	if is_instance_valid(target):
		var to_target := target.global_position + BODY_HEIGHT - global_position
		if _age > 0.35 and to_target.length() < MAGNET_RADIUS * target.stats.pickup_radius_mult:
			_magnetized = true
		if _magnetized:
			_velocity = _velocity.move_toward(to_target.normalized() * 1100.0, 3000.0 * delta)
			if to_target.length() < PICKUP_RADIUS:
				_collect()
				return
	if not _magnetized:
		_velocity = _velocity.move_toward(Vector2.ZERO, 600.0 * delta)
	position += _velocity * delta
	queue_redraw()


func _draw() -> void:
	var bob := Vector2(0, -6 + sin(_age * 6.0) * 3.0)
	draw_set_transform(Vector2(0, 4), 0.0, Vector2(1.0, 0.4))
	draw_circle(Vector2.ZERO, 8.0, Color(OUTLINE, 0.25))
	draw_set_transform(Vector2.ZERO)
	draw_circle(bob, 14.0, Color(GEM, 0.3))
	var gem := PackedVector2Array([bob + Vector2(0, -10), bob + Vector2(8, 0),
			bob + Vector2(0, 10), bob + Vector2(-8, 0)])
	draw_colored_polygon(gem, GEM)
	draw_colored_polygon(PackedVector2Array([bob + Vector2(0, -10), bob + Vector2(0, 0),
			bob + Vector2(-8, 0)]), GEM.lightened(0.35))
	gem.append(gem[0])
	draw_polyline(gem, OUTLINE, 2.5, true)


func _collect() -> void:
	Fx.burst(get_parent(), global_position, GEM.lightened(0.2), 5, 120.0, 0.25)
	collected.emit(value)
	queue_free()
