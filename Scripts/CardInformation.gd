extends Node2D

@onready var preview_sprite = $Sprite2D
@onready var card_name_label = $Name
@onready var card_effect_lable = $Effect
@onready var card_types_lable = $"Types and Suptypes"

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
		if current_hovered_card != last_displayed_card:
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
	if preview_sprite and slug != "":
		var card_image_path = "res://Assets/Grand Archive/Card Images/" + slug + ".png"
		if ResourceLoader.exists(card_image_path):
			preview_sprite.texture = load(card_image_path)
	var name_to_display = ""
	var effect_to_display = ""
	var types_to_display = ""
	if card_database_reference and card_database_reference.cards_db.has(slug):
		var data = card_database_reference.cards_db[slug]
		if data.has("edition_id") and not data.has("parent_orientation_slug"):
			var base_slug = find_base_card_for_edition(data["edition_id"])
			if base_slug and card_database_reference.cards_db.has(base_slug):
				var base_data = card_database_reference.cards_db[base_slug]
				name_to_display = base_data.get("name", "")
				effect_to_display = base_data.get("effect_raw", "")
				types_to_display = _format_types(base_data)
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
