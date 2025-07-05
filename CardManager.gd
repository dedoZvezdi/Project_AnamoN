extends Node2D

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SINGLE_SLOT = 2

var screen_size
var card_being_dragged = null
var last_hovered_card = null
var normal_scale = Vector2(0.349, 0.349)
var hover_scale = Vector2(0.39, 0.39)
var base_z_index = 0
var hover_z_index = 10
var drag_z_index = 20
var card_counter = 0
var player_hand_reference

func _ready() -> void:
	player_hand_reference = $"../PlayerHand"
	update_screen_size()
	get_viewport().connect("size_changed", Callable(self, "update_screen_size"))
	for card in get_tree().get_nodes_in_group("cards"):
		connect_card_signals(card)
		card.z_index = base_z_index
		
func update_screen_size():
	screen_size = get_viewport_rect().size

func _process(_delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(
			clamp(mouse_pos.x, 0, screen_size.x),
			clamp(mouse_pos.y, 0, screen_size.y)
		)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var card = raycast_check_for_card()
			if card:
				start_drag(card)
		elif card_being_dragged:  
			finish_drag()
	if event is InputEventMouseMotion:
		handle_hover()

func start_drag(card):
	card_being_dragged = card
	card.get_parent().move_child(card, card.get_parent().get_child_count())
	card.z_index = drag_z_index
	card.scale = normal_scale
	card.rotation = 0.0
	if last_hovered_card and last_hovered_card != card:
		if not last_hovered_card.get_node("Area2D/CollisionShape2D").disabled:
			last_hovered_card.scale = normal_scale
			last_hovered_card.z_index = base_z_index
		last_hovered_card = null

func finish_drag():
	var card_slot_found = raycast_check_for_card_single_slot()
	if card_slot_found:
		player_hand_reference.remove_card_from_hand(card_being_dragged)
		if card_slot_found.name == "MEMORY":
			card_slot_found.add_card_to_memory(card_being_dragged)
			card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
			card_being_dragged.scale = hover_scale
			card_being_dragged.z_index = base_z_index
		elif not card_slot_found.card_in_slot:
			card_being_dragged.position = card_slot_found.position
			card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
			card_slot_found.card_in_slot = true
			card_being_dragged.scale = hover_scale
			card_being_dragged.z_index = base_z_index
			if card_slot_found.name == "90DegreesCardSlot" or card_slot_found.is_in_group("rotated_slots"):
				card_being_dragged.rotation_degrees = -90
		else:
			card_being_dragged.z_index = base_z_index + card_counter
			card_counter += 1
	else:
		player_hand_reference.add_card_to_hand(card_being_dragged)
		card_being_dragged.z_index = base_z_index + card_counter
		card_counter += 1
	card_being_dragged = null
	call_deferred("force_hover_check")

func force_hover_check():
	handle_hover()
	var mouse_pos = get_global_mouse_position()
	var card = raycast_check_at_position(mouse_pos)
	if card:
		_on_card_hovered(card)

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
			if card.z_index > highest_z:
				highest_card = card
				highest_z = card.z_index
		return highest_card
	return null

func handle_hover():
	if card_being_dragged: 
		return
	var current_card = raycast_check_for_card()
	if current_card != last_hovered_card:
		if last_hovered_card:
			if not last_hovered_card.get_node("Area2D/CollisionShape2D").disabled:
				last_hovered_card.scale = normal_scale
				last_hovered_card.z_index = base_z_index
		if current_card:
			current_card.get_parent().move_child(current_card, current_card.get_parent().get_child_count())
			current_card.scale = hover_scale
			current_card.z_index = hover_z_index
		last_hovered_card = current_card

func connect_card_signals(card):
	if card.get_node("Area2D").is_connected("mouse_entered", Callable(self, "_on_card_hovered")):
		card.get_node("Area2D").disconnect("mouse_entered", Callable(self, "_on_card_hovered"))
	if card.get_node("Area2D").is_connected("mouse_exited", Callable(self, "_on_card_unhovered")):
		card.get_node("Area2D").disconnect("mouse_exited", Callable(self, "_on_card_unhovered"))
	card.get_node("Area2D").connect("mouse_entered", Callable(self, "_on_card_hovered").bind(card))
	card.get_node("Area2D").connect("mouse_exited", Callable(self, "_on_card_unhovered").bind(card))

func _on_card_hovered(card):
	if card != card_being_dragged:
		card.get_parent().move_child(card, card.get_parent().get_child_count())
		card.scale = hover_scale
		card.z_index = hover_z_index
		if last_hovered_card and last_hovered_card != card:
			if not last_hovered_card.get_node("Area2D/CollisionShape2D").disabled:
				last_hovered_card.scale = normal_scale
				last_hovered_card.z_index = base_z_index
		last_hovered_card = card

func _on_card_unhovered(card):
	if card != card_being_dragged and card == last_hovered_card:
		if not card.get_node("Area2D/CollisionShape2D").disabled:
			card.scale = normal_scale
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
