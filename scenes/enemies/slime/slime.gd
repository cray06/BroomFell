class_name Slime
extends CharacterBody2D
## Slime qui avance par petits sauts, vers la sorcière quand elle est proche.

signal died(enemy: Node2D)

const GOO := Color("#70C95B")
const SPARK := Color("#FFE6A1")
const HORDE_GOO := Color("#C9705B")
const FROZEN_TINT := Color(0.6, 0.85, 1.4)

@export var hop_speed := 230.0
@export var hop_interval := 1.1
@export var friction := 500.0
@export var detection_range := 420.0
@export var knockback := 320.0
@export var contact_damage := 10
@export var score_value := 10
@export var xp_drop := 3

## Rayon et centre du corps, utilisés par les sorts pour viser et toucher.
var hit_radius := 24.0
var center_offset := Vector2(0, -24)
## Fourni par la scène principale.
var target: Node2D
## Slime de horde : teinté de rouge, chasse la sorcière partout.
var horde := false
var is_dead := false

var _hop_timer := 0.0
var _frozen := 0.0
var _visual_tween: Tween

@onready var visual: Node2D = $Visual
@onready var sprite: Sprite2D = $Visual/Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var health: HealthComponent = $HealthComponent
@onready var health_bar: HealthBar = $HealthBar


func _ready() -> void:
	health.health_changed.connect(_on_health_changed)
	health.died.connect(_on_died)
	_hop_timer = randf_range(0.3, hop_interval)
	if horde:
		sprite.material.set_shader_parameter("swap_red_green", 1.0)
	_play_spawn_animation()


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	if _frozen > 0.0:
		_frozen -= delta
		if _frozen <= 0.0:
			sprite.self_modulate = Color.WHITE
		move_and_slide()
		return
	_hop_timer -= delta
	if _hop_timer <= 0.0:
		_hop_timer = hop_interval * randf_range(0.8, 1.2)
		_hop()
	move_and_slide()


func deals_contact_damage() -> bool:
	return not is_dead and _frozen <= 0.0


## Gèle le slime : il ne bouge plus et ne blesse plus.
func freeze(duration: float) -> void:
	if is_dead:
		return
	_frozen = maxf(_frozen, duration)
	velocity = Vector2.ZERO
	sprite.self_modulate = FROZEN_TINT


## Pousse le slime (tornade, explosions).
func push(force: Vector2) -> void:
	if not is_dead:
		velocity += force


## Appelé par les projectiles et les sorts.
func take_hit(damage: int, from_direction: Vector2, crit: bool = false) -> void:
	if is_dead:
		return
	if _frozen <= 0.0:
		velocity = from_direction.normalized() * knockback
	_flash()
	_squash(Vector2(1.3, 0.7), 0.3)
	Fx.damage_number(get_parent(), global_position + Vector2(randf_range(-14, 14), -80), damage,
			Fx.LIGHT, crit)
	Fx.burst(get_parent(), global_position + Vector2(0, -28), _goo_color(), 6, 160.0, 0.35)
	health.take_damage(damage)


func _hop() -> void:
	var direction := Vector2.from_angle(randf() * TAU)
	if is_instance_valid(target) \
			and global_position.distance_to(target.global_position) < detection_range:
		direction = global_position.direction_to(target.global_position)
	velocity = direction * hop_speed

	_kill_visual_tween()
	_visual_tween = create_tween()
	_visual_tween.tween_property(visual, "scale", Vector2(1.25, 0.75), 0.08)
	_visual_tween.tween_property(visual, "scale", Vector2(0.85, 1.2), 0.12)
	_visual_tween.tween_property(visual, "scale", Vector2.ONE, 0.25) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


func _flash() -> void:
	sprite.material.set_shader_parameter("flash_amount", 1.0)
	create_tween().tween_property(sprite, "material:shader_parameter/flash_amount", 0.0, 0.15)


func _squash(amount: Vector2, duration: float) -> void:
	_kill_visual_tween()
	visual.scale = amount
	_visual_tween = create_tween()
	_visual_tween.tween_property(visual, "scale", Vector2.ONE, duration) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


func _kill_visual_tween() -> void:
	if _visual_tween:
		_visual_tween.kill()


func _play_spawn_animation() -> void:
	visual.scale = Vector2.ZERO
	_visual_tween = create_tween()
	_visual_tween.tween_property(visual, "scale", Vector2.ONE, 0.35) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_health_changed(current: int, maximum: int) -> void:
	health_bar.set_ratio(float(current) / maximum)


func _on_died() -> void:
	is_dead = true
	collision.set_deferred("disabled", true)
	died.emit(self)

	_kill_visual_tween()
	sprite.material.set_shader_parameter("flash_amount", 1.0)
	var tween := create_tween()
	tween.tween_property(health_bar, "modulate:a", 0.0, 0.1)
	tween.parallel().tween_property(visual, "scale", Vector2(1.4, 0.5), 0.1)
	tween.tween_property(visual, "scale", Vector2(0.7, 1.5), 0.1)
	tween.tween_callback(_explode)
	tween.tween_property(visual, "scale", Vector2.ZERO, 0.08)
	tween.tween_callback(queue_free)


func _explode() -> void:
	var center := global_position + Vector2(0, -28)
	Fx.burst(get_parent(), center, _goo_color(), 24, 340.0, 0.6)
	Fx.burst(get_parent(), center, SPARK, 10, 260.0, 0.35)


func _goo_color() -> Color:
	return HORDE_GOO if horde else GOO
