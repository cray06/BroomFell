class_name SaveData
extends RefCounted
## Sauvegarde locale du meilleur score.

const PATH := "user://save.cfg"


static func best_score() -> int:
	var config := ConfigFile.new()
	if config.load(PATH) != OK:
		return 0
	return int(config.get_value("scores", "best", 0))


## Enregistre le score s'il bat le record. Renvoie vrai si c'est un nouveau record.
static func submit_score(score: int) -> bool:
	if score <= best_score():
		return false
	var config := ConfigFile.new()
	config.load(PATH)
	config.set_value("scores", "best", score)
	config.save(PATH)
	return true
