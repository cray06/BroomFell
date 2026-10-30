class_name ShakeCamera
extends Camera2D

@export var shake_decay := 60.0

var _strength := 0.0


func _ready() -> void:
	add_to_group("camera")


func shake(strength: float) -> void:
	_strength = maxf(_strength, strength)


func _process(delta: float) -> void:
	if _strength <= 0.0:
		offset = Vector2.ZERO
		return
	offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * _strength
	_strength = move_toward(_strength, 0.0, shake_decay * delta)
