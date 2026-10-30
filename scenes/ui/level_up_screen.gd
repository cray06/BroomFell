class_name LevelUpScreen
extends Control
## Écran de montée de niveau : 3 cartes de sorts à choisir.

signal chosen(id: String)

const OUTLINE := Color("#253047")
const GOLD := Color("#FFE6A1")
const CARD_GAP := 16.0
const RAY_COUNT := 18

var _cards: Array[SpellCard] = []
var _locked := false
var _rays_angle := 0.0
var _dim := 0.0
var _title: Label
var _subtitle: Label


func _ready() -> void:
	hide()
	mouse_filter = MOUSE_FILTER_STOP
	_title = _make_label("NIVEAU SUPÉRIEUR !", 52, GOLD, 16)
	_subtitle = _make_label("Choisis un sort", 28, Color.WHITE, 10)


func open(offers: Array[Dictionary]) -> void:
	for card in _cards:
		card.queue_free()
	_cards.clear()
	_locked = false
	show()

	var card_size := SpellCard.CARD_SIZE
	var total_width := offers.size() * card_size.x + (offers.size() - 1) * CARD_GAP
	var start_x := (size.x - total_width) / 2.0
	var card_y := size.y / 2.0 - card_size.y / 2.0 + 50.0

	_layout_label(_title, card_y - 160.0)
	_layout_label(_subtitle, card_y - 90.0)

	var tween := create_tween()
	tween.tween_property(self, "_dim", 0.78, 0.25)
	_pop_in(_title, 0.0)
	_pop_in(_subtitle, 0.15)

	for k in offers.size():
		var card := SpellCard.new()
		card.setup(offers[k], k)
		add_child(card)
		card.animate_in(Vector2(start_x + k * (card_size.x + CARD_GAP), card_y), 0.15 + k * 0.09)
		card.picked.connect(_on_card_picked)
		_cards.append(card)


func _process(delta: float) -> void:
	if not visible:
		return
	_rays_angle += delta * 0.3
	_title.rotation = sin(_rays_angle * 6.0) * 0.03
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(OUTLINE, _dim))
	var center := Vector2(size.x / 2.0, size.y / 2.0)
	var ray_alpha := 0.08 * _dim / 0.78
	for k in RAY_COUNT:
		var a0 := _rays_angle + TAU * k / RAY_COUNT
		var a1 := a0 + TAU / (RAY_COUNT * 2.0)
		draw_colored_polygon(PackedVector2Array([center, center + Vector2.from_angle(a0) * 1600.0,
				center + Vector2.from_angle(a1) * 1600.0]), Color(GOLD, ray_alpha))


func _on_card_picked(card: SpellCard) -> void:
	if _locked:
		return
	_locked = true
	for other in _cards:
		if other == card:
			other.animate_chosen()
		else:
			other.animate_discard()
	var tween := create_tween()
	tween.tween_interval(0.3)
	tween.tween_property(self, "_dim", 0.0, 0.25)
	tween.parallel().tween_property(_title, "modulate:a", 0.0, 0.2)
	tween.parallel().tween_property(_subtitle, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func() -> void:
		hide()
		chosen.emit(card.offer.id))


func _make_label(text: String, font_size: int, color: Color, outline: int) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var settings := LabelSettings.new()
	settings.font_size = font_size
	settings.font_color = color
	settings.outline_size = outline
	settings.outline_color = OUTLINE
	settings.shadow_size = 0
	settings.shadow_color = Color(OUTLINE, 0.6)
	settings.shadow_offset = Vector2(0, 5)
	label.label_settings = settings
	add_child(label)
	return label


func _layout_label(label: Label, y: float) -> void:
	label.size = Vector2(size.x, 70)
	label.position = Vector2(0, y)
	label.pivot_offset = label.size / 2.0


func _pop_in(label: Label, delay: float) -> void:
	label.modulate.a = 1.0
	label.scale = Vector2.ZERO
	create_tween().tween_property(label, "scale", Vector2.ONE, 0.45).set_delay(delay) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
