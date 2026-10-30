class_name KingSlime
extends CharacterBody2D

signal died(enemy: Node2D)

enum State { INTRO, CHASE, ATTACK, DEAD }
enum Attack { SLAM, RAIN, BURST }

const GOO := Color("#A45CDA")
const GOLD := Color("#FFE6A1")
const DANGER := Color("#F05B52")
const SPRITE_Y := -76.0
const INTRO_FALL_TIME := 1.6
const JUMP_HEIGHT := 280.0
const STOP_DISTANCE := 85.0

@export var move_speed := 75.0
@export var contact_damage := 20
@export var score_value := 300
@export var xp_drop := 25
@export var slam_damage := 30
@export var rain_damage := 18
@export var bullet_damage := 12

var hit_radius := 70.0
var center_offset := Vector2(0, -75)
var is_dead := false

var target: Player
var ground: Node2D
var entities: Node2D
var slime_scene: PackedScene
var arena_bounds := Rect2()

var _state := State.INTRO
var _timer := 0.0
var _enraged := false
var _airborne := false
var _last_attack := -1
var _time := 0.0
var _visual_tween: Tween
var _slowed := 0.0

@onready var visual: Node2D = $Visual
@onready var sprite: Sprite2D = $Visual/Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var health: HealthComponent = $HealthComponent
@onready var _sprite_scale: Vector2 = sprite.scale


func _ready() -> void:
	health.health_changed.connect(_on_health_changed)
	health.died.connect(_on_died)


func deals_contact_damage() -> bool:
	return _state == State.CHASE or (_state == State.ATTACK and not _airborne)


func play_intro() -> void:
	_state = State.INTRO
	AreaAttack.spawn(ground, global_position, 170.0, INTRO_FALL_TIME, 25, target)
	visual.position.y = -900.0
	visual.scale = Vector2(0.8, 1.3)
	var tween := create_tween()
	tween.tween_property(visual, "position:y", 0.0, INTRO_FALL_TIME) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(_land.bind(24.0))
	tween.tween_interval(0.9)
	tween.tween_callback(func() -> void:
		_state = State.CHASE
		_timer = 1.2)


func freeze(duration: float) -> void:
	if is_dead:
		return
	_slowed = maxf(_slowed, duration * 0.5)
	sprite.self_modulate = Color(0.7, 0.85, 1.3)


func take_hit(damage: int, _from_direction: Vector2, crit: bool = false) -> void:
	if is_dead or _state == State.INTRO:
		return
	sprite.material.set_shader_parameter("flash_amount", 0.8)
	create_tween().tween_property(sprite, "material:shader_parameter/flash_amount", 0.0, 0.12)
	Fx.damage_number(get_parent(), global_position + Vector2(randf_range(-50, 50), -190), damage,
			Fx.LIGHT, crit)
	health.take_damage(damage)


func _physics_process(delta: float) -> void:
	_time += delta
	if _state != State.DEAD:
		var breath := sin(_time * (5.0 if _enraged else 3.0)) * 0.04
		sprite.scale = _sprite_scale * Vector2(1.0 + breath, 1.0 - breath)
	if _slowed > 0.0:
		_slowed -= delta
		if _slowed <= 0.0:
			sprite.self_modulate = Color(1.0, 0.8, 0.85) if _enraged else Color.WHITE
	if _state != State.CHASE:
		return

	if is_instance_valid(target) and not target.is_dead:
		var speed := move_speed * (1.5 if _enraged else 1.0) * (0.4 if _slowed > 0.0 else 1.0)
		if global_position.distance_to(target.global_position) > STOP_DISTANCE:
			velocity = global_position.direction_to(target.global_position) * speed
		else:
			velocity = Vector2.ZERO
		move_and_slide()
	_timer -= delta
	if _timer <= 0.0:
		_start_attack()


func _start_attack() -> void:
	_state = State.ATTACK
	var options: Array[int] = [Attack.SLAM, Attack.RAIN, Attack.BURST]
	options.erase(_last_attack)
	var attack: int = options.pick_random()
	_last_attack = attack
	match attack:
		Attack.SLAM:
			await _attack_slam()
		Attack.RAIN:
			await _attack_rain()
		Attack.BURST:
			await _attack_burst()
	if is_dead:
		return
	_state = State.CHASE
	_timer = 0.9 if _enraged else 1.6


func _attack_slam() -> void:
	for jump in (2 if _enraged else 1):
		if is_dead or not _target_alive():
			return
		await _squash_to(Vector2(1.3, 0.7), 0.25)
		if is_dead:
			return
		var destination := _clamp_to_arena(target.global_position)
		var air_time := 0.75 if _enraged else 0.95
		AreaAttack.spawn(ground, destination, 150.0, air_time, slam_damage, target)
		_airborne = true
		visual.scale = Vector2(0.8, 1.25)
		var tween := create_tween()
		tween.tween_property(self, "global_position", destination, air_time)
		tween.parallel().tween_method(_set_jump_height, 0.0, 1.0, air_time)
		await tween.finished
		_airborne = false
		if is_dead:
			return
		_land(14.0)
		if _enraged:
			_spawn_minions(2)
		await _wait(0.35)


func _attack_rain() -> void:
	await _roar()
	var count := 11 if _enraged else 7
	for k in count:
		if is_dead or not _target_alive():
			return
		var at := target.global_position
		if k > 0:
			at += Vector2.from_angle(randf() * TAU) * randf_range(70.0, 320.0)
		AreaAttack.spawn(ground, _clamp_to_arena(at), 72.0, 1.15, rain_damage, target, true)
		await _wait(0.1)
	await _wait(0.9)


