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
		if not card.tree_exited.is_connected(popup.queue_free):
			card.tree_exited.connect(popup.queue_free)
		popup.selection_confirmed.connect(func(elements):
			if not is_instance_valid(card):
				return
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
	if not card.tree_exited.is_connected(dialog.queue_free):
		card.tree_exited.connect(dialog.queue_free)
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
	var mat_deck = find_mat_deck(card)
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

static func gimmick_apply_aura_mods(card: Node, current_mods: Dictionary, aura_local: bool, aura_opp: bool, rules: Array) -> Dictionary:
	var new_mods = current_mods.duplicate()
	if (not aura_local and not aura_opp) or rules.is_empty():
		return new_mods
	if not card or not is_instance_valid(card):
		return new_mods
	var is_local = condition_card_is_local(card)
	for rule in rules:
		if typeof(rule) != TYPE_DICTIONARY:
			continue
		var types = rule.get("types", [])
		if typeof(types) == TYPE_STRING:
			types = [types]
		if typeof(types) != TYPE_ARRAY or types.is_empty():
			continue
		var matched = false
		for type in types:
			if condition_card_type_contains(card, str(type)):
				matched = true
				break
		if not matched:
			continue
		var applies = false
		match str(rule.get("side", "any")).to_lower():
			"enemy":
				applies = (aura_local and not is_local) or (aura_opp and is_local)
			"ally":
				applies = (aura_local and is_local) or (aura_opp and not is_local)
			_:
				applies = aura_local or aura_opp
		if not applies:
			continue
		var stat = str(rule.get("stat", ""))
		if stat == "":
			continue
		new_mods[stat] = new_mods.get(stat, 0) + int(rule.get("amount", 0))
	return new_mods

static func gimmick_carry_stored_pick(source_card: Node, target_card: Node) -> void:
	if not source_card or not is_instance_valid(source_card):
		return
	if not target_card or not is_instance_valid(target_card):
		return
	if source_card.has_meta("stored_pick_slug"):
		target_card.set_meta("stored_pick_slug", str(source_card.get_meta("stored_pick_slug")))
	if source_card.has_meta("stored_pick_uuid"):
		target_card.set_meta("stored_pick_uuid", str(source_card.get_meta("stored_pick_uuid")))

static func gimmick_apply_ascendant(main_field_node: Node, root: Node, rite_type: String, is_opponent: bool = false):
	if not main_field_node:
		return
	var flag_name = ""
	if rite_type == "apotheosis" and "apotheosis_rite_active" in main_field_node:
		main_field_node.apotheosis_rite_active = true
		flag_name = "apotheosis_rite_active"
	elif rite_type == "transcendental" and "transcendental_rite_active" in main_field_node:
		main_field_node.transcendental_rite_active = true
		flag_name = "transcendental_rite_active"
	elif rite_type == "sacramental" and "sacramental_rite_active" in main_field_node:
		main_field_node.sacramental_rite_active = true
		flag_name = "sacramental_rite_active"
	if flag_name != "":
		gimmick_register_reset_flag(main_field_node, flag_name)
	if not is_opponent and root:
		var multiplayer_node = root.get_node_or_null("Main")
		if not multiplayer_node and root.name == "Main":
			multiplayer_node = root
		if multiplayer_node and multiplayer_node.has_method("rpc"):
			var my_id = multiplayer_node.multiplayer.get_unique_id()
			var rpc_name = "sync_" + rite_type + "_rite_activate"
			multiplayer_node.rpc(rpc_name, my_id)

static func gimmick_clear_ascendant(main_field_node: Node, root: Node, is_opponent: bool = false):
	if main_field_node:
		if "apotheosis_rite_active" in main_field_node:
			main_field_node.apotheosis_rite_active = false
		if "sacramental_rite_active" in main_field_node:
			main_field_node.sacramental_rite_active = false
		if "transcendental_rite_active" in main_field_node:
			main_field_node.transcendental_rite_active = false
		if main_field_node.has_meta("gimmick_reset_flags"):
			var flags = main_field_node.get_meta("gimmick_reset_flags")
			if typeof(flags) == TYPE_ARRAY:
				var kept = []
				for f in flags:
					var fname = str(f)
					if fname != "apotheosis_rite_active" and fname != "sacramental_rite_active" and fname != "transcendental_rite_active":
						kept.append(f)
				if kept.is_empty():
					main_field_node.remove_meta("gimmick_reset_flags")
				else:
					main_field_node.set_meta("gimmick_reset_flags", kept)
	if not is_opponent and root:
		var multiplayer_node = root.get_node_or_null("Main")
		if not multiplayer_node and root.name == "Main":
			multiplayer_node = root
		if multiplayer_node and multiplayer_node.has_method("rpc"):
			var my_id = multiplayer_node.multiplayer.get_unique_id()
			multiplayer_node.rpc("sync_ascendant_clear", my_id)

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

static func gimmick_register_reset_flag(main_field_node: Node, flag_name: String) -> void:
	if not main_field_node or not is_instance_valid(main_field_node) or flag_name == "":
		return
	var flags = []
	if main_field_node.has_meta("gimmick_reset_flags"):
		flags = main_field_node.get_meta("gimmick_reset_flags")
	if typeof(flags) != TYPE_ARRAY:
		flags = []
	if not (flag_name in flags):
		flags.append(flag_name)
	main_field_node.set_meta("gimmick_reset_flags", flags)

static func gimmick_clear_champion_from_field(champion: Node, main_field_node: Node) -> void:
	if not main_field_node:
		return
	if champion and is_instance_valid(champion) and main_field_node.has_method("deactivate_card_elements"):
		main_field_node.deactivate_card_elements(champion)
	var cards = main_field_node.get("cards_in_field")
	if typeof(cards) == TYPE_ARRAY and champion in cards:
		cards.erase(champion)
	if main_field_node.get("current_champion_card") == champion:
		main_field_node.current_champion_card = null
		if main_field_node.has_meta("gimmick_reset_flags"):
			var flags = main_field_node.get_meta("gimmick_reset_flags")
			if typeof(flags) == TYPE_ARRAY:
				for flag_name in flags:
					var fname = str(flag_name)
					if fname != "" and fname in main_field_node:
						main_field_node.set(fname, false)
			main_field_node.remove_meta("gimmick_reset_flags")

static func gimmick_sacrifice_champion(champion: Node, main_field_node: Node, banish_slot: Node, unique_id: int, multiplayer_node: Node) -> void:
	if not champion or not is_instance_valid(champion):
		return
	var card_uuid = str(champion.uuid) if "uuid" in champion else ""
	var card_slug = str(champion.get_meta("slug")) if champion.has_meta("slug") else ""
	if multiplayer_node and multiplayer_node.has_method("rpc"):
		multiplayer_node.rpc("sync_move_to_banish", unique_id, card_uuid, card_slug, false, false)
	if not banish_slot:
		return
	gimmick_clear_champion_from_field(champion, main_field_node)
	await _tween_card_to_zone(champion, banish_slot)
	if is_instance_valid(champion) and banish_slot.has_method("add_card_to_slot"):
		banish_slot.add_card_to_slot(champion, false, -1, true)

static func gimmick_destroy_token_animated(card: Node, main_field_node: Node, unique_id: int, multiplayer_node: Node, duration: float = 0.3) -> void:
	if not card or not is_instance_valid(card):
		return
	var slug = str(card.get_meta("slug")) if card.has_meta("slug") else ""
	var uuid = str(card.uuid) if "uuid" in card else ""
	var tree = card.get_tree()
	if tree:
		var tween = tree.create_tween()
		tween.tween_property(card, "modulate", Color(1, 1, 1, 0), duration)
		await tween.finished
	if multiplayer_node and multiplayer_node.has_method("rpc") and uuid != "":
		multiplayer_node.rpc("sync_destroy_token", unique_id, uuid, slug)
	if main_field_node and main_field_node.has_method("remove_card_from_field"):
		main_field_node.remove_card_from_field(card)
	if is_instance_valid(card):
		card.queue_free()

static func gimmick_spawn_card_visual(parent_node: Node, slug: String, uuid: String) -> Node:
	if not parent_node or not is_instance_valid(parent_node):
		return null
	var card_scene = load("res://Scenes/Card.tscn")
	if not card_scene:
		return null
	var fresh = card_scene.instantiate()
	parent_node.add_child(fresh)
	fresh.set_meta("slug", slug)
	if uuid != "":
		fresh.uuid = uuid
	var image_path = "res://Assets/Grand Archive/Card Images/" + slug + ".png"
	if ResourceLoader.exists(image_path):
		var card_image = fresh.get_node_or_null("CardImage")
		var card_image_back = fresh.get_node_or_null("CardImageBack")
		if card_image:
			card_image.texture = load(image_path)
			card_image.visible = true
			if card_image_back:
				card_image_back.visible = false
			card_image.z_index = 0
	return fresh

static func gimmick_sum_ally_stats(cards: Array) -> int:
	var total = 0
	for card in cards:
		if not card or not is_instance_valid(card):
			continue
		if not condition_card_type_contains(card, "ALLY"):
			continue
		if card.has_method("get_effective_stats"):
			var stats = card.get_effective_stats()
			total += stats.get("power", 0) + stats.get("life", 0)
	return total

static func gimmick_destroy_objects(cards: Array, main_field_node: Node, banish_slot: Node, graveyard_slot: Node, db_ref, card_info_node: Node, unique_id: int, multiplayer_node: Node) -> void:
	if not main_field_node:
		return
	var tree = main_field_node.get_tree()
	if not tree:
		return
	for card in cards:
		if not is_instance_valid(card):
			continue
		var card_slug = str(card.get_meta("slug")) if card.has_meta("slug") else ""
		var uuid = str(card.uuid) if "uuid" in card else ""
		var goes_to_banish = condition_card_has_memory_cost(db_ref, card_slug, card_info_node)
		if card.has_method("is_token") and card.is_token():
			await gimmick_destroy_token_animated(card, main_field_node, unique_id, multiplayer_node)
		else:
			var target_slot = banish_slot if goes_to_banish else graveyard_slot
			if target_slot:
				await _tween_card_to_zone(card, target_slot)
				if not is_instance_valid(card):
					continue
				if main_field_node.has_method("remove_card_from_field"):
					main_field_node.remove_card_from_field(card)
				if goes_to_banish:
					if target_slot.has_method("add_card_to_slot"):
						target_slot.add_card_to_slot(card, false, -1, true)
					if multiplayer_node and multiplayer_node.has_method("rpc"):
						multiplayer_node.rpc("sync_move_to_banish", unique_id, uuid, card_slug, false, false)
				else:
					if target_slot.has_method("add_card_to_slot"):
						target_slot.add_card_to_slot(card)
					if multiplayer_node and multiplayer_node.has_method("rpc"):
						multiplayer_node.rpc("sync_move_to_graveyard", unique_id, uuid, card_slug, false)
			else:
				await tree.create_timer(0.3).timeout

static func gimmick_refresh_all_cards_visuals(multiplayer_node: Node) -> void:
	if not multiplayer_node:
		return
	var player_field = multiplayer_node.get_node_or_null("PlayerField")
	if player_field:
		var main_field = player_field.get_node_or_null("MAINFIELD")
		if main_field:
			var cards = main_field.get("cards_in_field")
			if typeof(cards) == TYPE_ARRAY:
				for card in cards:
					if is_instance_valid(card) and card.has_method("show_card_info"):
						card.show_card_info()
	var opp_field = multiplayer_node.get_node_or_null("OpponentField")
	if opp_field:
		var opp_main_field = opp_field.get_node_or_null("OpponentMainField")
		if opp_main_field:
			var cards = opp_main_field.get("cards_in_field")
			if typeof(cards) == TYPE_ARRAY:
				for card in cards:
					if is_instance_valid(card) and card.has_method("show_card_info"):
						card.show_card_info()

static func gimmick_extract_lineage(champion: Node) -> Array:
	if not champion or not is_instance_valid(champion):
		return []
	if not ("champion_lineage" in champion):
		return []
	var lineage = champion.champion_lineage
	if typeof(lineage) != TYPE_ARRAY:
		return []
	var copy = lineage.duplicate(true)
	lineage.clear()
	return copy

static func gimmick_parade_lineage_to_banish(main_field_node: Node, lineage_entries: Array, pos: Vector2, banish_slot: Node, unique_id: int, multiplayer_node: Node) -> void:
	if not main_field_node or not is_instance_valid(main_field_node):
		return
	var tree = main_field_node.get_tree()
	if not tree:
		return
	while lineage_entries.size() > 0:
		var entry = lineage_entries.pop_back()
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var pre_slug = entry.get("slug", "")
		var pre_uuid = entry.get("uuid", "")
		var temp_champ = gimmick_spawn_card_visual(main_field_node, pre_slug, pre_uuid)
		if temp_champ == null:
			continue
		temp_champ.set_meta("lineage_replay_temp", true)
		temp_champ.global_position = pos
		if main_field_node.has_method("add_card_to_field"):
			main_field_node.add_card_to_field(temp_champ, pos)
		if multiplayer_node and multiplayer_node.has_method("rpc"):
			multiplayer_node.rpc("sync_move_to_main_field", unique_id, pre_uuid, pre_slug, pos, 0.0, false, false)
		await tree.create_timer(0.3).timeout
		await gimmick_sacrifice_champion(temp_champ, main_field_node, banish_slot, unique_id, multiplayer_node)

static func gimmick_deal_damage(multiplayer_node: Node, unique_id: int, target: Node, amount: int) -> void:
	if amount == 0:
		return
	if not target or not is_instance_valid(target):
		return
	if target.has_method("add_damage_counters"):
		target.add_damage_counters(amount)
		return
	if condition_card_is_local(target):
		return
	var uuid = str(target.uuid) if "uuid" in target else ""
	if uuid == "":
		return
	if not multiplayer_node or not multiplayer_node.has_method("rpc"):
		return
	if target.has_method("is_champion_card") and target.is_champion_card():
		multiplayer_node.rpc("sync_apply_damage_to_champion", unique_id, amount)
	else:
		multiplayer_node.rpc("sync_apply_damage_to_card", unique_id, uuid, amount)

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

static func condition_card_slug_contains(card: Node, slug_fragment: String) -> bool:
	if not card or not is_instance_valid(card) or not card.has_meta("slug"):
		return false
	return _normalize_slug(str(card.get_meta("slug"))).contains(_normalize_slug(slug_fragment))

static func condition_card_exact_damage_counters(card: Node, count: int) -> bool:
	if not card or not is_instance_valid(card):
		return false
	if not ("attached_counters" in card):
		return false
	var counters = card.attached_counters
	if typeof(counters) != TYPE_DICTIONARY or not counters.has("Damage"):
		return false
	return int(counters["Damage"]) == count

static func condition_card_has_memory_cost(db_ref, slug: String, card_info_node: Node = null) -> bool:
	if not db_ref or slug == "":
		return false
	var base_data = find_base_card_data(db_ref, slug, card_info_node)
	if base_data.is_empty():
		return false
	return base_data.has("cost_memory") and base_data["cost_memory"] != null

static func condition_card_type_contains(card: Node, type_fragment: String) -> bool:
	if not card or not is_instance_valid(card):
		return false
	var slug = str(card.get_meta("slug")) if card.has_meta("slug") else ""
	if slug == "":
		return false
	var tree = card.get_tree()
	if not tree or not tree.current_scene:
		return false
	var card_info = tree.current_scene.find_child("CardInformation", true, false)
	if not card_info or not ("card_database_reference" in card_info):
		return false
	var db_ref = card_info.card_database_reference
	if not db_ref:
		return false
	var base_data = find_base_card_data(db_ref, slug, card_info)
	if base_data.is_empty() or not base_data.has("types"):
		return false
	if typeof(base_data["types"]) != TYPE_ARRAY:
		return false
	var fragmet = _normalize_slug(type_fragment)
	for type in base_data["types"]:
		if _normalize_slug(str(type)).contains(fragmet):
			return true
	return false

static func condition_champion_name_contains(main_field_node: Node, name_fragment: String) -> bool:
	if not main_field_node:
		return false
	var champion = main_field_node.get("current_champion_card")
	if not champion or not is_instance_valid(champion) or not champion.has_meta("slug"):
		return false
	var slug = str(champion.get_meta("slug"))
	var fragmet = _normalize_slug(name_fragment)
	if _normalize_slug(slug).contains(fragmet):
		return true
	var tree = champion.get_tree()
	if tree and tree.current_scene:
		var card_info = tree.current_scene.find_child("CardInformation", true, false)
		if card_info and ("card_database_reference" in card_info):
			var db_ref = card_info.card_database_reference
			if db_ref and db_ref.cards_db.has(slug) and db_ref.cards_db[slug].has("name"):
				if _normalize_slug(str(db_ref.cards_db[slug]["name"])).contains(fragmet):
					return true
	return false

static func condition_card_is_dead(card: Node) -> bool:
	if not card or not is_instance_valid(card):
		return false
	if not card.has_method("get_effective_stats"):
		return false
	var stats = card.get_effective_stats()
	if typeof(stats) != TYPE_DICTIONARY or not stats.has("life"):
		return false
	return int(stats["life"]) <= 0

static func condition_card_is_local(card: Node) -> bool:
	if not card or not is_instance_valid(card):
		return true
	var script_path = ""
	if card.get_script():
		script_path = card.get_script().resource_path
	if "Opponent" in script_path or "Opponent" in card.name:
		return false
	var parent = card.get_parent()
	while parent:
		if "Opponent" in parent.name:
			return false
		parent = parent.get_parent()
	return true

static func condition_is_given(card: Node) -> bool:
	if not card or not is_instance_valid(card):
		return false
	return card.has_meta("is_given") and bool(card.get_meta("is_given"))

static func condition_is_lineage_replay(card: Node) -> bool:
	if not card or not is_instance_valid(card):
		return false
	return card.has_meta("lineage_replay_temp") and bool(card.get_meta("lineage_replay_temp"))

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

static func _scene_of(from_node: Node) -> Node:
	if not from_node:
		return null
	var tree = from_node.get_tree()
	if tree:
		return tree.current_scene
	return null

static func _normalize_slug(s: String) -> String:
	return str(s).to_lower().replace("-", "").replace("_", "").replace(" ", "")

static func _tween_card_to_zone(card: Node, zone_node: Node, duration: float = 0.5) -> void:
	if not card or not is_instance_valid(card) or not zone_node:
		return
	var target_pos = zone_node.global_position
	if zone_node.has_node("Area2D/CollisionShape2D"):
		target_pos = zone_node.get_node("Area2D/CollisionShape2D").global_position
	var target_rot = 90.0 if str(zone_node.name) == "BANISH" else 0.0
	var tree = card.get_tree()
	if not tree:
		return
	if card.has_method("set_tweening"):
		card.set_tweening(true)
	card.z_index = 1000
	var tween = tree.create_tween()
	tween.set_parallel(true)
	tween.tween_property(card, "global_position", target_pos, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "rotation_degrees", target_rot, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween.finished

# ==========================================
# FINDERS
# ==========================================

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

static func _find_base_slug_by_edition_id(db_ref, edition_id) -> String:
	if not db_ref or edition_id == null:
		return ""
	for key in db_ref.cards_db:
		var cd = db_ref.cards_db[key]
		if typeof(cd) == TYPE_DICTIONARY and cd.has("editions"):
			for ed in cd["editions"]:
				if typeof(ed) == TYPE_DICTIONARY and ed.get("edition_id") == edition_id:
					return key
	return ""

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

static func find_banish_node(from_node: Node) -> Node:
	if not from_node or not is_instance_valid(from_node):
		return null
	var tree = from_node.get_tree()
	if not tree or not tree.current_scene:
		return null
	return tree.current_scene.find_child("BANISH", true, false)

static func find_graveyard_node(from_node: Node) -> Node:
	if not from_node or not is_instance_valid(from_node):
		return null
	var tree = from_node.get_tree()
	if not tree:
		return null
	for slot in tree.get_nodes_in_group("single_card_slots"):
		if slot and is_instance_valid(slot) and str(slot.name) == "GRAVEYARD":
			return slot
	return null

static func find_field_card_by_slug(main_field_node: Node, slug_fragment: String) -> Node:
	if not main_field_node:
		return null
	var cards = main_field_node.get("cards_in_field")
	if typeof(cards) != TYPE_ARRAY:
		return null
	var fragmet = _normalize_slug(slug_fragment)
	for card in cards:
		if card and is_instance_valid(card) and card.has_meta("slug"):
			if _normalize_slug(str(card.get_meta("slug"))).contains(fragmet):
				return card
	return null

static func find_base_card_data(db_ref, slug: String, card_info_node: Node = null) -> Dictionary:
	if not db_ref or slug == "":
		return {}
	if not db_ref.cards_db.has(slug):
		return {}
	var data = db_ref.cards_db[slug]
	var base_data = data
	var base_slug = ""
	if data.has("edition_id") and not data.has("parent_orientation_slug"):
		if card_info_node and card_info_node.has_method("find_base_card_for_edition"):
			base_slug = card_info_node.find_base_card_for_edition(data["edition_id"])
		else:
			base_slug = _find_base_slug_by_edition_id(db_ref, data.get("edition_id"))
	elif data.has("parent_orientation_slug"):
		var parent_slug = data["parent_orientation_slug"]
		if db_ref.cards_db.has(parent_slug):
			base_data = db_ref.cards_db[parent_slug]
	if base_slug != "" and db_ref.cards_db.has(base_slug):
		base_data = db_ref.cards_db[base_slug]
	return base_data

static func find_multiplayer_unique_id(from_node: Node) -> int:
	var main = _find_main(from_node)
	if main and main.multiplayer:
		return main.multiplayer.get_unique_id()
	return 1

static func find_multiplayer_node(from_node: Node) -> Node:
	var tree = null
	if from_node and is_instance_valid(from_node):
		tree = from_node.get_tree()
	if not tree:
		tree = Engine.get_main_loop()
	if not tree:
		return null
	var multiplayer_node = tree.get_root().get_node_or_null("Main")
	if not multiplayer_node:
		var root = tree.current_scene
		multiplayer_node = root if root and root.name == "Main" else null
	return multiplayer_node

static func find_both_main_fields(multiplayer_node: Node) -> Array:
	var result = [null, null]
	if not multiplayer_node or not is_instance_valid(multiplayer_node):
		return result
	var player_field = multiplayer_node.get_node_or_null("PlayerField")
	if player_field:
		result[0] = player_field.get_node_or_null("MAINFIELD")
	var opp_field = multiplayer_node.get_node_or_null("OpponentField")
	if opp_field:
		result[1] = opp_field.get_node_or_null("OpponentMainField")
	return result

static func find_effect_context(from_node: Node) -> Dictionary:
	var ctx = {"tree": null, "root": null, "multiplayer_node": null, "unique_id": 1, "card_info_node": null, "db_ref": null, "banish_slot": null, "graveyard_slot": null}
	if not from_node or not is_instance_valid(from_node):
		return ctx
	var tree = from_node.get_tree()
	if not tree:
		return ctx
	ctx["tree"] = tree
	var root = tree.current_scene
	ctx["root"] = root
	var multiplayer_node = tree.get_root().get_node_or_null("Main")
	if not multiplayer_node:
		multiplayer_node = root if root and root.name == "Main" else null
	ctx["multiplayer_node"] = multiplayer_node
	if multiplayer_node and multiplayer_node.multiplayer:
		ctx["unique_id"] = multiplayer_node.multiplayer.get_unique_id()
	if from_node.has_method("find_card_information_reference"):
		var card_info_node = from_node.find_card_information_reference()
		ctx["card_info_node"] = card_info_node
		if card_info_node and "card_database_reference" in card_info_node:
			ctx["db_ref"] = card_info_node.card_database_reference
	ctx["banish_slot"] = find_banish_node(from_node)
	ctx["graveyard_slot"] = find_graveyard_node(from_node)
	return ctx

static func find_mat_deck(from_node: Node) -> Node:
	if not from_node or not is_instance_valid(from_node):
		return null
	var tree = from_node.get_tree()
	if not tree:
		return null
	for deck_node in tree.get_nodes_in_group("mat_deck_zones"):
		if deck_node and is_instance_valid(deck_node):
			return deck_node
	return null

static func find_field_objects(main_field_node: Node, skip_cards: Array = []) -> Array:
	var result = []
	if not main_field_node:
		return result
	var cards_in_field = main_field_node.get("cards_in_field")
	if typeof(cards_in_field) != TYPE_ARRAY:
		return result
	for card in cards_in_field:
		if not card or not is_instance_valid(card):
			continue
		if card in skip_cards:
			continue
		var is_mastery = card.has_method("is_mastery") and card.is_mastery()
		var is_status = card.has_method("is_status") and card.is_status()
		if is_mastery or is_status:
			continue
		result.append(card)
	return result
