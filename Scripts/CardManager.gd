extends Node2D

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SINGLE_SLOT = 2

var screen_size
var card_being_dragged = null
var last_hovered_card = null
var normal_scale = Vector2(0.39, 0.39)
var hover_scale = Vector2(0.46, 0.46)
var base_z_index = 0
var hover_z_index = 10
var drag_z_index = 1000
var card_counter = 0
var player_hand_reference
var animation_in_progress = false
var connected_cards = []
var signal_connections = {}

func _ready() -> void:
	$"../InputManager".connect("left_mouse_button_released", on_left_click_released)
	player_hand_reference = $"../PlayerHand"
	update_screen_size()
	var viewport = get_viewport()
	if viewport:
		if viewport.is_connected("size_changed", Callable(self, "update_screen_size")):
			viewport.disconnect("size_changed", Callable(self, "update_screen_size"))
		viewport.connect("size_changed", Callable(self, "update_screen_size"))
	if player_hand_reference and player_hand_reference.has_signal("animation_started"):
		if not player_hand_reference.is_connected("animation_started", _on_animation_started):
			player_hand_reference.connect("animation_started", _on_animation_started)
	if player_hand_reference and player_hand_reference.has_signal("animation_finished"):
		if not player_hand_reference.is_connected("animation_finished", _on_animation_finished):
			player_hand_reference.connect("animation_finished", _on_animation_finished)
	for card in get_tree().get_nodes_in_group("cards"):
		if is_instance_valid(card):
			connect_card_signals(card)
			card.z_index = base_z_index

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		cleanup()

func _exit_tree():
	cleanup()
		
func update_screen_size():
	screen_size = get_viewport_rect().size

func _process(_delta: float) -> void:
	if card_being_dragged and is_instance_valid(card_being_dragged):
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(
			clamp(mouse_pos.x, 0, screen_size.x),
			clamp(mouse_pos.y, 0, screen_size.y)
		)

func can_drag_card(card) -> bool:
	if not card or not is_instance_valid(card):
		return false
	if card.has_node("Area2D/CollisionShape2D"):
		var collision_shape = card.get_node("Area2D/CollisionShape2D")
		if collision_shape.disabled:
			return false
	return true

func _on_animation_started():
	animation_in_progress = true

func _on_animation_finished():
	animation_in_progress = false

func start_drag(card):
	if not card or not is_instance_valid(card):
		return
	card_being_dragged = card
	card.get_parent().move_child(card, card.get_parent().get_child_count())
	card.z_index = drag_z_index
	card.scale = normal_scale
	card.rotation = 0.0
	remove_card_from_rotated_slot(card)
	remove_card_from_memory_slot(card)
	remove_card_from_main_field(card)
	remove_card_from_single_card_slot(card)
	var graveyard_slot = get_graveyard_slot_for_card(card)
	var banish_slot = get_banish_slot_for_card(card)
	if graveyard_slot and graveyard_slot.has_method("get_top_card"):
		var top_card = graveyard_slot.get_top_card()
		if top_card and top_card != card:
			card = top_card
	if last_hovered_card and last_hovered_card != card and is_instance_valid(last_hovered_card):
		if last_hovered_card.has_node("Area2D/CollisionShape2D"):
			if not last_hovered_card.get_node("Area2D/CollisionShape2D").disabled:
				last_hovered_card.scale = normal_scale
		last_hovered_card = null
	if banish_slot and banish_slot.has_method("get_top_card"):
		var top_card = banish_slot.get_top_card()
		if top_card and top_card != card:
			card = top_card
	if last_hovered_card and last_hovered_card != card and is_instance_valid(last_hovered_card):
		if last_hovered_card.has_node("Area2D/CollisionShape2D"):
			if not last_hovered_card.get_node("Area2D/CollisionShape2D").disabled:
				last_hovered_card.scale = normal_scale
		last_hovered_card = null