func _attack_burst() -> void:
	var charge := create_tween()
	for i in 3:
		charge.tween_property(sprite, "material:shader_parameter/flash_amount", 0.7, 0.12)
		charge.parallel().tween_property(visual, "scale", Vector2(1.12, 1.12), 0.12)
		charge.tween_property(sprite, "material:shader_parameter/flash_amount", 0.0, 0.12)
		charge.parallel().tween_property(visual, "scale", Vector2.ONE, 0.12)
	await charge.finished

	var waves := 3 if _enraged else 2
	var count := 18 if _enraged else 14
	for wave in waves:
		if is_dead:
			return
		var offset := wave * PI / count
		var origin := global_position + center_offset
		for k in count:
			var dir := Vector2.from_angle(TAU * k / count + offset)
			BossBullet.spawn(entities, origin + dir * 60.0, dir * 260.0, target, bullet_damage)
		Fx.burst(entities, origin, GOO, 16, 280.0, 0.45)
		get_tree().call_group("camera", "shake", 6.0)
		_squash_to(Vector2(1.25, 0.8), 0.1)
		await _wait(0.5)


func _roar() -> void:
	var tween := create_tween()
	for i in 3:
		tween.tween_property(visual, "scale", Vector2(1.15, 0.88), 0.1)
		tween.tween_property(visual, "scale", Vector2(0.92, 1.1), 0.1)
	tween.tween_property(visual, "scale", Vector2.ONE, 0.1)
	Fx.burst(entities, global_position + center_offset, GOO, 20, 300.0, 0.5)
	get_tree().call_group("camera", "shake", 8.0)
	await tween.finished


func _land(shake: float) -> void:
	_set_jump_height(0.0)
	Fx.burst(entities, global_position + Vector2(0, -20), GOO, 30, 380.0, 0.6)
	Fx.burst(entities, global_position + Vector2(0, -20), GOLD, 10, 260.0, 0.35)
	get_tree().call_group("camera", "shake", shake)
	_squash_to(Vector2(1.4, 0.6), 0.0)
	_kill_visual_tween()
	_visual_tween = create_tween()
	_visual_tween.tween_property(visual, "scale", Vector2.ONE, 0.6) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


func _spawn_minions(count: int) -> void:
	for i in count:
		var slime := slime_scene.instantiate() as Slime
		slime.target = target
		slime.horde = true
		slime.detection_range = 5000.0
		slime.score_value = 5
		slime.xp_drop = 1
		slime.position = _clamp_to_arena(global_position + Vector2.from_angle(randf() * TAU) * 120.0)
		entities.add_child(slime)
		get_tree().call_group("wave_director", "track_enemy", slime)


func _set_jump_height(t: float) -> void:
	visual.position.y = -sin(PI * t) * JUMP_HEIGHT


func _squash_to(amount: Vector2, duration: float) -> Signal:
	_kill_visual_tween()
	_visual_tween = create_tween()
	if duration <= 0.0:
		visual.scale = amount
		_visual_tween.tween_interval(0.0)
	else:
		_visual_tween.tween_property(visual, "scale", amount, duration)
	return _visual_tween.finished


func _kill_visual_tween() -> void:
	if _visual_tween:
		_visual_tween.kill()


func _wait(seconds: float) -> Signal:
	return get_tree().create_timer(seconds, false).timeout


func _target_alive() -> bool:
	return is_instance_valid(target) and not target.is_dead


func _clamp_to_arena(at: Vector2) -> Vector2:
	var area := arena_bounds.grow(-90.0)
	return at.clamp(area.position, area.end)


func _on_health_changed(current: int, maximum: int) -> void:
	if not _enraged and current <= maximum / 2:
		_enraged = true
		sprite.self_modulate = Color(1.0, 0.8, 0.85)
		Fx.burst(entities, global_position + center_offset, DANGER, 30, 360.0, 0.55)
		get_tree().call_group("camera", "shake", 12.0)


func _on_died() -> void:
	is_dead = true
	_state = State.DEAD
	collision.set_deferred("disabled", true)
	_kill_visual_tween()
	died.emit(self)

	var tween := create_tween()
	for i in 6:
		tween.tween_callback(func() -> void:
			var spot := global_position + center_offset + Vector2(randf_range(-70, 70), randf_range(-60, 50))
			Fx.burst(entities, spot, GOO, 14, 260.0, 0.45)
			Fx.burst(entities, spot, GOLD, 6, 200.0, 0.3)
			get_tree().call_group("camera", "shake", 8.0)
			sprite.material.set_shader_parameter("flash_amount", 1.0 if i % 2 == 0 else 0.0)
			visual.position = Vector2(randf_range(-8, 8), randf_range(-4, 4)))
		tween.tween_interval(0.16)
	tween.tween_property(visual, "scale", Vector2(1.5, 0.45), 0.15)
	tween.tween_callback(func() -> void:
		var center := global_position + center_offset
		Fx.burst(entities, center, GOO, 50, 520.0, 0.8)
		Fx.burst(entities, center, GOLD, 24, 420.0, 0.5)
		NovaFx.spawn(entities, global_position, 320.0, GOLD)
		get_tree().call_group("camera", "shake", 26.0))
	tween.tween_property(visual, "scale", Vector2.ZERO, 0.12)
	tween.tween_callback(queue_free)
