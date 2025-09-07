extends Node2D

var opponent_deck = ["alice-golden-queen-dtr1e-cur","aetheric-calibration-dtrsd","alice-golden-queen-dtr","academy-guide-p24", "absolving-flames-amb","acolyte-of-cultivation-amb","acolyte-of-cultivation-amb"
,"suzaku-vermillion-phoenix-hvn1e-csr","acolyte-of-cultivation-amb","arcane-disposition-doap","arthur-young-heir-evp","suzaku-vermillion-phoenix-hvn1e"]

var card_database_reference
const CARD_SCENE_PATH = "res://Scenes/OpponentCard.tscn"
var cards_to_draw = 0
var draw_timer: Timer

func _ready() -> void:
	opponent_deck.shuffle()
	setup_draw_timer()
	draw_initial_hand()

func setup_draw_timer():
	draw_timer = Timer.new()
	draw_timer.wait_time = 1.0
	draw_timer.timeout.connect(_on_draw_timer_timeout)
	add_child(draw_timer)

func draw_initial_hand():
	cards_to_draw = min(10, opponent_deck.size())
	if cards_to_draw > 0:
		draw_timer.start()

func _on_draw_timer_timeout():
	if cards_to_draw > 0:
		draw_card()
		cards_to_draw -= 1
		if cards_to_draw > 0:
			draw_timer.start()
		else:
			draw_timer.stop()

func draw_card():
	if opponent_deck.size() == 0:
		return
	var card_drawn_name = opponent_deck[0]
	opponent_deck.erase(card_drawn_name)
	if opponent_deck.size() == 0:
		$Sprite2D.visible = false
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
