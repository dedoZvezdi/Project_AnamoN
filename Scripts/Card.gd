extends Node2D

signal hovered
signal hovered_off

@onready var popup_menu: PopupMenu = $PopupMenu
@onready var area: Area2D = $Area2D
@onready var card_level_lable = $Level
@onready var card_PLDS_lable = $PowerLifeDurSpeed

var current_field = null
var original_rotation = 0.0
var is_rotated = false
var hand_position
var mouse_inside = false
var was_rotated_before_drag = false
var card_information_reference = null

func _ready() -> void:
	if get_parent() and get_parent().has_method("connect_card_signals"):
		get_parent().connect_card_signals(self)
	popup_menu.id_pressed.connect(_on_PopupMenu_id_pressed)
	area.input_event.connect(_on_area_2d_input_event)
	find_card_information_reference()
	if card_level_lable:
		card_level_lable.clear()

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

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if mouse_inside:
			var logo_nodes = get_tree().get_nodes_in_group("logo")
			if logo_nodes.size() > 0:
				var logo_node = logo_nodes[0]
				if logo_node.has_method("has_active_status") and logo_node.has_active_status():
					logo_node.reset_all_status_values()
					return
			popup_menu.clear()
			popup_menu.add_item("Go to Graveyard", 0)
			popup_menu.add_item("Go to Banish FU", 1)
			popup_menu.add_item("Go to Banish FD", 2)
			popup_menu.add_item("Go to TD", 3)
			popup_menu.add_item("Go to BD", 4)
			if is_in_main_field():
				if is_rotated:
					popup_menu.add_item("Awake", 5)
				else:
					popup_menu.add_item("Rest", 5)
			popup_menu.add_item("Show", 6)
			popup_menu.add_item("Transform", 7)
			popup_menu.add_item("Give to your opponent", 8)
			popup_menu.reset_size()
			popup_menu.position = get_global_mouse_position()
			popup_menu.popup()

func _on_area_2d_mouse_entered() -> void:
	mouse_inside = true
	emit_signal("hovered", self)
	if is_in_main_field():
		show_card_info()

func _on_area_2d_mouse_exited() -> void:
	mouse_inside = false
	emit_signal("hovered_off", self)
	if is_in_main_field():
		hide_card_info()

func show_card_info():
	if not card_information_reference:
		return
	var card_slug = get_slug_from_card()
	if card_slug == "":
		return
	if card_level_lable:
		card_level_lable.clear()
	if card_PLDS_lable:
		card_PLDS_lable.clear()
	var card_database = card_information_reference.card_database_reference
	if not card_database or not card_database.cards_db.has(card_slug):
		return
	var level_to_display = null
	var plds_text_to_display = ""
	var data = card_database.cards_db[card_slug]
	if data.has("level") and data["level"] != null:
		level_to_display = data["level"]
	plds_text_to_display = _build_plds_text(data)
	if data.has("edition_id") and not data.has("parent_orientation_slug"):
		var base_slug = find_base_card_for_edition(data["edition_id"], card_database)
		if base_slug and card_database.cards_db.has(base_slug):
			var base_data = card_database.cards_db[base_slug]
			if base_data.has("level") and base_data["level"] != null:
				level_to_display = base_data["level"]
			if plds_text_to_display == "":
				plds_text_to_display = _build_plds_text(base_data)
	elif data.has("parent_orientation_slug"):
		var parent_slug = data["parent_orientation_slug"]
		if card_database.cards_db.has(parent_slug):
			var parent_data = card_database.cards_db[parent_slug]
			if parent_data.has("level") and parent_data["level"] != null:
				level_to_display = parent_data["level"]
			if plds_text_to_display == "":
				plds_text_to_display = _build_plds_text(parent_data)
	if level_to_display != null and card_level_lable:
		card_level_lable.append_text("[left][font_size=32]LV. %s[/font_size][/left]" % str(level_to_display))
	if plds_text_to_display != "" and card_PLDS_lable:
		card_PLDS_lable.append_text("[right][font_size=26]%s[/font_size][/right]" % plds_text_to_display)

func hide_card_info():
	if card_level_lable:
		card_level_lable.clear()
	if card_PLDS_lable:
		card_PLDS_lable.clear()

func _build_plds_text(data: Dictionary) -> String:
	var parts: Array[String] = []
	if data.has("power") and data["power"] != null:
		parts.append("POW. %s" % str(data["power"]))
	if data.has("life") and data["life"] != null:
		parts.append("LIFE %s" % str(data["life"]))
	if data.has("durability") and data["durability"] != null:
		parts.append("DUR. %s" % str(data["durability"]))
	if data.has("speed") and data["speed"] != null:
		if typeof(data["speed"]) in [TYPE_INT, TYPE_FLOAT]:
			if data["speed"] == 1:
				parts.append("SPD. FAST")
			elif data["speed"] == 0:
				parts.append("SPD. SLOW")
			else:
				parts.append("SPEED %s" % str(data["speed"]))
		elif typeof(data["speed"]) == TYPE_BOOL:
			parts.append("FAST" if data["speed"] else "SLOW")
		else:
			parts.append("SPEED ?")
	return " - ".join(parts)

func get_slug_from_card() -> String:
	if has_meta("slug"):
		return get_meta("slug")
	return ""

func find_base_card_for_edition(edition_id, card_database):
	if not card_database:
		return null
	for slug in card_database.cards_db:
		var data = card_database.cards_db[slug]
		if data.has("editions"):
			for edition in data["editions"]:
				if edition.get("edition_id") == edition_id:
					return slug
	return null

func _on_PopupMenu_id_pressed(id: int) -> void:
	match id:
		0: print("Go to Graveyard selected")
		1: print("Go to Banish FU selected")
		2: print("Go to Banish FD selected")
		3: print("Go to TD selected")
		4: print("Go to BD selected")
		5: if is_in_main_field(): rotate_card()
		6: print("Show selected")
		7: print("Transform selected")
		8: print("Give to your opponent")

func rotate_card():
	if not is_in_main_field():
		return
	if is_rotated:
		rotation_degrees = original_rotation
		is_rotated = false
	else:
		rotation_degrees = original_rotation + 90
		is_rotated = true

func on_drag_start():
	was_rotated_before_drag = is_rotated
	rotation_degrees = original_rotation

func on_drag_end():
	is_rotated = false
	rotation_degrees = original_rotation

func set_current_field(field):
	current_field = field

func is_in_main_field() -> bool:
	return current_field != null and current_field.is_in_group("main_fields")

func is_in_memory_slot() -> bool:
	return current_field != null and current_field.is_in_group("memory_slots")

func is_in_graveyard() -> bool:
	return current_field != null and current_field.is_in_group("single_card_slots")

func is_in_banish() -> bool:
	return current_field != null and current_field.is_in_group("rotated_slots")
