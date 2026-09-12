class_name Gimmicks

const ALL_ELEMENTS = ["Norm", "Fire", "Water", "Wind", "Astra", "Umbra", "Arcane", "Exia", "Crux", "Tera", "Neos", "Luxem"]
const BASIC_ELEMENTS = ["Fire", "Water", "Wind"]

# ==========================================
# GIMMICKS (Effects)
# ==========================================

static func gimmick_apply_all_elements(elements_node: Node, is_opponent: bool = false, source: Node = null):
	if not elements_node:
		return
	if source and is_instance_valid(source):
		if source.has_meta("gimmick_all_elements_active") and source.get_meta("gimmick_all_elements_active"):
			return
		source.set_meta("gimmick_all_elements_active", true)
	var prefix = "Opponent" if is_opponent else ""
	for element_name in ALL_ELEMENTS:
		var element_node = elements_node.get_node_or_null(prefix + element_name)
		if element_node and element_node.has_method("activate"):
			element_node.activate()

static func gimmick_remove_all_elements(elements_node: Node, is_opponent: bool = false, source: Node = null):
	if not elements_node:
		return
	if source and is_instance_valid(source):
		if not source.has_meta("gimmick_all_elements_active") or not source.get_meta("gimmick_all_elements_active"):
			return
		source.set_meta("gimmick_all_elements_active", false)
	var prefix = "Opponent" if is_opponent else ""
	for element_name in ALL_ELEMENTS:
		var element_node = elements_node.get_node_or_null(prefix + element_name)
		if element_node and element_node.has_method("deactivate"):
			element_node.deactivate()

static func gimmick_apply_basic_elements(elements_node: Node, is_opponent: bool = false, source: Node = null):
	if not elements_node:
		return
	if source and is_instance_valid(source):
		if source.has_meta("gimmick_basic_elements_active") and source.get_meta("gimmick_basic_elements_active"):
			return
		source.set_meta("gimmick_basic_elements_active", true)
	var prefix = "Opponent" if is_opponent else ""
	for element_name in BASIC_ELEMENTS:
		var element_node = elements_node.get_node_or_null(prefix + element_name)
		if element_node and element_node.has_method("activate"):
			element_node.activate()

static func gimmick_remove_basic_elements(elements_node: Node, is_opponent: bool = false, source: Node = null):
	if not elements_node:
		return
	if source and is_instance_valid(source):
		if not source.has_meta("gimmick_basic_elements_active") or not source.get_meta("gimmick_basic_elements_active"):
			return
		source.set_meta("gimmick_basic_elements_active", false)
	var prefix = "Opponent" if is_opponent else ""
	for element_name in BASIC_ELEMENTS:
		var element_node = elements_node.get_node_or_null(prefix + element_name)
		if element_node and element_node.has_method("deactivate"):
			element_node.deactivate()

static func gimmick_apply_ascendant(main_field_node: Node, root: Node, rite_type: String, is_opponent: bool = false):
	if not main_field_node:
		return
	if rite_type == "apotheosis" and "apotheosis_rite_active" in main_field_node:
		main_field_node.apotheosis_rite_active = true
	elif rite_type == "transcendental" and "transcendental_rite_active" in main_field_node:
		main_field_node.transcendental_rite_active = true
	elif rite_type == "sacramental" and "sacramental_rite_active" in main_field_node:
		main_field_node.sacramental_rite_active = true
	if not is_opponent and root:
		var multiplayer_node = root.get_node_or_null("Main")
		if not multiplayer_node and root.name == "Main":
			multiplayer_node = root
		if multiplayer_node and multiplayer_node.has_method("rpc"):
			var my_id = multiplayer_node.multiplayer.get_unique_id()
			var rpc_name = "sync_" + rite_type + "_rite_activate"
			multiplayer_node.rpc(rpc_name, my_id)

static func gimmick_sync_activation(root: Node, rpc_name: String, args: Array = []):
	if not root:
		return
	var multiplayer_node = root.get_node_or_null("Main")
	if not multiplayer_node and root.name == "Main":
		multiplayer_node = root
	if multiplayer_node and multiplayer_node.has_method("rpc"):
		var my_id = multiplayer_node.multiplayer.get_unique_id()
		var call_args = [rpc_name, my_id]
		call_args.append_array(args)
		multiplayer_node.callv("rpc", call_args)

static func gimmick_draw_card(root: Node):
	if root:
		var deck = root.find_child("GA_DECK", true, false)
		if deck and deck.has_method("draw_clicked"):
			deck.draw_clicked()

static func gimmick_send_to_banish_face_up(card: Node):
	if card and is_instance_valid(card) and card.has_method("go_to_banish_face_up"):
		card.go_to_banish_face_up()

