extends Node2D

var cards_in_slot = []
var base_position
var base_z_index = 0
var hover_z_index = 10
var memory_z_index_offset = 10
var memory_max_z_index = 49

func _ready() -> void:
	base_position = Vector2.ZERO
	add_to_group("memory_slots")

func add_card_to_memory(card):
	cards_in_slot.append(card)
	show_card_back(card)
	arrange_cards_symmetrically()

func remove_card_from_memory(card):
	if card in cards_in_slot:
		cards_in_slot.erase(card)
		show_card_front(card)
		arrange_cards_symmetrically()

func bring_card_to_front(card):
	if not card or not is_instance_valid(card):
		return
	var card_index = cards_in_slot.find(card)
	if card_index == -1:
		return
	var slot_size = cards_in_slot.size()
	for i in range(slot_size):
		var current_card = cards_in_slot[i]
		if current_card and is_instance_valid(current_card):
			if i >= card_index:
				current_card.z_index = min(memory_z_index_offset + i + 20, memory_max_z_index)
			else:
				current_card.z_index = memory_z_index_offset + i + 1

func clear_hovered_card():
	var slot_size = cards_in_slot.size()
	for i in range(slot_size):
		var card = cards_in_slot[i]
		if card and is_instance_valid(card):
			card.z_index = memory_z_index_offset + i + 1

func show_card_back(card):
	if not card or not is_instance_valid(card):
		return
	if not card.has_meta("original_card_texture"):
		var card_image = card.get_node_or_null("CardImage")
		if card_image and card_image.texture:
			card.set_meta("original_card_texture", card_image.texture)
	var card_image = card.get_node_or_null("CardImage")
	var card_image_back = card.get_node_or_null("CardImageBack")
	if card_image and card_image_back:
		card_image_back.z_index = 0
		card_image.z_index = -1
		card_image_back.visible = true
		card_image.visible = false

func show_card_front(card):
	if not card or not is_instance_valid(card):
		return
	var card_image = card.get_node_or_null("CardImage")
	var card_image_back = card.get_node_or_null("CardImageBack")
	if card_image and card_image_back:
		card_image_back.z_index = -1
		card_image.z_index = 0
		card_image_back.visible = false
		card_image.visible = true
		if card.has_meta("original_card_texture"):
			card_image.texture = card.get_meta("original_card_texture")

func insert_card_at_position(card, index):
	if index < 0:
		index = 0
	elif index > cards_in_slot.size():
		index = cards_in_slot.size()
	cards_in_slot.insert(index, card)
	arrange_cards_symmetrically()

func add_card_near_position(card, target_x_position):
	var slot_width = get_slot_width()
	var slot_start = global_position.x - slot_width/2
	var slot_end = global_position.x + slot_width/2
	target_x_position = clamp(target_x_position, slot_start, slot_end)
	var best_index = cards_in_slot.size() 
	if cards_in_slot.size() > 0:
		for i in range(cards_in_slot.size()):
			if target_x_position < cards_in_slot[i].global_position.x:
				best_index = i
				break
	insert_card_at_position(card, best_index)

func arrange_cards_symmetrically():
	var card_count = cards_in_slot.size()
	var slot_width = get_slot_width()
	if card_count == 1:
		cards_in_slot[0].global_position = global_position
	else:
		var positions = []
		if card_count == 2:
			positions = [0.4, 0.6]
		elif card_count == 3:
			positions = [0.3, 0.5, 0.7]
		elif card_count == 4:
			positions = [0.2, 0.4, 0.6, 0.8]
		elif card_count == 5:
			positions = [0.15, 0.325, 0.5, 0.675, 0.85]
		elif card_count == 6:
			positions = [0.125, 0.275, 0.425, 0.575, 0.725, 0.875]
		else:
			var min_pos = 0.07
			var max_pos = 0.93
			for i in range(card_count):
				var normalized_pos
				if card_count == 1:
					normalized_pos = 0.5
				else:
					normalized_pos = min_pos + (max_pos - min_pos) * i / (card_count - 1)
				positions.append(normalized_pos)
		for i in range(card_count):
			var normalized_x = positions[i]
			var actual_x = global_position.x - slot_width/2 + normalized_x * slot_width
			cards_in_slot[i].global_position = Vector2(actual_x, global_position.y)
			cards_in_slot[i].z_index = memory_z_index_offset + i + 1

func get_slot_width():
	var area = get_node("Area2D")
	if area:
		var collision_shape = area.get_node("CollisionShape2D")
		if collision_shape and collision_shape.shape:
			return collision_shape.shape.size.x
	return 400

func get_slot_height():
	var area = get_node("Area2D")
	if area:
		var collision_shape = area.get_node("CollisionShape2D")
		if collision_shape and collision_shape.shape:
			return collision_shape.shape.size.y
	return 100
