extends Node2D

signal animation_started
signal animation_finished

const CARD_WIDTH = 100
const HAND_Y_POSITION = 1050
const FIELD_Z_INDEX = 0
const HAND_Z_INDEX = 100
const MIN_CARD_SPACING = 10
const MAX_CARD_SPACING = 60
const BASE_CURVE_HEIGHT = 10

var HAND_FIELD_WIDTH = 600
var player_hand = []
var center_screen_x
var hand_field_left
var hand_field_right
var active_tweens = 0
var animation_in_progress = false
var active_tween_objects = []
var hovered_card = null
var hand_hidden := false
var dragging_card_from_hand = null
var external_preview_index := -1

func _ready() -> void:
	center_screen_x = get_viewport().size.x / 2
	hand_field_left = center_screen_x - HAND_FIELD_WIDTH / 2.0
	hand_field_right = center_screen_x + HAND_FIELD_WIDTH / 2.0
	add_to_group("player_hand")

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		cleanup()

func _exit_tree():
	cleanup()

func add_card_to_hand(card):
	if not card or not is_instance_valid(card):
		return
	_ensure_correct_parent(card)
	if card.has_method("is_token") and card.is_token():
		if card.has_method("destroy_token"):
			card.destroy_token()
		return
	if card.has_method("set_current_field"):
		card.set_current_field(self)
	if card not in player_hand:
		if external_preview_index != -1:
			player_hand.insert(external_preview_index, card)
			external_preview_index = -1
		else:
			player_hand.append(card)
		card.z_index = HAND_Z_INDEX + player_hand.size()
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
		update_hand_position()
		var card_index = player_hand.find(card)
		if card_index >= 0:
			var rotations = calculate_card_rotation(card_index)
			animate_card_to_position(card, card.hand_position, rotations)

func update_hand_position():
	validate_hand()
	start_animation()
	var hand_size = player_hand.size()
	var total_positions = hand_size
	if external_preview_index != -1:
		total_positions += 1
	if hand_size == 0 and external_preview_index == -1:
		end_animation()
		return
	for i in range(hand_size):
		var card = player_hand[i]
		if card and is_instance_valid(card):
			var virtual_index = i
			if external_preview_index != -1 and i >= external_preview_index:
				virtual_index += 1
			var new_position = calculate_card_position(virtual_index, total_positions)
			var new_rotation = calculate_card_rotation(virtual_index, total_positions)
			card.hand_position = new_position
			card.z_index = HAND_Z_INDEX + i + 1
			if card == dragging_card_from_hand:
				continue
			animate_card_to_position(card, new_position, new_rotation)
	call_deferred("enforce_z_ordering")

func enforce_z_ordering():
	validate_hand()
	for i in range(player_hand.size()):
		var card = player_hand[i]
		if card and is_instance_valid(card):
			if card == hovered_card:
				continue
			card.z_index = HAND_Z_INDEX + i + 1

func calculate_card_position(index, total_size = -1):
	var hand_size = total_size if total_size != -1 else player_hand.size()
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

func calculate_card_rotation(index, total_size = -1):
	var hand_size = total_size if total_size != -1 else player_hand.size()
	if hand_size <= 1:
		return 0.0
	var dynamic_max_angle = get_dynamic_max_angle(hand_size)
	var ratio = float(index) / (float(hand_size) - 1)
	var angle = lerp(-dynamic_max_angle, dynamic_max_angle, ratio)
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
	if card in player_hand:
		disconnect_card_signals(card)
		player_hand.erase(card)
		card.rotation = 0.0
		if not player_hand.is_empty():
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
	if card in player_hand:
		player_hand.erase(card)
		if not player_hand.is_empty():
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
	_ensure_correct_parent(card)
	if card.has_method("set_current_field"):
		card.set_current_field(self)
	if card not in player_hand:
		player_hand.append(card)
		card.z_index = int(HAND_Z_INDEX + player_hand.size())
		update_hand_position()
		if card.has_meta("slug"):
			var slug = card.get_meta("slug")
			var uuid = card.uuid if "uuid" in card else ""
			var multiplayer_node = get_tree().get_root().get_node_or_null("Main")
			if multiplayer_node and multiplayer_node.has_method("rpc"):
				multiplayer_node.rpc("sync_return_card_to_hand", multiplayer.get_unique_id(), uuid, slug)

func organise_cards(cards: Array) -> void:
	player_hand.clear()
	for card in cards:
		if card and is_instance_valid(card):
			player_hand.append(card)
	update_hand_position()

func set_hand_field_width(new_width: float):
	HAND_FIELD_WIDTH = new_width
	hand_field_left = center_screen_x - HAND_FIELD_WIDTH / 2
	hand_field_right = center_screen_x + HAND_FIELD_WIDTH / 2
	if not player_hand.is_empty():
		update_hand_position()

