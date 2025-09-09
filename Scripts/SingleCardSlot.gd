extends Node2D

var cards_in_graveyard = []
var card_in_slot = false
var base_z_index = 0
var selected_card_slug: String = ""

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
	$GraveyardViewWindow/PopupMenu.id_pressed.connect(_on_graveyard_view_popup_menu_pressed)

func update_deck_view():
	for child in grid_container.get_children():
		child.queue_free()
	for card in cards_in_graveyard:
		var card_slug = card.get_meta("slug") if card.has_meta("slug") else (card.card_name if card.has_method("card_name") else card.name)
		var card_display = create_card_display(card_slug)
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

func create_card_display(card_name: String):
	var card_display_scene = preload("res://Scenes/CardDisplay.tscn")
	var card_display = card_display_scene.instantiate()
	card_display.set_meta("slug", card_name)
	card_display.set_meta("zone", "graveyard")
	card_display.request_popup_menu.connect(_on_card_display_popup_menu)
	return card_display

func _on_card_display_popup_menu(slug):
	selected_card_slug = slug
	var popup_menu = $GraveyardViewWindow/PopupMenu
	popup_menu.clear()
	popup_menu.add_item("Banish Face Down", 0)
	popup_menu.add_item("To Top Deck", 1)
	popup_menu.add_item("To Bottom Deck", 2)
	popup_menu.popup(Rect2(get_viewport().get_mouse_position(), Vector2(0, 0)))

func _on_graveyard_view_popup_menu_pressed(id):
	match id:
		0: go_to_banish_face_down()
		1: go_to_top_deck()
		2: go_to_bottom_deck()

func go_to_banish_face_down():
	if selected_card_slug == "":
		return
	var target_card = null
	for card in cards_in_graveyard:
		var card_slug = card.get_meta("slug") if card.has_meta("slug") else (card.card_name if card.has_method("card_name") else card.name)
		if card_slug == selected_card_slug:
			target_card = card
			break
	if not target_card:
		return
	var scene = get_tree().get_current_scene()
	if scene == null:
		return
	var banish_node = scene.find_child("BANISH", true, false)
	if banish_node == null:
		return
	remove_card_from_slot(target_card)
	if banish_node.has_method("add_card_to_slot"):
		banish_node.add_card_to_slot(target_card)
	if banish_node.has_method("show_card_back"):
		banish_node.show_card_back(target_card)
	if graveyard_view_window.visible:
		update_deck_view()
	selected_card_slug = ""

func go_to_top_deck():
	if selected_card_slug == "":
		return
	var deck_nodes = get_tree().get_nodes_in_group("deck_zones")
	if deck_nodes.size() == 0:
		return
	var deck_node = deck_nodes[0]
	if not deck_node.has_method("add_to_top"):
		return
	var target_card = null
	for card in cards_in_graveyard:
		var card_slug = card.get_meta("slug") if card.has_meta("slug") else (card.card_name if card.has_method("card_name") else card.name)
		if card_slug == selected_card_slug:
			target_card = card
			break
	if not target_card:
		return
	remove_card_from_slot(target_card)
	target_card.queue_free()
	deck_node.add_to_top(selected_card_slug)
	if graveyard_view_window.visible:
		update_deck_view()
	selected_card_slug = ""

func go_to_bottom_deck():
	if selected_card_slug == "":
		return
	var deck_nodes = get_tree().get_nodes_in_group("deck_zones")
	if deck_nodes.size() == 0:
		return
	var deck_node = deck_nodes[0]
	if not deck_node.has_method("add_to_bottom"):
		return
	var target_card = null
	for card in cards_in_graveyard:
		var card_slug = card.get_meta("slug") if card.has_meta("slug") else (card.card_name if card.has_method("card_name") else card.name)
		if card_slug == selected_card_slug:
			target_card = card
			break
	if not target_card:
		return
	remove_card_from_slot(target_card)
	target_card.queue_free()
	deck_node.add_to_bottom(selected_card_slug)
	if graveyard_view_window.visible:
		update_deck_view()
	selected_card_slug = ""

func show_deck_view():
	update_deck_view()
	graveyard_view_window.popup_centered()
	$GraveyardViewWindow/ScrollContainer.call_deferred("set", "scroll_horizontal", 0)
	$GraveyardViewWindow/ScrollContainer.call_deferred("set", "scroll_vertical", 0)

func _on_deck_view_close():
	graveyard_view_window.hide()
	selected_card_slug = ""

func add_card_to_slot(card):
	if card.has_method("set_current_field"):
		card.set_current_field(self)
	cards_in_graveyard.append(card)
	card.global_position = global_position
	card.z_index = base_z_index + cards_in_graveyard.size()
	card_in_slot = true
	if graveyard_view_window.visible:
		update_deck_view()

func remove_card_from_slot(card):
	if card in cards_in_graveyard:
		if card.has_method("set_current_field"):
			card.set_current_field(null)
		cards_in_graveyard.erase(card)
		if cards_in_graveyard.is_empty():
			card_in_slot = false
		if graveyard_view_window.visible:
			update_deck_view()

func get_top_card():
	return null
