class_name PrismaticPerseveranceEffect

static func update_continuous_effect(elements_node: Node, is_opponent: bool = false, card: Node = null, main_field_node: Node = null):
	var conditions_met = (
		Gimmicks.condition_requires_champion(main_field_node)
		and Gimmicks.condition_while_on_main_field(card, main_field_node)
		and Gimmicks.condition_champion_min_damage_counters(main_field_node, 15)
		and Gimmicks.condition_min_delta_champion_level(main_field_node, 2))
	if conditions_met:
		Gimmicks.gimmick_apply_all_elements(elements_node, is_opponent, card)
	else:
		Gimmicks.gimmick_remove_all_elements(elements_node, is_opponent, card)

static func apply_activation(elements_node: Node, is_opponent: bool = false, card: Node = null, main_field_node: Node = null):
	update_continuous_effect(elements_node, is_opponent, card, main_field_node)

static func apply_deactivation(elements_node: Node, is_opponent: bool = false, card: Node = null):
	Gimmicks.gimmick_remove_all_elements(elements_node, is_opponent, card)
