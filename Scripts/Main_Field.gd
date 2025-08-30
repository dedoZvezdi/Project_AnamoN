extends Node2D

var cards_in_field = []
var base_position
var card_in_slot = false

func _ready() -> void:
	base_position = Vector2.ZERO
	add_to_group("main_fields")

func add_card_to_field(card, position = null):
	if position == null:
		card.global_position = global_position
	else:
		card.global_position = position
	cards_in_field.append(card)
	card_in_slot = true
	if card.has_method("set_current_field"):
		card.set_current_field(self)

func remove_card_from_field(card):
	if card in cards_in_field:
		cards_in_field.erase(card)
		if cards_in_field.is_empty():
			card_in_slot = false
		
		# Премахваме referencer към field-а
		if card.has_method("set_current_field"):
			card.set_current_field(null)

func bring_card_to_front(card):
	if not card or not is_instance_valid(card):
		return
	var card_index = cards_in_field.find(card)
	if card_index == -1:
		return
	var field_size = cards_in_field.size()
	for i in range(field_size):
		var current_card = cards_in_field[i]
		if current_card and is_instance_valid(current_card):
			if i >= card_index:
				current_card.z_index = 200 + i + 50
			else:
				current_card.z_index = 200 + i + 1

func clear_hovered_card():
	var field_size = cards_in_field.size()
	for i in range(field_size):
		var card = cards_in_field[i]
		if card and is_instance_valid(card):
			card.z_index = 200 + i + 1
