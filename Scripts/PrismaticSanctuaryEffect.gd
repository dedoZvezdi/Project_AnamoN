class_name PrismaticSanctuaryEffect

static func apply_activation(elements_node: Node, is_opponent: bool = false, card: Node = null, main_field_node: Node = null):
	var conditions_met = (
		Gimmicks.condition_while_on_main_field(card, main_field_node))
	if conditions_met:
		Gimmicks.gimmick_apply_basic_elements(elements_node, is_opponent, card)

static func apply_deactivation(elements_node: Node, is_opponent: bool = false, card: Node = null):
	Gimmicks.gimmick_remove_basic_elements(elements_node, is_opponent, card)
