class_name PrismaticSanctuaryEffect

static func apply_activation(elements_node: Node, is_opponent: bool = false, card: Node = null, main_field_node: Node = null):
	var conditions_met = (
		Gimmicks.condition_while_on_main_field(card, main_field_node))
	if conditions_met:
		Gimmicks.gimmick_apply_basic_elements(elements_node, is_opponent, card)
		Gimmicks.gimmick_bind_phase(card, "RECOLLECTION", apply_upkeep.bind(card, main_field_node), is_opponent)

static func apply_deactivation(elements_node: Node, is_opponent: bool = false, card: Node = null):
	Gimmicks.gimmick_remove_basic_elements(elements_node, is_opponent, card)
	Gimmicks.gimmick_unbind_phase(card)

static func apply_upkeep(card: Node, main_field_node: Node) -> void:
	var conditions_met = (
		Gimmicks.condition_while_on_main_field(card, main_field_node)
		and Gimmicks.condition_is_my_turn(card)
		and Gimmicks.condition_phase_is(card, "RECOLLECTION")
		and Gimmicks.condition_zone_min_cards(card, "memory", 1))
	if conditions_met:
		if not Gimmicks.condition_cards_are_basic_element(await Gimmicks.gimmick_reveal_random_cards(card, "memory", 1, 0.7)):
			await Gimmicks.gimmick_sacrifice_to_graveyard(card)
