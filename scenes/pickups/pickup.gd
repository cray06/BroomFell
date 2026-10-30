class_name Pickup
extends Node2D

signal collected(kind: String)

const OUTLINE := Color("#253047")
const COLORS := {
	"magnet": Color("#F05B52"),
	"bomb": Color("#FF9138"),
	"heart": Color("#F05B52"),
	"hourglass": Color("#9FE8FF"),
	"rage": Color("#FFE6A1"),
	"bubble": Color("#FFE6A1"),
	"chest": Color("#FFE6A1"),
}
const PICKUP_RADIUS := 40.0
const ATTRACT_RADIUS := 90.0
const LIFETIME := 15.0
const BODY_HEIGHT := Vector2(0, -24)

var kind := "heart"
var target: Player

var _velocity := Vector2.ZERO
var _age := 0.0


static func spawn(parent: Node, item_kind: String, at: Vector2, victim: Player) -> Pickup:
	var pickup := Pickup.new()
	pickup.kind = item_kind
	pickup.target = victim
	pickup.position = at
	pickup._velocity = Vector2.from_angle(randf() * TAU) * randf_range(80.0, 160.0)
	parent.add_child(pickup)
	return pickup


func _physics_process(delta: float) -> void:
	_age += delta
	if kind != "chest" and _age >= LIFETIME:
		queue_free()
		return
	_velocity = _velocity.move_toward(Vector2.ZERO, 400.0 * delta)
	if is_instance_valid(target) and not target.is_dead and _age > 0.4:
		var to_target := target.global_position - global_position
		if to_target.length() < PICKUP_RADIUS:
			_collect()
			return
		if to_target.length() < ATTRACT_RADIUS:
			_velocity = to_target.normalized() * 500.0
	position += _velocity * delta
	queue_redraw()


func _draw() -> void:
	if kind != "chest" and _age > LIFETIME - 3.0 and int(_age * 8.0) % 2 == 0:
		return
	var color: Color = COLORS.get(kind, Color.WHITE)
	var bob := Vector2(0, -24 + sin(_age * 4.0) * 5.0)
	var pulse := 0.5 + 0.5 * sin(_age * 6.0)
	draw_set_transform(Vector2(0, 2), 0.0, Vector2(1.0, 0.4))
	draw_circle(Vector2.ZERO, 18.0, Color(OUTLINE, 0.25))
	draw_set_transform(Vector2.ZERO)
	draw_circle(bob, 30.0 + pulse * 4.0, Color(color, 0.22))
	draw_arc(bob, 26.0, _age * 2.0, _age * 2.0 + PI * 1.4, 24, Color(Color.WHITE, 0.6), 2.5, true)
	SpellIcons.draw(self, "pickup_" + kind, bob, 40.0)


func _collect() -> void:
	Fx.burst(get_parent(), global_position + Vector2(0, -24), COLORS.get(kind, Color.WHITE), 16, 240.0, 0.45)
	collected.emit(kind)
	queue_free()