func finish_drag():
	if not card_being_dragged or not is_instance_valid(card_being_dragged):
		card_being_dragged = null
		return
	free_card_from_slot(card_being_dragged)
	var card_slot_found = raycast_check_for_card_single_slot()
	if card_slot_found:
		if player_hand_reference and card_being_dragged in player_hand_reference.player_hand:
			player_hand_reference.remove_card_from_hand(card_being_dragged)
		if card_slot_found.name == "MEMORY":
			card_slot_found.add_card_to_memory(card_being_dragged)
			card_being_dragged.scale = normal_scale
			card_being_dragged.z_index = base_z_index
		elif card_slot_found.name == "MAINFIELD":
			var is_first_card = card_slot_found.cards_in_field.is_empty()
			var drop_position = null
			if not is_first_card:
				drop_position = card_being_dragged.global_position
			card_slot_found.add_card_to_field(card_being_dragged, drop_position)
			card_being_dragged.scale = normal_scale
			card_being_dragged.z_index = base_z_index
		elif card_slot_found.name == "CardsSlotForSignleCard" or card_slot_found.name == "GRAVEYARD":
			card_slot_found.add_card_to_slot(card_being_dragged)
			card_being_dragged.scale = normal_scale
			card_being_dragged.z_index = base_z_index
		elif card_slot_found.name == "90DegreesCardSlot" or card_slot_found.name == "BANISH":
			card_slot_found.add_card_to_slot(card_being_dragged)
			card_being_dragged.scale = normal_scale
			card_being_dragged.z_index = base_z_index
			card_being_dragged.rotation_degrees = -90
			#TODO see if it's needed (i am lazy now)
		#elif not card_slot_found.card_in_slot:
			#card_being_dragged.position = card_slot_found.position
			#if card_being_dragged.has_node("Area2D/CollisionShape2D"):
				#card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
			#card_slot_found.card_in_slot = true
			#card_being_dragged.scale = normal_scale
			#card_being_dragged.z_index = base_z_index
			#if card_slot_found.name == "90DegreesCardSlot" or card_slot_found.is_in_group("rotated_slots"):
				#card_being_dragged.rotation_degrees = -90
		else:
			card_being_dragged.z_index = base_z_index + card_counter
			card_counter += 1
	else:
		if player_hand_reference:
			player_hand_reference.add_card_to_hand(card_being_dragged)
	card_being_dragged = null
	call_deferred("force_hover_check")

func free_card_from_slot(card):
	if not card or not is_instance_valid(card):
		return
	if card.has_node("Area2D/CollisionShape2D"):
		var collision_shape = card.get_node("Area2D/CollisionShape2D")
		if collision_shape.disabled:
			collision_shape.disabled = false
			var all_slots = get_tree().get_nodes_in_group("card_slots")
			for slot in all_slots:
				if is_instance_valid(slot) and slot.has_method("get_card_position"):
					var slot_pos = slot.get_card_position()
					if card.position.distance_to(slot_pos) < 50:
						if slot.has_property("card_in_slot"):
							slot.card_in_slot = false
						break
	var all_nodes = get_tree().get_nodes_in_group("")
	for node in all_nodes:
		if node.name == "MAINFIELD" and is_instance_valid(node) and node.has_method("remove_card_from_field"):
			if card in node.cards_in_field:
				node.remove_card_from_field(card)
				break
	var single_card_slots = get_tree().get_nodes_in_group("single_card_slots")
	for slot in single_card_slots:
		if is_instance_valid(slot) and slot.has_method("remove_card_from_slot"):
			if slot.card_in_slot:
				slot.remove_card_from_slot(card)
				break
	var rotated_slots = get_tree().get_nodes_in_group("rotated_slots")
	for slot in rotated_slots:
		if is_instance_valid(slot) and slot.has_method("remove_card_from_slot"):
			if slot.card_in_slot:
				slot.remove_card_from_slot(card)
				break
	var all_nodes_graveyard = get_tree().get_nodes_in_group("")
	for node in all_nodes_graveyard:
		if node.name == "GRAVEYARD" and is_instance_valid(node) and node.has_method("remove_card_from_slot"):
			if card in node.cards_in_graveyard:
				node.remove_card_from_slot(card)
				break
	var all_nodes_banish = get_tree().get_nodes_in_group("")
	for node in all_nodes_banish:
		if node.name == "BANISH" and is_instance_valid(node) and node.has_method("remove_card_from_slot"):
			if card in node.cards_in_banish:
				node.remove_card_from_slot(card)
				break

func is_card_in_graveyard(card):
	if not card or not is_instance_valid(card):
		return false
	var all_nodes = get_tree().get_nodes_in_group("")
	for node in all_nodes:
		if node.name == "GRAVEYARD" and is_instance_valid(node) and node.has_method("bring_card_to_front"):
			if card in node.cards_in_graveyard:
				return true
	return false

func is_card_in_banish(card):
	if not card or not is_instance_valid(card):
		return false
	var all_nodes = get_tree().get_nodes_in_group("")
	for node in all_nodes:
		if node.name == "BANISH" and is_instance_valid(node) and node.has_method("bring_card_to_front"):
			if card in node.cards_in_banish:
				return true
	return false

