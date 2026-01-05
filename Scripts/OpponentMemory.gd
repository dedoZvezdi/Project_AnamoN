extends Node2D

var cards_in_slot: Array = []
var base_z_index := 0
var memory_z_index_offset := 0
var memory_max_z_index := 49
var is_roulette_running = false
var roulette_timer: Timer
var current_highlight_index = 0
var target_card_index = -1
var roulette_speed = 0.2
var roulette_elapsed_time = 0.0
var total_roulette_time = 0.0
var final_slowdown_started = false
var highlighted_card = null
var roulette_cards = []

func _ready():
	z_as_relative = false
	z_index = 0
	add_to_group("memory_slots")
	roulette_timer = Timer.new()
	roulette_timer.wait_time = roulette_speed
	roulette_timer.timeout.connect(_on_roulette_tick)
	roulette_timer.one_shot = false
	add_child(roulette_timer)

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
		card.z_index = memory_z_index_offset + cards_in_slot.size()
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
	if is_roulette_running:
		return
	var idx := cards_in_slot.find(card)
	if idx == -1:
		return
	for i in range(cards_in_slot.size()):
		var cards = cards_in_slot[i]
		if cards and is_instance_valid(cards):
			if i >= idx:
				cards.z_index = min(memory_z_index_offset + i + 20, memory_max_z_index)
			else:
				cards.z_index = memory_z_index_offset + i + 1

func clear_hovered_card():
	if is_roulette_running:
		return
	for i in range(cards_in_slot.size()):
		var card = cards_in_slot[i]
		if card and is_instance_valid(card):
			card.z_index = memory_z_index_offset + i + 1

func are_cards_blocked() -> bool:
	return is_roulette_running

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
		var reversed_index = card_count - 1 - i
		var normalized_x = positions[reversed_index]
		var actual_x = global_position.x - slot_width / 2.0 + normalized_x * slot_width
		var target = Vector2(actual_x, global_position.y)
		var card = cards_in_slot[i]
		if card and is_instance_valid(card):
			var tween = create_tween()
			tween.set_parallel(true)
			tween.tween_property(card, "global_position", target, 0.3)
			tween.tween_property(card, "rotation", 0.0, 0.3)
			card.z_index = memory_z_index_offset + i + 1

func start_synced_roulette(target_index: int, total_time: float):
	if cards_in_slot.is_empty():
		return
	if is_roulette_running:
		return
	is_roulette_running = true
	current_highlight_index = 0
	roulette_elapsed_time = 0.0
	final_slowdown_started = false
	roulette_cards = cards_in_slot.duplicate()
	target_card_index = target_index
	total_roulette_time = total_time
	roulette_speed = 0.1
	roulette_timer.wait_time = roulette_speed
	roulette_timer.start()
	_highlight_card_at_index(current_highlight_index)

func _on_roulette_tick():
	if not is_roulette_running or roulette_cards.is_empty():
		return
	roulette_elapsed_time += roulette_timer.wait_time
	_clear_current_highlight()
	current_highlight_index = (current_highlight_index + 1) % roulette_cards.size()
	_highlight_card_at_index(current_highlight_index)
	var progress = roulette_elapsed_time / total_roulette_time
	if progress >= 0.85 and not final_slowdown_started:
		final_slowdown_started = true
		roulette_speed = 0.3
		roulette_timer.wait_time = roulette_speed
	elif progress >= 0.7 and not final_slowdown_started:
		roulette_speed = lerp(0.1, 0.25, (progress - 0.7) / 0.15)
		roulette_timer.wait_time = roulette_speed
	if roulette_elapsed_time >= total_roulette_time:
		if current_highlight_index == target_card_index:
			_stop_roulette()

func _stop_roulette():
	roulette_timer.stop()
	is_roulette_running = false
	_highlight_card_at_index(target_card_index)
	highlighted_card = roulette_cards[target_card_index]
	var final_timer = Timer.new()
	final_timer.wait_time = 0.5
	final_timer.one_shot = true
	final_timer.timeout.connect(_on_final_highlight_finished.bind(final_timer))
	add_child(final_timer)
	final_timer.start()

func _on_final_highlight_finished(timer: Timer):
	timer.queue_free()

func _highlight_card_at_index(index: int):
	for i in range(cards_in_slot.size()):
		var card = cards_in_slot[i]
		if card and is_instance_valid(card):
			card.modulate = Color(1, 1, 1, 1)
	if index >= 0 and index < cards_in_slot.size():
		var card = cards_in_slot[index]
		if card and is_instance_valid(card):
			card.modulate = Color(0.7, 1.3, 0.7, 1)

func _clear_current_highlight():
	for i in range(cards_in_slot.size()):
		var card = cards_in_slot[i]
		if card and is_instance_valid(card):
			card.modulate = Color(1, 1, 1, 1)

func reset_card_colors():
	_clear_current_highlight()
	highlighted_card = null

func set_all_cards_reveal_status(revealed: bool):
	for card in cards_in_slot:
		if card and is_instance_valid(card) and card.has_method("set_opponent_reveal_status"):
			card.set_opponent_reveal_status(revealed)
