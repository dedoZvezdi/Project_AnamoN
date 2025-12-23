extends Node2D

signal hovered
signal hovered_off

var hand_position
var mouse_inside = false
var card_information_reference = null
var runtime_modifiers = {"level": 0, "power": 0, "life": 0, "durability": 0}
var attached_markers := {}
var attached_counters := {}
var uuid = ""
var is_revealed_by_opponent = false

func _ready() -> void:
	if get_parent() and get_parent().has_method("connect_card_signals"):
		get_parent().connect_card_signals(self)
	find_card_information_reference()
	if has_node("Area2D"):
		var area = get_node("Area2D")
		if not area.mouse_entered.is_connected(_on_area_2d_mouse_entered):
			area.mouse_entered.connect(_on_area_2d_mouse_entered)
		if not area.mouse_exited.is_connected(_on_area_2d_mouse_exited):
			area.mouse_exited.connect(_on_area_2d_mouse_exited)

func find_card_information_reference():
	var root = get_tree().current_scene
	if root:
		card_information_reference = find_node_by_script(root, "res://Scripts/CardInformation.gd")

func find_node_by_script(node: Node, script_path: String) -> Node:
	if node.get_script() and node.get_script().resource_path == script_path:
		return node
	for child in node.get_children():
		var result = find_node_by_script(child, script_path)
		if result:
			return result
	return null

func _on_area_2d_mouse_entered() -> void:
	mouse_inside = true
	if not _is_card_in_restricted_zones():
		emit_signal("hovered", self)
		if card_information_reference:
			card_information_reference.show_card_preview(self)

func _on_area_2d_mouse_exited() -> void:
	mouse_inside = false
	emit_signal("hovered_off", self)

func _is_card_in_restricted_zones() -> bool:
	var opponent_hand_nodes = get_tree().get_nodes_in_group("opponent_hand")
	for hand_node in opponent_hand_nodes:
		if hand_node.has_method("has_cards"):
			if self in hand_node.opponent_hand:
				return true
	
	var opponent_memory_nodes = get_tree().get_nodes_in_group("memory_slots")
	for memory_node in opponent_memory_nodes:
		if memory_node.name.contains("Opponent"):
			if self in memory_node.cards_in_slot:
				if is_revealed_by_opponent:
					return false
				return true
	return false

func is_in_main_field() -> bool:
	return not _is_card_in_restricted_zones()

func get_runtime_modifiers() -> Dictionary:
	return runtime_modifiers.duplicate()

func get_attached_markers() -> Dictionary:
	return attached_markers.duplicate()

func get_attached_counters() -> Dictionary:
	return attached_counters.duplicate()

func get_slug_from_card() -> String:
	if has_meta("slug"):
		return get_meta("slug")
	return ""

func get_uuid() -> String:
	return uuid

func set_opponent_reveal_status(revealed: bool):
	is_revealed_by_opponent = revealed
	var anim_player = get_node_or_null("AnimationPlayer")
	if anim_player and anim_player.has_animation("card_flip"):
		anim_player.play("card_flip")
		var length = anim_player.get_animation("card_flip").length
		await get_tree().create_timer(length / 2.0).timeout
		_update_card_visuals(revealed)
	else:
		_update_card_visuals(revealed)

func _update_card_visuals(revealed: bool):
	var front = get_node_or_null("CardImage")
	var back = get_node_or_null("CardImageBack")
	
	if revealed:
		if front: front.visible = true
		if back: back.visible = false
	else:
		if front: front.visible = false
		if back: back.visible = true
