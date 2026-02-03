extends Node2D

var cards_in_graveyard = []
var card_in_slot = false
var base_z_index = 0
var selected_card_slug: String = ""
var selected_card_uuid: String = ""
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
	$GraveyardViewWindow/PopupMenu.id_pressed.connect(_on_graveyard_view_popup_menu_pressed)

func update_deck_view():
	for child in grid_container.get_children():
		child.queue_free()
	for card in cards_in_graveyard:
		var card_slug = card.get_meta("slug") if card.has_meta("slug") else (card.card_name if card.has_method("card_name") else card.name)
		var card_uuid = card.uuid if "uuid" in card else ""
		var card_display = create_card_display(card_slug, card_uuid)
		if card_uuid in marked_uuids:
			card_display.modulate = Color(0.5, 0.5, 1.5, 0.9)
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
		card_display.modulate = Color(0.5, 0.5, 1.5, 0.9)
		card_display.set_meta("is_marked", true)
	card_display.request_popup_menu.connect(_on_card_display_popup_menu)
	return card_display

func _on_card_display_popup_menu(slug, uuid):
	selected_card_slug = slug
	selected_card_uuid = uuid
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
	var card_uuid = target_card.uuid if "uuid" in target_card else ""
	remove_card_from_slot(target_card)
	if banish_node.has_method("add_card_to_slot"):
		banish_node.add_card_to_slot(target_card, true)
	if banish_node.has_method("show_card_back"):
		banish_node.show_card_back(target_card)
	var multiplayer_node = get_tree().get_root().get_node_or_null("Main")
	if multiplayer_node and multiplayer_node.has_method("rpc"):
		multiplayer_node.rpc("sync_move_to_banish", multiplayer.get_unique_id(), card_uuid, selected_card_slug, true)
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
		var c_uuid = card.uuid if "uuid" in card else ""
		if c_uuid == selected_card_uuid:
			target_card = card
			break
	if not target_card:
		for card in cards_in_graveyard:
			var card_slug = card.get_meta("slug") if card.has_meta("slug") else (card.card_name if card.has_method("card_name") else card.name)
			if card_slug == selected_card_slug:
				target_card = card
				break
	if not target_card:
		return
	var card_uuid_to_send = target_card.uuid if "uuid" in target_card else ""
	animate_card_to_deck_from_graveyard(target_card, deck_node.global_position, selected_card_slug, card_uuid_to_send, true)
	_sync_move_to_deck(card_uuid_to_send, true)
	selected_card_slug = ""
	selected_card_uuid = ""

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
		var c_uuid = card.uuid if "uuid" in card else ""
		if c_uuid == selected_card_uuid:
			target_card = card
			break
	if not target_card:
		for card in cards_in_graveyard:
			var card_slug = card.get_meta("slug") if card.has_meta("slug") else (card.card_name if card.has_method("card_name") else card.name)
			if card_slug == selected_card_slug:
				target_card = card
				break
	if not target_card:
		return
	var card_uuid_to_send = target_card.uuid if "uuid" in target_card else ""
	animate_card_to_deck_from_graveyard(target_card, deck_node.global_position, selected_card_slug, card_uuid_to_send, false)
	_sync_move_to_deck(card_uuid_to_send, false)
	selected_card_slug = ""
	selected_card_uuid = ""

func _sync_move_to_deck(uuid: String, is_top: bool):
	var multiplayer_node = get_tree().get_root().get_node_or_null("Main")
	if multiplayer_node and multiplayer_node.has_method("rpc"):
		multiplayer_node.rpc("sync_move_to_deck", multiplayer.get_unique_id(), uuid, is_top)

func animate_card_to_deck_from_graveyard(card, deck_position: Vector2, slug: String, card_uuid: String, is_top: bool):
	remove_card_from_slot(card)
	var card_image = card.get_node("CardImage")
	var original_texture = card_image.texture
	card_image.texture = load("res://Assets/Grand Archive/ga_back.png")
	if is_top:
		card.z_index = 2
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(card, "global_position", deck_position, 0.5)
	tween.tween_callback(_on_graveyard_deck_animation_completed.bind(card, slug, card_uuid, is_top, original_texture)).set_delay(0.5)

