class_name OwlFamiliar
extends Spell
## Petit hibou qui vole près de la sorcière et tire des plumes magiques.

const INTERVAL: Array[float] = [1.0, 0.85, 0.7, 0.6, 0.45]
const DAMAGE: Array[int] = [8, 10, 12, 14, 18]
const SHOTS: Array[int] = [1, 1, 2, 2, 3]
const RANGE := 520.0
const FEATHER := Color("#FFE6A1")
const BODY := Color("#879DA5")
const BELLY := Color("#E6C58D")
const BEAK := Color("#FF9138")
const OUTLINE := Color("#253047")

var _timer := 0.5
var _time := 0.0
var _facing_left := false


func _physics_process(delta: float) -> void:
	_time += delta
	position = Vector2(-55, -105) + Vector2(sin(_time * 2.0) * 10.0, sin(_time * 3.1) * 6.0)
	queue_redraw()
	_timer -= delta
	if _timer > 0.0:
		return
	var target := _nearest_enemy(_alive_enemies(), global_position, RANGE)
	if target == null:
		_timer = 0.2
		return
	_timer = _cooldown(INTERVAL[_tier()])
	var aim := global_position.direction_to(Spell.center_of(target))
	_facing_left = aim.x < 0.0
	var shots := SHOTS[_tier()]
	for k in shots:
		var bolt := player.bolt_scene.instantiate() as MagicBolt
		bolt.direction = aim.rotated((k - (shots - 1) / 2.0) * 0.15)
		bolt.damage = DAMAGE[_tier()]
		bolt.source = player
		bolt.color = FEATHER
		bolt.size_scale = 0.7
		bolt.speed = 720.0
		_world().add_child(bolt)
		bolt.global_position = global_position


func _draw() -> void:
	var flap := sin(_time * 14.0) * 0.4
	var side := -1.0 if _facing_left else 1.0
	# Ailes
	for wing in [-1.0, 1.0]:
		var base := Vector2(16.0 * wing, 2.0)
		var tip := base + Vector2(14.0 * wing, -6.0 + flap * 10.0)
		var wing_shape := PackedVector2Array([base + Vector2(0, -8), tip, base + Vector2(0, 8)])
		draw_colored_polygon(wing_shape, BODY.darkened(0.15))
		wing_shape.append(wing_shape[0])
		draw_polyline(wing_shape, OUTLINE, 3.0, true)
	# Corps
	draw_circle(Vector2.ZERO, 21.0, OUTLINE)
	draw_circle(Vector2.ZERO, 18.0, BODY)
	draw_circle(Vector2(0, 7), 11.0, BELLY)
	# Aigrettes
	for ear in [-1.0, 1.0]:
		var tuft := PackedVector2Array([Vector2(9 * ear, -13), Vector2(15 * ear, -26), Vector2(3 * ear, -16)])
		draw_colored_polygon(tuft, BODY)
		tuft.append(tuft[0])
		draw_polyline(tuft, OUTLINE, 3.0, true)
	# Yeux
	for eye in [-1.0, 1.0]:
		var at := Vector2(7.0 * eye, -5.0)
		draw_circle(at, 7.5, OUTLINE)
		draw_circle(at, 6.0, FEATHER)
		draw_circle(at + Vector2(side * 1.5, 0), 3.0, OUTLINE)
	# Bec
	draw_colored_polygon(PackedVector2Array([Vector2(-3, 1), Vector2(3, 1), Vector2(0, 7)]), BEAK)
