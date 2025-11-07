extends Node2D

signal animation_started
signal animation_finished

const CARD_WIDTH = 100
const HAND_Y_POSITION = 10
const FIELD_Z_INDEX = 0
const HAND_Z_INDEX = 100
const MIN_CARD_SPACING = 10
const MAX_CARD_SPACING = 60
const BASE_CURVE_HEIGHT = 10

var HAND_FIELD_WIDTH = 600
var opponent_hand = []
var center_screen_x
var hand_field_left
var hand_field_right
var active_tweens = 0
var animation_in_progress = false
var active_tween_objects = []
var hovered_card = null
var hand_hidden := false

func _ready() -> void:
	center_screen_x = get_viewport().size.x / 2
	hand_field_left = center_screen_x - HAND_FIELD_WIDTH / 2.0
	hand_field_right = center_screen_x + HAND_FIELD_WIDTH / 2.0
	add_to_group("opponent_hand")

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		cleanup()

func _exit_tree():
	cleanup()

func add_card_to_hand(card):
	if not card or not is_instance_valid(card):
		return
	if card not in opponent_hand:
		opponent_hand.insert(0, card)
		for i in range(opponent_hand.size()):
			opponent_hand[i].z_index = HAND_Z_INDEX + i + 1
		update_hand_position()
		if hand_hidden:
			show_card(card)
			var start_pos = card.position
			var logo_pos = Vector2(590, 960)
			var offscreen_pos = Vector2(2500, 1200)
			card.position = start_pos
			var tween = create_tween()
			tween.tween_property(card, "position", logo_pos, 0.3)
			tween.tween_callback(Callable(self, "_move_card_offscreen").bind(card, offscreen_pos))
			if card.has_node("Area2D"):
				card.get_node("Area2D").set_deferred("input_pickable", false)
		else:
			show_card(card)
	else:
		var card_index = opponent_hand.find(card)
		if card_index >= 0:
			var rotations = calculate_card_rotation(card_index)
			animate_card_to_position(card, card.hand_position, rotations)

func update_hand_position():
	validate_hand()
	if opponent_hand.is_empty():
		return
	start_animation()
	for i in range(opponent_hand.size()):
		var card = opponent_hand[i]
		if card and is_instance_valid(card):
			var new_position = calculate_card_position(i)
			var new_rotation = calculate_card_rotation(i)
			card.hand_position = new_position
			card.z_index = HAND_Z_INDEX + i + 1
			animate_card_to_position(card, new_position, new_rotation)

func calculate_card_position(index):
	var hand_size = opponent_hand.size()
	if hand_size == 1:
		return Vector2(center_screen_x, HAND_Y_POSITION)
	var card_spacing = calculate_card_spacing(hand_size)
	var total_width = (hand_size - 1) * card_spacing
	var start_x = center_screen_x - total_width / 2
	var x_position = start_x + index * card_spacing
	var leftmost_card = start_x - CARD_WIDTH / 2.0
	var rightmost_card = start_x + total_width + CARD_WIDTH / 2.0
	if leftmost_card < hand_field_left or rightmost_card > hand_field_right:
		var available_width = HAND_FIELD_WIDTH - CARD_WIDTH
		if hand_size > 1:
			card_spacing = available_width / (hand_size - 1.0)
		total_width = (hand_size - 1) * card_spacing
		start_x = center_screen_x - total_width / 2
		x_position = start_x + index * card_spacing
	var ratio = 0.0
	if hand_size > 1:
		ratio = float(index) / float(hand_size - 1)
	var curve_height = calculate_curve_height(hand_size)
	var curve_factor = 4 * ratio * (1.0 - ratio)
	var y_position = HAND_Y_POSITION + curve_factor * curve_height
	return Vector2(x_position, y_position)

