extends Node2D

@onready var sprite = $Sprite2D
var activation_count: int = 0

func _ready():
	sprite.modulate.a = 0.0

func activate():
	activation_count += 1
	if activation_count > 1:
		return
	sprite.modulate.a = 1.0
	if get_parent() and get_parent().has_method("refresh_layout"):
		get_parent().refresh_layout()
	if name.begins_with("Opponent"):
		return
	var multiplayer_node = get_tree().current_scene
	if multiplayer_node and multiplayer_node.has_method("rpc"):
		multiplayer_node.rpc("sync_element", name, 1.0)

func deactivate():
	activation_count -= 1
	if activation_count > 0:
		return
	if activation_count < 0:
		activation_count = 0
	sprite.modulate.a = 0.0
	if get_parent() and get_parent().has_method("refresh_layout"):
		get_parent().refresh_layout()
	if name.begins_with("Opponent"):
		return
	var multiplayer_node = get_tree().current_scene
	if multiplayer_node and multiplayer_node.has_method("rpc"):
		multiplayer_node.rpc("sync_element", name, 0.0)
