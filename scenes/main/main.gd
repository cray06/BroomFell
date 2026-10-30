extends Node2D

const MENU_SCENE := "res://scenes/menu/main_menu.tscn"
const HORDE_COLOR := Color("#FF9138")
const BOSS_COLOR := Color("#F05B52")
const VICTORY_COLOR := Color("#FFE6A1")
const ICE := Color("#9FE8FF")

const DROP_CHANCE := 0.05
const DROP_WEIGHTS := {
	"heart": 25,
	"magnet": 20,
	"hourglass": 15,
	"rage": 15,
	"bubble": 13,
	"bomb": 12,
}
const BOMB_RANGE := 1000.0
const BOMB_BOSS_DAMAGE := 150
const FREEZE_TIME := 5.0
const RAGE_TIME := 8.0
const BUBBLE_TIME := 5.0
const HEART_HEAL := 30

var _score := 0
var _level := 1
var _xp := 0
var _free_levels := 0
var _leveling := false
var _game_over := false

@onready var arena: Arena = $Arena
@onready var ground_fx: Node2D = $GroundFx
@onready var entities: Node2D = $Entities
@onready var player: Player = $Entities/Player
@onready var camera: ShakeCamera = $Entities/Player/Camera2D
@onready var director: WaveDirector = $WaveDirector
@onready var hud: Hud = $HUD


func _ready() -> void:
	ground_fx.add_to_group("ground_fx")
	arena.generate(entities)
	player.global_position = arena.bounds.get_center()
	player.joystick = hud.joystick
	player.hurt.connect(_on_player_hurt)
	player.died.connect(_on_player_died)
	player.spell_book.changed.connect(_refresh_loadout)
	hud.game_over.restart_requested.connect(_restart)
	hud.game_over.menu_requested.connect(_go_to_menu)

	var limits := arena.bounds.grow(arena.wall_thickness)
	camera.limit_left = int(limits.position.x)
	camera.limit_top = int(limits.position.y)
	camera.limit_right = int(limits.end.x)
	camera.limit_bottom = int(limits.end.y)
	camera.reset_smoothing()

	director.enemy_killed.connect(_on_enemy_killed)
	director.horde_incoming.connect(_on_horde_incoming)
	director.boss_incoming.connect(_on_boss_incoming)
	director.boss_spawned.connect(_on_boss_spawned)
	director.boss_defeated.connect(_on_boss_defeated)
	director.setup(arena, entities, ground_fx, player)

	hud.set_score(_score)
	hud.xp_bar.set_level(_level)
	_refresh_xp()
	_refresh_loadout()


func _required_xp() -> int:
	return 5 + (_level - 1) * 4


func _drop_xp(at: Vector2, count: int) -> void:
	var max_speed := 260.0 if count <= 5 else 520.0
	for k in count:
		var orb := XpOrb.new()
		orb.target = player
		orb.position = at
		orb.launch(Vector2.from_angle(randf() * TAU) * randf_range(140.0, max_speed))
		orb.collected.connect(_on_xp_collected)
		entities.add_child.call_deferred(orb)


func _drop_item(kind: String, at: Vector2) -> void:
	var pickup := Pickup.spawn(entities, kind, at, player)
	pickup.collected.connect(_on_pickup_collected)


func _random_drop() -> String:
	var total := 0
	for weight in DROP_WEIGHTS.values():
		total += weight
	var roll := randi() % total
	for kind in DROP_WEIGHTS:
		roll -= DROP_WEIGHTS[kind]
		if roll < 0:
			return kind
	return "heart"


func _refresh_xp() -> void:
	hud.xp_bar.set_ratio(float(_xp) / _required_xp())


func _refresh_loadout() -> void:
	hud.loadout.refresh(player.spell_book.snapshot())


func _try_level_up() -> void:
	var free := _free_levels > 0
	if _leveling or _game_over or (_xp < _required_xp() and not free):
		return
	_leveling = true
	hud.xp_bar.set_rainbow(true)
	get_tree().paused = true
	await get_tree().create_timer(0.8).timeout

	hud.level_up.open(player.spell_book.get_offers(3))
	var id: String = await hud.level_up.chosen
	player.spell_book.learn(id)

	if free:
		_free_levels -= 1
	else:
		_xp -= _required_xp()
	_level += 1
	hud.xp_bar.set_rainbow(false)
	hud.xp_bar.set_level(_level)
	_refresh_xp()
	get_tree().paused = false
	_leveling = false
	director.on_level_up(_level)
	_try_level_up()


