extends Node2D

const CARD_SCENE_PATH = "res://Scenes/OpponentCard.tscn"

var card_database_reference
var deck_size

func _ready() -> void:
	card_database_reference = preload("res://Scripts/CardDatabase.gd")

func draw_card(card_drawn_name):
	if deck_size - 1 == 0:
		visible = false
	else:
		deck_size -= 1
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	var card_image_path = "res://Assets/Grand Archive/Card Images/" + card_drawn_name + ".png"
	if ResourceLoader.exists(card_image_path):
		new_card.get_node("CardImage").texture = load(card_image_path)
	new_card.set_meta("slug", card_drawn_name)
	var unique_name = card_drawn_name
	var counter = 2
	while $"../CardManager".has_node(unique_name):
		unique_name = "%s (%d)" % [card_drawn_name, counter]
		counter += 1
	new_card.name = unique_name
	$"../CardManager".add_child(new_card)
	$"../OpponentHand".add_card_to_hand(new_card)
