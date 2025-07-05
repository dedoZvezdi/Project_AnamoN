extends Node2D

const HAND_COUNT = 11
const CARD_SCENE_PATH = "res://Scenes/Card.tscn"
const CARD_WIDTH = 100
const HAND_Y_POSITION = 1000
const FIELD_Z_INDEX = 0
const HAND_Z_INDEX = 100
const MIN_CARD_SPACING = 10
const MAX_CARD_SPACING = 60
const BASE_CURVE_HEIGHT = 20

var HAND_FIELD_WIDTH = 600
var player_hand = []
var center_screen_x
var hand_field_left
var hand_field_right

func _ready() -> void:
	center_screen_x = get_viewport().size.x / 2
	hand_field_left = center_screen_x - HAND_FIELD_WIDTH / 2
	hand_field_right = center_screen_x + HAND_FIELD_WIDTH / 2
	
	var card_scene = preload(CARD_SCENE_PATH)
	for i in range(HAND_COUNT):
		var new_card = card_scene.instantiate()
		$"../CardManager".add_child(new_card)
		new_card.name = "Card" + str(i)
		new_card.z_index = HAND_Z_INDEX + i
		add_card_to_hand(new_card)

func add_card_to_hand(card):
	if card not in player_hand:
		player_hand.append(card)
		card.z_index = HAND_Z_INDEX + player_hand.size()
		update_hand_position()
	else:
		animate_card_to_position(card, card.hand_position, calculate_card_rotation(player_hand.find(card)))

func update_hand_position():
	for i in range(player_hand.size()):
		var new_position = calculate_card_position(i)
		var new_rotation = calculate_card_rotation(i)
		var card = player_hand[i]
		card.hand_position = new_position
		card.z_index = HAND_Z_INDEX + i
		animate_card_to_position(card, new_position, new_rotation)

func calculate_card_position(index):
	var hand_size = player_hand.size()
	if hand_size == 1:
		return Vector2(center_screen_x, HAND_Y_POSITION)
	var card_spacing = calculate_card_spacing(hand_size)
	var total_width = (hand_size - 1) * card_spacing
	var start_x = center_screen_x - total_width / 2
	var x_position = start_x + index * card_spacing
	var leftmost_card = start_x - CARD_WIDTH / 2
	var rightmost_card = start_x + total_width + CARD_WIDTH / 2
	if leftmost_card < hand_field_left or rightmost_card > hand_field_right:
		var available_width = HAND_FIELD_WIDTH - CARD_WIDTH
		if hand_size > 1:
			card_spacing = available_width / (hand_size - 1)
		total_width = (hand_size - 1) * card_spacing
		start_x = center_screen_x - total_width / 2
		x_position = start_x + index * card_spacing
	var ratio
	if hand_size > 1:
		ratio = float(index) / float(hand_size - 1)
	var curve_height = calculate_curve_height(hand_size)
	var curve_factor = 4 * ratio * (1.0 - ratio)
	var y_position = HAND_Y_POSITION - curve_factor * curve_height
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
	return BASE_CURVE_HEIGHT  

func get_dynamic_max_angle(hand_size: int) -> float:
	if hand_size <= 1:
		return 0.0
	elif hand_size <= 5:
		return lerp(0.0, 15.0, (hand_size - 1) / 4.0)
	else:
		return clamp(30.0 / sqrt(hand_size), 4.0, 15.0)

func calculate_card_rotation(index):
	var hand_size = player_hand.size()
	if hand_size == 1:
		return 0.0
	var dynamic_max_angle = get_dynamic_max_angle(hand_size)
	var ratio = float(index) / (float(hand_size) - 1)
	var angle = lerp(-dynamic_max_angle, dynamic_max_angle, ratio)
	return deg_to_rad(angle)

func animate_card_to_position(card, new_position, new_rotation = 0.0):
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(card, "position", new_position, 0.3)
	tween.parallel().tween_property(card, "rotation", new_rotation, 0.3)

func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		card.rotation = 0.0
		update_hand_position()

func reset_card_rotation(card, target_rotation = 0.0):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "rotation", target_rotation, 0.2)

func place_card_in_field(card, field_position, field_rotation = 0.0):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_position()
	card.z_index = FIELD_Z_INDEX
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(card, "position", field_position, 0.3)
	tween.parallel().tween_property(card, "rotation", field_rotation, 0.3)

func return_card_to_hand(card):
	if card not in player_hand:
		player_hand.append(card)
		card.z_index = HAND_Z_INDEX + player_hand.size()
		update_hand_position()

func organise_cards(cards: Array) -> void:
	player_hand.clear()
	for card in cards:
		player_hand.append(card)
	update_hand_position()

func set_hand_field_width(new_width: float):
	HAND_FIELD_WIDTH = new_width
	hand_field_left = center_screen_x - HAND_FIELD_WIDTH / 2
	hand_field_right = center_screen_x + HAND_FIELD_WIDTH / 2
	update_hand_position()

func get_hand_info():
	return {
		"hand_size": player_hand.size(),
		"field_width": HAND_FIELD_WIDTH,
		"current_spacing": calculate_card_spacing(player_hand.size()),
		"current_curve_height": calculate_curve_height(player_hand.size())
	}

func bring_card_to_front(card):
	var max_z = HAND_Z_INDEX
	for hand_card in player_hand:
		if hand_card.z_index > max_z:
			max_z = hand_card.z_index
	card.z_index = max_z + 1

func set_card_z_index(card, z_value: int):
	card.z_index = z_value
