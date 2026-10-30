class_name FlyingBroom
extends Node2D

const HANDLE := Color("#E6C58D")
const BRISTLES := Color("#FFE6A1")
const BAND := Color("#A45CDA")
const OUTLINE := Color("#253047")
const RANGE := 300.0
const OUT_TIME := 0.45
const RETURN_SPEED := 760.0
const HIT_RADIUS := 30.0
const HIT_COOLDOWN := 0.3
const BODY_HEIGHT := Vector2(0, -40)

var spell: Spell
var direction := Vector2.RIGHT
var damage := 10

var _origin := Vector2.ZERO
var _t := 0.0
var _returning := false
var _spin := 0.0
var _cooldowns := {}


static func spawn(parent: Node, caster: Spell, dir: Vector2, hit_damage: int) -> void:
	var broom := FlyingBroom.new()
	broom.spell = caster
	broom.direction = dir
	broom.damage = hit_damage
	broom.top_level = true
	broom.z_index = 45
	parent.add_child(broom)
	broom._origin = caster.player.global_position + BODY_HEIGHT
	broom.global_position = broom._origin


func _physics_process(delta: float) -> void:
	if not is_instance_valid(spell) or not is_instance_valid(spell.player) or spell.player.is_dead:
		queue_free()
		return
	_t += delta
	_spin += delta * 18.0
	if not _returning:
		var p := minf(_t / OUT_TIME, 1.0)
		global_position = _origin + direction * RANGE * (1.0 - pow(1.0 - p, 3.0))
		if p >= 1.0:
			_returning = true
	else:
		var home := spell.player.global_position + BODY_HEIGHT
		global_position = global_position.move_toward(home, RETURN_SPEED * delta)
		if global_position.distance_to(home) < 20.0 or _t > 3.0:
			queue_free()
			return
	_hit_enemies(delta)
	queue_redraw()


func _hit_enemies(delta: float) -> void:
	for id in _cooldowns.keys():
		_cooldowns[id] -= delta
		if _cooldowns[id] <= 0.0:
			_cooldowns.erase(id)
	for enemy in spell._alive_enemies():
		var id := enemy.get_instance_id()
		if _cooldowns.has(id):
			continue
		if global_position.distance_to(Spell.center_of(enemy)) < HIT_RADIUS + enemy.hit_radius:
			_cooldowns[id] = HIT_COOLDOWN
			spell._hit(enemy, damage, global_position.direction_to(enemy.global_position))
			Fx.burst(get_parent(), global_position, BRISTLES, 5, 140.0, 0.3)


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, _spin)
	draw_line(Vector2(-30, 0), Vector2(14, 0), OUTLINE, 10.0, true)
	draw_line(Vector2(-30, 0), Vector2(14, 0), HANDLE, 5.0, true)
	var bristles := PackedVector2Array([Vector2(12, -7), Vector2(36, -13), Vector2(36, 13), Vector2(12, 7)])
	draw_colored_polygon(bristles, BRISTLES)
	bristles.append(bristles[0])
	draw_polyline(bristles, OUTLINE, 3.5, true)
	draw_line(Vector2(13, -7), Vector2(13, 7), BAND, 5.0)