static func gimmick_until_end_of_turn(main_field_node: Node, mechanic_name: String):
	if not main_field_node:
		return
	var count_var = mechanic_name + "_turn_count"
	if count_var in main_field_node:
		main_field_node.set(count_var, main_field_node.get(count_var) + 1)

# ==========================================
# CONDITIONS (Requirements)
# ==========================================

static func condition_requires_champion(main_field_node: Node) -> bool:
	if not main_field_node:
		return false
	return main_field_node.get("current_champion_card") != null

static func condition_while_on_main_field(card: Node, main_field_node: Node) -> bool:
	if not card or not is_instance_valid(card) or not main_field_node:
		return false
	var cards_in_field = main_field_node.get("cards_in_field")
	if typeof(cards_in_field) == TYPE_ARRAY:
		return card in cards_in_field
	return false

static func condition_champion_min_damage_counters(main_field_node: Node, min_counters: int) -> bool:
	if not main_field_node:
		return false
	var champion = main_field_node.get("current_champion_card")
	if not champion or not is_instance_valid(champion):
		return false
	var damage_counters = 0
	if "attached_counters" in champion:
		var counters = champion.attached_counters
		if typeof(counters) == TYPE_DICTIONARY and counters.has("Damage"):
			damage_counters = int(counters["Damage"])
	return damage_counters >= min_counters

static func condition_card_min_damage_counters(card: Node, min_counters: int) -> bool:
	if not card or not is_instance_valid(card):
		return false
	var damage_counters = 0
	if "attached_counters" in card:
		var counters = card.attached_counters
		if typeof(counters) == TYPE_DICTIONARY and counters.has("Damage"):
			damage_counters = int(counters["Damage"])
	return damage_counters >= min_counters

static func condition_min_delta_champion_level(main_field_node: Node, min_level: int) -> bool:
	if not main_field_node:
		return false
	var champion = main_field_node.get("current_champion_card")
	if not champion or not is_instance_valid(champion) or not champion.has_meta("slug"):
		return false
	var slug = str(champion.get_meta("slug"))
	var level = 0
	var card_info_node = main_field_node.find_card_information_reference() if main_field_node.has_method("find_card_information_reference") else null
	if card_info_node and "card_database_reference" in card_info_node:
		var db_ref = card_info_node.card_database_reference
		if db_ref and db_ref.cards_db.has(slug):
			var data = db_ref.cards_db[slug]
			var base_data = data
			if data.has("edition_id") and not data.has("parent_orientation_slug"):
				if card_info_node.has_method("find_base_card_for_edition"):
					var base_slug = card_info_node.find_base_card_for_edition(data["edition_id"])
					if base_slug and db_ref.cards_db.has(base_slug):
						base_data = db_ref.cards_db[base_slug]
			elif data.has("parent_orientation_slug"):
				var parent_slug = data["parent_orientation_slug"]
				if db_ref.cards_db.has(parent_slug):
					base_data = db_ref.cards_db[parent_slug]
			if base_data.has("level") and base_data["level"] != null:
				level = int(base_data["level"])
	var mods = champion.runtime_modifiers if "runtime_modifiers" in champion else {}
	level += int(mods.get("level", 0))
	return level >= min_level

static func condition_min_original_champion_level(main_field_node: Node, min_level: int) -> bool:
	if not main_field_node:
		return false
	var champion = main_field_node.get("current_champion_card")
	if not champion or not is_instance_valid(champion) or not champion.has_meta("slug"):
		return false
	var slug = str(champion.get_meta("slug"))
	var level = 0
	var card_info_node = main_field_node.find_card_information_reference() if main_field_node.has_method("find_card_information_reference") else null
	if card_info_node and "card_database_reference" in card_info_node:
		var db_ref = card_info_node.card_database_reference
		if db_ref and db_ref.cards_db.has(slug):
			var data = db_ref.cards_db[slug]
			var base_data = data
			if data.has("edition_id") and not data.has("parent_orientation_slug"):
				if card_info_node.has_method("find_base_card_for_edition"):
					var base_slug = card_info_node.find_base_card_for_edition(data["edition_id"])
					if base_slug and db_ref.cards_db.has(base_slug):
						base_data = db_ref.cards_db[base_slug]
			elif data.has("parent_orientation_slug"):
				var parent_slug = data["parent_orientation_slug"]
				if db_ref.cards_db.has(parent_slug):
					base_data = db_ref.cards_db[parent_slug]
			if base_data.has("level") and base_data["level"] != null:
				level = int(base_data["level"])
	return level >= min_level
