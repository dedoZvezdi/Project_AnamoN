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

static func gimmick_apply_chosen_elements(elements_node: Node, chosen_elements: Array, is_opponent: bool = false, _source: Node = null):
	if not elements_node or chosen_elements.is_empty():
		return
	var prefix = "Opponent" if is_opponent else ""
	for element_name in chosen_elements:
		var element_node = elements_node.get_node_or_null(prefix + str(element_name))
		if element_node and element_node.has_method("activate"):
			element_node.activate()

static func gimmick_remove_chosen_elements(elements_node: Node, chosen_elements: Array, is_opponent: bool = false, _source: Node = null):
	if not elements_node or chosen_elements.is_empty():
		return
	var prefix = "Opponent" if is_opponent else ""
	for element_name in chosen_elements:
		var element_node = elements_node.get_node_or_null(prefix + str(element_name))
		if element_node and element_node.has_method("deactivate"):
			element_node.deactivate()

static func gimmick_show_prismatic_selection(card: Node, is_opponent: bool = false, on_confirmed: Callable = Callable()):
	if is_opponent:
		return
	if not card or not is_instance_valid(card):
		return
	var popup_scene = load("res://Scenes/PrismaticSelectionPopup.tscn")
	if popup_scene:
		var popup = popup_scene.instantiate()
		card.get_tree().root.add_child(popup)
		popup.selection_confirmed.connect(func(elements):
			if "chosen_elements" in card:
				card.chosen_elements = elements
			if card.has_method("set_meta"):
				card.set_meta("chosen_elements", elements)
			var root = card.get_tree().current_scene
			var multiplayer_node = root.get_node_or_null("Main") if root else null
			if not multiplayer_node and root and root.name == "Main":
				multiplayer_node = root
			if multiplayer_node and multiplayer_node.has_method("rpc") and "uuid" in card:
				var my_id = multiplayer_node.multiplayer.get_unique_id()
				multiplayer_node.rpc("sync_prismatic_elements", my_id, card.uuid, elements)
			if on_confirmed.is_valid():
				on_confirmed.call(card, elements))

static func gimmick_show_mat_deck_pick(mat_deck_node: Node, pickables: Array, on_picked: Callable = Callable()):
	if pickables.is_empty():
		return
	if not mat_deck_node or not is_instance_valid(mat_deck_node):
		return
	var overlay_scene = load("res://Scenes/SacramentalPickOverlay.tscn")
	if not overlay_scene:
		return
	var overlay = overlay_scene.instantiate()
	mat_deck_node.get_tree().root.add_child(overlay)
	overlay.setup(pickables)
	overlay.picked.connect(func(slug, uuid):
		if on_picked.is_valid():
			on_picked.call(mat_deck_node, slug, uuid))

static func gimmick_show_choice_panel(card: Node, title_text: String, message_text: String, buttons: Array, on_chosen: Callable = Callable()):
	if not card or not is_instance_valid(card):
		return
	if buttons.is_empty():
		return
	var dialog_scene = load("res://Scenes/ChoiceDialog.tscn")
	if not dialog_scene:
		return
	var dialog = dialog_scene.instantiate()
	card.get_tree().root.add_child(dialog)
	dialog.setup(title_text, message_text, buttons)
	dialog.chosen.connect(func(index):
		if on_chosen.is_valid():
			on_chosen.call(index))

static func gimmick_finish_rite_activation(card: Node, main_field_node: Node, rite_type: String) -> void:
	if not card or not is_instance_valid(card):
		return
	var root = card.get_tree().current_scene
	gimmick_apply_ascendant(main_field_node, root, rite_type, false)
	gimmick_send_to_banish_face_up(card)

