extends Node2D

@onready var preview_sprite = $Sprite2D
@onready var card_name_label = $Name
@onready var card_effect_lable = $Effect
var card_database_reference = null
var default_texture = null
var card_manager_reference = null
var last_displayed_card = null

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

func show_card_preview(card):
	var card_slug = get_slug_from_card(card)
	if not card or not is_instance_valid(card) or not preview_sprite:
		return
	var card_image_node = card.get_node_or_null("CardImage")
	if card_image_node and card_image_node.texture:
		preview_sprite.texture = card_image_node.texture
	else:
		if card_slug != "":
			var card_image_path = "res://Assets/Grand Archive/Card Images/" + card_slug + ".png"
			if ResourceLoader.exists(card_image_path):
				preview_sprite.texture = load(card_image_path)
	if card_name_label:
		show_card_info(card_slug)

func show_card_info(slug: String):
	if not slug or not card_name_label:
		return

	card_name_label.clear()
	card_effect_lable.clear()  # 🆕 Почисти ефекта

	var name_to_display = ""
	var effect_to_display = ""

	if card_database_reference and card_database_reference.cards_db.has(slug):
		var data = card_database_reference.cards_db[slug]
		
		if data.has("edition_id") and not data.has("parent_orientation_slug"):
			var base_slug = find_base_card_for_edition(data["edition_id"])
			if base_slug and card_database_reference.cards_db.has(base_slug):
				var base_data = card_database_reference.cards_db[base_slug]
				name_to_display = base_data.get("name", "")
				effect_to_display = base_data.get("effect_raw", "")
		
		elif data.has("parent_orientation_slug"):
			var parent_slug = data["parent_orientation_slug"]
			if card_database_reference.cards_db.has(parent_slug):
				var parent_data = card_database_reference.cards_db[parent_slug]
				name_to_display = parent_data.get("name", "")
				effect_to_display = parent_data.get("effect_raw", "")
		
		else:
			name_to_display = data.get("name", "")
			effect_to_display = data.get("effect_raw", "")
	
	if name_to_display != "":
		var cleaned_name = fix_weird_quotes_and_dashes(name_to_display.strip_edges())
		card_name_label.append_text("[center][b]%s[/b][/center]" % cleaned_name)

	if effect_to_display != "":
		var cleaned_effect = fix_weird_quotes_and_dashes(effect_to_display.strip_edges())
		card_effect_lable.append_text(cleaned_effect)

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