func get_graveyard_slot_for_card(card):
	if not card or not is_instance_valid(card):
		return null
	var all_nodes = get_tree().get_nodes_in_group("")
	for node in all_nodes:
		if node.name == "GRAVEYARD" and is_instance_valid(node) and node.has_method("bring_card_to_front"):
			if card in node.cards_in_graveyard:
				return node
	return null

func get_banish_slot_for_card(card):
	if not card or not is_instance_valid(card):
		return null
	var all_nodes = get_tree().get_nodes_in_group("")
	for node in all_nodes:
		if node.name == "BANISH" and is_instance_valid(node) and node.has_method("bring_card_to_front"):
			if card in node.cards_in_banish:
				return node
	return null

func force_hover_check():
	validate_references()
	await get_tree().process_frame
	handle_hover()
	var mouse_pos = get_global_mouse_position()
	var card = raycast_check_at_position(mouse_pos)
	if card and is_instance_valid(card):
		_on_card_hovered(card)

func is_card_truly_hovered(card) -> bool:
	if not card or not is_instance_valid(card):
		return false
	var mouse_pos = get_global_mouse_position()
	var space_state = get_world_2d().direct_space_state
	if !space_state:
		return false
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = mouse_pos
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	parameters.collide_with_bodies = false
	var result = space_state.intersect_point(parameters)
	if result.size() == 0:
		return false
	var highest_card = null
	var highest_z = -9999
	for collision in result:
		var detected_card = collision.collider.get_parent()
		if detected_card and is_instance_valid(detected_card) and detected_card.z_index > highest_z:
			highest_card = detected_card
			highest_z = detected_card.z_index
	return highest_card == card

func raycast_check_at_position(pos):
	var space_state = get_world_2d().direct_space_state
	if !space_state:
		return null
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = pos
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	parameters.collide_with_bodies = false
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		var highest_card = null
		var highest_z = -9999
		for collision in result:
			var card = collision.collider.get_parent()
			if card and is_instance_valid(card) and card.z_index > highest_z:
				highest_card = card
				highest_z = card.z_index
		return highest_card
	return null

func handle_hover():
	if card_being_dragged or animation_in_progress:
		return
	validate_references()
	var current_card = raycast_check_for_card()
	if current_card and is_instance_valid(current_card):
		if current_card.get_parent() and current_card.get_parent().is_in_group("rotated_slots"):
			current_card = null
		else:
			for slot in get_tree().get_nodes_in_group("rotated_slots"):
				if current_card in slot.cards_in_banish:
					current_card = null
					break
		if current_card and is_instance_valid(current_card) and not is_card_truly_hovered(current_card):
			current_card = null
	if current_card and is_instance_valid(current_card):
		if current_card.get_parent() and current_card.get_parent().is_in_group("single_card_slots"):
			current_card = null
		else:
			for slot in get_tree().get_nodes_in_group("single_card_slots"):
				if current_card in slot.cards_in_graveyard:
					current_card = null
					break
		if current_card and is_instance_valid(current_card) and not is_card_truly_hovered(current_card):
			current_card = null
	if current_card != last_hovered_card:
		if last_hovered_card and is_instance_valid(last_hovered_card):
			if can_drag_card(last_hovered_card):
				last_hovered_card.scale = normal_scale
				if player_hand_reference and last_hovered_card in player_hand_reference.player_hand:
					player_hand_reference.clear_hovered_card()
				elif is_card_in_memory_slot(last_hovered_card):
					get_memory_slot_for_card(last_hovered_card).clear_hovered_card()
				elif is_card_in_graveyard(last_hovered_card):
					get_graveyard_slot_for_card(last_hovered_card).clear_hovered_card()
				elif is_card_in_banish(last_hovered_card):
					get_banish_slot_for_card(last_hovered_card).clear_hovered_card()
				else:
					last_hovered_card.z_index = base_z_index
		if current_card and is_instance_valid(current_card):
			if can_drag_card(current_card):
				current_card.get_parent().move_child(current_card, current_card.get_parent().get_child_count())
				current_card.scale = hover_scale
				if player_hand_reference and current_card in player_hand_reference.player_hand:
					player_hand_reference.bring_card_to_front(current_card)
				elif is_card_in_memory_slot(current_card):
					get_memory_slot_for_card(current_card).bring_card_to_front(current_card)
				elif is_card_in_graveyard(current_card):
					get_graveyard_slot_for_card(current_card).bring_card_to_front(current_card)
				elif is_card_in_banish(current_card):
					get_banish_slot_for_card(current_card).bring_card_to_front(current_card)
				else:
					current_card.z_index = hover_z_index
		last_hovered_card = current_card

