class_name WaveDirector
extends Node

signal enemy_killed(enemy: Node2D)
signal horde_incoming
signal boss_incoming
signal boss_spawned(boss: KingSlime)
signal boss_defeated
signal overtime_started

enum Phase { WAVES, BOSS, OVERTIME }

@export var slime_scene: PackedScene
@export var boss_scene: PackedScene
@export var stage_duration := 900.0
@export var base_slimes := 6
@export var max_wave_slimes := 45
@export var max_overtime_slimes := 140
@export var hard_cap_slimes := 180
@export var horde_interval_start := 35.0
@export var horde_interval_end := 22.0
@export var spawn_distance := 380.0

const BOSS_PHASE_SLIMES := 4
const VICTORY_DELAY := 1.4
const OVERTIME_DELAY := 2.5
const OVERTIME_HEALTH_BASE := 1.6
const OVERTIME_HEALTH_PERIOD := 30.0
const OVERTIME_DAMAGE_PERIOD := 45.0

var phase := Phase.WAVES
var difficulty := 1.0
var time_left := 0.0
var overtime := 0.0

var _arena: Arena
var _entities: Node2D
var _ground: Node2D
var _player: Player
var _spawn_timer := 0.0
var _horde_timer := 0.0
var _player_level := 1
var _stopped := false


func setup(arena: Arena, entities: Node2D, ground: Node2D, player: Player) -> void:
	_arena = arena
	_entities = entities
	_ground = ground
	_player = player
	time_left = stage_duration
	_horde_timer = horde_interval_start
	add_to_group("wave_director")
	for i in base_slimes:
		_spawn_slime(_random_spawn_point(spawn_distance), false)


func _physics_process(delta: float) -> void:
	if _stopped or _arena == null:
		return
	_advance_clock(delta)

	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = _spawn_interval()
		var missing := _target_count() - _alive_slimes()
		for k in mini(missing, _spawn_batch()):
			_spawn_slime(_random_spawn_point(spawn_distance), false)

	if phase != Phase.BOSS:
		_horde_timer -= delta
		if _horde_timer <= 0.0:
			_start_horde()


func clock() -> float:
	return -overtime if phase == Phase.OVERTIME else time_left


func on_level_up(level: int) -> void:
	_player_level = level
	if level % 5 == 0 and phase == Phase.WAVES:
		_start_horde()


func stop() -> void:
	_stopped = true


func track_enemy(enemy: Node2D) -> void:
	enemy.died.connect(_on_enemy_died)


func _advance_clock(delta: float) -> void:
	match phase:
		Phase.WAVES:
			time_left -= delta
			if time_left <= 0.0:
				time_left = 0.0
				phase = Phase.BOSS
				_start_boss()
		Phase.OVERTIME:
			overtime += delta


func _progress() -> float:
	return clampf(1.0 - time_left / stage_duration, 0.0, 1.0)


func _health_multiplier() -> float:
	var p := _progress()
	var wave_mult := 1.0 + 3.0 * p + 3.0 * p * p
	if phase == Phase.OVERTIME:
		wave_mult *= pow(OVERTIME_HEALTH_BASE, overtime / OVERTIME_HEALTH_PERIOD)
	return wave_mult * difficulty


func _contact_damage() -> int:
	var damage := 10.0 * (1.0 + 1.5 * _progress())
	if phase == Phase.OVERTIME:
		damage *= 1.0 + overtime / OVERTIME_DAMAGE_PERIOD
	return int(damage * difficulty)


func _speed_multiplier() -> float:
	var bonus := 0.6 * _progress()
	if phase == Phase.OVERTIME:
		bonus += minf(overtime / 120.0, 0.6)
	return 1.0 + bonus


func _target_count() -> int:
	match phase:
		Phase.BOSS:
			return BOSS_PHASE_SLIMES
		Phase.OVERTIME:
			return mini(max_wave_slimes + int(overtime * 0.5), max_overtime_slimes)
	var count := int(lerpf(base_slimes, max_wave_slimes, _progress())) + _player_level / 3
	return mini(count, max_wave_slimes)


