extends Node2D

var cards_in_field = []
var base_position
var card_in_slot = false
var current_champion_card = null
var current_mastery_card = null
var champion_life_delta := 0
var first_champion_summoned = false

func adjust_champion_life_delta(delta):
	champion_life_delta += int(delta)

func _ready() -> void:
	base_position = Vector2.ZERO
	add_to_group("main_fields")

func activate_champion_elements(card):
	if not card or not is_instance_valid(card):
		return
	var root = get_tree().current_scene
	var card_slug = get_card_slug(card)
	if card_slug == "":
		return
	var elements_node = get_parent().get_node_or_null("Elements")
	if not elements_node:
		if root and root.has_method("find_child"):
			elements_node = root.find_child("Elements", true, false)	
	if not elements_node:
		return
	if card_slug.contains("prismatic-sanctuary"):
		for e_name in ["Fire", "Water", "Wind"]:
			var e_node = elements_node.get_node_or_null(e_name)
			if e_node and e_node.has_method("activate"):
				e_node.activate()
	if is_champion_card(card):
		var card_info_ref = find_card_information_reference()
		if not card_info_ref or not card_info_ref.card_database_reference:
			if root and root.has_method("find_child"):
				card_info_ref = root.find_child("CardInformation", true, false)
		var element_name = ""
		if card_info_ref and card_info_ref.has_method("get_card_element"):
			element_name = card_info_ref.get_card_element(card_slug)
		if element_name != "":
			if not first_champion_summoned:
				var norm = elements_node.get_node_or_null("Norm")
				if norm and norm.has_method("activate"):
					norm.activate()
				first_champion_summoned = true
			var capitalized_name = str(element_name).capitalize()
			var element_node = elements_node.get_node_or_null(capitalized_name)
			if element_node and element_node.has_method("activate"):
				element_node.activate()

func deactivate_card_elements(card):
	if not card or not is_instance_valid(card):
		return
	var card_slug = get_card_slug(card)
	if not card_slug.contains("prismatic-sanctuary"):
		return
	var root = get_tree().current_scene
	var elements_node = get_parent().get_node_or_null("Elements")
	if not elements_node:
		if root and root.has_method("find_child"):
			elements_node = root.find_child("Elements", true, false)	
	if elements_node:
		for e_name in ["Fire", "Water", "Wind"]:
			var e_node = elements_node.get_node_or_null(e_name)
			if e_node and e_node.has_method("deactivate"):
				e_node.deactivate()

@warning_ignore("shadowed_variable_base_class")
func add_card_to_field(card, position = null):
	if is_champion_card(card):
		var card_already_in_field = card in cards_in_field
		if not card_already_in_field:
			var inherit_source = current_champion_card
			if inherit_source == null:
				for cards in cards_in_field:
					if is_instance_valid(cards) and cards != card and not is_mastery_card(cards) and "champion_lineage" in cards:
						if cards.champion_lineage.size() > 0:
							inherit_source = cards
							break
			if is_instance_valid(inherit_source) and inherit_source != card:
				if "champion_lineage" in inherit_source:
					var old_lineage = inherit_source.champion_lineage
					for entry in old_lineage:
						if card.has_method("add_to_lineage"):
							card.add_to_lineage(entry)
				if "attached_counters" in inherit_source:
					for c_name in inherit_source.attached_counters:
						card.attached_counters[c_name] = inherit_source.attached_counters[c_name]
			if current_champion_card != null and current_champion_card != card:
				if "attached_counters" in current_champion_card and card.has_method("get") and "attached_counters" in card:
					for c_name in current_champion_card.attached_counters:
						card.attached_counters[c_name] = current_champion_card.attached_counters[c_name]
				if card.has_method("add_to_lineage"):
					var lineage_data = {
						"slug": get_card_slug(current_champion_card),
						"uuid": current_champion_card.uuid if "uuid" in current_champion_card else ""}
					card.add_to_lineage(lineage_data)
				remove_previous_champions()
			current_champion_card = card
			cards_in_field.append(card)
			card_in_slot = true
			activate_champion_elements(card)
		if card and is_instance_valid(card) and card.has_method("apply_champion_life_delta"):
			card.apply_champion_life_delta(champion_life_delta)
		card.global_position = global_position + Vector2(0, -20)
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
	elif is_mastery_card(card):
		var card_already_in_field = card in cards_in_field
		if not card_already_in_field:
			if current_mastery_card != null and current_mastery_card != card:
				remove_previous_mastery()
			current_mastery_card = card
			cards_in_field.append(card)
			card_in_slot = true
			if get_card_slug(card).contains("prismatic-sanctuary"):
				activate_champion_elements(card)
		if position != null:
			card.global_position = position
		else:
			card.global_position = global_position
		card.z_index = 350
		var ci2 = card.get_node_or_null("CardImage")
		var cib2 = card.get_node_or_null("CardImageBack")
		if ci2 and cib2:
			cib2.z_index = -1
			ci2.z_index = 0
			cib2.visible = false
			ci2.visible = true
		if card.has_method("set_current_field"):
			card.set_current_field(self)
	else:
		if not (card in cards_in_field):
			cards_in_field.append(card)
			card_in_slot = true
			if get_card_slug(card).contains("prismatic-sanctuary"):
				activate_champion_elements(card)
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

func notify_card_transformed(card):
	if card == current_champion_card and not is_champion_card(card):
		current_champion_card = null
	elif is_champion_card(card):
		activate_champion_elements(card)

func remove_previous_champions():
	if current_champion_card and is_instance_valid(current_champion_card):
		cards_in_field.erase(current_champion_card)
		if current_champion_card.has_method("set_current_field"):
			current_champion_card.set_current_field(null)
		if current_champion_card.get_parent():
			current_champion_card.get_parent().remove_child(current_champion_card)
		current_champion_card.queue_free()
		deactivate_card_elements(current_champion_card)
		current_champion_card = null
		
func is_champion_card(card) -> bool:
	if not card or not is_instance_valid(card):
		return false
	var card_slug = get_card_slug(card)
	if card_slug == "":
		return false
	var card_info_ref = find_card_information_reference()
	if card_info_ref and card_info_ref.has_method("is_card_of_type"):
		return card_info_ref.is_card_of_type(card_slug, "CHAMPION")
	return false

func is_regalia_card(card) -> bool:
	if not card or not is_instance_valid(card):
		return false
	var card_slug = get_card_slug(card)
	if card_slug == "":
		return false
	var card_info_ref = find_card_information_reference()
	if card_info_ref and card_info_ref.has_method("is_card_of_type"):
		return card_info_ref.is_card_of_type(card_slug, "REGALIA")
	return false

func remove_previous_mastery():
	if current_mastery_card and is_instance_valid(current_mastery_card):
		cards_in_field.erase(current_mastery_card)
		if current_mastery_card.has_method("set_current_field"):
			current_mastery_card.set_current_field(null)
		if current_mastery_card.get_parent():
			current_mastery_card.get_parent().remove_child(current_mastery_card)
		current_mastery_card.queue_free()
		deactivate_card_elements(current_mastery_card)
		current_mastery_card = null

func is_mastery_card(card) -> bool:
	if not card or not is_instance_valid(card):
		return false
	if card.has_method("is_mastery"):
		return card.is_mastery()
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

func remove_card_from_field(card):
	if card in cards_in_field:
		cards_in_field.erase(card)
		if cards_in_field.is_empty():
			card_in_slot = false
		if card.has_method("set_current_field"):
			card.set_current_field(null)
		if card == current_champion_card:
			current_champion_card = null
		if card == current_mastery_card:
			current_mastery_card = null
		deactivate_card_elements(card)

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
