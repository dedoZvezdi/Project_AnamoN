extends Node2D

var cards_in_field = []
var base_position
var card_in_slot = false
var current_champion_card = null
var champion_life_delta := 0

func adjust_champion_life_delta(delta):
	champion_life_delta += int(delta)

func _ready() -> void:
	base_position = Vector2.ZERO
	add_to_group("main_fields")

func add_card_to_field(card, position = null):
	if is_champion_card(card):
		var card_already_in_field = card in cards_in_field
		if not card_already_in_field:
			if current_champion_card != null and current_champion_card != card:
				remove_previous_champions()
			current_champion_card = card
			cards_in_field.append(card)
			card_in_slot = true
		if card and is_instance_valid(card) and card.has_method("apply_champion_life_delta"):
			card.apply_champion_life_delta(champion_life_delta)
		card.global_position = global_position
		card.z_index = 400
		var ci = card.get_node_or_null("CardImage")
		var cib = card.get_node_or_null("CardImageBack")
		if ci and cib:
			cib.z_index = -1
			ci.z_index = 0
			cib.visible = false
			ci.visible = true
		var ap = card.get_node_or_null("AnimationPlayer")
		if ap and ap.has_animation("card_flip"):
			ap.play("card_flip")
		if card.has_method("set_current_field"):
			card.set_current_field(self)
		if card.has_method("show_card_info"):
			card.show_card_info()
		var card_info_ref = find_card_information_reference()
		if card_info_ref and card_info_ref.has_method("show_card_preview"):
			card_info_ref.show_card_preview(card)
	else:
		if not (card in cards_in_field):
			cards_in_field.append(card)
			card_in_slot = true
		if card.has_method("set_current_field"):
			card.set_current_field(self)
		if position != null:
			card.global_position = position
			var ci2 = card.get_node_or_null("CardImage")
			var cib2 = card.get_node_or_null("CardImageBack")
			if ci2 and cib2:
				cib2.z_index = -1
				ci2.z_index = 0
				cib2.visible = false
				ci2.visible = true
			var ap2 = card.get_node_or_null("AnimationPlayer")
			if ap2 and ap2.has_animation("card_flip"):
				ap2.play("card_flip")

func notify_card_transformed(card):
	if card == current_champion_card and not is_champion_card(card):
		current_champion_card = null

func remove_previous_champions():
	if current_champion_card and is_instance_valid(current_champion_card):
		cards_in_field.erase(current_champion_card)
		if current_champion_card.has_method("set_current_field"):
			current_champion_card.set_current_field(null)
		if current_champion_card.get_parent():
			current_champion_card.get_parent().remove_child(current_champion_card)
		current_champion_card.queue_free()
		current_champion_card = null
		
func is_champion_card(card) -> bool:
	if not card or not is_instance_valid(card):
		return false
	var card_slug = get_card_slug(card)
	if card_slug == "":
		return false
	var card_info_ref = find_card_information_reference()
	if not card_info_ref or not card_info_ref.card_database_reference:
		return false
	var card_database = card_info_ref.card_database_reference
	if not card_database.cards_db.has(card_slug):
		return false
	var data = card_database.cards_db[card_slug]
	if data.has("types") and data["types"] is Array:
		for card_type in data["types"]:
			if str(card_type).to_upper() == "CHAMPION":
				return true
	if data.has("edition_id") and not data.has("parent_orientation_slug"):
		var base_slug = find_base_card_for_edition(data["edition_id"], card_database)
		if base_slug and card_database.cards_db.has(base_slug):
			var base_data = card_database.cards_db[base_slug]
			if base_data.has("types") and base_data["types"] is Array:
				for card_type in base_data["types"]:
					if str(card_type).to_upper() == "CHAMPION":
						return true
	elif data.has("parent_orientation_slug"):
		var parent_slug = data["parent_orientation_slug"]
		if card_database.cards_db.has(parent_slug):
			var parent_data = card_database.cards_db[parent_slug]
			if parent_data.has("types") and parent_data["types"] is Array:
				for card_type in parent_data["types"]:
					if str(card_type).to_upper() == "CHAMPION":
						return true
	return false

func get_card_slug(card) -> String:
	if card.has_meta("slug"):
		return card.get_meta("slug")
	return ""

func find_card_information_reference():
	var root = get_tree().current_scene
	if root:
		return find_node_by_script(root, "res://Scripts/CardInformation.gd")
	return null

func find_node_by_script(node: Node, script_path: String) -> Node:
	if node.get_script() and node.get_script().resource_path == script_path:
		return node
	for child in node.get_children():
		var result = find_node_by_script(child, script_path)
		if result:
			return result
	return null

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

func remove_card_from_field(card):
	if card in cards_in_field:
		cards_in_field.erase(card)
		if cards_in_field.is_empty():
			card_in_slot = false
		if card.has_method("set_current_field"):
			card.set_current_field(null)
		if card == current_champion_card:
			current_champion_card = null

func bring_card_to_front(card):
	if not card or not is_instance_valid(card):
		return
	var card_index = cards_in_field.find(card)
	if card_index == -1:
		return
	var field_size = cards_in_field.size()
	for i in range(field_size):
		var current_card = cards_in_field[i]
		if current_card and is_instance_valid(current_card):
			if i >= card_index:
				current_card.z_index = 200 + i + 50
			else:
				current_card.z_index = 200 + i + 1

func clear_hovered_card():
	var field_size = cards_in_field.size()
	for i in range(field_size):
		var card = cards_in_field[i]
		if card and is_instance_valid(card):
			card.z_index = 200 + i + 1
