class_name HealthComponent
extends Node
## Points de vie réutilisables. Émet des signaux, ne connaît pas son parent.

signal health_changed(current: int, maximum: int)
signal died

@export var max_health: int = 30

var current_health: int

var is_dead: bool:
	get:
		return current_health <= 0


func _ready() -> void:
	current_health = max_health


func take_damage(amount: int) -> void:
	if is_dead:
		return
	current_health = maxi(0, current_health - amount)
	health_changed.emit(current_health, max_health)
	if is_dead:
		died.emit()


func heal(amount: int) -> void:
	if is_dead:
		return
	current_health = mini(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)
