class_name SpellBook
extends Node2D

signal changed

const MAX_SPELLS := 3
const MAX_AUGMENTS := 3
const HEAL_ID := "heal"
const HEAL_AMOUNT := 30

const SPELLS: Array[Dictionary] = [
	{"id": "fire_orbs", "title": "Orbes de feu", "color": Color("#FF9138"),
		"script": preload("res://scenes/spells/fire_orbs.gd"), "descriptions": [
			"2 boules de feu tournent autour de toi.", "+1 orbe de feu.", "Dégâts des orbes +50 %.",
			"+1 orbe, rotation plus rapide.", "+1 orbe, orbite plus large, dégâts +30 %."]},
	{"id": "chain_lightning", "title": "Éclair en chaîne", "color": Color("#39C9F0"),
		"script": preload("res://scenes/spells/chain_lightning.gd"), "descriptions": [
			"Foudroie un monstre proche puis rebondit sur un autre.", "+1 rebond.",
			"Dégâts de l'éclair +40 %.", "Plus fréquent, +1 rebond.", "Très fréquent, dégâts +40 %."]},
	{"id": "arcane_nova", "title": "Onde arcanique", "color": Color("#A45CDA"),
		"script": preload("res://scenes/spells/arcane_nova.gd"), "descriptions": [
			"Une onde magique blesse et repousse les monstres autour de toi.", "Zone de l'onde plus grande.",
			"Dégâts de l'onde +50 %.", "Onde plus fréquente.", "Zone énorme, dégâts +30 %."]},
	{"id": "meteor_shower", "title": "Météores", "color": Color("#F0703A"),
		"script": preload("res://scenes/spells/meteor_shower.gd"), "descriptions": [
			"Un météore s'écrase sur un monstre proche.", "+1 météore.", "Dégâts et zone +40 %.",
			"+1 météore.", "+1 météore, dégâts +40 %, plus fréquent."]},
	{"id": "broom_boomerang", "title": "Balais volants", "color": Color("#D9A55B"),
		"script": preload("res://scenes/spells/broom_boomerang.gd"), "descriptions": [
			"Lance un balai qui part et revient comme un boomerang.", "Dégâts des balais +40 %.",
			"+1 balai.", "Dégâts +30 %, plus fréquent.", "+1 balai, dégâts +20 %."]},
	{"id": "frost_nova", "title": "Nova de givre", "color": Color("#5FC8E8"),
		"script": preload("res://scenes/spells/frost_nova.gd"), "descriptions": [
			"Gèle les monstres autour de toi pendant 1,5 s.", "Zone plus grande, gel plus long.",
			"Zone plus grande, plus de dégâts.", "Plus fréquente.", "Zone énorme, gel de 2,6 s."]},
	{"id": "owl_familiar", "title": "Hibou familier", "color": Color("#879DA5"),
		"script": preload("res://scenes/spells/owl_familiar.gd"), "descriptions": [
			"Un hibou t'accompagne et tire des plumes magiques.", "Tire plus vite, plus de dégâts.",
			"Tire 2 plumes à la fois.", "Tire plus vite, plus de dégâts.", "Tire 3 plumes, très vite."]},
	{"id": "tornado", "title": "Tornade", "color": Color("#9DB8C4"),
		"script": preload("res://scenes/spells/tornado.gd"), "descriptions": [
			"Une tornade aspire et blesse les monstres.", "Dure plus longtemps.",
			"Dure plus longtemps, plus de dégâts.", "+1 tornade.", "Tornades plus fortes et durables."]},
	{"id": "poison_trail", "title": "Traînée toxique", "color": Color("#7BC043"),
		"script": preload("res://scenes/spells/poison_trail.gd"), "descriptions": [
			"Tu laisses des flaques de poison derrière toi.", "Flaques plus grandes et durables.",
			"Poison plus fort.", "Flaques plus grandes et durables.", "Poison très fort."]},
	{"id": "arcane_beam", "title": "Faisceau", "color": Color("#2FA7D6"),
		"script": preload("res://scenes/spells/arcane_beam.gd"), "descriptions": [
			"Un rayon magique tourne autour de toi.", "Rayon plus long, plus de dégâts.",
			"+1 rayon.", "Rayons plus longs.", "+1 rayon, dégâts +25 %."]},
	{"id": "bounce_bubbles", "title": "Bulles", "color": Color("#6CC3E0"),
		"script": preload("res://scenes/spells/bounce_bubbles.gd"), "descriptions": [
			"Des bulles rebondissent sur les murs et traversent les monstres.", "+1 bulle.",
			"Dégâts +40 %, plus fréquent.", "+1 bulle.", "+1 bulle, dégâts +25 %."]},
]

