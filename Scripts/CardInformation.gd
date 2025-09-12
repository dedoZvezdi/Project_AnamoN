extends Node2D

@onready var preview_sprite = $Sprite2D
@onready var card_name_label = $Name
@onready var card_effect_lable = $Effect
@onready var card_types_lable = $"Types and Suptypes"
@onready var card_level_lable = $Level
@onready var card_element_lable = $Element
@onready var card_cost_lable = $Cost
@onready var card_PLDS_lable = $PowerLifeDurSpeed
@onready var card_Markers_lable = $Markers
@onready var card_Counters_lable = $Counters

var card_database_reference = null
var default_texture = null
var card_manager_reference = null
var last_displayed_card = null
var current_displayed_slug = ""

func _ready() -> void:
	if preview_sprite:
		default_texture = preview_sprite.texture
	card_manager_reference = get_parent().get_node("CardManager")
	card_database_reference = load("res://Scripts/CardDatabase.gd").new()
	card_database_reference.initialize_database()
	card_database_reference.load_all_cards_data()
	if card_manager_reference:
		set_process(true)

func _process(_delta: float) -> void:
	if not card_manager_reference:
		return
	var current_hovered_card = card_manager_reference.last_hovered_card
	if current_hovered_card and is_instance_valid(current_hovered_card):
		var current_slug = get_slug_from_card(current_hovered_card)
		var need_refresh := false
		if current_hovered_card != last_displayed_card or current_slug != current_displayed_slug:
			need_refresh = true
		elif last_displayed_card and is_instance_valid(last_displayed_card):
			var prev_show_custom = _should_show_custom(last_displayed_card)
			var now_show_custom = _should_show_custom(current_hovered_card)
			if prev_show_custom != now_show_custom:
				need_refresh = true
		if need_refresh:
			show_card_preview(current_hovered_card)
			last_displayed_card = current_hovered_card

func show_card_info(slug: String):
	current_displayed_slug = slug
	last_displayed_card = null
	_update_card_display(slug)
	
func _format_types(data: Dictionary) -> String:
	var types_text = ""
	var types_list = []
	var subtypes_list = []
	if data.has("types") and data["types"] is Array:
		for t in data["types"]:
			types_list.append(str(t).to_upper())
	if data.has("subtypes") and data["subtypes"] is Array:
		for s in data["subtypes"]:
			subtypes_list.append(str(s).to_upper())
		subtypes_list.sort()
	if types_list.size() > 0:
		types_text += " ".join(types_list)
	if subtypes_list.size() > 0:
		if types_text != "":
			types_text += " - "
		types_text += " ".join(subtypes_list)
	return types_text

func show_card_preview(card):
	var card_slug = get_slug_from_card(card)
	if not card or not is_instance_valid(card) or not preview_sprite:
		return
	current_displayed_slug = card_slug
	last_displayed_card = card
	var is_in_memory_slot = false
	var memory_slots = get_tree().get_nodes_in_group("memory_slots")
	for memory_slot in memory_slots:
		if is_instance_valid(memory_slot) and card in memory_slot.cards_in_slot:
			is_in_memory_slot = true
			break
	if not is_in_memory_slot:
		var all_nodes = get_tree().get_nodes_in_group("")
		for node in all_nodes:
			if node.name == "MEMORY" and is_instance_valid(node) and card in node.cards_in_slot:
				is_in_memory_slot = true
				break
	if is_in_memory_slot and card.has_meta("original_card_texture"):
		preview_sprite.texture = card.get_meta("original_card_texture")
	else:
		var card_image_node = card.get_node_or_null("CardImage")
		if card_image_node and card_image_node.texture:
			preview_sprite.texture = card_image_node.texture
		else:
			if card_slug != "":
				var card_image_path = "res://Assets/Grand Archive/Card Images/" + card_slug + ".png"
				if ResourceLoader.exists(card_image_path):
					preview_sprite.texture = load(card_image_path)
	if card_name_label:
		_update_card_display(card_slug)