static func gimmick_spawn_play_proxy(host_card: Node, banished: Dictionary) -> void:
	if not host_card or not is_instance_valid(host_card):
		return
	var tree = host_card.get_tree()
	var scene = tree.current_scene
	if not scene:
		return
	var card_manager = scene.find_child("CardManager", true, false)
	if not card_manager:
		return
	var proxy = load("res://Scenes/Card.tscn").instantiate()
	proxy.set_meta("slug", str(banished.get("slug", "")))
	proxy.uuid = str(banished.get("uuid", ""))
	proxy.set_meta("play_proxy", true)
	var center = Vector2(tree.root.size) * 0.5
	proxy.set_meta("play_proxy_home", center)
	var card_image_path = "res://Assets/Grand Archive/Card Images/" + str(banished.get("slug", "")) + ".png"
	if ResourceLoader.exists(card_image_path):
		var card_image = proxy.get_node("CardImage")
		var card_image_back = proxy.get_node("CardImageBack")
		card_image.texture = load(card_image_path)
		card_image.visible = true
		card_image_back.visible = false
		card_image.z_index = 0
	card_manager.add_child(proxy)
	proxy.add_to_group("cards")
	if card_manager.has_method("connect_card_signals"):
		card_manager.connect_card_signals(proxy)
	proxy.global_position = center
	proxy.z_index = 1000
	proxy.scale = Vector2(0.35, 0.35)

static func gimmick_enter_pick_from_mat_deck(card: Node, main_field_node: Node, on_picked: Callable = Callable()) -> void:
	if not condition_on_main_field_enter(card, main_field_node):
		return
	var mat_deck = condition_find_mat_deck(card)
	if not mat_deck:
		return
	var pickables = condition_mat_deck_has_pickable(mat_deck)
	if pickables.is_empty():
		return
	gimmick_show_mat_deck_pick(mat_deck, pickables, on_picked)

static func gimmick_banish_mat_pick(mat_deck: Node, slug: String, uuid: String, card: Node) -> void:
	if not card or not is_instance_valid(card):
		return
	card.set_meta("stored_pick_slug", slug)
	card.set_meta("stored_pick_uuid", uuid)
	if not mat_deck or not is_instance_valid(mat_deck):
		return
	if mat_deck.has_method("banish_card_fd"):
		mat_deck.banish_card_fd(uuid)

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

static func gimmick_draw_card(root: Node, count: int = 1, interval: float = 0.0):
	if not root:
		return
	var deck = root.find_child("GA_DECK", true, false)
	if not deck or not deck.has_method("draw_clicked"):
		return
	var total = maxi(1, count)
	for i in range(total):
		if not is_instance_valid(deck):
			return
		deck.draw_clicked()
		if interval > 0.0 and i < total - 1:
			var tree = deck.get_tree()
			if tree:
				await tree.create_timer(interval).timeout

static func gimmick_send_to_banish_face_up(card: Node):
	if card and is_instance_valid(card) and card.has_method("go_to_banish_face_up"):
		card.go_to_banish_face_up()

static func gimmick_until_end_of_turn(main_field_node: Node, mechanic_name: String):
	if not main_field_node:
		return
	var count_var = mechanic_name + "_turn_count"
	if count_var in main_field_node:
		main_field_node.set(count_var, main_field_node.get(count_var) + 1)

static func gimmick_reveal_random_cards(from_node: Node, zone: String, count: int, duration: float) -> Array:
	var result = []
	var zone_node = _find_zone_node(from_node, zone)
	if not zone_node or count <= 0:
		return result
	var pool = []
	for card in _get_zone_cards(zone_node):
		if card and is_instance_valid(card):
			pool.append(card)
	if pool.is_empty():
		return result
	pool.shuffle()
	var pick_count = mini(count, pool.size())
	var tree = zone_node.get_tree()
	for i in range(pick_count):
		var chosen = pool[i]
		if not chosen or not is_instance_valid(chosen):
			continue
		if chosen.has_method("reveal_to_opponent"):
			chosen.reveal_to_opponent()
		if tree and duration > 0.0:
			await tree.create_timer(duration).timeout
		if chosen and is_instance_valid(chosen) and chosen.has_method("hide_from_opponent"):
			chosen.hide_from_opponent()
			await tree.create_timer(0.2).timeout
		if chosen and is_instance_valid(chosen):
			result.append(chosen)
	return result

static func gimmick_sacrifice_to_graveyard(card: Node, delay: float = 0.0):
	if delay > 0.0 and card and is_instance_valid(card):
		var tree = card.get_tree()
		if tree:
			await tree.create_timer(delay).timeout
	if card and is_instance_valid(card) and card.has_method("go_to_graveyard"):
		card.go_to_graveyard()

