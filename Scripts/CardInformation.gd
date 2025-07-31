extends Node2D

@onready var preview_sprite = $Sprite2D
@onready var card_name_label = $RichTextLabel
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
	var name_to_display = ""
	
	if card_database_reference and card_database_reference.cards_db.has(slug):
		var data = card_database_reference.cards_db[slug]
		
		# 1. Проверка за EDITION (заредено от load_editions)
		if data.has("edition_id") and not data.has("parent_orientation_slug"):
			var base_slug = find_base_card_for_edition(data["edition_id"])
			if base_slug and card_database_reference.cards_db.has(base_slug):
				name_to_display = card_database_reference.cards_db[base_slug].get("name", "")
		
		# 2. Проверка за ORIENTATION EDITION (заредено от load_orientation_editions)
		elif data.has("parent_orientation_slug"):
			var parent_slug = data["parent_orientation_slug"]
			if card_database_reference.cards_db.has(parent_slug):
				name_to_display = card_database_reference.cards_db[parent_slug].get("name", "")
		elif data.has("name"):
			name_to_display = data.get("name", "")
	
	if name_to_display != "":
		card_name_label.append_text("[center][b]%s[/b][/center]" % name_to_display.strip_edges())

func find_parent_orientation_for_edition(edition_slug: String):
	# Търси в orientation editions
	for card_slug in card_database_reference.cards_db:
		var card_data = card_database_reference.cards_db[card_slug]
		# Проверява дали има editions и търси в тях
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