func _update_card_display(slug: String):
	if not slug or not card_name_label:
		return
	card_name_label.clear()
	card_effect_lable.clear()
	card_types_lable.clear()
	card_level_lable.clear()
	card_element_lable.clear()
	card_cost_lable.clear()
	card_PLDS_lable.clear()
	if card_Markers_lable:
		card_Markers_lable.clear()
	if card_Counters_lable:
		card_Counters_lable.clear()
	if preview_sprite and slug != "":
		var card_image_path = "res://Assets/Grand Archive/Card Images/" + slug + ".png"
		if ResourceLoader.exists(card_image_path):
			preview_sprite.texture = load(card_image_path)
	var name_to_display = ""
	var effect_to_display = ""
	var types_to_display = ""
	var level_to_display = null
	var element_to_display = null
	var cost_text_to_display = ""
	var plds_text_to_display = ""
	var mods = get_effective_mods_for_card()
	if card_database_reference and card_database_reference.cards_db.has(slug):
		var data = card_database_reference.cards_db[slug]
		if data.has("level") and data["level"] != null:
			level_to_display = data["level"]
		if data.has("element") and data["element"] != null:
			element_to_display = data["element"]
		if data.has("cost_memory") and data["cost_memory"] != null:
			cost_text_to_display = "MEMORY %s" % str(data["cost_memory"])
		elif data.has("cost_reserve") and data["cost_reserve"] != null:
			cost_text_to_display = "RESERVE %s" % str(data["cost_reserve"])
		plds_text_to_display = _build_plds_text_effective(data, mods)
		if data.has("edition_id") and not data.has("parent_orientation_slug"):
			var base_slug = find_base_card_for_edition(data["edition_id"])
			if base_slug and card_database_reference.cards_db.has(base_slug):
				var base_data = card_database_reference.cards_db[base_slug]
				name_to_display = base_data.get("name", "")
				effect_to_display = base_data.get("effect_raw", "")
				types_to_display = _format_types(base_data)
				if base_data.has("level") and base_data["level"] != null:
					level_to_display = base_data["level"]
				if base_data.has("element") and base_data["element"] != null:
					element_to_display = base_data["element"]
				if base_data.has("cost_memory") and base_data["cost_memory"] != null:
					cost_text_to_display = "MEMORY %s" % str(base_data["cost_memory"])
				elif base_data.has("cost_reserve") and base_data["cost_reserve"] != null:
					cost_text_to_display = "RESERVE %s" % str(base_data["cost_reserve"])
				if plds_text_to_display == "":
					plds_text_to_display = _build_plds_text_effective(base_data, mods)
				if (effect_to_display == null or effect_to_display.strip_edges() == "") and base_data.get("flavor"):
					effect_to_display = base_data["flavor"]
				elif effect_to_display == null or effect_to_display.strip_edges() == "":
					if base_data.has("editions"):
						for edition in base_data["editions"]:
							if edition.get("flavor"):
								effect_to_display = edition["flavor"]
								break
		elif data.has("parent_orientation_slug"):
			var parent_slug = data["parent_orientation_slug"]
			if card_database_reference.cards_db.has(parent_slug):
				var parent_data = card_database_reference.cards_db[parent_slug]
				name_to_display = parent_data.get("name", "")
				effect_to_display = parent_data.get("effect_raw", "")
				types_to_display = _format_types(parent_data)
				if parent_data.has("level") and parent_data["level"] != null:
					level_to_display = parent_data["level"]
				if parent_data.has("element") and parent_data["element"] != null:
					element_to_display = parent_data["element"]
				if parent_data.has("cost_memory") and parent_data["cost_memory"] != null:
					cost_text_to_display = "MEMORY %s" % str(parent_data["cost_memory"])
				elif parent_data.has("cost_reserve") and parent_data["cost_reserve"] != null:
					cost_text_to_display = "RESERVE %s" % str(parent_data["cost_reserve"])
				if plds_text_to_display == "":
					plds_text_to_display = _build_plds_text_effective(parent_data, mods)
				if (effect_to_display == null or effect_to_display.strip_edges() == "") and parent_data.get("flavor"):
					effect_to_display = parent_data["flavor"]
				elif effect_to_display == null or effect_to_display.strip_edges() == "":
					if parent_data.has("editions"):
						for edition in parent_data["editions"]:
							if edition.get("flavor"):
								effect_to_display = edition["flavor"]
								break
		else:
			name_to_display = data.get("name", "")
			effect_to_display = data.get("effect_raw", "")
			types_to_display = _format_types(data)
			if plds_text_to_display == "":
				plds_text_to_display = _build_plds_text_effective(data, mods)
			if (effect_to_display == null or effect_to_display.strip_edges() == "") and data.get("flavor"):
				effect_to_display = data["flavor"]
			elif effect_to_display == null or effect_to_display.strip_edges() == "":
				if data.has("editions"):
					for edition in data["editions"]:
						if edition.get("flavor"):
							effect_to_display = edition["flavor"]
							break
	if name_to_display and name_to_display.strip_edges() != "":
		var cleaned_name = fix_weird_quotes_and_dashes(name_to_display.strip_edges())
		card_name_label.append_text("[center][b]%s[/b][/center]" % cleaned_name)
	if effect_to_display and effect_to_display.strip_edges() != "":
		var cleaned_effect = fix_weird_quotes_and_dashes(effect_to_display.strip_edges())
		card_effect_lable.append_text(cleaned_effect)
	if types_to_display and types_to_display.strip_edges() != "":
		card_types_lable.append_text("[center]%s[/center]" % types_to_display)
	if level_to_display != null:
		var lvl_eff = int(level_to_display) + int(mods.get("level", 0))
		level_to_display = max(0, lvl_eff)
		card_level_lable.append_text("[left]LV. %s[/left]" % str(level_to_display))
	if element_to_display != null:
		card_element_lable.append_text("[center]%s[/center]" % str(element_to_display))
	if cost_text_to_display != "":
		card_cost_lable.append_text("[left]%s[/left]" % cost_text_to_display)
	if plds_text_to_display != "":
		card_PLDS_lable.append_text("[left]%s[/left]" % plds_text_to_display)
	if last_displayed_card and is_instance_valid(last_displayed_card):
		var markers_text_lines: Array[String] = []
		var counters_text_lines: Array[String] = []
		var show_custom = _should_show_custom(last_displayed_card)
		if show_custom:
			var any_markers := false
			var any_counters := false
			if last_displayed_card.has_method("get_attached_markers"):
				var mk = last_displayed_card.get_attached_markers()
				for marker_name in mk.keys():
					var v = int(mk[marker_name])
					var sign = "+" if v > 0 else ""
					markers_text_lines.append("%s %s%s" % [str(marker_name), sign, str(v)])
				if mk.size() > 0:
					any_markers = true
			if last_displayed_card.has_method("get_attached_counters"):
				var cn = last_displayed_card.get_attached_counters()
				for counter_name in cn.keys():
					var v2 = int(cn[counter_name])
					var sign2 = "+" if v2 > 0 else ""
					counters_text_lines.append("%s %s%s" % [str(counter_name), sign2, str(v2)])
				if cn.size() > 0:
					any_counters = true
			if card_Markers_lable and any_markers:
				card_Markers_lable.append_text("[left][b]Markers:[/b]\n%s[/left]" % "\n".join(markers_text_lines))
			if card_Counters_lable and any_counters:
				card_Counters_lable.append_text("[left][b]Counters:[/b]\n%s[/left]" % "\n".join(counters_text_lines))

