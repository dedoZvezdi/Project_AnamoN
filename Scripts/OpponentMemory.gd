extends Node2D

var cards_in_slot: Array = []
var base_z_index := 0
var memory_z_index_offset := 10
var memory_max_z_index := 49

func _ready():
	add_to_group("memory_slots")

func add_card_to_memory(card):
	if not card or not is_instance_valid(card):
		return
	if card.has_method("is_token") and card.is_token():
		if card.has_method("destroy_token"):
			card.destroy_token()
		return
	if card.has_method("set_current_field"):
		card.set_current_field(self)
	if card not in cards_in_slot:
		cards_in_slot.append(card)
	_show_card_back(card)
	_arrange_cards_symmetrically()

func remove_card_from_memory(card):
	if card in cards_in_slot:
		if card.has_method("set_current_field"):
			card.set_current_field(null)
		cards_in_slot.erase(card)
		_show_card_front(card)
		_arrange_cards_symmetrically()

func bring_card_to_front(card):
	if not card or not is_instance_valid(card):
		return
	var idx := cards_in_slot.find(card)
	if idx == -1:
		return
	for i in range(cards_in_slot.size()):
		var c = cards_in_slot[i]
		if c and is_instance_valid(c):
			if i >= idx:
				c.z_index = min(memory_z_index_offset + i + 20, memory_max_z_index)
			else:
				c.z_index = memory_z_index_offset + i + 1

func clear_hovered_card():
	for i in range(cards_in_slot.size()):
		var c = cards_in_slot[i]
		if c and is_instance_valid(c):
			c.z_index = memory_z_index_offset + i + 1

func are_cards_blocked() -> bool:
	return false

func _show_card_back(card):
	if not card or not is_instance_valid(card):
		return
	var card_image = card.get_node_or_null("CardImage")
	if not card.has_meta("original_card_texture"):
		if card_image and card_image.texture:
			card.set_meta("original_card_texture", card_image.texture)
	var card_image_back = card.get_node_or_null("CardImageBack")
	if card_image and card_image_back:
		card_image_back.z_index = 0
		card_image.z_index = -1
		card_image_back.visible = true
		card_image.visible = false

func _show_card_front(card):
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

func _get_slot_width() -> float:
	var area = get_node_or_null("Area2D")
	if area:
		var collision_shape = area.get_node_or_null("CollisionShape2D")
		if collision_shape and collision_shape.shape:
			return collision_shape.shape.size.x
	return 400.0

func _arrange_cards_symmetrically():
	var card_count = cards_in_slot.size()
	var slot_width = _get_slot_width()
	if card_count <= 0:
		return
	var positions: Array[float] = []
	if card_count == 1:
		positions = [0.5]
	elif card_count == 2:
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
			var normalized_pos = min_pos + (max_pos - min_pos) * i / (card_count - 1)
			positions.append(normalized_pos)
	for i in range(card_count):
		var normalized_x = positions[i]
		var actual_x = global_position.x - slot_width / 2.0 + normalized_x * slot_width
		var target = Vector2(actual_x, global_position.y)
		var card = cards_in_slot[i]
		if card and is_instance_valid(card):
			var tween = create_tween()
			tween.tween_property(card, "global_position", target, 0.3)
			card.z_index = memory_z_index_offset + i + 1
