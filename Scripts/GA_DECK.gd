extends Node2D

var player_deck = ["spirit-of-water", "spirit-of-water","spirit-of-water"]

const CARD_SCENE_PATH = "res://Scenes/Card.tscn"

func free() -> void:
	pass

func draw_card():
	var card_drawn = player_deck[0]
	player_deck.erase(card_drawn)
	
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	$"../CardManager".add_child(new_card)
	new_card.name = "Card"
	$"../PlayerHand".add_card_to_hand(new_card)
