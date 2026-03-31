extends Node2D

@onready var sprite = $Sprite2D

func _ready():
	sprite.modulate.a = 0.0

func activate():
	if sprite.modulate.a > 0.9:
		return
	sprite.modulate.a = 1.0
	if get_parent() and get_parent().has_method("refresh_layout"):
		get_parent().refresh_layout()
	if name.begins_with("Opponent"):
		return
	var multiplayer_node = get_tree().current_scene
	if multiplayer_node and multiplayer_node.has_method("rpc"):
		multiplayer_node.rpc("sync_element", name, 1.0)