func calculate_card_spacing(hand_size):
	if hand_size <= 1:
		return MAX_CARD_SPACING
	var ideal_spacing = MAX_CARD_SPACING
	var total_width = (hand_size - 1) * ideal_spacing + CARD_WIDTH
	if total_width > HAND_FIELD_WIDTH:
		ideal_spacing = (HAND_FIELD_WIDTH - CARD_WIDTH) / (hand_size - 1)
		ideal_spacing = max(ideal_spacing, MIN_CARD_SPACING)
	return ideal_spacing

func calculate_curve_height(hand_size):
	if hand_size == 3:
		return 4
	elif hand_size == 4:
		return 6
	elif hand_size == 5:
		return 8
	else:
		return BASE_CURVE_HEIGHT  

func get_dynamic_max_angle(hand_size: int) -> float:
	if hand_size <= 1:
		return 0.0
	elif hand_size <= 3:
		return lerp(0.0, 6.0, (hand_size - 1) / 4.0)
	else:
		return clamp(30.0 / sqrt(hand_size), 4.0, 6.0)

func calculate_card_rotation(index):
	var hand_size = opponent_hand.size()
	if hand_size <= 1:
		return 0.0
	var dynamic_max_angle = get_dynamic_max_angle(hand_size)
	var ratio = float(index) / (float(hand_size) - 1)
	var angle = lerp(dynamic_max_angle, -dynamic_max_angle, ratio)
	return deg_to_rad(angle)

func animate_card_to_position(card, new_position, new_rotation = 0.0):
	if not card or not is_instance_valid(card):
		return
	active_tweens += 1
	var tween = create_tween()
	active_tween_objects.append(tween)
	tween.parallel().tween_property(card, "position", new_position, 0.3)
	tween.parallel().tween_property(card, "rotation", new_rotation, 0.3)
	tween.finished.connect(_on_tween_finished.bind(tween), CONNECT_ONE_SHOT)

func _on_tween_finished(tween):
	active_tweens -= 1
	if active_tweens <= 0:
		active_tweens = 0
		end_animation()
	if tween and tween in active_tween_objects:
		active_tween_objects.erase(tween)

func start_animation():
	if not animation_in_progress:
		animation_in_progress = true
		animation_started.emit()

func end_animation():
	animation_in_progress = false
	animation_finished.emit()

func remove_card_from_hand(card):
	if not card or not is_instance_valid(card):
		return
	if card in opponent_hand:
		disconnect_card_signals(card)
		opponent_hand.erase(card)
		card.rotation = 0.0
		if not opponent_hand.is_empty():
			update_hand_position()
		else:
			active_tweens = 0
			end_animation()

func reset_card_rotation(card, target_rotation = 0.0):
	if not card or not is_instance_valid(card):
		return
	var tween = create_tween()
	active_tween_objects.append(tween)
	tween.tween_property(card, "rotation", target_rotation, 0.2)
	tween.finished.connect(_on_single_tween_finished.bind(tween), CONNECT_ONE_SHOT)

func _on_single_tween_finished(tween):
	if tween and tween in active_tween_objects:
		active_tween_objects.erase(tween)

func place_card_in_field(card, field_position, field_rotation = 0.0):
	if not card or not is_instance_valid(card):
		return
	if card in opponent_hand:
		opponent_hand.erase(card)
		if not opponent_hand.is_empty():
			update_hand_position()
		else:
			end_animation()
	card.z_index = FIELD_Z_INDEX
	var tween = create_tween()
	active_tween_objects.append(tween)
	tween.parallel().tween_property(card, "position", field_position, 0.3)
	tween.parallel().tween_property(card, "rotation", field_rotation, 0.3)
	tween.finished.connect(_on_single_tween_finished.bind(tween), CONNECT_ONE_SHOT)

func return_card_to_hand(card):
	if not card or not is_instance_valid(card):
		return
	if card not in opponent_hand:
		opponent_hand.append(card)
		card.z_index = HAND_Z_INDEX + opponent_hand.size()
		update_hand_position()