static func gimmick_bind_phase(card: Node, phase_name: String, callback: Callable, is_opponent: bool = false):
	if is_opponent or not card or not is_instance_valid(card) or callback.is_null():
		return
	var phase_key = phase_name.to_upper()
	var binds = card.get_meta("gimmick_phase_binds") if card.has_meta("gimmick_phase_binds") else []
	for bind in binds:
		if str(bind.get("phase", "")).to_upper() == phase_key:
			return
	binds.append({"phase": phase_key, "callback": callback})
	card.set_meta("gimmick_phase_binds", binds)
	if card.has_meta("gimmick_phase_dispatcher"):
		return
	var phases = _find_phases(card)
	if not phases or not phases.has_signal("phase_advanced"):
		return
	var dispatcher = func(advanced_phase: String):
		_dispatch_phase_binds(card, advanced_phase)
	phases.phase_advanced.connect(dispatcher)
	card.set_meta("gimmick_phase_dispatcher", dispatcher)

static func gimmick_unbind_phase(card: Node):
	if not card or not is_instance_valid(card):
		return
	var phases = _find_phases(card)
	if card.has_meta("gimmick_phase_dispatcher"):
		var dispatcher = card.get_meta("gimmick_phase_dispatcher")
		if phases and dispatcher is Callable and phases.phase_advanced.is_connected(dispatcher):
			phases.phase_advanced.disconnect(dispatcher)
		card.remove_meta("gimmick_phase_dispatcher")
	if card.has_meta("gimmick_phase_binds"):
		card.remove_meta("gimmick_phase_binds")

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

static func condition_on_main_field_enter(card: Node, main_field_node: Node) -> bool:
	if not card or not is_instance_valid(card) or not main_field_node:
		return false
	if not card.has_meta("just_entered_main_field") or not card.get_meta("just_entered_main_field"):
		return false
	card.remove_meta("just_entered_main_field")
	var cards_in_field = main_field_node.get("cards_in_field")
	if typeof(cards_in_field) == TYPE_ARRAY:
		return card in cards_in_field
	return false

static func condition_inherited_prismatic_spirit(champion_card: Node) -> Array:
	if not champion_card or not is_instance_valid(champion_card):
		return []
	var lineage = []
	if "champion_lineage" in champion_card:
		lineage = champion_card.champion_lineage
	if typeof(lineage) != TYPE_ARRAY:
		return []
	for entry in lineage:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		if not str(entry.get("slug", "")).contains("prismatic-spirit"):
			continue
		var chosen = entry.get("chosen_elements", [])
		if typeof(chosen) == TYPE_ARRAY and chosen.size() == 2:
			return chosen.duplicate()
	return []

static func condition_is_my_turn(from_node: Node) -> bool:
	var multiplayer_node = _find_main(from_node)
	if not multiplayer_node:
		return false
	return multiplayer_node.get("is_my_turn") == true

static func condition_phase_is(from_node: Node, phase_name: String) -> bool:
	var phases = _find_phases(from_node)
	if not phases:
		return false
	var order = phases.get("PHASE_ORDER")
	var index = phases.get("current_phase_index")
	if typeof(order) != TYPE_ARRAY or index == null:
		return false
	if int(index) < 0 or int(index) >= order.size():
		return false
	return str(order[index]).to_upper() == phase_name.to_upper()

static func condition_find_mat_deck(from_node: Node) -> Node:
	if not from_node or not is_instance_valid(from_node):
		return null
	var tree = from_node.get_tree()
	if not tree:
		return null
	for deck_node in tree.get_nodes_in_group("mat_deck_zones"):
		if deck_node and is_instance_valid(deck_node):
			return deck_node
	return null

static func condition_mat_deck_has_pickable(mat_deck_node: Node) -> Array:
	var result = []
	if not mat_deck_node or not is_instance_valid(mat_deck_node):
		return result
	if not ("player_deck" in mat_deck_node):
		return result
	var card_info = null
	var tree = mat_deck_node.get_tree()
	if tree and tree.current_scene:
		card_info = tree.current_scene.find_child("CardInformation", true, false)
	for entry in mat_deck_node.player_deck:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var slug = str(entry.get("slug", ""))
		var uuid = str(entry.get("uuid", ""))
		if slug == "" or uuid == "":
			continue
		var is_champion = true
		if card_info and card_info.has_method("is_card_of_type"):
			is_champion = card_info.is_card_of_type(slug, "CHAMPION")
		if not is_champion:
			result.append({"slug": slug, "uuid": uuid})
	return result

