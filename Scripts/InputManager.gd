extends Node2D

signal left_mouse_button_clicked
signal left_mouse_button_released

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_DECK = 4

var card_manager_reference
var deck_reference

func _ready():
	card_manager_reference = $"../CardManager"
	deck_reference = $"../GA_DECK"

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			emit_signal("left_mouse_button_clicked")
			if not card_manager_reference.animation_in_progress:
				card_manager_reference.validate_references()
				var card = raycast_for_card()
				if card and card_manager_reference.can_drag_card(card):
					card_manager_reference.start_drag(card)
		else:
			emit_signal("left_mouse_button_released")
	if event is InputEventMouseMotion:
		card_manager_reference.validate_references()
		card_manager_reference.handle_hover()

func raycast_for_card():
	var space_state = get_world_2d().direct_space_state
	if !space_state:
		return null
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD | COLLISION_MASK_CARD_DECK
	parameters.collide_with_bodies = false
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		for collision in result:
			var collider = collision.collider
			if collider.collision_layer & COLLISION_MASK_CARD_DECK:
				deck_reference.draw_card()
				return null
		var highest_card = null
		var highest_z_index = -9999
		for collision in result:
			var collider = collision.collider
			if collider.collision_layer & COLLISION_MASK_CARD:
				var card = collider.get_parent()
				if card and is_instance_valid(card) and card.z_index > highest_z_index:
					highest_card = card
					highest_z_index = card.z_index
		return highest_card
	return null
