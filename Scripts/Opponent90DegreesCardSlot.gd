extends Node2D

var cards_in_banish = []
var card_in_slot = false
var base_z_index = 0
var selected_card_slug: String = ""

@onready var context_menu = $PopupMenu
@onready var banish_view_window = $BanishViewWindow
@onready var grid_container = $BanishViewWindow/ScrollContainer/GridContainer
@onready var area2d = $Area2D

func _ready() -> void:
	add_to_group("rotated_slots")
	setup_context_menu()
	setup_deck_view()
	if area2d and not area2d.input_event.is_connected(_on_area_2d_input_event):
		area2d.input_event.connect(_on_area_2d_input_event)

func update_deck_view():
	for child in grid_container.get_children():
		child.queue_free()
	for card in cards_in_banish:
		var card_slug = card.get_meta("slug") if card.has_meta("slug") else (card.card_name if card.has_method("card_name") else card.name)
		var card_display = create_card_display(card_slug)
		grid_container.add_child(card_display)
		var tex_rect = card_display.get_node_or_null("TextureRect")
		if tex_rect:
			var image_path = "res://Assets/Grand Archive/Card Images/" + card_slug + ".png"
			if card.has_meta("is_face_down") and card.get_meta("is_face_down") == true:
				image_path = "res://Assets/Grand Archive/ga_back.png"
			if ResourceLoader.exists(image_path):
				tex_rect.texture = load(image_path)
		grid_container.move_child(card_display, 0)

func setup_context_menu():
	context_menu.clear()
	context_menu.add_item("View Banish", 0)
	context_menu.id_pressed.connect(_on_context_menu_pressed)

func setup_deck_view():
	banish_view_window.close_requested.connect(_on_deck_view_close)
	banish_view_window.hide()

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
	card_display.set_meta("zone", "banish")
	return card_display

func show_card_back(card):
	if not card or not is_instance_valid(card):
		return
	var card_image = card.get_node_or_null("CardImage")
	var card_image_back = card.get_node_or_null("CardImageBack")
	if not card.has_meta("original_card_texture"):
		if card_image and card_image.texture:
			card.set_meta("original_card_texture", card_image.texture)
	if card_image and card_image_back:
		card_image_back.z_index = 0
		card_image.z_index = -1
		card_image_back.visible = true
		card_image.visible = false
		card.set_meta("is_face_down", true)
	if banish_view_window.visible:
		update_deck_view()

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
		card.set_meta("is_face_down", false)

func show_deck_view():
	update_deck_view()
	banish_view_window.popup_centered()
	$BanishViewWindow/ScrollContainer.call_deferred("set", "scroll_horizontal", 0)
	$BanishViewWindow/ScrollContainer.call_deferred("set", "scroll_vertical", 0)

func _on_deck_view_close():
	banish_view_window.hide()
	selected_card_slug = ""

func add_card_to_slot(card, face_down := false):
	if not card or not is_instance_valid(card):
		return
	if card.has_method("is_token") and card.is_token():
		if card.has_method("destroy_token"):
			card.destroy_token()
		return
	if card.has_method("set_current_field"):
		card.set_current_field(self)
	cards_in_banish.append(card)
	var target_pos := Vector2()
	if has_node("Area2D/CollisionShape2D"):
		target_pos = $Area2D/CollisionShape2D.global_position
	else:
		target_pos = global_position
	card.visible = true
	if card.has_node("Area2D"):
		card.get_node("Area2D").set_deferred("input_pickable", false)
	if face_down:
		if has_method("show_card_back"):
			show_card_back(card)
	else:
		if has_method("show_card_front"):
			show_card_front(card)
	var tween = create_tween()
	tween.parallel().tween_property(card, "global_position", target_pos, 0.3)
	tween.parallel().tween_property(card, "rotation_degrees", 90.0, 0.3)
	card.z_index = base_z_index + cards_in_banish.size()
	card_in_slot = true
	if banish_view_window.visible:
		call_deferred("update_deck_view")

func remove_card_from_slot(card):
	if card in cards_in_banish:
		if card.has_method("set_current_field"):
			card.set_current_field(null)
		cards_in_banish.erase(card)
		if cards_in_banish.is_empty():
			card_in_slot = false
		reorder_z_indices()
		if banish_view_window.visible:
			update_deck_view()

func reorder_z_indices():
	var idx := 0
	for c in cards_in_banish:
		if c and is_instance_valid(c):
			c.z_index = base_z_index + idx + 1
			idx += 1

func get_top_card():
	return null

func remove_card_by_slug(slug: String):
	var target_card = null
	for card in cards_in_banish:
		var card_slug = card.get_meta("slug") if card.has_meta("slug") else (card.card_name if card.has_method("card_name") else card.name)
		if card_slug == slug:
			target_card = card
			break
	if target_card:
		remove_card_from_slot(target_card)
		target_card.queue_free()
		if banish_view_window.visible:
			update_deck_view()
