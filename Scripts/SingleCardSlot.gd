extends Node2D

var cards_in_graveyard = []
var card_in_slot = false
var base_z_index = 0
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
	var card_control = Control.new()
	card_control.custom_minimum_size = Vector2(125, 180)
	var texture_rect = TextureRect.new()
	texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var card_image_path = "res://Assets/Grand Archive/Card Images/" + card_name + ".png"
	if ResourceLoader.exists(card_image_path):
		texture_rect.texture = load(card_image_path)
	else:
		var label = Label.new()
		label.text = card_name
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		card_control.add_child(label)
	card_control.add_child(texture_rect)
	return card_control

func show_deck_view():
	update_deck_view()
	graveyard_view_window.popup_centered()

func _on_deck_view_close():
	graveyard_view_window.hide()

func add_card_to_slot(card):
	cards_in_graveyard.append(card)
	card.global_position = global_position
	card.z_index = base_z_index + cards_in_graveyard.size()
	card_in_slot = true
	if graveyard_view_window.visible:
		update_deck_view()

func remove_card_from_slot(card):
	if card in cards_in_graveyard:
		cards_in_graveyard.erase(card)
		if cards_in_graveyard.is_empty():
			card_in_slot = false

func get_top_card():
	return null

func bring_card_to_front(card):
	pass

func clear_hovered_card():
	pass
