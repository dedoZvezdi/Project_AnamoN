extends Node2D

var opponent_deck = ["alice-golden-queen-dtr1e-cur","bellonas-runestone-ambdp",
"alice-golden-queen-dtr","apotheosis-rite-p24-cpr", "crimson-protective-trinket-ftc",
"assassins-mantle-rec-brv","polaris-twinkling-cauldron-prxy",
"lost-providence-ptm1e","fabled-azurite-fatestone-hvn1e-csr",
"huaji-of-heavens-rise-hvn1e","fabled-ruby-fatestone-hvn1e","kaleidoscope-barrette-rec-idy"]
var card_database_reference
const CARD_SCENE_PATH = "res://Scenes/OpponentCard.tscn"

func _ready() -> void:
	card_database_reference = preload("res://Scripts/CardDatabase.gd")

func add_to_top(slug: String):
	opponent_deck.insert(0, slug)
