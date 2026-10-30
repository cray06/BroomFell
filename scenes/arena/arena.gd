class_name Arena
extends Node2D

const GRASS := Color("#5AA55A")
const GRASS_DARK := Color("#4F9852")
const TUFT := Color("#438A4D")
const SAND := Color("#E6C58D")
const STONE := Color("#879DA5")
const STONE_TOP := Color("#A3B6BC")
const OUTLINE := Color("#253047")
const FLOWER_COLORS: Array[Color] = [Color("#FFE6A1"), Color("#A45CDA"), Color("#F05B52")]

@export var size := Vector2(1200, 1800)
@export var wall_thickness := 64.0
@export var obstacle_count := 12
@export var map_seed := 7
@export var spawn_clearance := 240.0

var bounds: Rect2:
	get:
		return Rect2(Vector2.ZERO, size)

var _obstacles: Array[Obstacle] = []
var _patches: Array[Dictionary] = []
var _tufts: Array[Vector2] = []
var _flowers: Array[Dictionary] = []


func generate(entities: Node2D) -> void:
	add_to_group("arena")
	var rng := RandomNumberGenerator.new()
	rng.seed = map_seed
	_build_walls()
	_place_obstacles(rng, entities)
	_place_decor(rng)
	queue_redraw()


func is_free(at: Vector2, radius: float) -> bool:
	if not bounds.grow(-radius - 20.0).has_point(at):
		return false
	for obstacle in _obstacles:
		if at.distance_to(obstacle.position) < obstacle.radius + radius + 20.0:
			return false
	return true


func _build_walls() -> void:
	var t := wall_thickness
	var walls: Array[Rect2] = [
		Rect2(-t, -t, size.x + 2 * t, t),
		Rect2(-t, size.y, size.x + 2 * t, t),
		Rect2(-t, 0, t, size.y),
		Rect2(size.x, 0, t, size.y),
	]
	for rect in walls:
		var shape := RectangleShape2D.new()
		shape.size = rect.size
		var collision := CollisionShape2D.new()
		collision.shape = shape
		collision.position = rect.get_center()
		var body := StaticBody2D.new()
		body.add_child(collision)
		add_child(body)


func _place_obstacles(rng: RandomNumberGenerator, entities: Node2D) -> void:
	var center := bounds.get_center()
	for attempt in 300:
		if _obstacles.size() >= obstacle_count:
			break
		var radius := rng.randf_range(30.0, 46.0)
		var at := Vector2(rng.randf_range(100, size.x - 100), rng.randf_range(140, size.y - 100))
		if at.distance_to(center) < spawn_clearance or not is_free(at, radius + 60.0):
			continue
		var obstacle := Obstacle.new()
		obstacle.setup(Obstacle.Kind.ROCK if rng.randf() < 0.5 else Obstacle.Kind.BUSH, radius)
		obstacle.position = at
		entities.add_child(obstacle)
		_obstacles.append(obstacle)


func _place_decor(rng: RandomNumberGenerator) -> void:
	for i in 26:
		_patches.append({
			"at": Vector2(rng.randf() * size.x, rng.randf() * size.y),
			"rx": rng.randf_range(60, 150),
			"ry": rng.randf_range(35, 80),
			"sand": rng.randf() < 0.2,
		})
	for i in 160:
		_tufts.append(Vector2(rng.randf() * size.x, rng.randf() * size.y))
	for i in 50:
		_flowers.append({
			"at": Vector2(rng.randf() * size.x, rng.randf() * size.y),
			"color": FLOWER_COLORS[rng.randi() % FLOWER_COLORS.size()],
		})


func _draw() -> void:
	var t := wall_thickness
	draw_rect(bounds, GRASS)
	for patch in _patches:
		var color: Color = SAND if patch.sand else GRASS_DARK
		if patch.sand:
			draw_colored_polygon(Obstacle.ellipse(patch.at, patch.rx + 6, patch.ry + 6), SAND.darkened(0.12))
		draw_colored_polygon(Obstacle.ellipse(patch.at, patch.rx, patch.ry), color)
	for tuft in _tufts:
		draw_polyline(PackedVector2Array([tuft + Vector2(-7, -2), tuft + Vector2(-3, 6),
				tuft + Vector2(0, -4), tuft + Vector2(3, 6), tuft + Vector2(7, -2)]), TUFT, 3.0, true)
	for flower in _flowers:
		draw_circle(flower.at, 6.0, OUTLINE)
		draw_circle(flower.at, 4.5, flower.color)
		draw_circle(flower.at, 1.8, Color.WHITE)

	draw_rect(Rect2(0, 0, size.x, 22), Color(OUTLINE, 0.22))
	draw_rect(Rect2(0, 0, 10, size.y), Color(OUTLINE, 0.15))
	draw_rect(Rect2(size.x - 10, 0, 10, size.y), Color(OUTLINE, 0.15))

	var outer := bounds.grow(t)
	for wall in [Rect2(outer.position, Vector2(outer.size.x, t)),
			Rect2(outer.position.x, size.y, outer.size.x, t),
			Rect2(outer.position.x, 0, t, size.y),
			Rect2(size.x, 0, t, size.y)]:
		draw_rect(wall, STONE)
		_draw_bricks(wall)
	draw_rect(Rect2(outer.position, Vector2(outer.size.x, t * 0.3)), STONE_TOP)
	draw_rect(bounds, OUTLINE, false, 5.0)
	draw_rect(outer, OUTLINE, false, 6.0)


func _draw_bricks(wall: Rect2) -> void:
	const BRICK := Vector2(64, 32)
	var line_color := Color(OUTLINE, 0.35)
	var row := 0
	var y := wall.position.y
	while y < wall.end.y:
		draw_line(Vector2(wall.position.x, y), Vector2(wall.end.x, y), line_color, 2.0)
		var x := wall.position.x + (BRICK.x / 2.0 if row % 2 else 0.0)
		while x < wall.end.x:
			draw_line(Vector2(x, y), Vector2(x, minf(y + BRICK.y, wall.end.y)), line_color, 2.0)
			x += BRICK.x
		y += BRICK.y
		row += 1