static func condition_zone_min_cards(from_node: Node, zone: String, min_count: int) -> bool:
	if min_count <= 0:
		return true
	var valid = 0
	for card in _get_zone_cards(_find_zone_node(from_node, zone)):
		if card and is_instance_valid(card):
			valid += 1
	return valid >= min_count

static func condition_card_is_basic_element(card: Node) -> bool:
	if not card or not is_instance_valid(card) or not card.has_meta("slug"):
		return false
	var slug = str(card.get_meta("slug"))
	if slug == "":
		return false
	var tree = card.get_tree()
	if not tree or not tree.current_scene:
		return false
	var card_info = tree.current_scene.find_child("CardInformation", true, false)
	if not card_info or not card_info.has_method("get_card_element"):
		return false
	var element_name = str(card_info.get_card_element(slug)).to_lower()
	for basic in BASIC_ELEMENTS:
		if element_name == str(basic).to_lower():
			return true
	return false

static func condition_cards_are_basic_element(cards: Array) -> bool:
	if cards.is_empty():
		return true
	for card in cards:
		if not condition_card_is_basic_element(card):
			return false
	return true

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

# ==========================================
# HELPERS (Internal)
# ==========================================

static func _dispatch_phase_binds(card: Node, advanced_phase: String):
	if not card or not is_instance_valid(card) or not card.has_meta("gimmick_phase_binds"):
		return
	var phase_key = advanced_phase.to_upper()
	for bind in card.get_meta("gimmick_phase_binds"):
		if str(bind.get("phase", "")).to_upper() != phase_key:
			continue
		var callback = bind.get("callback")
		if callback is Callable and not callback.is_null():
			callback.call()

static func _get_zone_cards(zone_node: Node) -> Array:
	if not zone_node:
		return []
	if "cards_in_slot" in zone_node and typeof(zone_node.cards_in_slot) == TYPE_ARRAY:
		return zone_node.cards_in_slot
	if "player_hand" in zone_node and typeof(zone_node.player_hand) == TYPE_ARRAY:
		return zone_node.player_hand
	return []

static func _find_zone_node(from_node: Node, zone: String) -> Node:
	var scene = _scene_of(from_node)
	if not scene:
		return null
	var key = zone.strip_edges().to_lower()
	if key == "memory":
		return scene.find_child("MEMORY", true, false)
	if key == "hand":
		return scene.find_child("PlayerHand", true, false)
	return scene.find_child(zone, true, false)

static func _find_phases(from_node: Node) -> Node:
	var scene = _scene_of(from_node)
	if not scene:
		return null
	return scene.find_child("Phases", true, false)

static func _find_main(from_node: Node) -> Node:
	if not from_node:
		return null
	if from_node.name == "Main":
		return from_node
	var tree = from_node.get_tree()
	if tree:
		return tree.get_root().get_node_or_null("Main")
	return from_node.get_node_or_null("Main")

static func _scene_of(from_node: Node) -> Node:
	if not from_node:
		return null
	var tree = from_node.get_tree()
	if tree:
		return tree.current_scene
	return null
	
static func find_stored_card(card: Node, zone_node: Node) -> Dictionary:
	if not card or not is_instance_valid(card):
		return {}
	if not zone_node or not is_instance_valid(zone_node):
		return {}
	if not card.has_meta("stored_pick_uuid"):
		return {}
	var uuid = str(card.get_meta("stored_pick_uuid"))
	var slug = str(card.get_meta("stored_pick_slug")) if card.has_meta("stored_pick_slug") else ""
	if uuid == "" or slug == "":
		return {}
	for array_name in ["cards_in_banish", "cards_in_slot", "cards_in_graveyard", "cards_in_field", "player_hand", "opponent_hand"]:
		if not (array_name in zone_node):
			continue
		var pool = zone_node.get(array_name)
		if typeof(pool) != TYPE_ARRAY:
			continue
		for cards in pool:
			if cards and is_instance_valid(cards) and "uuid" in cards and cards.uuid == uuid:
				return {"slug": slug, "uuid": uuid, "node": cards}
	return {}
	
static func find_banish_node(from_node: Node) -> Node:
	if not from_node or not is_instance_valid(from_node):
		return null
	var tree = from_node.get_tree()
	if not tree or not tree.current_scene:
		return null
	return tree.current_scene.find_child("BANISH", true, false)
