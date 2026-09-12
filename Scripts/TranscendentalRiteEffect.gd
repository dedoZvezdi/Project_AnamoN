class_name TranscendentalRiteEffect

static func apply_activation(card: Node, main_field_node: Node):
	var conditions_met = (
		Gimmicks.condition_requires_champion(main_field_node)
		and Gimmicks.condition_while_on_main_field(card, main_field_node))
	if conditions_met:
		var root = card.get_tree().current_scene
		Gimmicks.gimmick_apply_ascendant(main_field_node, root, "transcendental", false)
		var elements_node = root.find_child("Elements", true, false)
		Gimmicks.gimmick_apply_basic_elements(elements_node, false)
		Gimmicks.gimmick_until_end_of_turn(main_field_node, "transcendental_rite")
		Gimmicks.gimmick_send_to_banish_face_up(card)

static func activate_rite(card: Node):
	var root = card.get_tree().current_scene
	var main_field = root.find_child("MAINFIELD", true, false)
	apply_activation(card, main_field)

static func apply_opponent_activation(root: Node):
	var opp_main_field = root.find_child("OpponentMainField", true, false)
	if opp_main_field:
		Gimmicks.gimmick_apply_ascendant(opp_main_field, root, "transcendental", true)
		var elements_node = root.find_child("OpponentElements", true, false)
		Gimmicks.gimmick_apply_basic_elements(elements_node, true)
		Gimmicks.gimmick_until_end_of_turn(opp_main_field, "transcendental_rite")
