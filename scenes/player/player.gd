class_name Player
extends CharacterBody2D
## La sorcière. Se déplace au joystick (ou ZQSD / WASD / flèches),
## tire automatiquement dans la direction où elle regarde,
## et perd des PV quand un monstre la touche.

signal hurt
signal died

const SPRITE_Y := -37.0
const CAST_HEIGHT := 46.0
const CAST_DISTANCE := 34.0
const BOLT_DAMAGE := 10
const SPREAD_ANGLE := 0.2
const ARROW_COLOR := Color("#FFE6A1")
const OUTLINE := Color("#253047")
const MAGIC := Color("#39C9F0")
const DANGER := Color("#F05B52")
const HEAL := Color("#70C95B")
const RAGE := Color("#FF9138")
const DEATH_SPARK := Color("#A45CDA")

@export var move_speed := 260.0
@export var acceleration := 2200.0
@export var fire_interval := 0.35
@export var invulnerability_time := 0.8
@export var hurt_knockback := 420.0
@export var bolt_scene: PackedScene

## Fourni par la scène principale.
var joystick: TouchJoystick
var facing := Vector2.UP
var is_dead := false
var stats := PlayerStats.new()

var _fire_cooldown := 0.0
var _anim_time := 0.0
var _aim_angle := Vector2.UP.angle()
var _invulnerable := 0.0
var _rage_time := 0.0
var _bubble_time := 0.0
var _shield_ready := false
var _shield_cooldown := 0.0
var _regen_progress := 0.0
var _shoot_tween: Tween
var _bubble: ShieldBubble

@onready var visual: Node2D = $Visual
@onready var body_sprite: Sprite2D = $Visual/Sprite2D
@onready var health: HealthComponent = $HealthComponent
@onready var health_bar: HealthBar = $HealthBar
@onready var hurtbox: Area2D = $Hurtbox
@onready var spell_book: SpellBook = $SpellBook
@onready var _sprite_scale: Vector2 = body_sprite.scale


func _ready() -> void:
	spell_book.player = self
	health.health_changed.connect(_on_health_changed)
	health.died.connect(_on_died)
	_bubble = ShieldBubble.new()
	_bubble.player = self
	add_child(_bubble)


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	var input := _read_input()
	if input != Vector2.ZERO:
		facing = input.normalized()

	var speed := move_speed * stats.move_speed_mult
	velocity = velocity.move_toward(input * speed, acceleration * delta)
	move_and_slide()
	_animate(delta)
	_update_invulnerability(delta)
	_update_buffs(delta)
	_check_contact_damage()

	_fire_cooldown -= delta
	if _fire_cooldown <= 0.0:
		var rage_mult := 2.0 if _rage_time > 0.0 else 1.0
		_fire_cooldown = fire_interval / (stats.fire_rate_mult * rage_mult)
		_shoot()


func _draw() -> void:
	if is_dead:
		return
	# Flèche de visée au sol, aplatie pour suivre la vue 3/4.
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.6))
	draw_arc(Vector2.ZERO, 48.0, 0.0, TAU, 48, Color(1, 1, 1, 0.25), 3.0, true)
	var dir := Vector2.from_angle(_aim_angle)
	var side := dir.orthogonal() * 12.0
	var arrow := PackedVector2Array([dir * 74.0, dir * 54.0 + side, dir * 54.0 - side])
	draw_colored_polygon(arrow, ARROW_COLOR)
	arrow.append(arrow[0])
	draw_polyline(arrow, OUTLINE, 3.0, true)


## Dégâts finaux d'une attaque : puissance et chance de critique.
func roll_damage(base: int) -> Dictionary:
	var amount := float(base) * stats.damage_mult
	var crit := randf() < stats.crit_chance
	if crit:
		amount *= stats.crit_multiplier
	return {"amount": maxi(1, roundi(amount)), "crit": crit}


