class_name AreaAttack
extends Node2D
## Zone d'attaque signalée au sol : un cercle rouge se remplit,
## puis frappe. La sorcière doit en sortir avant l'impact.

const DANGER := Color("#F05B52")
const OUTLINE := Color("#253047")
const GOO := Color("#A45CDA")
## Le sol est vu en 3/4 : les zones sont des ellipses aplaties.
const FLATTEN := 0.7
const DROP_HEIGHT := 520.0

var radius := 100.0
var delay := 1.0
var damage := 20
var target: Player
## Une goutte tombe du ciel pendant la fin de l'attente.
var falling := false

var _t := 0.0
var _drop: FallingDrop


static func spawn(parent: Node, at: Vector2, zone_radius: float, wait: float, hit_damage: int,
		victim: Player, with_drop: bool = false) -> AreaAttack:
	var attack := AreaAttack.new()
	attack.radius = zone_radius
	attack.delay = wait
	attack.damage = hit_damage
	attack.target = victim
	attack.falling = with_drop
	attack.position = at
	parent.add_child(attack)
	return attack


func _ready() -> void:
	if falling:
		_drop = FallingDrop.new()
		_drop.attack = self
		_drop.z_index = 60
		add_child(_drop)


func _process(delta: float) -> void:
	_t += delta
	if _t >= delay:
		_impact()
		return
	queue_redraw()
	if _drop:
		_drop.queue_redraw()


func progress() -> float:
	return clampf(_t / delay, 0.0, 1.0)


func _draw() -> void:
	var p := progress()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, FLATTEN))
	draw_circle(Vector2.ZERO, radius, Color(DANGER, 0.16))
	draw_circle(Vector2.ZERO, radius * p, Color(DANGER, 0.32))
	var blink := 0.55 + 0.45 * sin(_t * (8.0 + 30.0 * p))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 64, Color(DANGER, blink), 5.0, true)
	draw_arc(Vector2.ZERO, radius * p, 0.0, TAU, 64, Color(1, 1, 1, 0.35), 2.0, true)


func _impact() -> void:
	if is_instance_valid(target) and not target.is_dead:
		var offset := target.global_position - global_position
		if Vector2(offset.x, offset.y / FLATTEN).length() <= radius + 10.0:
			target.take_damage(damage, global_position)
	NovaFx.spawn(get_parent(), global_position, radius * 1.1, DANGER)
	Fx.burst(get_parent(), global_position + Vector2(0, -10), GOO, 14, 300.0, 0.5)
	Fx.burst(get_parent(), global_position + Vector2(0, -10), DANGER, 8, 220.0, 0.35)
	get_tree().call_group("camera", "shake", 4.0 + radius / 25.0)
	queue_free()


## Goutte de bave qui tombe sur la zone, dessinée au-dessus des personnages.
class FallingDrop extends Node2D:
	var attack: AreaAttack

	func _draw() -> void:
		var p := attack.progress()
		if p < 0.55:
			return
		var fall := (p - 0.55) / 0.45
		var center := Vector2(0, -AreaAttack.DROP_HEIGHT * (1.0 - fall * fall))
		var stretch := Vector2(0.8, 1.3)
		draw_set_transform(center, 0.0, stretch)
		draw_circle(Vector2.ZERO, 24.0, AreaAttack.OUTLINE)
		draw_circle(Vector2.ZERO, 19.0, AreaAttack.GOO)
		draw_circle(Vector2(-6, -6), 6.0, Color(1, 1, 1, 0.6))
