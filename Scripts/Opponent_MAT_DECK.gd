extends Node2D

var opponent_deck = []
var card_database_reference
const CARD_SCENE_PATH = "res://Scenes/OpponentCard.tscn"

func _ready() -> void:
	card_database_reference = preload("res://Scripts/CardDatabase.gd")

func set_deck(list: Array):
	opponent_deck = list
	update_deck_state()

func decrement_deck_size():
	if opponent_deck.size() > 0:
		opponent_deck.remove_at(0)
		update_deck_state()

func increment_deck_size():
	opponent_deck.append({"slug": "placeholder", "uuid": ""})
	update_deck_state()

func update_deck_state():
	if opponent_deck.size() == 0:
		visible = false
	else:
		visible = true

func add_to_top(slug: String, uuid: String = ""):
	opponent_deck.insert(0, {"slug": slug, "uuid": uuid})
	update_deck_state()
