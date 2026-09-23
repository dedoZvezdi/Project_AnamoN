class_name ApotheosisRiteEffect

const CARD_SLUG := "apotheosis-rite"
const IS_DIVINE_RELIC := true

static func apply_activation(card: Node, main_field_node: Node):
	var conditions_met = (
		Gimmicks.condition_requires_champion(main_field_node)
		and Gimmicks.condition_while_on_main_field(card, main_field_node))
	if conditions_met:
		var root = card.get_tree().current_scene
		Gimmicks.gimmick_apply_ascendant(main_field_node, root, "apotheosis", false)
		Gimmicks.gimmick_draw_card(root, 1)
		Gimmicks.gimmick_send_to_banish_face_up(card)

static func activate_rite(card: Node):
	var root = card.get_tree().current_scene
	var main_field = root.find_child("MAINFIELD", true, false)
	apply_activation(card, main_field)

static func apply_opponent_activation(root: Node):
	var opp_main_field = root.find_child("OpponentMainField", true, false)
	if opp_main_field:
		Gimmicks.gimmick_apply_ascendant(opp_main_field, root, "apotheosis", true)
