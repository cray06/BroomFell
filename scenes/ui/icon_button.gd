class_name IconButton
extends Button

var icon_id := ""
var icon_ratio := 0.6


func _init(id: String = "", color: Color = Color("#A45CDA"), min_size: Vector2 = Vector2(84, 84)) -> void:
	icon_id = id
	custom_minimum_size = min_size
	UiStyle.style_button(self, color)
	pivot_offset = min_size / 2.0
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)


func _draw() -> void:
	var lift := Vector2(0, 2) if button_pressed else Vector2.ZERO
	MenuIcons.draw(self, icon_id, size / 2.0 + lift, minf(size.x, size.y) * icon_ratio)


func _on_button_down() -> void:
	pivot_offset = size / 2.0
	create_tween().tween_property(self, "scale", Vector2(0.9, 0.9), 0.06)


func _on_button_up() -> void:
	create_tween().tween_property(self, "scale", Vector2.ONE, 0.18) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
