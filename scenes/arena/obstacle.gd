class_name Obstacle
extends StaticBody2D

enum Kind { ROCK, BUSH }

const OUTLINE := Color("#253047")
const SHADOW := Color(0.145, 0.188, 0.278, 0.25)
const STONE := Color("#879DA5")
const STONE_SHADE := Color("#6B8089")
const STONE_LIGHT := Color("#B7C7CC")
const LEAF := Color("#387E55")
const LEAF_LIGHT := Color("#4FA35A")
const BERRY := Color("#F05B52")

var kind := Kind.ROCK
var radius := 36.0


func setup(obstacle_kind: Kind, obstacle_radius: float) -> void:
	kind = obstacle_kind
	radius = obstacle_radius
	var shape := CircleShape2D.new()
	shape.radius = radius * 0.8
	var collision := CollisionShape2D.new()
	collision.shape = shape
	collision.position = Vector2(0, -radius * 0.25)
	add_child(collision)


func _draw() -> void:
	draw_colored_polygon(ellipse(Vector2.ZERO, radius * 1.1, radius * 0.45), SHADOW)
	if kind == Kind.ROCK:
		_draw_rock()
	else:
		_draw_bush()


func _draw_rock() -> void:
	var center := Vector2(0, -radius * 0.4)
	var body := ellipse(center, radius, radius * 0.85)
	draw_colored_polygon(body, STONE)
	draw_colored_polygon(ellipse(center + Vector2(radius * 0.25, radius * 0.25),
			radius * 0.7, radius * 0.55), STONE_SHADE)
	draw_colored_polygon(ellipse(center + Vector2(-radius * 0.35, -radius * 0.35),
			radius * 0.3, radius * 0.18), STONE_LIGHT)
	_outline(body)


func _draw_bush() -> void:
	var blobs: Array[Vector3] = [
		Vector3(-0.45, -0.45, 0.62),
		Vector3(0.45, -0.45, 0.62),
		Vector3(0.0, -0.85, 0.7),
	]
	for blob in blobs:
		draw_circle(Vector2(blob.x, blob.y) * radius, blob.z * radius + 4.0, OUTLINE)
	for blob in blobs:
		draw_circle(Vector2(blob.x, blob.y) * radius, blob.z * radius, LEAF)
	for blob in blobs:
		draw_circle(Vector2(blob.x - 0.15, blob.y - 0.2) * radius, blob.z * radius * 0.45, LEAF_LIGHT)
	for berry in [Vector2(-0.4, -0.3), Vector2(0.3, -0.9), Vector2(0.55, -0.35)]:
		draw_circle(berry * radius, 4.5, OUTLINE)
		draw_circle(berry * radius, 3.0, BERRY)


func _outline(points: PackedVector2Array) -> void:
	var closed := points.duplicate()
	closed.append(points[0])
	draw_polyline(closed, OUTLINE, 4.0, true)


static func ellipse(center: Vector2, rx: float, ry: float, steps: int = 32) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in steps:
		var angle := TAU * i / steps
		points.append(center + Vector2(cos(angle) * rx, sin(angle) * ry))
	return points
