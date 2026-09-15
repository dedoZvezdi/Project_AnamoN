class_name SacramentalRiteEffect

static func apply_activation(card: Node, main_field_node: Node):
	var conditions_met = (
		Gimmicks.condition_requires_champion(main_field_node)
		and Gimmicks.condition_while_on_main_field(card, main_field_node))
	if conditions_met:
		var root = card.get_tree().current_scene
		Gimmicks.gimmick_apply_ascendant(main_field_node, root, "sacramental", false)
		Gimmicks.gimmick_send_to_banish_face_up(card)

static func apply_on_enter_banish(card: Node, main_field_node: Node):
	if not Gimmicks.condition_on_main_field_enter(card, main_field_node):
		return
	var mat_deck = Gimmicks.condition_find_mat_deck(card)
	if not mat_deck:
		return
	var pickables = Gimmicks.condition_mat_deck_has_pickable(mat_deck)
	if pickables.is_empty():
		return
	Gimmicks.gimmick_show_mat_deck_pick(mat_deck, pickables, Callable(SacramentalRiteEffect, "apply_banish_pick"))

static func apply_banish_pick(mat_deck: Node, _slug: String, uuid: String) -> void:
	if not mat_deck or not is_instance_valid(mat_deck):
		return
	if mat_deck.has_method("banish_card_fd"):
		mat_deck.banish_card_fd(uuid)

static func activate_rite(card: Node):
	var root = card.get_tree().current_scene
	var main_field = root.find_child("MAINFIELD", true, false)
	apply_activation(card, main_field)

static func apply_opponent_activation(root: Node):
	var opp_main_field = root.find_child("OpponentMainField", true, false)
	if opp_main_field:
		Gimmicks.gimmick_apply_ascendant(opp_main_field, root, "sacramental", true)
