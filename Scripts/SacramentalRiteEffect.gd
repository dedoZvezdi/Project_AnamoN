class_name SacramentalRiteEffect

const CARD_SLUG := "sacramental-rite"
const IS_DIVINE_RELIC := true

const CHOICE_TITLE = "Sacramental Rite"
const CHOICE_TEXT = "Do you want to play the banished card?"
const CHOICE_BUTTONS = ["Yes", "No"]
const CHOICE_YES = 0
const CHOICE_NO = 1

static func apply_activation(card: Node, main_field_node: Node):
	var conditions_met = (
		Gimmicks.condition_requires_champion(main_field_node)
		and Gimmicks.condition_while_on_main_field(card, main_field_node))
	if not conditions_met:
		return
	if Gimmicks.find_stored_card(card, Gimmicks.find_banish_node(card)).is_empty():
		Gimmicks.gimmick_finish_rite_activation(card, main_field_node, "sacramental")
		return
	show_sacramental_choice(card, Callable(SacramentalRiteEffect, "_resolve_play_choice").bind(card, main_field_node))

static func _resolve_play_choice(index: int, card: Node, main_field_node: Node) -> void:
	if not card or not is_instance_valid(card):
		return
	if not is_instance_valid(main_field_node):
		return
	if not Gimmicks.condition_while_on_main_field(card, main_field_node):
		return
	var stored = Gimmicks.find_stored_card(card, Gimmicks.find_banish_node(card))
	Gimmicks.gimmick_finish_rite_activation(card, main_field_node, "sacramental")
	if index != CHOICE_YES or stored.is_empty():
		return
	Gimmicks.gimmick_spawn_play_proxy(card, stored)

static func show_sacramental_choice(card: Node, on_chosen: Callable = Callable()):
	Gimmicks.gimmick_show_choice_panel(card, CHOICE_TITLE, CHOICE_TEXT, CHOICE_BUTTONS, on_chosen)

static func activate_rite(card: Node):
	var root = card.get_tree().current_scene
	var main_field = root.find_child("MAINFIELD", true, false)
	apply_activation(card, main_field)

static func apply_opponent_activation(root: Node):
	var opp_main_field = root.find_child("OpponentMainField", true, false)
	if opp_main_field:
		Gimmicks.gimmick_apply_ascendant(opp_main_field, root, "sacramental", true)
