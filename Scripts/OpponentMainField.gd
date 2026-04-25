extends Node2D

var cards_in_field: Array = []
var base_position := Vector2.ZERO
var current_mastery_card: Node = null
var current_champion_card: Node = null
var first_champion_summoned = false
var imperial_seal_turn_count = 0

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
	if card_info and card_info.has_method("is_card_of_type"):
		return card_info.is_card_of_type(slug, "CHAMPION")
	return false

func find_node_by_script(node: Node, script_path: String) -> Node:
	if node.get_script() and node.get_script().resource_path == script_path:
		return node
	for child in node.get_children():
		var result = find_node_by_script(child, script_path)
		if result:
			return result
	return null

func activate_champion_elements(card):
	if not card or not is_instance_valid(card):
		return
	var card_slug = ""
	if card.has_meta("slug"):
		card_slug = card.get_meta("slug")
	if card_slug == "":
		return
	var root = get_tree().current_scene
	var card_info = null
	if root:
		card_info = find_node_by_script(root, "res://Scripts/CardInformation.gd")
	if not card_info:
		return
	var elements_node = get_parent().get_node_or_null("OpponentElements")
	if not elements_node:
		if root:
			elements_node = root.find_child("OpponentElements", true, false)	
	if not elements_node:
		return
	if card_slug.contains("prismatic-sanctuary"):
		for e_name in ["Fire", "Water", "Wind"]:
			var e_node = elements_node.get_node_or_null("Opponent" + e_name)
			if e_node and e_node.has_method("activate"):
				e_node.activate()
	elif card_slug.contains("prismatic-perseverance"):
		for e_name in ["Norm", "Fire", "Water", "Wind", "Astra", "Umbra", "Arcane", "Exia", "Crux", "Tera", "Neos", "Luxem"]:
			var e_node = elements_node.get_node_or_null("Opponent" + e_name)
			if e_node and e_node.has_method("activate"):
				e_node.activate()
	elif card_slug.contains("imperial-seal"):
		if card.has_meta("is_given") and card.get_meta("is_given"):
			card.set_meta("is_given", false)
			return
		imperial_seal_turn_count += 1
		for e_name in ["Fire", "Water", "Wind"]:
			var e_node = elements_node.get_node_or_null("Opponent" + e_name)
			if e_node and e_node.has_method("activate"):
				e_node.activate()
	elif card_slug.contains("prismatic-spirit"):
		var norm = elements_node.get_node_or_null("OpponentNorm")
		if norm and norm.has_method("activate"):
			norm.activate()
	if "champion_lineage" in card:
		for entry in card.champion_lineage:
			var slug = entry.get("slug", "")
			if slug.contains("prismatic-spirit"):
				var chosen = entry.get("chosen_elements", [])
				for e_name in chosen:
					var e_node = elements_node.get_node_or_null("Opponent" + e_name)
					if e_node and e_node.has_method("activate"):
						e_node.activate()
	if is_champion_card(card):
		var element_name = ""
		if card_info.has_method("get_card_element"):
			element_name = card_info.get_card_element(card_slug)
		if element_name != "":
			if not first_champion_summoned:
				var norm = elements_node.get_node_or_null("OpponentNorm")
				if norm and norm.has_method("activate"):
					norm.activate()
				first_champion_summoned = true
			var capitalized_name = str(element_name).capitalize()
			var element_node = elements_node.get_node_or_null("Opponent" + capitalized_name)
			if element_node and element_node.has_method("activate"):
				element_node.activate()

