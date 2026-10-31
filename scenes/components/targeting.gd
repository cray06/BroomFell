class_name Targeting
extends RefCounted


static func nearest_enemy(tree: SceneTree, from: Vector2, max_distance: float,
		ignored: Dictionary = {}, area: Rect2 = Rect2()) -> Node2D:
	var best: Node2D = null
	var best_distance := max_distance * max_distance
	var limited := area.has_area()
	for enemy: Node2D in tree.get_nodes_in_group("enemies"):
		if enemy.is_dead or ignored.has(enemy.get_instance_id()):
			continue
		var center := Spell.center_of(enemy)
		if limited and not area.has_point(center):
			continue
		var distance := from.distance_squared_to(center)
		if distance < best_distance:
			best = enemy
			best_distance = distance
	return best


static func is_targetable(enemy: Node2D, area: Rect2 = Rect2()) -> bool:
	if not is_instance_valid(enemy) or enemy.is_dead:
		return false
	return not area.has_area() or area.has_point(Spell.center_of(enemy))


static func visible_area(viewport: Viewport, margin: float) -> Rect2:
	var screen := viewport.get_canvas_transform().affine_inverse() * viewport.get_visible_rect()
	return screen.grow(-margin)