func take_damage(amount: int, from_position: Vector2) -> void:
	if is_dead or _invulnerable > 0.0 or _bubble_time > 0.0:
		return
	if _shield_ready:
		_shield_ready = false
		_shield_cooldown = stats.shield_interval
		_invulnerable = 0.5
		Fx.burst(get_parent(), global_position + Vector2(0, -40), MAGIC, 16, 260.0, 0.4)
		Fx.popup_text(get_parent(), global_position + Vector2(0, -110), "Bloqué !", MAGIC, 28)
		return
	_invulnerable = invulnerability_time
	velocity = from_position.direction_to(global_position) * hurt_knockback
	body_sprite.material.set_shader_parameter("flash_amount", 1.0)
	create_tween().tween_property(body_sprite, "material:shader_parameter/flash_amount", 0.0, 0.2)
	Fx.damage_number(get_parent(), global_position + Vector2(0, -100), amount, DANGER)
	Fx.burst(get_parent(), global_position + Vector2(0, -40), DANGER, 8, 200.0, 0.35)
	hurt.emit()
	health.take_damage(amount)


func heal(amount: int) -> void:
	if is_dead:
		return
	health.heal(amount)
	Fx.burst(get_parent(), global_position + Vector2(0, -40), HEAL, 14, 200.0, 0.4)
	Fx.popup_text(get_parent(), global_position + Vector2(0, -100), "+%d" % amount, HEAL, 30)


func add_max_health(amount: int) -> void:
	health.max_health += amount
	heal(amount)


## Appelé à chaque monstre tué (vampirisme).
func on_kill() -> void:
	if stats.lifesteal_chance > 0.0 and randf() < stats.lifesteal_chance:
		health.heal(3)
		Fx.burst(get_parent(), global_position + Vector2(0, -40), DANGER, 6, 140.0, 0.3)


func activate_rage(duration: float) -> void:
	_rage_time = maxf(_rage_time, duration)


func activate_bubble(duration: float) -> void:
	_bubble_time = maxf(_bubble_time, duration)


func is_raging() -> bool:
	return _rage_time > 0.0


func has_bubble() -> bool:
	return _bubble_time > 0.0


func bubble_time_left() -> float:
	return _bubble_time


func shield_ready() -> bool:
	return _shield_ready


func _read_input() -> Vector2:
	if joystick and joystick.output != Vector2.ZERO:
		return joystick.output
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")


func _check_contact_damage() -> void:
	if _invulnerable > 0.0:
		return
	for body in hurtbox.get_overlapping_bodies():
		if body.has_method("deals_contact_damage") and body.deals_contact_damage():
			take_damage(body.contact_damage, body.global_position)
			return


func _update_invulnerability(delta: float) -> void:
	if _invulnerable <= 0.0:
		return
	_invulnerable -= delta
	# Clignotement pendant l'invincibilité.
	var blink_on := int(_invulnerable * 20.0) % 2 == 0
	visual.modulate.a = 0.35 if blink_on and _invulnerable > 0.0 else 1.0


func _update_buffs(delta: float) -> void:
	if _rage_time > 0.0:
		_rage_time -= delta
		var pulse := 0.5 + 0.5 * sin(_anim_time * 14.0)
		body_sprite.self_modulate = Color.WHITE.lerp(Color(1.5, 1.15, 0.7), pulse)
		if randf() < 0.3:
			Fx.burst(get_parent(), global_position + Vector2(randf_range(-20, 20), -10), RAGE, 1, 80.0, 0.25)
	else:
		body_sprite.self_modulate = Color.WHITE

	if _bubble_time > 0.0:
		_bubble_time -= delta

	if stats.shield_interval > 0.0 and not _shield_ready:
		_shield_cooldown -= delta
		if _shield_cooldown <= 0.0:
			_shield_ready = true

	if stats.regen_per_second > 0.0 and health.current_health < health.max_health:
		_regen_progress += stats.regen_per_second * delta
		if _regen_progress >= 1.0:
			var amount := int(_regen_progress)
			_regen_progress -= amount
			health.heal(amount)
	_bubble.queue_redraw()


func _animate(delta: float) -> void:
	_aim_angle = lerp_angle(_aim_angle, facing.angle(), minf(1.0, 18.0 * delta))
	queue_redraw()

	if absf(facing.x) > 0.1:
		body_sprite.flip_h = facing.x < 0.0

	_anim_time += delta
	if velocity.length() > 20.0:
		# Marche : petits rebonds et balancement.
		body_sprite.position.y = SPRITE_Y - absf(sin(_anim_time * 14.0)) * 6.0
		body_sprite.rotation = sin(_anim_time * 14.0) * 0.08
		body_sprite.scale = _sprite_scale
	else:
		# Repos : respiration légère.
		var weight := minf(1.0, 12.0 * delta)
		body_sprite.position.y = lerpf(body_sprite.position.y, SPRITE_Y, weight)
		body_sprite.rotation = lerpf(body_sprite.rotation, 0.0, weight)
		var breath := sin(_anim_time * 3.0) * 0.025
		body_sprite.scale = _sprite_scale * Vector2(1.0 + breath, 1.0 - breath)


