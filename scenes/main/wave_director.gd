class_name WaveDirector
extends Node

signal enemy_killed(enemy: Node2D)
signal horde_incoming
signal boss_incoming
signal boss_spawned(boss: KingSlime)
signal boss_defeated

@export var slime_scene: PackedScene
@export var boss_scene: PackedScene
@export var base_slimes := 6
@export var max_slimes := 28
@export var horde_interval := 35.0
@export var first_boss_score := 400
@export var boss_score_step := 1200
@export var spawn_distance := 380.0

var elapsed := 0.0

var _arena: Arena
var _entities: Node2D
var _ground: Node2D
var _player: Player
var _spawn_timer := 0.0
var _horde_timer := 0.0
var _next_boss_score := 0
var _last_score := 0
var _player_level := 1
var _boss: KingSlime
var _boss_pending := false
var _boss_count := 0
var _stopped := false


func setup(arena: Arena, entities: Node2D, ground: Node2D, player: Player) -> void:
	_arena = arena
	_entities = entities
	_ground = ground
	_player = player
	_horde_timer = horde_interval
	_next_boss_score = first_boss_score
	add_to_group("wave_director")
	for i in base_slimes:
		_spawn_slime(_random_spawn_point(spawn_distance), false)


func _physics_process(delta: float) -> void:
	if _stopped or _arena == null:
		return
	elapsed += delta

	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = 0.5
		if _alive_slimes() < _target_count():
			_spawn_slime(_random_spawn_point(spawn_distance), false)

	if _boss == null and not _boss_pending:
		_horde_timer -= delta
		if _horde_timer <= 0.0:
			_start_horde()


func on_score_changed(score: int) -> void:
	_last_score = score
	if _boss == null and not _boss_pending and not _stopped and score >= _next_boss_score:
		_start_boss()


func on_level_up(level: int) -> void:
	_player_level = level
	if level % 5 == 0 and _boss == null and not _boss_pending:
		_start_horde()


func stop() -> void:
	_stopped = true


func track_enemy(enemy: Node2D) -> void:
	enemy.died.connect(_on_enemy_died)


func _target_count() -> int:
	if _boss != null or _boss_pending:
		return 4
	return mini(base_slimes + int(elapsed / 12.0) + _player_level / 2, max_slimes)


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
	health.max_health = int(30.0 * (1.0 + elapsed / 90.0))
	slime.hop_speed *= 1.0 + minf(elapsed / 200.0, 0.6)
	slime.contact_damage = 10 + int(elapsed / 60.0) * 2
	if horde:
		slime.horde = true
		slime.detection_range = 5000.0
		slime.hop_interval = 0.8
	_entities.add_child(slime)
	slime.died.connect(_on_enemy_died)


func _start_horde() -> void:
	_horde_timer = horde_interval
	horde_incoming.emit()
	var size := mini(10 + _player_level * 2 + int(elapsed / 10.0), 32)
	var center := _random_spawn_point(520.0)
	var area := _arena.bounds.grow(-60.0)
	for k in size:
		if _stopped:
			return
		var at := center + Vector2.from_angle(randf() * TAU) * randf_range(0.0, 170.0)
		at = at.clamp(area.position, area.end)
		if not _arena.is_free(at, 30.0):
			at = center
		Fx.burst(_entities, at + Vector2(0, -20), Slime.HORDE_GOO, 6, 160.0, 0.35)
		_spawn_slime(at, true)
		await get_tree().create_timer(0.06, false).timeout


func _start_boss() -> void:
	_boss_pending = true
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
	health.max_health = int(health.max_health * (1.0 + 0.6 * _boss_count))
	_entities.add_child(boss)
	boss.died.connect(_on_boss_died)
	_boss = boss
	_boss_pending = false
	boss_spawned.emit(boss)
	boss.play_intro()


func _on_enemy_died(enemy: Node2D) -> void:
	enemy_killed.emit(enemy)


func _on_boss_died(boss: Node2D) -> void:
	enemy_killed.emit(boss)
	_boss = null
	_boss_count += 1
	_next_boss_score = _last_score + boss_score_step
	_horde_timer = horde_interval
	await get_tree().create_timer(1.4, false).timeout
	boss_defeated.emit()


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
