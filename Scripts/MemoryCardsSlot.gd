extends Node2D

var cards_in_slot = []
var roulette_cards = []
var base_position
var base_z_index = 0
var hover_z_index = 10
var memory_z_index_offset = 0
var memory_max_z_index = 49
var highlighted_card: Node = null
var steps_left = 0
var is_roulette_running = false
var roulette_timer: Timer
var current_highlight_index = 0
var target_card_index = -1
var roulette_speed = 0.2
var roulette_elapsed_time = 0.0
var total_roulette_time = 0.0
var final_slowdown_started = false

func _ready():
	randomize()
	base_position = Vector2.ZERO
	z_as_relative = false
	z_index = 0
	add_to_group("memory_slots")
	roulette_timer = Timer.new()
	roulette_timer.wait_time = roulette_speed
	roulette_timer.timeout.connect(_on_roulette_tick)
	roulette_timer.one_shot = false
	add_child(roulette_timer)
	var im = get_node_or_null("../InputManager")
	if im and not im.is_connected("left_mouse_button_released", Callable(self, "_on_global_lmb_released")):
		im.connect("left_mouse_button_released", Callable(self, "_on_global_lmb_released"))

func _on_global_lmb_released():
	reset_card_colors()

func add_card_to_memory(card, skip_arrangement: bool = false, target_index: int = -1):
	if not card or not is_instance_valid(card):
		return
	if card.has_method("is_token") and card.is_token():
		if card.has_method("destroy_token"):
			card.destroy_token()
		return
	var final_card = card
	if card.get_parent() != self:
		var saved_uuid = card.uuid if "uuid" in card else ""
		final_card = card.duplicate()
		add_child(final_card)
		if saved_uuid != "" and "uuid" in final_card:
			final_card.uuid = saved_uuid
		if card.has_meta("slug"):
			final_card.set_meta("slug", card.get_meta("slug"))
		final_card.global_position = card.global_position
		final_card.rotation = card.rotation
		card.queue_free()
	final_card.visible = true
	if "is_publicly_revealed" in final_card:
		final_card.is_publicly_revealed = false
	if final_card.has_method("set_current_field"):
		final_card.set_current_field(self)
	if target_index >= 0 and target_index <= cards_in_slot.size():
		cards_in_slot.insert(target_index, final_card)
	else:
		cards_in_slot.append(final_card)
	final_card.z_index = memory_z_index_offset + cards_in_slot.size()
	show_card_back(final_card)
	var card_manager = get_tree().current_scene.find_child("CardManager", true, false)
	if card_manager and card_manager.has_method("connect_card_signals"):
		card_manager.connect_card_signals(final_card)
	if not skip_arrangement:
		arrange_cards_symmetrically()

func remove_card_from_memory(card):
	if card in cards_in_slot:
		if card.has_method("set_current_field"):
			card.set_current_field(null)
		cards_in_slot.erase(card)
		show_card_front(card)
		arrange_cards_symmetrically()
		if highlighted_card == card:
			reset_card_colors()

func bring_card_to_front(card):
	if not card or not is_instance_valid(card):
		return
	if is_roulette_running:
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
	if is_roulette_running:
		return
	var slot_size = cards_in_slot.size()
	for i in range(slot_size):
		var card = cards_in_slot[i]
		if card and is_instance_valid(card):
			card.z_index = memory_z_index_offset + i + 1

func are_cards_blocked() -> bool:
	return is_roulette_running

func show_card_back(card):
	var card_image = card.get_node_or_null("CardImage")
	if not card or not is_instance_valid(card):
		return
	if not card.has_meta("original_card_texture"):
		if card_image and card_image.texture:
			card.set_meta("original_card_texture", card_image.texture)
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
	if not card or not is_instance_valid(card):
		return
	if card.has_method("is_token") and card.is_token():
		if card.has_method("destroy_token"):
			card.destroy_token()
		return
	if card.has_method("set_current_field"):
		card.set_current_field(self)
	if index < 0:
		index = 0
	elif index > cards_in_slot.size():
		index = cards_in_slot.size()
	cards_in_slot.insert(index, card)
	card.z_index = memory_z_index_offset + index + 1
	arrange_cards_symmetrically()

func add_card_near_position(card, target_x_position):
	if not card or not is_instance_valid(card):
		return
	if card.has_method("is_token") and card.is_token():
		if card.has_method("destroy_token"):
			card.destroy_token()
		return
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