func deactivate_card_elements(card):
	if not card or not is_instance_valid(card):
		return
	var card_slug = ""
	if card.has_meta("slug"):
		card_slug = card.get_meta("slug")
	if not (card_slug.contains("prismatic-sanctuary") or card_slug.contains("prismatic-perseverance") or card_slug.contains("prismatic-spirit")):
		pass
	if card_slug.contains("imperial-seal"):
		return
	var root = get_tree().current_scene
	var elements_node = get_parent().get_node_or_null("OpponentElements")
	if not elements_node:
		if root:
			elements_node = root.find_child("OpponentElements", true, false)	
	if elements_node:
		var elements_to_deactivate = []
		if card_slug.contains("prismatic-sanctuary"):
			elements_to_deactivate = ["Fire", "Water", "Wind"]
		elif card_slug.contains("prismatic-perseverance"):
			elements_to_deactivate = ["Norm", "Fire", "Water", "Wind", "Astra", "Umbra", "Arcane", "Exia", "Crux", "Tera", "Neos", "Luxem"]
		for e_name in elements_to_deactivate:
			var e_node = elements_node.get_node_or_null("Opponent" + e_name)
			if e_node and e_node.has_method("deactivate"):
				e_node.deactivate()

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
			if "attached_counters" in current_champion_card:
				for c_name in current_champion_card.attached_counters:
					card.attached_counters[c_name] = current_champion_card.attached_counters[c_name]
			if "runtime_modifiers" in current_champion_card:
				card.runtime_modifiers = current_champion_card.runtime_modifiers.duplicate()
			if card.has_method("add_to_lineage"):
				card.add_to_lineage({"slug": old_slug, "uuid": old_uuid, "chosen_elements": current_champion_card.chosen_elements if "chosen_elements" in current_champion_card else []})
			remove_previous_champions()
		current_champion_card = card
		if not (card in cards_in_field):
			activate_champion_elements(card)
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
		deactivate_card_elements(current_champion_card)
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
			if "attached_counters" in current_champion_card:
				for c_name in current_champion_card.attached_counters:
					card.attached_counters[c_name] = current_champion_card.attached_counters[c_name]
			if "runtime_modifiers" in current_champion_card:
				card.runtime_modifiers = current_champion_card.runtime_modifiers.duplicate()
			if card.has_method("add_to_lineage"):
				card.add_to_lineage({"slug": old_slug, "uuid": old_uuid, "chosen_elements": current_champion_card.chosen_elements if "chosen_elements" in current_champion_card else []})
			remove_previous_champions()
		current_champion_card = card
		if not (card in cards_in_field):
			activate_champion_elements(card)
		card.global_position = global_position + Vector2(0, 20)
	elif is_mastery_card(card):
		if current_mastery_card != null and current_mastery_card != card:
			remove_previous_mastery()
		current_mastery_card = card
		if not (card in cards_in_field):
			if get_card_slug(card).contains("prismatic-sanctuary") or get_card_slug(card).contains("prismatic-perseverance") or get_card_slug(card).contains("imperial-seal"):
				activate_champion_elements(card)
	if card.has_method("set_current_field"):
		card.set_current_field(self)
	if card not in cards_in_field:
		cards_in_field.append(card)
		if (get_card_slug(card).contains("prismatic-sanctuary") or get_card_slug(card).contains("prismatic-perseverance") or get_card_slug(card).contains("imperial-seal")) and not is_champion_card(card) and not is_mastery_card(card):
			activate_champion_elements(card)
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
		deactivate_card_elements(current_mastery_card)
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
		deactivate_card_elements(card)

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

func clear_imperial_seal_activations():
	var root = get_tree().current_scene
	var elements_node = get_parent().get_node_or_null("OpponentElements")
	if not elements_node:
		if root:
			elements_node = root.find_child("OpponentElements", true, false)	
	if not elements_node:
		imperial_seal_turn_count = 0
		return
	while imperial_seal_turn_count > 0:
		for e_name in ["Fire", "Water", "Wind"]:
			var e_node = elements_node.get_node_or_null("Opponent" + e_name)
			if e_node and e_node.has_method("deactivate"):
				e_node.deactivate()
		imperial_seal_turn_count -= 1

func connect_card_signals(card):
	var card_manager = get_tree().get_root().find_child("CardManager", true, false)
	if card_manager and card_manager.has_method("connect_card_signals"):
		card_manager.connect_card_signals(card)

func get_card_slug(card) -> String:
	if card.has_meta("slug"):
		return card.get_meta("slug")
	return ""
