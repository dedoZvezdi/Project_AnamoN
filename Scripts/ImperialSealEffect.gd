class_name ImperialSealEffect

static func apply_activation(card: Node, main_field_node: Node):
	var conditions_met = (
		Gimmicks.condition_while_on_main_field(card, main_field_node))
	if conditions_met:
		var root = card.get_tree().current_scene
		var elements_node = root.find_child("Elements", true, false)
		Gimmicks.gimmick_apply_basic_elements(elements_node, false)
		Gimmicks.gimmick_until_end_of_turn(main_field_node, "imperial_seal")
		if "uuid" in card:
			Gimmicks.gimmick_sync_activation(root, "sync_imperial_seal_activate", [card.uuid])
		Gimmicks.gimmick_send_to_banish_face_up(card)

static func activate_seal(card: Node):
	var root = card.get_tree().current_scene
	var main_field = root.find_child("MAINFIELD", true, false)
	apply_activation(card, main_field)

static func apply_opponent_activation(root: Node):
	var opp_main_field = root.find_child("OpponentMainField", true, false)
	if opp_main_field:
		var elements_node = root.find_child("OpponentElements", true, false)
		Gimmicks.gimmick_apply_basic_elements(elements_node, true)
		Gimmicks.gimmick_until_end_of_turn(opp_main_field, "imperial_seal")