func connect_card_signals(card):
	if not card or not is_instance_valid(card) or not card.has_node("Area2D"):
		return
	var area = card.get_node("Area2D")
	var card_id = card.get_instance_id()
	disconnect_card_signals(card)
	var callable_hovered = Callable(self, "_on_card_hovered").bind(card)
	var callable_unhovered = Callable(self, "_on_card_unhovered").bind(card)
	area.connect("mouse_entered", callable_hovered)
	area.connect("mouse_exited", callable_unhovered)
	signal_connections[card_id] = {
		"area": area,
		"mouse_entered": callable_hovered,
		"mouse_exited": callable_unhovered
	}
	if card not in connected_cards:
		connected_cards.append(card)

func on_left_click_released():
	if card_being_dragged:  
		finish_drag()

func disconnect_card_signals(card):
	if not card or not is_instance_valid(card):
		return
	var card_id = card.get_instance_id()
	if card_id in signal_connections:
		var connection_data = signal_connections[card_id]
		var area = connection_data["area"]
		if is_instance_valid(area):
			if area.is_connected("mouse_entered", connection_data["mouse_entered"]):
				area.disconnect("mouse_entered", connection_data["mouse_entered"])
			if area.is_connected("mouse_exited", connection_data["mouse_exited"]):
				area.disconnect("mouse_exited", connection_data["mouse_exited"])
		signal_connections.erase(card_id)
	if card in connected_cards:
		connected_cards.erase(card)

func _on_card_hovered(card):
	if not card or not is_instance_valid(card) or animation_in_progress:
		return
	if card.get_parent() and card.get_parent().is_in_group("single_card_slots"):
		return
	for slot in get_tree().get_nodes_in_group("single_card_slots"):
		if card in slot.cards_in_graveyard:
			return
	if card.get_parent() and card.get_parent().is_in_group("rotated_slots"):
		return
	for slot in get_tree().get_nodes_in_group("rotated_slots"):
		if card in slot.cards_in_banish:
			return
	if card == card_being_dragged:
		return
	if card_being_dragged:
		return 
	if not can_drag_card(card):
		return
	if card == last_hovered_card:
		return
	if not is_card_truly_hovered(card):
		return
	card.get_parent().move_child(card, card.get_parent().get_child_count())
	card.scale = hover_scale
	if player_hand_reference and card in player_hand_reference.player_hand:
		player_hand_reference.bring_card_to_front(card)
	elif is_card_in_memory_slot(card):
		get_memory_slot_for_card(card).bring_card_to_front(card)
	elif is_card_in_graveyard(card):
		get_graveyard_slot_for_card(card).bring_card_to_front(card)
	elif is_card_in_banish(card):
		get_banish_slot_for_card(card).bring_card_to_front(card)
	else:
		card.z_index = hover_z_index
	if last_hovered_card and last_hovered_card != card and is_instance_valid(last_hovered_card):
		if can_drag_card(last_hovered_card):
			last_hovered_card.scale = normal_scale
			if player_hand_reference and last_hovered_card in player_hand_reference.player_hand:
				player_hand_reference.clear_hovered_card()
			else:
				last_hovered_card.z_index = base_z_index
	last_hovered_card = card

func _on_card_unhovered(card):
	if not card or not is_instance_valid(card) or card == card_being_dragged or card != last_hovered_card or animation_in_progress:
		return
	if can_drag_card(card):
		card.scale = normal_scale
		if player_hand_reference and card in player_hand_reference.player_hand:
			player_hand_reference.clear_hovered_card()
		elif is_card_in_memory_slot(card):
			get_memory_slot_for_card(card).clear_hovered_card()
		elif is_card_in_graveyard(card):
			get_graveyard_slot_for_card(card).clear_hovered_card()
		elif is_card_in_banish(card):
			get_banish_slot_for_card(card).clear_hovered_card()
		else:
			card.z_index = base_z_index
	last_hovered_card = null

func raycast_check_for_card_single_slot():
	var space_state = get_world_2d().direct_space_state
	if !space_state:
		return null
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD_SINGLE_SLOT
	parameters.collide_with_bodies = false
	var result = space_state.intersect_point(parameters, 1)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

func raycast_check_for_card():
	return raycast_check_at_position(get_global_mouse_position())

func validate_references():
	if last_hovered_card and not is_instance_valid(last_hovered_card):
		last_hovered_card = null
	if card_being_dragged and not is_instance_valid(card_being_dragged):
		card_being_dragged = null
	if player_hand_reference and not is_instance_valid(player_hand_reference):
		player_hand_reference = null
	var invalid_cards = []
	for card in connected_cards:
		if not card or not is_instance_valid(card):
			invalid_cards.append(card)
	for invalid_card in invalid_cards:
		connected_cards.erase(invalid_card)
	var invalid_connections = []
	for card_id in signal_connections.keys():
		var connection_data = signal_connections[card_id]
		if not is_instance_valid(connection_data["area"]):
			invalid_connections.append(card_id)
	for invalid_id in invalid_connections:
		signal_connections.erase(invalid_id)

