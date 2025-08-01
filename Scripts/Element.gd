extends Node2D

@onready var sprite = $Sprite2D
@onready var area = $Area2D
func _ready():
	area.connect("input_event", _on_area_input_event)
func _on_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if sprite.modulate.a > 0.75:
			sprite.modulate.a = 0.5
		else:
			sprite.modulate.a = 1.0
