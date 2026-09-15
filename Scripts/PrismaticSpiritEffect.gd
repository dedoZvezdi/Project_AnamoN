class_name PrismaticSpiritEffect

static func apply_activation(_elements_node: Node, is_opponent: bool = false, card: Node = null, main_field_node: Node = null):
	if not Gimmicks.condition_on_main_field_enter(card, main_field_node):
		return
	if is_opponent:
		return
	_enter_sequence(card, main_field_node)

static func _enter_sequence(card: Node, main_field_node: Node) -> void:
	if not card or not is_instance_valid(card):
		return
	var root = card.get_tree().current_scene
	await Gimmicks.gimmick_draw_card(root, 6, 0.1)
	if not card or not is_instance_valid(card):
		return
	if not is_instance_valid(main_field_node):
		return
	if not Gimmicks.condition_while_on_main_field(card, main_field_node):
		return
	Gimmicks.gimmick_show_prismatic_selection(card, false)

static func apply_lineage_activation(elements_node: Node, champion_card: Node, is_opponent: bool = false):
	var chosen = Gimmicks.condition_inherited_prismatic_spirit(champion_card)
	if chosen.is_empty():
		return
	Gimmicks.gimmick_apply_chosen_elements(elements_node, chosen, is_opponent, champion_card)

static func remove_lineage_activation(elements_node: Node, champion_card: Node, is_opponent: bool = false):
	var chosen = Gimmicks.condition_inherited_prismatic_spirit(champion_card)
	if chosen.is_empty():
		return
	Gimmicks.gimmick_remove_chosen_elements(elements_node, chosen, is_opponent, champion_card)