func cleanup():
	card_being_dragged = null
	last_hovered_card = null
	var viewport = get_viewport()
	if viewport and viewport.is_connected("size_changed", Callable(self, "update_screen_size")):
		viewport.disconnect("size_changed", Callable(self, "update_screen_size"))
	if player_hand_reference and is_instance_valid(player_hand_reference):
		if player_hand_reference.is_connected("animation_started", _on_animation_started):
			player_hand_reference.disconnect("animation_started", _on_animation_started)
		if player_hand_reference.is_connected("animation_finished", _on_animation_finished):
			player_hand_reference.disconnect("animation_finished", _on_animation_finished)
	for card in connected_cards.duplicate():
		if is_instance_valid(card):
			disconnect_card_signals(card)
	connected_cards.clear()
	signal_connections.clear()
	player_hand_reference = null

func remove_card_from_main_field(card):
	if not card or not is_instance_valid(card):
		return
	var all_nodes = get_tree().get_nodes_in_group("")
	for node in all_nodes:
		if node.name == "MAINFIELD" and is_instance_valid(node) and node.has_method("remove_card_from_field"):
			if card in node.cards_in_field:
				node.remove_card_from_field(card)
				break

func remove_card_from_single_card_slot(card):
	if not card or not is_instance_valid(card):
		return
	var single_card_slots = get_tree().get_nodes_in_group("single_card_slots")
	for slot in single_card_slots:
		if is_instance_valid(slot) and slot.has_method("remove_card_from_slot"):
			if slot.card_in_slot:
				slot.remove_card_from_slot(card)
				break
	var all_nodes = get_tree().get_nodes_in_group("")
	for node in all_nodes:
		if node.name == "GRAVEYARD" and is_instance_valid(node) and node.has_method("remove_card_from_slot"):
			if node.card_in_slot:
				node.remove_card_from_slot(card)
				break
				
func remove_card_from_rotated_slot(card):
	if not card or not is_instance_valid(card):
		return
	var rotated_slot = get_tree().get_nodes_in_group("rotated_slots")
	for slot in rotated_slot:
		if is_instance_valid(slot) and slot.has_method("remove_card_from_slot"):
			if slot.card_in_slot:
				slot.remove_card_from_slot(card)
				break
	var all_nodes = get_tree().get_nodes_in_group("")
	for node in all_nodes:
		if node.name == "BANISH" and is_instance_valid(node) and node.has_method("remove_card_from_slot"):
			if node.card_in_slot:
				node.remove_card_from_slot(card)
				break

func remove_card_from_memory_slot(card):
	if not card or not is_instance_valid(card):
		return
	var memory_slots = get_tree().get_nodes_in_group("memory_slots")
	for memory_slot in memory_slots:
		if is_instance_valid(memory_slot) and memory_slot.has_method("remove_card_from_memory"):
			if card in memory_slot.cards_in_slot:
				memory_slot.remove_card_from_memory(card)
				break
	var all_nodes = get_tree().get_nodes_in_group("")
	for node in all_nodes:
		if node.name == "MEMORY" and is_instance_valid(node) and node.has_method("remove_card_from_memory"):
			if card in node.cards_in_slot:
				node.remove_card_from_memory(card)
				break

func is_card_in_memory_slot(card):
	if not card or not is_instance_valid(card):
		return false
	var memory_slots = get_tree().get_nodes_in_group("memory_slots")
	for memory_slot in memory_slots:
		if is_instance_valid(memory_slot) and card in memory_slot.cards_in_slot:
			return true
	var all_nodes = get_tree().get_nodes_in_group("")
	for node in all_nodes:
		if node.name == "MEMORY" and is_instance_valid(node) and card in node.cards_in_slot:
			return true
	return false

func get_memory_slot_for_card(card):
	if not card or not is_instance_valid(card):
		return null
	var memory_slots = get_tree().get_nodes_in_group("memory_slots")
	for memory_slot in memory_slots:
		if is_instance_valid(memory_slot) and card in memory_slot.cards_in_slot:
			return memory_slot
	var all_nodes = get_tree().get_nodes_in_group("")
	for node in all_nodes:
		if node.name == "MEMORY" and is_instance_valid(node) and card in node.cards_in_slot:
			return node
	return null
