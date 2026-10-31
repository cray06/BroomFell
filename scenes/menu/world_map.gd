class_name WorldMap
extends RefCounted

const STAGES_PER_ISLAND := 3
const STAGE_DIFFICULTY: Array[float] = [1.0, 1.35, 1.75]
const STAGE_NAMES: Array[String] = ["Facile", "Normal", "Difficile"]
const ISLANDS: Array[Dictionary] = [
	{
		"name": "Prairie Gluante",
		"ground": Color("#70C95B"),
		"ground_dark": Color("#387E55"),
		"playable": true,
	},
	{
		"name": "Dunes Ensorcelées",
		"ground": Color("#E6C58D"),
		"ground_dark": Color("#B08A55"),
		"playable": false,
	},
	{
		"name": "Pics Givrés",
		"ground": Color("#CFEFFF"),
		"ground_dark": Color("#879DA5"),
		"playable": false,
	},
]


static func island_count() -> int:
	return ISLANDS.size()


static func island(index: int) -> Dictionary:
	return ISLANDS[index]


static func is_playable(index: int) -> bool:
	return index >= 0 and index < ISLANDS.size() and ISLANDS[index].playable


static func stage_label(stage: Vector2i) -> String:
	return "%d-%d" % [stage.x + 1, stage.y + 1]


static func difficulty(stage: Vector2i) -> float:
	return STAGE_DIFFICULTY[clampi(stage.y, 0, STAGE_DIFFICULTY.size() - 1)]


static func stage_name(stage: Vector2i) -> String:
	return STAGE_NAMES[clampi(stage.y, 0, STAGE_NAMES.size() - 1)]