const AUGMENTS: Array[Dictionary] = [
	{"id": "multishot", "title": "Multi-tir", "color": Color("#39C9F0"), "descriptions": [
		"+1 projectile tiré en éventail.", "+1 projectile.", "+1 projectile.", "+1 projectile.", "+1 projectile."]},
	{"id": "crit", "title": "Critique", "color": Color("#F05B52"), "descriptions": [
		"+10 % de chance de coup critique (dégâts x2).", "+10 % de critique.", "+10 % de critique.",
		"+10 % de critique.", "+10 % de critique, critiques x2,5."]},
	{"id": "fire_rate", "title": "Cadence", "color": Color("#FF9138"), "descriptions": [
		"Tu tires 15 % plus vite.", "+15 % de cadence.", "+15 % de cadence.", "+15 % de cadence.", "+15 % de cadence."]},
	{"id": "power", "title": "Puissance", "color": Color("#A45CDA"), "descriptions": [
		"+15 % de dégâts sur tout.", "+15 % de dégâts.", "+15 % de dégâts.", "+15 % de dégâts.", "+15 % de dégâts."]},
	{"id": "pierce", "title": "Perforation", "color": Color("#70C95B"), "descriptions": [
		"Tes projectiles traversent 1 monstre.", "+1 monstre traversé.", "+1 monstre traversé.",
		"+1 monstre traversé.", "+1 monstre traversé."]},
	{"id": "ricochet", "title": "Ricochet", "color": Color("#2FA7D6"), "descriptions": [
		"Tes projectiles rebondissent vers 1 autre monstre.", "+1 rebond.", "+1 rebond.", "+1 rebond.", "+1 rebond."]},
	{"id": "back_shot", "title": "Tir arrière", "color": Color("#D9A55B"), "descriptions": [
		"Un projectile part aussi derrière toi.", "+1 projectile arrière.", "+1 projectile arrière.",
		"+1 projectile arrière.", "+1 projectile arrière."]},
	{"id": "speed", "title": "Vitesse", "color": Color("#9DB8C4"), "descriptions": [
		"Tu te déplaces 10 % plus vite.", "+10 % de vitesse.", "+10 % de vitesse.", "+10 % de vitesse.", "+10 % de vitesse."]},
	{"id": "vitality", "title": "Vitalité", "color": Color("#F05B52"), "descriptions": [
		"+20 PV max et soin de 20 PV.", "+20 PV max et soin.", "+20 PV max et soin.", "+20 PV max et soin.",
		"+20 PV max et soin."]},
	{"id": "regen", "title": "Régénération", "color": Color("#70C95B"), "descriptions": [
		"Tu récupères 0,6 PV par seconde.", "Régénération 1,2 PV/s.", "Régénération 1,8 PV/s.",
		"Régénération 2,4 PV/s.", "Régénération 3 PV/s."]},
	{"id": "vampirism", "title": "Vampirisme", "color": Color("#C2364A"), "descriptions": [
		"8 % de chance de te soigner de 3 PV à chaque kill.", "16 % de chance.", "24 % de chance.",
		"32 % de chance.", "40 % de chance."]},
	{"id": "focus", "title": "Concentration", "color": Color("#7E3FB0"), "descriptions": [
		"Tes sorts se rechargent 8 % plus vite.", "Recharge -16 %.", "Recharge -24 %.", "Recharge -32 %.",
		"Recharge -40 %."]},
	{"id": "shield", "title": "Bouclier", "color": Color("#39C9F0"), "descriptions": [
		"Une bulle bloque un coup toutes les 12 s.", "Recharge en 10 s.", "Recharge en 8,5 s.",
		"Recharge en 7 s.", "Recharge en 6 s."]},
	{"id": "magnet", "title": "Aimant", "color": Color("#F05B52"), "descriptions": [
		"Tu ramasses l'XP de 40 % plus loin.", "+40 % de portée.", "+40 % de portée.", "+40 % de portée.",
		"+40 % de portée."]},
]

