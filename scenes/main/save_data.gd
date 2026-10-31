class_name SaveData
extends RefCounted

const PATH := "user://save.cfg"

static var _config: ConfigFile


static func best_score() -> int:
	return int(_read("scores", "best", 0))


static func submit_score(score: int) -> bool:
	if score <= best_score():
		return false
	_write("scores", "best", score)
	return true


static func gold() -> int:
	return int(_read("wallet", "gold", 0))


static func add_gold(amount: int) -> void:
	_write("wallet", "gold", gold() + amount)


static func selected_stage() -> Vector2i:
	return Vector2i(int(_read("progress", "island", 0)), int(_read("progress", "stage", 0)))


static func select_stage(stage: Vector2i) -> void:
	_write("progress", "island", stage.x)
	_write("progress", "stage", stage.y)


static func cleared_stages(island: int) -> int:
	return int(_read("progress", "cleared_%d" % island, 0))


static func is_stage_unlocked(stage: Vector2i) -> bool:
	return WorldMap.is_playable(stage.x) and stage.y <= cleared_stages(stage.x)


static func clear_stage(stage: Vector2i) -> void:
	if stage.y >= cleared_stages(stage.x):
		_write("progress", "cleared_%d" % stage.x, stage.y + 1)


static func _read(section: String, key: String, default: Variant) -> Variant:
	return _load().get_value(section, key, default)


static func _write(section: String, key: String, value: Variant) -> void:
	_load().set_value(section, key, value)
	_config.save(PATH)


static func _load() -> ConfigFile:
	if _config == null:
		_config = ConfigFile.new()
		_config.load(PATH)
	return _config
