extends Node2D

var hand_position
var mouse_inside = false

func _ready() -> void:
	if get_parent() and get_parent().has_method("connect_card_signals"):
		get_parent().connect_card_signals(self)

func _on_area_2d_mouse_entered() -> void:
	mouse_inside = true
	emit_signal("hovered", self)

func _on_area_2d_mouse_exited() -> void:
	mouse_inside = false
	emit_signal("hovered_off", self)