const BACK_SHOTS: Array[int] = [1, 2, 3, 4, 5]
const SHIELD_INTERVAL: Array[float] = [12.0, 10.0, 8.5, 7.0, 6.0]

const HEAL_OFFER := {
	"id": HEAL_ID,
	"kind": "bonus",
	"title": "Potion",
	"color": Color("#F05B52"),
	"level": 0,
	"max_level": 0,
	"description": "Récupère 30 PV.",
}

var player: Player

var _spells := {}
var _augments := {}


func level_of(id: String) -> int:
	if _spells.has(id):
		return _spells[id].level
	return _augments.get(id, 0)


func get_offers(count: int) -> Array[Dictionary]:
	var spell_offers := _eligible(SPELLS, "spell", _spells.size() < MAX_SPELLS)
	var augment_offers := _eligible(AUGMENTS, "augment", _augments.size() < MAX_AUGMENTS)
	spell_offers.shuffle()
	augment_offers.shuffle()

	var offers: Array[Dictionary] = []
	if not spell_offers.is_empty():
		offers.append(spell_offers.pop_back())
	if not augment_offers.is_empty():
		offers.append(augment_offers.pop_back())
	var rest: Array[Dictionary] = []
	rest.append_array(spell_offers)
	rest.append_array(augment_offers)
	rest.shuffle()
	while offers.size() < count and not rest.is_empty():
		offers.append(rest.pop_back())
	while offers.size() < count:
		offers.append(HEAL_OFFER.duplicate())
	offers.shuffle()
	return offers


func learn(id: String) -> void:
	if id == HEAL_ID:
		player.heal(HEAL_AMOUNT)
	elif not _find(SPELLS, id).is_empty():
		if not _spells.has(id):
			var spell: Spell = _find(SPELLS, id).script.new()
			spell.player = player
			_spells[id] = spell
			add_child(spell)
		var known: Spell = _spells[id]
		known.set_level(known.level + 1)
	elif not _find(AUGMENTS, id).is_empty():
		var level: int = _augments.get(id, 0) + 1
		_augments[id] = level
		_apply_augment(id, level)
	changed.emit()


func snapshot() -> Dictionary:
	var spells: Array[Dictionary] = []
	for id in _spells:
		spells.append({"id": id, "level": _spells[id].level, "color": _find(SPELLS, id).color})
	var augments: Array[Dictionary] = []
	for id in _augments:
		augments.append({"id": id, "level": _augments[id], "color": _find(AUGMENTS, id).color})
	return {"spells": spells, "augments": augments}


func _eligible(catalog: Array[Dictionary], kind: String, can_add_new: bool) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry in catalog:
		var current := level_of(entry.id)
		var descriptions: Array = entry.descriptions
		if current >= descriptions.size() or (current == 0 and not can_add_new):
			continue
		result.append({
			"id": entry.id,
			"kind": kind,
			"title": entry.title,
			"color": entry.color,
			"level": current,
			"max_level": descriptions.size(),
			"description": descriptions[current],
		})
	return result


func _apply_augment(id: String, level: int) -> void:
	var stats := player.stats
	match id:
		"multishot":
			stats.projectile_count = 1 + level
		"crit":
			stats.crit_chance = 0.05 + 0.1 * level
			stats.crit_multiplier = 2.5 if level >= 5 else 2.0
		"fire_rate":
			stats.fire_rate_mult = 1.0 + 0.15 * level
		"power":
			stats.damage_mult = 1.0 + 0.15 * level
		"pierce":
			stats.pierce = level
		"ricochet":
			stats.ricochet = level
		"back_shot":
			stats.back_shots = BACK_SHOTS[level - 1]
		"speed":
			stats.move_speed_mult = 1.0 + 0.1 * level
		"vitality":
			player.add_max_health(20)
		"regen":
			stats.regen_per_second = 0.6 * level
		"vampirism":
			stats.lifesteal_chance = 0.08 * level
		"focus":
			stats.cooldown_mult = 1.0 - 0.08 * level
		"shield":
			stats.shield_interval = SHIELD_INTERVAL[level - 1]
		"magnet":
			stats.pickup_radius_mult = 1.0 + 0.4 * level


static func _find(catalog: Array[Dictionary], id: String) -> Dictionary:
	for entry in catalog:
		if entry.id == id:
			return entry
	return {}
