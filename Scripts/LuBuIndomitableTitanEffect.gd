class_name LuBuIndomitableTitanEffect

static var is_executing_effect = false

static func check_and_apply(champion: Node, main_field_node: Node) -> bool:
	if is_executing_effect:
		return true
	if not champion or not champion.has_meta("slug"):
		return false
	var slug = str(champion.get_meta("slug")).to_lower()
	if not (slug.contains("diao-chan") or slug.contains("diaochan")):
		return false
	var damage_counters = 0
	if "attached_counters" in champion:
		var counters = champion.attached_counters
		if typeof(counters) == TYPE_DICTIONARY and counters.has("Damage"):
			damage_counters = int(counters["Damage"])
	if damage_counters != 32:
		return false
	if not main_field_node:
		return false
	var cards = main_field_node.get("cards_in_field")
	if typeof(cards) == TYPE_ARRAY:
		for card in cards:
			if is_instance_valid(card) and card.has_meta("slug"):
				var card_slug = str(card.get_meta("slug")).to_lower()
				var stripped_slug = card_slug.replace("-", "").replace("_", "")
				if stripped_slug.contains("lubuindomitabletitan"):
					is_executing_effect = true
					_execute_wipe_and_transform(champion, main_field_node, card)
					return true
	return false

static func _execute_wipe_and_transform(champion: Node, main_field_node: Node, lu_bu: Node):
	var tree = main_field_node.get_tree()
	var root = tree.current_scene
	var multiplayer_node = tree.get_root().get_node_or_null("Main")
	if not multiplayer_node:
		multiplayer_node = root if root.name == "Main" else null
	var unique_id = 1
	if multiplayer_node and multiplayer_node.multiplayer:
		unique_id = multiplayer_node.multiplayer.get_unique_id()
	var card_info_node = null
	if main_field_node and main_field_node.has_method("find_card_information_reference"):
		card_info_node = main_field_node.find_card_information_reference()
	var db_ref = null
	if card_info_node and "card_database_reference" in card_info_node:
		db_ref = card_info_node.card_database_reference
	var graveyard_slot = null
	var banish_slot = null
	var single_slots = tree.get_nodes_in_group("single_card_slots")
	for slot in single_slots:
		if slot.name == "GRAVEYARD":
			graveyard_slot = slot
			break
	var rotated_slots = tree.get_nodes_in_group("rotated_slots")
	for slot in rotated_slots:
		if slot.name == "BANISH":
			banish_slot = slot
			break
	if not banish_slot and root:
		banish_slot = root.find_child("BANISH", true, false)
	var current_champion = champion
	if current_champion and banish_slot:
		var champ_pos = current_champion.global_position
		var card_uuid = current_champion.uuid if "uuid" in current_champion else ""
		var card_slug = current_champion.get_meta("slug") if current_champion.has_meta("slug") else ""
		if multiplayer_node and multiplayer_node.has_method("rpc"):
			multiplayer_node.rpc("sync_move_to_banish", unique_id, card_uuid, card_slug, false, false)
		var tween = tree.create_tween()
		tween.tween_property(current_champion, "global_position", banish_slot.global_position, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		var lineage_to_process = []
		if main_field_node.has_method("deactivate_card_elements"):
			main_field_node.deactivate_card_elements(current_champion)
		if "champion_lineage" in current_champion:
			lineage_to_process = current_champion.champion_lineage.duplicate(true)
			current_champion.champion_lineage.clear()
		if current_champion in main_field_node.cards_in_field:
			main_field_node.cards_in_field.erase(current_champion)
		if main_field_node.get("current_champion_card") == current_champion:
			main_field_node.current_champion_card = null
			if "apotheosis_rite_active" in main_field_node:
				main_field_node.apotheosis_rite_active = false
			if "sacramental_rite_active" in main_field_node:
				main_field_node.sacramental_rite_active = false
			if "transcendental_rite_active" in main_field_node:
				main_field_node.transcendental_rite_active = false
		await tween.finished
		banish_slot.add_card_to_slot(current_champion, false)
		var card_scene = load("res://Scenes/Card.tscn")
		while lineage_to_process.size() > 0:
			var pre_lineage = lineage_to_process.pop_back()
			var pre_slug = pre_lineage.get("slug", "")
			var pre_uuid = pre_lineage.get("uuid", "")
			if card_scene:
				var temp_champ = card_scene.instantiate()
				main_field_node.add_child(temp_champ)
				temp_champ.set_meta("slug", pre_slug)
				if pre_uuid != "":
					temp_champ.uuid = pre_uuid
				var image_path = "res://Assets/Grand Archive/Card Images/" + pre_slug + ".png"
				if ResourceLoader.exists(image_path):
					var card_image = temp_champ.get_node_or_null("CardImage")
					var card_image_back = temp_champ.get_node_or_null("CardImageBack")
					if card_image:
						card_image.texture = load(image_path)
						card_image.visible = true
						if card_image_back:
							card_image_back.visible = false
						card_image.z_index = 0
				temp_champ.global_position = champ_pos
				if main_field_node.has_method("add_card_to_field"):
					main_field_node.add_card_to_field(temp_champ, champ_pos)
				if multiplayer_node and multiplayer_node.has_method("rpc"):
					multiplayer_node.rpc("sync_move_to_main_field", unique_id, pre_uuid, pre_slug, champ_pos, 0.0, false, false)
				await tree.create_timer(0.3).timeout
				if multiplayer_node and multiplayer_node.has_method("rpc"):
					multiplayer_node.rpc("sync_move_to_banish", unique_id, pre_uuid, pre_slug, false, false)
				var banish_tween = tree.create_tween()
				banish_tween.tween_property(temp_champ, "global_position", banish_slot.global_position, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				await banish_tween.finished
				banish_slot.add_card_to_slot(temp_champ, false)
				if temp_champ in main_field_node.cards_in_field:
					main_field_node.cards_in_field.erase(temp_champ)
				if main_field_node.has_method("deactivate_card_elements"):
					main_field_node.deactivate_card_elements(temp_champ)
				if main_field_node.get("current_champion_card") == temp_champ:
					main_field_node.current_champion_card = null
	var champion_to_skip = current_champion
	var cards_to_process = []
	var cards_in_field = main_field_node.get("cards_in_field")
	if typeof(cards_in_field) == TYPE_ARRAY:
		for card in cards_in_field:
			if card != champion_to_skip and card != lu_bu and is_instance_valid(card):
				var is_mastery = card.has_method("is_mastery") and card.is_mastery()
				var is_status = card.has_method("is_status") and card.is_status()
				if not is_mastery and not is_status:
					cards_to_process.append(card)
	var total_ally_stats = 0
	for card in cards_to_process:
		if not is_instance_valid(card):
			continue
		var card_slug = ""
		if card.has_meta("slug"):
			card_slug = card.get_meta("slug")
		var goes_to_banish = false
		var is_ally = false
		var base_data = null
		if db_ref and db_ref.cards_db.has(card_slug):
			var data = db_ref.cards_db[card_slug]
			base_data = data
			if data.has("edition_id") and not data.has("parent_orientation_slug"):
				if card_info_node and card_info_node.has_method("find_base_card_for_edition"):
					var base_slug = card_info_node.find_base_card_for_edition(data["edition_id"])
					if base_slug and db_ref.cards_db.has(base_slug):
						base_data = db_ref.cards_db[base_slug]
			elif data.has("parent_orientation_slug"):
				var parent_slug = data["parent_orientation_slug"]
				if db_ref.cards_db.has(parent_slug):
					base_data = db_ref.cards_db[parent_slug]
			if base_data.has("cost_memory") and base_data["cost_memory"] != null:
				goes_to_banish = true
			if base_data.has("types") and base_data["types"] is Array:
				for type in base_data["types"]:
					if str(type).to_upper().contains("ALLY"):
						is_ally = true
						break
		if is_ally and base_data != null:
			var mods = card.runtime_modifiers if "runtime_modifiers" in card else {}
			var attached = card.attached_counters if "attached_counters" in card else {}
			var buff_count = attached.get("Buff", 0)
			var debuff_count = attached.get("Debuff", 0)
			var counter_mod = buff_count - debuff_count
			var card_pow = 0
			if base_data.has("power") and base_data["power"] != null:
				card_pow = int(base_data["power"]) + int(mods.get("power", 0)) + counter_mod + attached.get("Power", 0)
				card_pow = max(0, card_pow)
			var card_life = 0
			if base_data.has("life") and base_data["life"] != null:
				var life_count = attached.get("Life", 0)
				var damage_count = attached.get("Damage", 0)
				card_life = int(base_data["life"]) + int(mods.get("life", 0)) + counter_mod + (life_count - damage_count)
				card_life = max(0, card_life)
			total_ally_stats += (card_pow + card_life)
		var uuid = ""
		if "uuid" in card:
			uuid = card.uuid
		if card.has_method("is_token") and card.is_token():
			var tween = tree.create_tween()
			tween.tween_property(card, "modulate", Color(1, 1, 1, 0), 0.3)
			await tween.finished
			if multiplayer_node and multiplayer_node.has_method("rpc") and uuid != "":
				multiplayer_node.rpc("sync_destroy_token", unique_id, uuid, card_slug)
			if main_field_node.has_method("remove_card_from_field"):
				main_field_node.remove_card_from_field(card)
			card.queue_free()
		else:
			var target_slot = banish_slot if goes_to_banish else graveyard_slot
			if target_slot:
				var tween = tree.create_tween()
				tween.tween_property(card, "global_position", target_slot.global_position, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				await tween.finished
				if main_field_node.has_method("remove_card_from_field"):
					main_field_node.remove_card_from_field(card)
				if goes_to_banish:
					banish_slot.add_card_to_slot(card, false)
					if multiplayer_node and multiplayer_node.has_method("rpc"):
						multiplayer_node.rpc("sync_move_to_banish", unique_id, uuid, card_slug, false, false)
				else:
					graveyard_slot.add_card_to_slot(card)
					if multiplayer_node and multiplayer_node.has_method("rpc"):
						multiplayer_node.rpc("sync_move_to_graveyard", unique_id, uuid, card_slug, false)
			else:
				await tree.create_timer(0.3).timeout
	if is_instance_valid(lu_bu) and lu_bu.has_method("transform_card"):
		lu_bu.transform_card()
	if total_ally_stats > 0 and multiplayer_node and multiplayer_node.has_method("rpc"):
		multiplayer_node.rpc("sync_apply_damage_to_champion", unique_id, total_ally_stats)
	is_executing_effect = false

static func apply_wrath_incarnate_global_mods(card: Node, data: Dictionary, current_mods: Dictionary) -> Dictionary:
	var tree = card.get_tree() if card else Engine.get_main_loop()
	if not tree: return current_mods
	var root = tree.current_scene
	var multiplayer_node = tree.get_root().get_node_or_null("Main")
	if not multiplayer_node:
		multiplayer_node = root if root and root.name == "Main" else null
	if not multiplayer_node: return current_mods
	var local_has_wrath = false
	var opp_has_wrath = false
	var db_ref = null
	if multiplayer_node.has_node("PlayerField/CardManager"):
		var cm = multiplayer_node.get_node("PlayerField/CardManager")
		if cm.has_method("find_card_information_reference"):
			var info = cm.find_card_information_reference()
			if info and "card_database_reference" in info:
				db_ref = info.card_database_reference
	var player_field = multiplayer_node.get_node_or_null("PlayerField")
	if player_field:
		var main_field = player_field.get_node_or_null("MAINFIELD")
		if main_field:
			var cham = main_field.get("current_champion_card")
			if cham and is_instance_valid(cham) and cham.has_meta("slug"):
				var slug = str(cham.get_meta("slug"))
				var cham_name = ""
				if db_ref and db_ref.cards_db.has(slug) and db_ref.cards_db[slug].has("name"):
					cham_name = str(db_ref.cards_db[slug]["name"]).to_lower()
				else:
					cham_name = slug.to_lower().replace("-", " ")
				if cham_name.contains("wrath incarnate") or slug.to_lower().contains("wrath"):
					local_has_wrath = true
	var opp_field = multiplayer_node.get_node_or_null("OpponentField")
	if opp_field:
		var opp_main_f = opp_field.get_node_or_null("OpponentMainField")
		if opp_main_f:
			var cham = opp_main_f.get("current_champion_card")
			if cham and is_instance_valid(cham) and cham.has_meta("slug"):
				var slug = str(cham.get_meta("slug"))
				var card_name = ""
				if db_ref and db_ref.cards_db.has(slug) and db_ref.cards_db[slug].has("name"):
					card_name = str(db_ref.cards_db[slug]["name"]).to_lower()
				else:
					card_name = slug.to_lower().replace("-", " ")
				if card_name.contains("wrath incarnate") or slug.to_lower().contains("wrath"):
					opp_has_wrath = true
	if not local_has_wrath and not opp_has_wrath:
		return current_mods
	var effective_data = data
	if db_ref:
		if data.has("edition_id") and not data.has("parent_orientation_slug"):
			var base_slug = ""
			if db_ref.has_method("find_base_card_for_edition"):
				base_slug = db_ref.find_base_card_for_edition(data["edition_id"])
			else:
				for key in db_ref.cards_db:
					var cd = db_ref.cards_db[key]
					if cd.has("editions"):
						for ed in cd["editions"]:
							if ed.get("slug") == data.get("slug"):
								base_slug = key
								break
					if base_slug != "": break
			if base_slug != "" and db_ref.cards_db.has(base_slug):
				effective_data = db_ref.cards_db[base_slug]
		elif data.has("parent_orientation_slug"):
			var parent_slug = data["parent_orientation_slug"]
			if db_ref.cards_db.has(parent_slug):
				effective_data = db_ref.cards_db[parent_slug]
	var is_ally = false
	var is_champion = false
	if effective_data.has("types") and effective_data["types"] is Array:
		for t in effective_data["types"]:
			if str(t).to_upper().contains("ALLY"):
				is_ally = true
			if str(t).to_upper().contains("CHAMPION"):
				is_champion = true
	var new_mods = current_mods.duplicate()
	if is_ally:
		new_mods["power"] = new_mods.get("power", 0) - 3
	if is_champion:
		var is_local_card = true
		if card:
			var script_path = ""
			if card.get_script():
				script_path = card.get_script().resource_path
			if "Opponent" in script_path or "Opponent" in card.name:
				is_local_card = false
			else:
				var parent = card.get_parent()
				while parent:
					if "Opponent" in parent.name:
						is_local_card = false
						break
					parent = parent.get_parent()
		if local_has_wrath and not is_local_card:
			new_mods["level"] = new_mods.get("level", 0) - 3
		if opp_has_wrath and is_local_card:
			new_mods["level"] = new_mods.get("level", 0) - 3
	return new_mods

static func refresh_all_cards_visuals(multiplayer_node: Node):
	if not multiplayer_node: return
	var player_field = multiplayer_node.get_node_or_null("PlayerField")
	if player_field:
		var main_field = player_field.get_node_or_null("MAINFIELD")
		if main_field:
			var cards = main_field.get("cards_in_field")
			if typeof(cards) == TYPE_ARRAY:
				for card in cards:
					if is_instance_valid(card) and card.has_method("show_card_info"):
						card.show_card_info()
					if is_instance_valid(card) and card.has_method("update_visuals"):
						card.update_visuals()
	var opp_field = multiplayer_node.get_node_or_null("OpponentField")
	if opp_field:
		var opp_main_field = opp_field.get_node_or_null("OpponentMainField")
		if opp_main_field:
			var cards = opp_main_field.get("cards_in_field")
			if typeof(cards) == TYPE_ARRAY:
				for card in cards:
					if is_instance_valid(card) and card.has_method("update_visuals"):
						card.update_visuals()
