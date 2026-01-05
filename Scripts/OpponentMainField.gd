extends Node2D

var cards_in_field: Array = []
var base_position := Vector2.ZERO
var current_mastery_card: Node = null
var current_champion_card: Node = null

func is_champion_card(card) -> bool:
	if not card or not is_instance_valid(card):
		return false
	var slug = ""
	if card.has_meta("slug"):
		slug = card.get_meta("slug")
	if slug == "":
		return false
	var root = get_tree().current_scene
	var card_info = null
	if root:
		card_info = find_node_by_script(root, "res://Scripts/CardInformation.gd")
	if not card_info or not card_info.card_database_reference:
		return false
	var db = card_info.card_database_reference
	if not db.cards_db.has(slug):
		return false
	var data = db.cards_db[slug]
	if data.has("types") and data["types"] is Array:
		for t in data["types"]:
			if str(t).to_upper() == "CHAMPION":
				return true
	if data.has("edition_id") and not data.has("parent_orientation_slug"):
		var base_slug = find_base_card_for_edition(data["edition_id"], db)
		if base_slug and db.cards_db.has(base_slug):
			var base_data = db.cards_db[base_slug]
			if base_data.has("types") and base_data["types"] is Array:
				for card_type in base_data["types"]:
					if str(card_type).to_upper() == "CHAMPION":
						return true
	elif data.has("parent_orientation_slug"):
		var parent_slug = data["parent_orientation_slug"]
		if db.cards_db.has(parent_slug):
			var parent_data = db.cards_db[parent_slug]
			if parent_data.has("types") and parent_data["types"] is Array:
				for card_type in parent_data["types"]:
					if str(card_type).to_upper() == "CHAMPION":
						return true
	return false

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

func find_node_by_script(node: Node, script_path: String) -> Node:
	if node.get_script() and node.get_script().resource_path == script_path:
		return node
	for child in node.get_children():
		var result = find_node_by_script(child, script_path)
		if result:
			return result
	return null

func notify_card_transformed(card: Node):
	if is_champion_card(card):
		if current_champion_card != null and current_champion_card != card:
			var old_lineage = []
			if "champion_lineage" in current_champion_card:
				old_lineage = current_champion_card.champion_lineage
			for entry in old_lineage:
				if card.has_method("add_to_lineage"):
					card.add_to_lineage(entry)
			var old_slug = ""
			if current_champion_card.has_meta("slug"):
				old_slug = current_champion_card.get_meta("slug")
			var old_uuid = ""
			if "uuid" in current_champion_card:
				old_uuid = current_champion_card.uuid
			if card.has_method("add_to_lineage"):
				card.add_to_lineage({"slug": old_slug, "uuid": old_uuid})
			remove_previous_champions()
		current_champion_card = card
		card.global_position = global_position + Vector2(0, 20)
		card.z_index = 400
	elif card == current_champion_card:
		current_champion_card = null

func remove_previous_champions():
	if current_champion_card and is_instance_valid(current_champion_card):
		if current_champion_card in cards_in_field:
			cards_in_field.erase(current_champion_card)
		if current_champion_card.get_parent():
			current_champion_card.get_parent().remove_child(current_champion_card)
		current_champion_card.queue_free()
		current_champion_card = null

func _ready() -> void:
	base_position = Vector2.ZERO
	add_to_group("main_fields")

func add_card_to_field(card: Node, target_pos: Vector2, target_rot_deg: float = 0.0) -> void:
	if not card or not is_instance_valid(card):
		return
	if is_champion_card(card):
		if current_champion_card != null and current_champion_card != card:
			var old_lineage = []
			if "champion_lineage" in current_champion_card:
				old_lineage = current_champion_card.champion_lineage
			for entry in old_lineage:
				if card.has_method("add_to_lineage"):
					card.add_to_lineage(entry)
			var old_slug = ""
			if current_champion_card.has_meta("slug"):
				old_slug = current_champion_card.get_meta("slug")
			var old_uuid = ""
			if "uuid" in current_champion_card:
				old_uuid = current_champion_card.uuid
			if card.has_method("add_to_lineage"):
				card.add_to_lineage({"slug": old_slug, "uuid": old_uuid})
			remove_previous_champions()
		current_champion_card = card
		card.global_position = global_position + Vector2(0, 20)
	elif is_mastery_card(card):
		if current_mastery_card != null and current_mastery_card != card:
			remove_previous_mastery()
		current_mastery_card = card
	if card.has_method("set_current_field"):
		card.set_current_field(self)
	if card not in cards_in_field:
		cards_in_field.append(card)
	var card_image = card.get_node_or_null("CardImage")
	var card_image_back = card.get_node_or_null("CardImageBack")
	if card_image and card_image_back:
		card_image_back.z_index = -1
		card_image.z_index = 0
		card_image_back.visible = false
		card_image.visible = true
	var tween = create_tween()
	tween.parallel().tween_property(card, "global_position", target_pos, 0.2)
	tween.parallel().tween_property(card, "rotation_degrees", target_rot_deg, 0.2)
	card.z_index = 200 + cards_in_field.size()

func remove_previous_mastery():
	if current_mastery_card and is_instance_valid(current_mastery_card):
		cards_in_field.erase(current_mastery_card)
		current_mastery_card.queue_free()
		current_mastery_card = null

func is_mastery_card(card) -> bool:
	if not card or not is_instance_valid(card):
		return false
	if card.has_method("is_mastery"):
		return card.is_mastery()
	var slug = ""
	if card.has_meta("slug"):
		slug = card.get_meta("slug")
	var logos = get_tree().get_nodes_in_group("logo")
	if logos.size() > 0:
		var logo = logos[0]
		if "mastery_slugs" in logo:
			return slug in logo.mastery_slugs
	return false

func remove_card_from_field(card: Node) -> void:
	if card in cards_in_field:
		cards_in_field.erase(card)
		if card.has_method("set_current_field"):
			card.set_current_field(null)
		if card == current_champion_card:
			current_champion_card = null
		if card == current_mastery_card:
			current_mastery_card = null

func bring_card_to_front(card: Node) -> void:
	var idx := cards_in_field.find(card)
	if idx == -1:
		return
	for i in range(cards_in_field.size()):
		var cards = cards_in_field[i]
		if cards and is_instance_valid(cards):
			if i >= idx:
				cards.z_index = 200 + i + 50
			else:
				cards.z_index = 200 + i + 1

func clear_hovered_card() -> void:
	for i in range(cards_in_field.size()):
		var card = cards_in_field[i]
		if card and is_instance_valid(card):
			card.z_index = 200 + i + 1

func connect_card_signals(card):
	var card_manager = get_tree().get_root().find_child("CardManager", true, false)
	if card_manager and card_manager.has_method("connect_card_signals"):
		card_manager.connect_card_signals(card)
