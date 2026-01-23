extends Node2D

var cards_in_graveyard = []
var card_in_slot = false
var base_z_index = 0
var selected_card_slug: String = ""
var marked_uuids : Array = []

@onready var context_menu = $PopupMenu
@onready var graveyard_view_window = $GraveyardViewWindow
@onready var grid_container = $GraveyardViewWindow/ScrollContainer/GridContainer
@onready var area2d = $Area2D

func _ready() -> void:
	add_to_group("single_card_slots")
	setup_context_menu()
	setup_deck_view()
	if area2d and not area2d.input_event.is_connected(_on_area_2d_input_event):
		area2d.input_event.connect(_on_area_2d_input_event)

func update_deck_view():
	for child in grid_container.get_children():
		child.queue_free()
	for card in cards_in_graveyard:
		if not is_instance_valid(card):
			continue
		var card_slug = card.get_meta("slug") if card.has_meta("slug") else (card.card_name if card.has_method("card_name") else card.get_name())
		var card_uuid = card.uuid if "uuid" in card else ""
		var card_display = create_card_display(card_slug, card_uuid)
		if card_uuid in marked_uuids:
			card_display.modulate = Color(1.5, 0.5, 0.5, 0.9)
			card_display.set_meta("is_marked", true)
		grid_container.add_child(card_display)
		grid_container.move_child(card_display, 0)

func setup_context_menu():
	context_menu.clear()
	context_menu.add_item("View Graveyard", 0)
	context_menu.id_pressed.connect(_on_context_menu_pressed)

func setup_deck_view():
	graveyard_view_window.close_requested.connect(_on_deck_view_close)
	graveyard_view_window.hide()

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			context_menu.position = get_global_mouse_position()
			context_menu.popup()

func _on_context_menu_pressed(id):
	match id:
		0: view_deck()

func view_deck():
	show_deck_view()

func create_card_display(card_name: String, card_uuid: String = ""):
	var card_display_scene = preload("res://Scenes/CardDisplay.tscn")
	var card_display = card_display_scene.instantiate()
	card_display.set_meta("slug", card_name)
	card_display.set_meta("uuid", card_uuid)
	card_display.set_meta("zone", "graveyard")
	if card_uuid != "" and card_uuid in marked_uuids:
		card_display.modulate = Color(1.5, 0.5, 0.5, 0.9)
		card_display.set_meta("is_marked", true)
	return card_display

func show_deck_view():
	update_deck_view()
	graveyard_view_window.popup_centered()
	$GraveyardViewWindow/ScrollContainer.call_deferred("set", "scroll_horizontal", 0)
	$GraveyardViewWindow/ScrollContainer.call_deferred("set", "scroll_vertical", 0)

func _on_deck_view_close():
	graveyard_view_window.hide()
	selected_card_slug = ""

func add_card_to_slot(card):
	if not card or not is_instance_valid(card):
		return
	if card.has_method("is_token") and card.is_token():
		if card.has_method("destroy_token"):
			card.destroy_token()
		return
	if card.has_method("set_current_field"):
		card.set_current_field(self)
	cards_in_graveyard.append(card)
	var target_pos := Vector2()
	if has_node("Area2D/CollisionShape2D"):
		target_pos = $Area2D/CollisionShape2D.global_position
	else:
		target_pos = global_position
	card.visible = true
	if card.has_node("Area2D"):
		card.get_node("Area2D").set_deferred("input_pickable", false)
	var tween = create_tween()
	tween.parallel().tween_property(card, "global_position", target_pos, 0.3)
	tween.parallel().tween_property(card, "rotation", 0.0, 0.3)
	if card.has_node("AnimationPlayer"):
		var ap = card.get_node("AnimationPlayer")
		if ap.has_animation("card_flip"):
			ap.play("card_flip")
	reorder_z_indices()
	card_in_slot = true
	update_top_card_visual()
	if graveyard_view_window.visible:
		update_deck_view()

func remove_card_from_slot(card):
	if card in cards_in_graveyard:
		if card.has_method("set_current_field"):
			card.set_current_field(null)
		cards_in_graveyard.erase(card)
		var uuid = card.uuid if "uuid" in card else ""
		if uuid != "" and uuid in marked_uuids:
			marked_uuids.erase(uuid)
		if is_instance_valid(card):
			card.modulate = Color(1, 1, 1)
			if card.has_meta("is_marked"):
				card.set_meta("is_marked", false)
		reorder_z_indices()
		update_top_card_visual()
		if graveyard_view_window.visible:
			update_deck_view()

func reorder_z_indices():
	var idx := 0
	for card in cards_in_graveyard:
		if card and is_instance_valid(card):
			card.z_index = base_z_index + idx + 1
			idx += 1

func get_top_card():
	return null

func remove_card_by_slug(slug: String):
	var target_card = null
	for card in cards_in_graveyard:
		if not is_instance_valid(card):
			continue
		var card_slug = card.get_meta("slug") if card.has_meta("slug") else (card.card_name if card.has_method("card_name") else card.get_name())
		if card_slug == slug:
			target_card = card
			break
	if target_card and is_instance_valid(target_card):
		remove_card_from_slot(target_card)
		target_card.queue_free()
		if graveyard_view_window.visible:
			update_deck_view()

func set_card_marked(uuid: String, is_marked: bool):
	if is_marked:
		if not uuid in marked_uuids:
			marked_uuids.append(uuid)
	else:
		marked_uuids.erase(uuid)
	update_top_card_visual()
	if graveyard_view_window.visible:
		update_deck_view()

func update_top_card_visual():
	if cards_in_graveyard.is_empty():
		return
	var top_card = cards_in_graveyard[-1]
	if not is_instance_valid(top_card):
		return
	if marked_uuids.size() > 0:
		top_card.modulate = Color(1.5, 0.5, 0.5, 0.9)
	else:
		top_card.modulate = Color(1, 1, 1)