func _spawn_interval() -> float:
	if phase == Phase.OVERTIME:
		return maxf(0.12, 0.4 - overtime / 300.0)
	return 0.5


func _spawn_batch() -> int:
	if phase == Phase.OVERTIME:
		return 1 + int(overtime / 40.0)
	return 1


func _horde_interval() -> float:
	if phase == Phase.OVERTIME:
		return maxf(8.0, 16.0 - overtime / 30.0)
	return lerpf(horde_interval_start, horde_interval_end, _progress())


func _horde_size() -> int:
	if phase == Phase.OVERTIME:
		return mini(32 + int(overtime / 5.0), 60)
	return mini(10 + _player_level * 2 + int(_progress() * 20.0), 32)


func _alive_slimes() -> int:
	var count := 0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy is Slime and not enemy.is_dead:
			count += 1
	return count


func _spawn_slime(at: Vector2, horde: bool) -> void:
	var slime := slime_scene.instantiate() as Slime
	slime.target = _player
	slime.position = at
	var health: HealthComponent = slime.get_node("HealthComponent")
	health.max_health = int(30.0 * _health_multiplier())
	slime.hop_speed *= _speed_multiplier()
	slime.contact_damage = _contact_damage()
	if horde:
		slime.horde = true
		slime.detection_range = 5000.0
		slime.hop_interval = 0.8
	_entities.add_child(slime)
	slime.died.connect(_on_enemy_died)


func _start_horde() -> void:
	_horde_timer = _horde_interval()
	horde_incoming.emit()
	var center := _random_spawn_point(520.0)
	var area := _arena.bounds.grow(-60.0)
	for k in _horde_size():
		if _stopped or _alive_slimes() >= hard_cap_slimes:
			return
		var at := center + Vector2.from_angle(randf() * TAU) * randf_range(0.0, 170.0)
		at = at.clamp(area.position, area.end)
		if not _arena.is_free(at, 30.0):
			at = center
		Fx.burst(_entities, at + Vector2(0, -20), Slime.HORDE_GOO, 6, 160.0, 0.35)
		_spawn_slime(at, true)
		await get_tree().create_timer(0.06, false).timeout


func _start_boss() -> void:
	boss_incoming.emit()
	await get_tree().create_timer(2.0, false).timeout
	if _stopped:
		return

	var boss := boss_scene.instantiate() as KingSlime
	boss.target = _player
	boss.ground = _ground
	boss.entities = _entities
	boss.slime_scene = slime_scene
	boss.arena_bounds = _arena.bounds
	boss.position = _arena.bounds.get_center()
	var health: HealthComponent = boss.get_node("HealthComponent")
	health.max_health = int(health.max_health * difficulty)
	_entities.add_child(boss)
	boss.died.connect(_on_boss_died)
	boss_spawned.emit(boss)
	boss.play_intro()


func _on_enemy_died(enemy: Node2D) -> void:
	enemy_killed.emit(enemy)


func _on_boss_died(boss: Node2D) -> void:
	enemy_killed.emit(boss)
	await get_tree().create_timer(VICTORY_DELAY, false).timeout
	if _stopped:
		return
	boss_defeated.emit()
	await get_tree().create_timer(OVERTIME_DELAY, false).timeout
	if _stopped:
		return
	phase = Phase.OVERTIME
	overtime = 0.0
	_horde_timer = _horde_interval()
	overtime_started.emit()


func _random_spawn_point(min_distance: float) -> Vector2:
	var area := _arena.bounds.grow(-80.0)
	for attempt in 60:
		var at := Vector2(randf_range(area.position.x, area.end.x), randf_range(area.position.y, area.end.y))
		if _arena.is_free(at, 40.0) and at.distance_to(_player.global_position) > min_distance:
			return at
	var corners: Array[Vector2] = [area.position, Vector2(area.end.x, area.position.y),
			Vector2(area.position.x, area.end.y), area.end]
	var best := corners[0]
	for corner in corners:
		if corner.distance_to(_player.global_position) > best.distance_to(_player.global_position):
			best = corner
	return best
