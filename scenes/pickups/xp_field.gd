class_name XpField
extends Node2D

signal collected(value: int)

const GEM_TEXTURE := preload("res://assets/sprites/pickups/xp_gem.svg")
const BIG_GEM_TEXTURE := preload("res://assets/sprites/pickups/xp_gem_big.svg")
const GEM_COLOR := Color("#C895EC")
const SHADOW_COLOR := Color(0.145, 0.188, 0.278, 0.25)
const SHADOW_RECT := Rect2(-9, 0, 18, 8)
const BOB_HEIGHT := -6.0
const MAX_ORBS := 220
const BIG_VALUE := 5
const MAGNET_RADIUS := 170.0
const PICKUP_RADIUS := 26.0
const BODY_HEIGHT := Vector2(0, -30)
const ATTRACT_DELAY := 0.35
const PULL_SPEED := 1100.0
const PULL_ACCELERATION := 3000.0
const FRICTION := 600.0
const MAX_BURSTS_PER_FRAME := 2

var target: Player

var _positions := PackedVector2Array()
var _velocities := PackedVector2Array()
var _ages := PackedFloat32Array()
var _values := PackedInt32Array()
var _magnetized := PackedByteArray()


func spawn(at: Vector2, value: int, initial_velocity: Vector2) -> void:
	if _positions.size() >= MAX_ORBS:
		_values[_nearest_orb(at)] += value
		return
	_positions.append(at)
	_velocities.append(initial_velocity)
	_ages.append(0.0)
	_values.append(value)
	_magnetized.append(0)


func attract_all() -> void:
	_magnetized.fill(1)


func _physics_process(delta: float) -> void:
	if _positions.is_empty():
		return
	var has_target := is_instance_valid(target) and not target.is_dead
	var goal := target.global_position + BODY_HEIGHT if has_target else Vector2.ZERO
	var magnet_radius := MAGNET_RADIUS * target.stats.pickup_radius_mult if has_target else 0.0
	var magnet_sq := magnet_radius * magnet_radius
	var pickup_sq := PICKUP_RADIUS * PICKUP_RADIUS
	var gained := 0
	var bursts := 0

	var i := _positions.size() - 1
	while i >= 0:
		_ages[i] += delta
		var position_i := _positions[i]
		var velocity_i := _velocities[i]
		if has_target:
			var to_goal := goal - position_i
			var distance_sq := to_goal.length_squared()
			if _magnetized[i] == 1 and distance_sq < pickup_sq:
				gained += _values[i]
				if bursts < MAX_BURSTS_PER_FRAME:
					bursts += 1
					Fx.burst(get_parent(), position_i, GEM_COLOR, 5, 120.0, 0.25)
				_remove(i)
				i -= 1
				continue
			if _ages[i] > ATTRACT_DELAY and distance_sq < magnet_sq:
				_magnetized[i] = 1
			if _magnetized[i] == 1:
				velocity_i = velocity_i.move_toward(to_goal.normalized() * PULL_SPEED, PULL_ACCELERATION * delta)
		if _magnetized[i] == 0:
			velocity_i = velocity_i.move_toward(Vector2.ZERO, FRICTION * delta)
		_velocities[i] = velocity_i
		_positions[i] = position_i + velocity_i * delta
		i -= 1

	if gained > 0:
		collected.emit(gained)
	queue_redraw()


func _draw() -> void:
	var shadow := Fx.dot_texture()
	for i in _positions.size():
		var shadow_rect := Rect2(_positions[i] + SHADOW_RECT.position, SHADOW_RECT.size)
		draw_texture_rect(shadow, shadow_rect, false, SHADOW_COLOR)
	_draw_gems(GEM_TEXTURE, false)
	_draw_gems(BIG_GEM_TEXTURE, true)


func _draw_gems(texture: Texture2D, big: bool) -> void:
	var half := texture.get_size() / 2.0
	for i in _positions.size():
		if (_values[i] >= BIG_VALUE) != big:
			continue
		var bob := Vector2(0, BOB_HEIGHT + sin(_ages[i] * 6.0) * 3.0)
		draw_texture(texture, _positions[i] + bob - half)


func _nearest_orb(at: Vector2) -> int:
	var best := 0
	var best_distance := INF
	for i in _positions.size():
		var distance := at.distance_squared_to(_positions[i])
		if distance < best_distance:
			best = i
			best_distance = distance
	return best


func _remove(index: int) -> void:
	var last := _positions.size() - 1
	if index != last:
		_positions[index] = _positions[last]
		_velocities[index] = _velocities[last]
		_ages[index] = _ages[last]
		_values[index] = _values[last]
		_magnetized[index] = _magnetized[last]
	_positions.resize(last)
	_velocities.resize(last)
	_ages.resize(last)
	_values.resize(last)
	_magnetized.resize(last)
