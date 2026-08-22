class_name ImperialSealEffect

static func activate_seal(card: Node):
	var root = card.get_tree().current_scene
	var elements_node = root.find_child("Elements", true, false)
	if elements_node:
		var main_field = root.find_child("MAINFIELD", true, false)
		if main_field and "imperial_seal_turn_count" in main_field:
			main_field.imperial_seal_turn_count += 1
		for element_name in ["Fire", "Water", "Wind"]:
			var element_node = elements_node.get_node_or_null(element_name)
			if element_node and element_node.has_method("activate"):
				element_node.activate()
	var multiplayer_node = root.get_node_or_null("Main")
	if not multiplayer_node and root.name == "Main":
		multiplayer_node = root
	if multiplayer_node and multiplayer_node.has_method("rpc") and "uuid" in card:
		var my_id = multiplayer_node.multiplayer.get_unique_id()
		multiplayer_node.rpc("sync_imperial_seal_activate", my_id, card.uuid)
	if card and is_instance_valid(card) and card.has_method("go_to_banish_face_up"):
		card.go_to_banish_face_up()

static func apply_opponent_activation(root: Node):
	var elements_node = root.find_child("OpponentElements", true, false)
	if elements_node:
		var opp_main_field = root.find_child("OpponentMainField", true, false)
		if opp_main_field and "imperial_seal_turn_count" in opp_main_field:
			opp_main_field.imperial_seal_turn_count += 1
		for element_name in ["Fire", "Water", "Wind"]:
			var element_node = elements_node.get_node_or_null("Opponent" + element_name)
			if element_node and element_node.has_method("activate"):
				element_node.activate()