func _on_graveyard_deck_animation_completed(card, slug: String, card_uuid: String, is_top: bool, original_texture: Texture2D):
	var card_image = card.get_node("CardImage")
	card_image.texture = original_texture
	var deck_nodes = get_tree().get_nodes_in_group("deck_zones")
	if deck_nodes.size() > 0:
		var deck_node = deck_nodes[0]
		if is_top and deck_node.has_method("add_to_top"):
			deck_node.add_to_top(slug, card_uuid)
		elif not is_top and deck_node.has_method("add_to_bottom"):
			deck_node.add_to_bottom(slug, card_uuid)
	card.queue_free()
	if graveyard_view_window.visible:
		update_deck_view()

func show_deck_view():
	update_deck_view()
	graveyard_view_window.popup_centered()
	$GraveyardViewWindow/ScrollContainer.call_deferred("set", "scroll_horizontal", 0)
	$GraveyardViewWindow/ScrollContainer.call_deferred("set", "scroll_vertical", 0)

func _on_deck_view_close():
	graveyard_view_window.hide()
	selected_card_slug = ""

func add_card_to_slot(card, at_index: int = -1):
	if not card or not is_instance_valid(card):
		return
	if card.has_method("is_token") and card.is_token():
		if card.has_method("destroy_token"):
			card.destroy_token()
		return
	var final_card = card
	if card.get_parent() != self:
		var saved_uuid = card.uuid if "uuid" in card else ""
		final_card = card.duplicate()
		add_child(final_card)
		if saved_uuid != "" and "uuid" in final_card:
			final_card.uuid = saved_uuid
		if card.has_meta("slug"):
			final_card.set_meta("slug", card.get_meta("slug"))
		final_card.global_position = card.global_position
		final_card.rotation = card.rotation
		card.queue_free()
	final_card.visible = true
	if final_card.has_method("set_current_field"):
		final_card.set_current_field(self)
	if final_card.has_method("show_card_front"):
		final_card.show_card_front()
	else:
		var ci = final_card.get_node_or_null("CardImage")
		var cib = final_card.get_node_or_null("CardImageBack")
		if ci and cib:
			ci.visible = true
			cib.visible = false
	final_card.rotation = 0.0
	
	if at_index != -1 and at_index < cards_in_graveyard.size():
		cards_in_graveyard.insert(at_index, final_card)
	else:
		cards_in_graveyard.append(final_card)
		
	reorder_z_indices()
	var card_manager = get_tree().current_scene.find_child("CardManager", true, false)
	if card_manager and card_manager.has_method("connect_card_signals"):
		card_manager.connect_card_signals(final_card)
	var target_pos := Vector2()
	if has_node("Area2D/CollisionShape2D"):
		target_pos = $Area2D/CollisionShape2D.global_position
	else:
		target_pos = global_position
	final_card.visible = true
	if final_card.has_node("Area2D"):
		final_card.get_node("Area2D").set_deferred("input_pickable", false)
	final_card.global_position = target_pos
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
		var card_slug = card.get_meta("slug") if card.has_meta("slug") else (card.card_name if card.has_method("card_name") else card.name)
		if card_slug == slug:
			target_card = card
			break
	if target_card:
		remove_card_from_slot(target_card)
		target_card.queue_free()
		if graveyard_view_window.visible:
			update_deck_view()

func remove_card_by_uuid(uuid: String):
	if uuid == "": return
	var target_card = null
	for card in cards_in_graveyard:
		if "uuid" in card and card.uuid == uuid:
			target_card = card
			break
	if target_card:
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
		top_card.modulate = Color(0.5, 0.5, 1.5, 0.9)
	else:
		top_card.modulate = Color(1, 1, 1)

func add_card_to_slot_precise(card, left_uuid: String, right_uuid: String, fallback_index: int):
	var target_array_index = -1
	if left_uuid != "":
		for i in range(cards_in_graveyard.size()):
			if cards_in_graveyard[i].has_meta("uuid") and cards_in_graveyard[i].get_meta("uuid") == left_uuid:
				target_array_index = i
				break
	elif right_uuid != "":
		for i in range(cards_in_graveyard.size()):
			if cards_in_graveyard[i].has_meta("uuid") and cards_in_graveyard[i].get_meta("uuid") == right_uuid:
				target_array_index = i + 1
				break
	if target_array_index == -1:
		target_array_index = cards_in_graveyard.size() - fallback_index
	target_array_index = clampi(target_array_index, 0, cards_in_graveyard.size())
	add_card_to_slot(card, target_array_index)