func arrange_cards_symmetrically(simulate_new_card: bool = false):
	var card_count = cards_in_slot.size()
	var future_card_count = card_count + 1 if simulate_new_card else card_count
	var slot_width = get_slot_width()
	if future_card_count == 1:
		if card_count > 0:
			cards_in_slot[0].global_position = global_position
	else:
		var positions = []
		if future_card_count == 2:
			positions = [0.4, 0.6]
		elif future_card_count == 3:
			positions = [0.3, 0.5, 0.7]
		elif future_card_count == 4:
			positions = [0.2, 0.4, 0.6, 0.8]
		elif future_card_count == 5:
			positions = [0.15, 0.325, 0.5, 0.675, 0.85]
		elif future_card_count == 6:
			positions = [0.125, 0.275, 0.425, 0.575, 0.725, 0.875]
		else:
			var min_pos = 0.07
			var max_pos = 0.93
			for i in range(future_card_count):
				var normalized_pos
				if future_card_count == 1:
					normalized_pos = 0.5
				else:
					normalized_pos = min_pos + (max_pos - min_pos) * i / (future_card_count - 1)
				positions.append(normalized_pos)
		for i in range(card_count):
			var normalized_x = positions[i]
			var actual_x = global_position.x - slot_width/2 + normalized_x * slot_width
			var target = Vector2(actual_x, global_position.y)
			var tween = create_tween()
			tween.tween_property(cards_in_slot[i], "global_position", target, 0.3)
			cards_in_slot[i].z_index = memory_z_index_offset + i + 1

func calculate_final_position_for_new_card() -> Vector2:
	var future_card_count = cards_in_slot.size() + 1
	var slot_width = get_slot_width()
	var positions = []
	if future_card_count == 1:
		return global_position
	elif future_card_count == 2:
		positions = [0.4, 0.6]
	elif future_card_count == 3:
		positions = [0.3, 0.5, 0.7]
	elif future_card_count == 4:
		positions = [0.2, 0.4, 0.6, 0.8]
	elif future_card_count == 5:
		positions = [0.15, 0.325, 0.5, 0.675, 0.85]
	elif future_card_count == 6:
		positions = [0.125, 0.275, 0.425, 0.575, 0.725, 0.875]
	else:
		var min_pos = 0.07
		var max_pos = 0.93
		for i in range(future_card_count):
			var normalized_pos = min_pos + (max_pos - min_pos) * i / (future_card_count - 1)
			positions.append(normalized_pos)
	var new_card_index = future_card_count - 1
	var normalized_x = positions[new_card_index]
	var actual_x = global_position.x - slot_width/2 + normalized_x * slot_width
	return Vector2(actual_x, global_position.y)

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

func highlight_random_card():
	if cards_in_slot.is_empty() or is_roulette_running:
		return
	start_roulette()

func start_roulette():
	is_roulette_running = true
	current_highlight_index = 0
	roulette_elapsed_time = 0.0
	final_slowdown_started = false
	roulette_cards = cards_in_slot.duplicate()  
	target_card_index = randi() % roulette_cards.size()
	total_roulette_time = randf_range(2.7, 3.5)
	var main_node = get_tree().get_root().get_node_or_null("Main")
	if main_node:
		var my_id = multiplayer.get_unique_id()
		main_node.rpc("rpc_start_memory_roulette", my_id, target_card_index, total_roulette_time)
	roulette_speed = 0.1
	roulette_timer.wait_time = roulette_speed
	roulette_timer.start()
	_highlight_card_at_index(current_highlight_index)
	_set_cards_collision_disabled(true)

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
	_set_cards_collision_disabled(false)
	var final_timer = Timer.new()
	final_timer.wait_time = 0.5
	final_timer.one_shot = true
	final_timer.timeout.connect(_on_final_highlight_finished.bind(final_timer))
	add_child(final_timer)
	final_timer.start()

func _set_cards_collision_disabled(disabled: bool):
	for card in cards_in_slot:
		if card and is_instance_valid(card) and card.has_node("Area2D/CollisionShape2D"):
			var collision_shape = card.get_node("Area2D/CollisionShape2D")
			collision_shape.disabled = disabled

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
	if highlighted_card:
		highlighted_card = null
		var main_node = get_tree().get_root().get_node_or_null("Main")
		if main_node:
			main_node.rpc("rpc_reset_memory_roulette", multiplayer.get_unique_id())

func _unhandled_input(event):
	if highlighted_card and (
		event is InputEventMouseButton or event is InputEventMouseMotion
	):
		if event is InputEventMouseButton and event.pressed:
			reset_card_colors()
		elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			reset_card_colors()