func _shoot() -> void:
	var directions: Array[Vector2] = []
	var front := stats.projectile_count
	for i in front:
		directions.append(facing.rotated((i - (front - 1) / 2.0) * SPREAD_ANGLE))
	var back := stats.back_shots
	for i in back:
		directions.append((-facing).rotated((i - (back - 1) / 2.0) * SPREAD_ANGLE * 1.5))

	var origin := global_position + Vector2(0, -CAST_HEIGHT)
	for dir in directions:
		var bolt := bolt_scene.instantiate() as MagicBolt
		bolt.direction = dir
		bolt.damage = BOLT_DAMAGE
		bolt.source = self
		bolt.pierce = stats.pierce
		bolt.ricochet = stats.ricochet
		if _rage_time > 0.0:
			bolt.color = RAGE
		get_parent().add_child(bolt)
		bolt.global_position = origin + dir * CAST_DISTANCE
	Fx.burst(get_parent(), origin + facing * CAST_DISTANCE, MAGIC, 6, 120.0, 0.3)
	_play_shoot_animation()


func _play_shoot_animation() -> void:
	if _shoot_tween:
		_shoot_tween.kill()
	visual.scale = Vector2(1.12, 0.88)
	visual.position = -facing * 5.0
	_shoot_tween = create_tween().set_parallel()
	_shoot_tween.tween_property(visual, "scale", Vector2.ONE, 0.18) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_shoot_tween.tween_property(visual, "position", Vector2.ZERO, 0.12)


func _on_health_changed(current: int, maximum: int) -> void:
	health_bar.set_ratio(float(current) / maximum)


func _on_died() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	visual.modulate.a = 1.0
	_rage_time = 0.0
	_bubble_time = 0.0
	_shield_ready = false
	health_bar.hide()
	spell_book.hide()
	spell_book.process_mode = Node.PROCESS_MODE_DISABLED
	hurtbox.set_deferred("monitoring", false)
	queue_redraw()
	died.emit()

	if _shoot_tween:
		_shoot_tween.kill()
	var tween := create_tween()
	tween.tween_property(visual, "scale", Vector2(1.3, 0.7), 0.12)
	tween.tween_property(visual, "scale", Vector2(0.8, 1.3), 0.1)
	tween.tween_callback(func() -> void:
		Fx.burst(get_parent(), global_position + Vector2(0, -40), DEATH_SPARK, 26, 320.0, 0.55)
		Fx.burst(get_parent(), global_position + Vector2(0, -40), ARROW_COLOR, 12, 260.0, 0.4))
	tween.tween_property(visual, "rotation", TAU * 2.0, 0.6).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(visual, "scale", Vector2.ZERO, 0.6).set_ease(Tween.EASE_IN)


## Bulle autour de la sorcière : dorée = invincible, bleue = bouclier prêt.
class ShieldBubble extends Node2D:
	const GOLD := Color("#FFE6A1")
	const BLUE := Color("#39C9F0")
	var player: Player
	var _time := 0.0

	func _process(delta: float) -> void:
		_time += delta

	func _draw() -> void:
		var color: Color
		if player.has_bubble():
			# Clignote quand l'effet va se terminer.
			if player.bubble_time_left() < 1.2 and int(_time * 10.0) % 2 == 0:
				return
			color = GOLD
		elif player.shield_ready():
			color = BLUE
		else:
			return
		var center := Vector2(0, -40)
		var radius := 54.0 + sin(_time * 4.0) * 2.0
		draw_circle(center, radius, Color(color, 0.18))
		draw_arc(center, radius, 0.0, TAU, 48, Color(color, 0.85), 3.0, true)
		draw_arc(center, radius - 10.0, deg_to_rad(200), deg_to_rad(250), 12, Color(1, 1, 1, 0.7), 4.0, true)