func _should_show_custom(card) -> bool:
	if not card or not is_instance_valid(card):
		return false
	if card.has_method("is_in_main_field") and card.is_in_main_field():
		return true
	if card.has_method("is_in_graveyard") and card.is_in_graveyard():
		return true
	if card.has_method("is_in_banish") and card.is_in_banish():
		return true
	if card.has_method("is_in_memory_slot") and card.is_in_memory_slot():
		return false
	if card.has_method("is_in_hand") and card.is_in_hand():
		return false
	return false

func _build_plds_text(data: Dictionary) -> String:
	var parts: Array[String] = []
	if data.has("power") and data["power"] != null:
		parts.append("POW. %s" % str(data["power"]))
	if data.has("life") and data["life"] != null:
		parts.append("LIFE %s" % str(data["life"]))
	if data.has("durability") and data["durability"] != null:
		parts.append("DUR. %s" % str(data["durability"]))
	if data.has("speed") and data["speed"] != null:
		if typeof(data["speed"]) in [TYPE_INT, TYPE_FLOAT]:
			if data["speed"] == 1:
				parts.append("SPD. FAST")
			elif data["speed"] == 0:
				parts.append("SPD. SLOW")
			else:
				parts.append("SPEED %s" % str(data["speed"]))
		elif typeof(data["speed"]) == TYPE_BOOL:
			parts.append("FAST" if data["speed"] else "SLOW")
		else:
			parts.append("SPEED ?")
	return " - ".join(parts)

