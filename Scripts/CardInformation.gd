extends Node2D

@onready var preview_sprite = $Sprite2D
var default_texture = null
var card_manager_reference = null
var last_displayed_card = null

func _ready() -> void:
	if preview_sprite:
		default_texture = preview_sprite.texture
	card_manager_reference = get_parent().get_node("CardManager")
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
	if not card or not is_instance_valid(card) or not preview_sprite:
		return
	var card_image_node = card.get_node_or_null("CardImage")
	if card_image_node and card_image_node.texture:
		preview_sprite.texture = card_image_node.texture
	else:
		var card_name = get_card_name_from_card(card)
		if card_name != "":
			var card_image_path = "res://Assets/Grand Archive/Card Images/" + card_name + ".png"
			if ResourceLoader.exists(card_image_path):
				preview_sprite.texture = load(card_image_path)

func get_card_name_from_card(card) -> String:
	return "" if not card.name else card.name

func reset_to_default():
	if default_texture and preview_sprite:
		preview_sprite.texture = default_texture
		last_displayed_card = null