func bring_card_to_front(card):
	if not card or not is_instance_valid(card):
		return
	hovered_card = card
	card.z_index = HAND_Z_INDEX + 2000
	var screen_height = get_viewport().size.y
	var texture_height = 1000
	if card.has_node("CardImage") and card.get_node("CardImage").texture:
		texture_height = card.get_node("CardImage").texture.get_size().y
	var current_scale_y = card.scale.y
	var half_height = (texture_height * current_scale_y) / 2
	var target_y = screen_height - half_height + 77
	var target_pos = Vector2(card.position.x, target_y)
	var tween = create_tween()
	active_tween_objects.append(tween)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(card, "position", target_pos, 0.25)
	tween.parallel().tween_property(card, "rotation", 0.0, 0.25)
	tween.finished.connect(_on_single_tween_finished.bind(tween), CONNECT_ONE_SHOT)

func clear_hovered_card():
	var card_to_restore = hovered_card
	hovered_card = null
	var hand_size = player_hand.size()
	for i in range(hand_size):
		var card = player_hand[i]
		if card and is_instance_valid(card):
			card.z_index = HAND_Z_INDEX + i + 1
			if card == card_to_restore:
				var target_pos = calculate_card_position(i)
				var target_rot = calculate_card_rotation(i)
				var tween = create_tween()
				active_tween_objects.append(tween)
				tween.set_ease(Tween.EASE_OUT)
				tween.set_trans(Tween.TRANS_CUBIC)
				tween.parallel().tween_property(card, "position", target_pos, 0.25)
				tween.parallel().tween_property(card, "rotation", target_rot, 0.25)
				tween.finished.connect(_on_single_tween_finished.bind(tween), CONNECT_ONE_SHOT)

func is_mouse_over_hand() -> bool:
	var mouse_pos = get_global_mouse_position()
	return mouse_pos.y > HAND_Y_POSITION - 300 and mouse_pos.x > hand_field_left - 100 and mouse_pos.x < hand_field_right + 100

func is_mouse_near_hand() -> bool:
	var mouse_pos = get_global_mouse_position()
	return mouse_pos.y > HAND_Y_POSITION - 50 and mouse_pos.y < HAND_Y_POSITION + 30 and \
		   mouse_pos.x > hand_field_left - 20 and mouse_pos.x < hand_field_right + 20

func preview_reorder(mouse_x: float):
	if dragging_card_from_hand:
		if player_hand.size() <= 1:
			return
		var hand_size = player_hand.size()
		var card_spacing = calculate_card_spacing(hand_size)
		var total_width = (hand_size - 1) * card_spacing
		var start_x = center_screen_x - total_width / 2
		var target_index = round((mouse_x - start_x) / card_spacing)
		target_index = clamp(target_index, 0, hand_size - 1)
		var current_index = player_hand.find(dragging_card_from_hand)
		if target_index != current_index:
			player_hand.erase(dragging_card_from_hand)
			player_hand.insert(target_index, dragging_card_from_hand)
			update_hand_position()
	else:
		var hand_size = player_hand.size()
		var total_positions = hand_size + 1
		var card_spacing = calculate_card_spacing(total_positions)
		var total_width = (total_positions - 1) * card_spacing
		var start_x = center_screen_x - total_width / 2
		var target_index = round((mouse_x - start_x) / card_spacing)
		target_index = clamp(target_index, 0, total_positions - 1)
		if target_index != external_preview_index:
			external_preview_index = target_index
			update_hand_position()

func clear_external_preview():
	if external_preview_index != -1:
		external_preview_index = -1
		update_hand_position()

func hide_hand():
	hand_hidden = true
	for card in player_hand:
		hide_card_with_animation(card)

func show_hand():
	hand_hidden = false
	var logo_pos = Vector2(590, 960)
	for i in range(player_hand.size()):
		var card = player_hand[i]
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
	return not player_hand.is_empty()

func get_hand_count() -> int:
	validate_hand()
	return player_hand.size()

func is_hand_empty() -> bool:
	validate_hand()
	return player_hand.is_empty()

func validate_hand():
	var invalid_cards = []
	for card in player_hand:
		if not card or not is_instance_valid(card):
			invalid_cards.append(card)
	for invalid_card in invalid_cards:
		player_hand.erase(invalid_card)

func _ensure_correct_parent(card: Node2D):
	if not card or not is_instance_valid(card):
		return
	var card_manager = get_tree().current_scene.find_child("CardManager", true, false)
	if card_manager and card.get_parent() != card_manager:
		card.reparent(card_manager)

func disconnect_card_signals(card):
	if not card or not is_instance_valid(card) or not card.has_node("Area2D"):
		return
		
func cleanup():
	for tween in active_tween_objects:
		if tween and tween.is_valid():
			tween.kill()
	active_tween_objects.clear()
	for card in player_hand:
		if card and is_instance_valid(card):
			disconnect_card_signals(card)
	player_hand.clear()
	active_tweens = 0
	animation_in_progress = false