func _build_plds_text_effective(data: Dictionary, mods: Dictionary) -> String:
	var parts: Array[String] = []
	if data.has("power") and data["power"] != null:
		var p = int(data["power"]) + int(mods.get("power", 0))
		p = max(0, p)
		parts.append("POW. %s" % str(p))
	if data.has("life") and data["life"] != null:
		var l = int(data["life"]) + int(mods.get("life", 0))
		l = max(0, l)
		parts.append("LIFE %s" % str(l))
	if data.has("durability") and data["durability"] != null:
		var d = int(data["durability"]) + int(mods.get("durability", 0))
		d = max(0, d)
		parts.append("DUR. %s" % str(d))
	if data.has("speed") and data["speed"] != null:
		if typeof(data["speed"]) in [TYPE_INT, TYPE_FLOAT]:
			if data["speed"] == 1:
				parts.append("SPD. FAST")
			elif data["speed"] == 0:
				parts.append("SPD. SLOW")
			else:
				parts.append("SPEED %s" % str(data["speed"]))
		elif typeof(data["speed"]) == TYPE_BOOL:
			parts.append("FAST" if data["speed"] else "SLOW")
		else:
			parts.append("SPEED ?")
	return " - ".join(parts)

func get_effective_mods_for_card() -> Dictionary:
	var zero = {"level": 0, "power": 0, "life": 0, "durability": 0}
	if last_displayed_card and is_instance_valid(last_displayed_card):
		if last_displayed_card.has_method("is_in_main_field") and last_displayed_card.is_in_main_field():
			if last_displayed_card.has_method("get_runtime_modifiers"):
				return last_displayed_card.get_runtime_modifiers()
	return zero

func clear_preview():
	if card_name_label:
		card_name_label.clear()
	if card_effect_lable:
		card_effect_lable.clear()
	if card_types_lable:
		card_types_lable.clear()
	if preview_sprite and default_texture:
		preview_sprite.texture = default_texture
	current_displayed_slug = ""

func find_parent_orientation_for_edition(edition_slug: String):
	for card_slug in card_database_reference.cards_db:
		var card_data = card_database_reference.cards_db[card_slug]
		if card_data.has("editions"):
			for edition in card_data.get("editions", []):
				if edition.get("slug") == edition_slug:
					return card_slug
	return null

func format_slug(slug):
	var words = slug.split("-")
	var formatted_words = []
	for word in words:
		formatted_words.append(word.capitalize())
	return " ".join(formatted_words)

func find_base_card_for_edition(edition_id):
	for slug in card_database_reference.cards_db:
		var data = card_database_reference.cards_db[slug]
		if data.has("editions"):
			for edition in data["editions"]:
				if edition.get("edition_id") == edition_id:
					return slug
	return null

func get_slug_from_card(card) -> String:
	if card.has_meta("slug"):
		return card.get_meta("slug")
	return ""

func fix_weird_quotes_and_dashes(text: String) -> String:
	var replacements = {
		"вЂ™": "'",
		"вЂ”": "-",
		"вЂњ": "\"",
		"вЂќ": "\"",
		"вЂ“": "-",
		"вЂ¦": "..."
	}
	for weird_char in replacements:
		text = text.replace(weird_char, replacements[weird_char])
	return text