func organise_cards(cards: Array) -> void:
	opponent_hand.clear()
	for card in cards:
		if card and is_instance_valid(card):
			opponent_hand.append(card)
	update_hand_position()

func set_hand_field_width(new_width: float):
	HAND_FIELD_WIDTH = new_width
	hand_field_left = center_screen_x - HAND_FIELD_WIDTH / 2
	hand_field_right = center_screen_x + HAND_FIELD_WIDTH / 2
	if not opponent_hand.is_empty():
		update_hand_position()

func bring_card_to_front(card):
	if not card or not is_instance_valid(card):
		return
	hovered_card = card
	var hovered_card_index = opponent_hand.find(card)
	if hovered_card_index == -1:
		return
	var hand_size = opponent_hand.size()
	for i in range(hand_size):
		var current_card = opponent_hand[i]
		if current_card and is_instance_valid(current_card):
			if i >= hovered_card_index:
				current_card.z_index = HAND_Z_INDEX + i + 100
			else:
				current_card.z_index = HAND_Z_INDEX + i + 1

func clear_hovered_card():
	hovered_card = null
	var hand_size = opponent_hand.size()
	for i in range(hand_size):
		var card = opponent_hand[i]
		if card and is_instance_valid(card):
			card.z_index = HAND_Z_INDEX + i + 1

func hide_hand():
	hand_hidden = true
	for card in opponent_hand:
		hide_card_with_animation(card)

func show_hand():
	hand_hidden = false
	var logo_pos = Vector2(590, 960)
	for i in range(opponent_hand.size()):
		var card = opponent_hand[i]
		if card and is_instance_valid(card):
			card.position = logo_pos
			card.visible = true
			if card.has_node("Area2D"):
				card.get_node("Area2D").set_deferred("input_pickable", true)
	update_hand_position()

func hide_card_with_animation(card):
	if card and is_instance_valid(card):
		var logo_pos = Vector2(590, 960)
		var offscreen_pos = Vector2(3300, 3300)
		var tween = create_tween()
		tween.tween_property(card, "position", logo_pos, 0.3)
		tween.tween_callback(Callable(self, "_move_card_offscreen").bind(card, offscreen_pos))
		if card.has_node("Area2D"):
			card.get_node("Area2D").set_deferred("input_pickable", false)

func _move_card_offscreen(card, offscreen_pos):
	if card and is_instance_valid(card):
		card.position = offscreen_pos
		card.visible = false

func hide_card(card):
	if card and is_instance_valid(card):
		card.position = Vector2(2500, 1200)
		card.visible = false
		if card.has_node("Area2D"):
			card.get_node("Area2D").set_deferred("input_pickable", false)

func show_card(card):
	if card and is_instance_valid(card):
		card.visible = true
		if card.has_node("Area2D"):
			card.get_node("Area2D").set_deferred("input_pickable", true)

func toggle_hand_visibility():
	if hand_hidden:
		show_hand()
	else:
		hide_hand()

func set_card_z_index(card, z_value: int):
	if card and is_instance_valid(card):
		card.z_index = z_value

func has_cards() -> bool:
	validate_hand()
	return not opponent_hand.is_empty()

func get_hand_count() -> int:
	validate_hand()
	return opponent_hand.size()

func is_hand_empty() -> bool:
	validate_hand()
	return opponent_hand.is_empty()

func validate_hand():
	var invalid_cards = []
	for card in opponent_hand:
		if not card or not is_instance_valid(card):
			invalid_cards.append(card)
	for invalid_card in invalid_cards:
		opponent_hand.erase(invalid_card)

func disconnect_card_signals(card):
	if not card or not is_instance_valid(card) or not card.has_node("Area2D"):
		return
		
func cleanup():
	for tween in active_tween_objects:
		if tween and tween.is_valid():
			tween.kill()
	active_tween_objects.clear()
	for card in opponent_hand:
		if card and is_instance_valid(card):
			disconnect_card_signals(card)
	opponent_hand.clear()
	active_tweens = 0
	animation_in_progress = false
