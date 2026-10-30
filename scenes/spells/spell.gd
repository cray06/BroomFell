class_name Spell
extends Node2D

var level := 0
var player: Player


func set_level(new_level: int) -> void:
	level = new_level
	_apply_level()


func _apply_level() -> void:
	pass


func _tier() -> int:
	return level - 1


func _alive_enemies() -> Array[Node2D]:
	var enemies: Array[Node2D] = []
	for node in get_tree().get_nodes_in_group("enemies"):
		if not node.is_dead:
			enemies.append(node)
	return enemies


func _nearest_enemy(enemies: Array[Node2D], from: Vector2, max_distance: float) -> Node2D:
	var best: Node2D = null
	var best_distance := max_distance
	for enemy in enemies:
		var distance := from.distance_to(center_of(enemy))
		if distance < best_distance:
			best = enemy
			best_distance = distance
	return best


func _hit(enemy: Node2D, base_damage: int, direction: Vector2) -> void:
	var roll := player.roll_damage(base_damage)
	enemy.take_hit(roll.amount, direction, roll.crit)


func _cooldown(base: float) -> float:
	return base * player.stats.cooldown_mult


func _ground() -> Node:
	var ground := get_tree().get_first_node_in_group("ground_fx")
	return ground if ground else _world()


func _arena_bounds() -> Rect2:
	var arena := get_tree().get_first_node_in_group("arena")
	return arena.bounds if arena else Rect2(-5000, -5000, 10000, 10000)


static func center_of(enemy: Node2D) -> Vector2:
	return enemy.global_position + enemy.center_offset


func _world() -> Node:
	return player.get_parent()