func _on_enemy_killed(enemy: Node2D) -> void:
	_score += enemy.score_value
	hud.set_score(_score)
	player.on_kill()
	var at := enemy.global_position + Vector2(0, -10)
	_drop_xp(at, enemy.xp_drop)
	if enemy is KingSlime:
		_drop_item.call_deferred("chest", at)
		_drop_item.call_deferred("heart", at)
		_drop_item.call_deferred("magnet", at)
	else:
		camera.shake(10.0)
		if randf() < DROP_CHANCE:
			_drop_item.call_deferred(_random_drop(), at)
	director.on_score_changed(_score)


func _on_xp_collected(value: int) -> void:
	if _game_over:
		return
	_xp += value
	_refresh_xp()
	_try_level_up()


func _on_pickup_collected(kind: String) -> void:
	if _game_over:
		return
	var text_at := player.global_position + Vector2(0, -140)
	match kind:
		"heart":
			player.heal(HEART_HEAL)
		"magnet":
			for orb in get_tree().get_nodes_in_group("xp_orbs"):
				orb.attract()
			Fx.popup_text(entities, text_at, "Aimant !", Pickup.COLORS.magnet)
		"bomb":
			_explode_bomb()
			Fx.popup_text(entities, text_at, "BOUM !", Pickup.COLORS.bomb, 44)
		"hourglass":
			for enemy in get_tree().get_nodes_in_group("enemies"):
				if not enemy.is_dead:
					enemy.freeze(FREEZE_TIME)
			hud.flash(ICE, 0.5)
			Fx.popup_text(entities, text_at, "Temps figé !", ICE)
		"rage":
			player.activate_rage(RAGE_TIME)
			Fx.popup_text(entities, text_at, "Rage !", Pickup.COLORS.bomb)
		"bubble":
			player.activate_bubble(BUBBLE_TIME)
			Fx.popup_text(entities, text_at, "Invincible !", Pickup.COLORS.bubble)
		"chest":
			_free_levels += 1
			Fx.popup_text(entities, text_at, "Coffre !", VICTORY_COLOR, 44)
			_try_level_up()


func _explode_bomb() -> void:
	hud.flash(Color.WHITE, 0.5)
	camera.shake(24.0)
	NovaFx.spawn(entities, player.global_position, 600.0, Pickup.COLORS.bomb)
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.is_dead or enemy.global_position.distance_to(player.global_position) > BOMB_RANGE:
			continue
		var damage := BOMB_BOSS_DAMAGE if enemy is KingSlime else 9999
		enemy.take_hit(damage, player.global_position.direction_to(enemy.global_position))
		Fx.burst(entities, enemy.global_position + Vector2(0, -24), Pickup.COLORS.bomb, 8, 220.0, 0.4)


func _on_horde_incoming() -> void:
	hud.banner.show_banner("UNE HORDE ARRIVE !", HORDE_COLOR)
	camera.shake(8.0)


func _on_boss_incoming() -> void:
	hud.banner.show_banner("LE ROI GLUANT APPROCHE !", BOSS_COLOR)
	camera.shake(12.0)


func _on_boss_spawned(boss: KingSlime) -> void:
	hud.boss_bar.open("Roi Gluant", boss.health)


func _on_boss_defeated() -> void:
	hud.banner.show_banner("VICTOIRE !", VICTORY_COLOR)
	hud.boss_bar.close()


func _on_player_hurt() -> void:
	camera.shake(14.0)


func _on_player_died() -> void:
	_game_over = true
	director.stop()
	camera.shake(18.0)
	var previous_best := SaveData.best_score()
	var record := SaveData.submit_score(_score)
	await get_tree().create_timer(1.2).timeout
	get_tree().paused = true
	hud.game_over.open(_score, _level, record, previous_best)


func _restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _go_to_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU_SCENE)
