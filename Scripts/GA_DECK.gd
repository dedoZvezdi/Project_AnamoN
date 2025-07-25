extends Node2D

var player_deck = ["academy-guide-p24", "absolving-flames-amb","acolyte-of-cultivation-amb","acolyte-of-cultivation-amb","acolyte-of-cultivation-amb"
,"acolyte-of-cultivation-amb","acolyte-of-cultivation-amb","acolyte-of-cultivation-amb","acolyte-of-cultivation-amb","acolyte-of-cultivation-amb"
,"acolyte-of-cultivation-amb","acolyte-of-cultivation-amb","acolyte-of-cultivation-amb","acolyte-of-cultivation-amb"]
var card_database_reference

const CARD_SCENE_PATH = "res://Scenes/Card.tscn"

func _ready() -> void:
	player_deck.shuffle()
	card_database_reference = preload("res://Scripts/CardDatabase.gd")

func draw_card():
	var card_drawn_name = player_deck[0]
	player_deck.erase(card_drawn_name)
	
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	var card_image_path = str("res://Assets/Grand Archive/Card Images/" + card_drawn_name + ".png")
	new_card.get_node("CardImage").texture = load(card_image_path)
	$"../CardManager".add_child(new_card)
	new_card.name = "Card"
	$"../PlayerHand".add_card_to_hand(new_card)
	new_card.get_node("AnimationPlayer").play("card_flip")
