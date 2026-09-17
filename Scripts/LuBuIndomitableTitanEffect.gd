class_name LuBuIndomitableTitanEffect

const WRATH_AURA_RULES = [
	{"types": ["ALLY"], "stat": "power", "amount": -3, "side": "any"},
	{"types": ["CHAMPION"], "stat": "level", "amount": -3, "side": "enemy"},]

static var is_executing_effect = false

static func check_and_apply(champion: Node, main_field_node: Node) -> bool:
	if is_executing_effect:
		return true
	var conditions_met = (
		Gimmicks.condition_requires_champion(main_field_node)
		and Gimmicks.condition_card_slug_contains(champion, "diaochan")
		and Gimmicks.condition_card_exact_damage_counters(champion, 32)
		and Gimmicks.condition_card_is_dead(champion)
		and Gimmicks.condition_while_on_main_field(champion, main_field_node))
	if not conditions_met:
		return false
	var lu_bu = Gimmicks.find_field_card_by_slug(main_field_node, "lubuindomitabletitan")
	if lu_bu == null:
		return false
	is_executing_effect = true
	_execute_wipe_and_transform(champion, main_field_node, lu_bu)
	return true

static func _execute_wipe_and_transform(champion: Node, main_field_node: Node, lu_bu: Node):
	var ctx = Gimmicks.find_effect_context(main_field_node)
	if not ctx["tree"]:
		is_executing_effect = false
		return
	var champ_pos = champion.global_position
	await Gimmicks.gimmick_sacrifice_champion(champion, main_field_node, ctx["banish_slot"], ctx["unique_id"], ctx["multiplayer_node"])
	var lineage_to_process = Gimmicks.gimmick_extract_lineage(champion)
	await Gimmicks.gimmick_parade_lineage_to_banish(main_field_node, lineage_to_process, champ_pos, ctx["banish_slot"], ctx["unique_id"], ctx["multiplayer_node"])
	var targets = Gimmicks.find_field_objects(main_field_node, [champion, lu_bu])
	await Gimmicks.gimmick_destroy_objects(targets, main_field_node, ctx["banish_slot"], ctx["graveyard_slot"], ctx["db_ref"], ctx["card_info_node"], ctx["unique_id"], ctx["multiplayer_node"])
	Gimmicks.gimmick_clear_ascendant(main_field_node, ctx["root"], false)
	if ctx["multiplayer_node"]:
		Gimmicks.gimmick_refresh_all_cards_visuals(ctx["multiplayer_node"])
	if is_instance_valid(lu_bu) and lu_bu.has_method("transform_card"):
		lu_bu.transform_card()
	is_executing_effect = false

static func apply_wrath_incarnate_global_mods(card: Node, _data: Dictionary, current_mods: Dictionary) -> Dictionary:
	var multiplayer_node = Gimmicks.find_multiplayer_node(card)
	if not multiplayer_node:
		return current_mods
	var mains = Gimmicks.find_both_main_fields(multiplayer_node)
	var local_has_wrath = Gimmicks.condition_champion_name_contains(mains[0], "wrath incarnate")
	var opp_has_wrath = Gimmicks.condition_champion_name_contains(mains[1], "wrath incarnate")
	return Gimmicks.gimmick_apply_aura_mods(card, current_mods, local_has_wrath, opp_has_wrath, WRATH_AURA_RULES)
