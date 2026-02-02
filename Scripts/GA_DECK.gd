extends Node2D

const CARD_SCENE_PATH = "res://Scenes/Card.tscn"

var player_deck = ["fabled-ruby-fatestone-hvn1e","excalibur-reflected-edge-dtr1e","lu-bu-indomitable-titan-hvn1e-cur","lu-bu-wrath-incarnate-hvn1e-cur","alice-golden-queen-dtr1e-cur","aetheric-calibration-dtrsd","alice-golden-queen-dtr","academy-guide-p24", "absolving-flames-amb","acolyte-of-cultivation-amb","acolyte-of-cultivation-amb"
,"suzaku-vermillion-phoenix-hvn1e-csr","acolyte-of-cultivation-amb","arcane-disposition-doap","arthur-young-heir-evp","suzaku-vermillion-phoenix-hvn1e"]
var card_database_reference
var selected_card_slug: String = ""
var selected_card_uuid: String = ""

@onready var context_menu = $PopupMenu
@onready var deck_view_window = $DeckViewWindow
@onready var grid_container = $DeckViewWindow/ScrollContainer/GridContainer

func _ready() -> void:
	add_to_group("deck_zones")
	var deck_with_uuids = []
	for slug in player_deck:
		var card_uuid = str(Time.get_unix_time_from_system()) + "_" + str(get_instance_id()) + "_" + str(randi())
		deck_with_uuids.append({"slug": slug, "uuid": card_uuid})
	player_deck = deck_with_uuids
	player_deck.shuffle()
	card_database_reference = preload("res://Scripts/CardDatabase.gd")
	setup_context_menu()
	setup_deck_view()
	$Area2D.input_event.connect(_on_area_2d_input_event)
	update_deck_state()
	
@rpc("any_peer")
func draw_here_and_for_peer(player_id, card_drawn_name, card_uuid := ""):
	if multiplayer.get_unique_id() == player_id:
		draw_card(card_drawn_name, card_uuid)
	else:
		var opp_deck = get_parent().get_parent().get_node_or_null("OpponentField/OpponentDeck")
		if opp_deck and opp_deck.has_method("draw_card"):
			opp_deck.draw_card(card_drawn_name, card_uuid)

func draw_clicked():
	var player_id = multiplayer.get_unique_id()
	if player_deck.size() == 0:
		return
	var card_data = player_deck[0]
	var slug = card_data["slug"]
	var card_uuid = card_data["uuid"]
	draw_here_and_for_peer(player_id, slug, card_uuid)
	rpc("draw_here_and_for_peer", player_id, slug, card_uuid)
	
func setup_context_menu():
	context_menu.add_item("View Deck", 0)
	context_menu.add_item("Shuffle Deck", 1)
	context_menu.add_item("Draw to Memory", 2)
	context_menu.add_item("Sent top card to GY", 3)
	context_menu.add_item("Banish top card FD", 4)
	context_menu.add_item("Banish top card FU", 5)
	context_menu.id_pressed.connect(_on_context_menu_pressed)

func setup_deck_view():
	deck_view_window.close_requested.connect(_on_deck_view_close)
	deck_view_window.hide()
	$DeckViewWindow/PopupMenu.id_pressed.connect(_on_deck_view_popup_menu_pressed)

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			context_menu.position = get_global_mouse_position()
			context_menu.popup()

func _on_context_menu_pressed(id):
	match id:
		0: view_deck()
		1: shuffle_deck()
		2: draw_to_memory()
		3: send_top_to_gy()
		4: banish_top_fd()
		5: banish_top_fu()

func view_deck():
	show_deck_view()

func update_deck_view():
	if not deck_view_window.visible:
		return
	for child in grid_container.get_children():
		child.queue_free()
	for card_data in player_deck:
		var card_display = create_card_display(card_data["slug"], card_data["uuid"])
		grid_container.add_child(card_display)
	grid_container.call_deferred("queue_sort")

func show_deck_view():
	deck_view_window.popup_centered()
	update_deck_view()
	$DeckViewWindow/ScrollContainer.call_deferred("set", "scroll_horizontal", 0)
	$DeckViewWindow/ScrollContainer.call_deferred("set", "scroll_vertical", 0)
	if has_node("Sprite2D"):
		$Sprite2D.modulate = Color(0.5, 0.5, 1.5, 0.9)

func create_card_display(card_name: String, card_uuid: String):
	var card_display_scene = preload("res://Scenes/CardDisplay.tscn")
	var card_display = card_display_scene.instantiate()
	card_display.set_meta("slug", card_name)
	card_display.set_meta("uuid", card_uuid)
	card_display.set_meta("zone", "ga_deck")
	card_display.request_popup_menu.connect(_on_card_display_popup_menu)
	return card_display

func _on_card_display_popup_menu(_slug, card_uuid):
	selected_card_uuid = card_uuid
	var popup_menu = $DeckViewWindow/PopupMenu
	popup_menu.clear()
	popup_menu.add_item("Go Top Deck", 0)
	popup_menu.add_item("Go Bottom Deck", 1)
	popup_menu.popup(Rect2(get_viewport().get_mouse_position(), Vector2(0, 0)))

func _on_deck_view_popup_menu_pressed(id):
	match id:
		0: move_card_to_top()
		1: move_card_to_bottom()

func move_card_to_top():
	if selected_card_uuid == "":
		return
	var card_index = -1
	for i in range(player_deck.size()):
		if player_deck[i]["uuid"] == selected_card_uuid:
			card_index = i
			break
	if card_index == -1:
		return
	var card_data = player_deck[card_index]
	player_deck.remove_at(card_index)
	player_deck.insert(0, card_data)
	update_deck_view()
	selected_card_uuid = ""

func move_card_to_bottom():
	if selected_card_uuid == "":
		return
	var card_index = -1
	for i in range(player_deck.size()):
		if player_deck[i]["uuid"] == selected_card_uuid:
			card_index = i
			break
	if card_index == -1:
		return
	var card_data = player_deck[card_index]
	player_deck.remove_at(card_index)
	player_deck.append(card_data)
	update_deck_view()
	selected_card_uuid = ""

func draw_to_memory():
	var slug = ""
	var card_uuid = ""
	if selected_card_uuid != "":
		for i in range(player_deck.size()):
			if player_deck[i]["uuid"] == selected_card_uuid:
				slug = player_deck[i]["slug"]
				card_uuid = player_deck[i]["uuid"]
				player_deck.remove_at(i)
				break
	elif player_deck.size() > 0:
		slug = player_deck[0]["slug"]
		card_uuid = player_deck[0]["uuid"]
		player_deck.remove_at(0)
	if slug == "":
		return
	var memory_node = get_tree().current_scene.find_child("MEMORY", true, false)
	if memory_node:
		var main_node = get_tree().get_root().get_node("Main")
		if main_node:
			main_node.rpc("sync_move_to_memory", multiplayer.get_unique_id(), card_uuid, slug)
		var final_position = memory_node.calculate_final_position_for_new_card()
		memory_node.arrange_cards_symmetrically(true)
		_animate_deck_card_to_zone(slug, card_uuid, final_position, memory_node, "add_card_to_memory", true, "", false)
	update_deck_view()
	update_deck_state()
	selected_card_uuid = ""

func send_top_to_gy():
	if player_deck.size() == 0:
		return
	var card_data = player_deck[0]
	var slug = card_data["slug"]
	var card_uuid = card_data["uuid"]
	player_deck.remove_at(0)
	var graveyard_node = get_parent().get_parent().find_child("GRAVEYARD", true, false)
	if graveyard_node:
		var main_node = get_tree().get_root().get_node("Main")
		if main_node:
			main_node.rpc("sync_move_to_graveyard", multiplayer.get_unique_id(), card_uuid, slug, true)
		_animate_deck_card_to_zone(slug, card_uuid, graveyard_node.global_position, graveyard_node, "add_card_to_slot", false, "", true, true)
	update_deck_view()
	update_deck_state()

func banish_top_fd():
	if player_deck.size() == 0:
		return
	var card_data = player_deck[0]
	var slug = card_data["slug"]
	var card_uuid = card_data["uuid"]
	player_deck.remove_at(0)
	var banish_node = get_tree().current_scene.find_child("BANISH", true, false)
	if banish_node:
		var main_node = get_tree().get_root().get_node("Main")
		if main_node:
			main_node.rpc("sync_move_to_banish", multiplayer.get_unique_id(), card_uuid, slug, true)
		_animate_deck_card_to_zone(slug, card_uuid, banish_node.global_position, banish_node, "add_card_to_slot", true, "", false)
	update_deck_view()
	update_deck_state()

func banish_top_fu():
	if player_deck.size() == 0:
		return
	var card_data = player_deck[0]
	var slug = card_data["slug"]
	var card_uuid = card_data["uuid"]
	player_deck.remove_at(0)
	var banish_node = get_tree().current_scene.find_child("BANISH", true, false)
	if banish_node:
		var main_node = get_tree().get_root().get_node("Main")
		if main_node:
			main_node.rpc("sync_move_to_banish", multiplayer.get_unique_id(), card_uuid, slug, false, true)
		_animate_deck_card_to_zone(slug, card_uuid, banish_node.global_position, banish_node, "add_card_to_slot", false, "", true)
	update_deck_view()
	update_deck_state()

func _animate_deck_card_to_zone(slug: String, card_uuid: String, target_pos: Vector2, zone_node: Node, zone_method: String, face_down: bool, _sync_method: String, play_flip: bool = false, block_interaction: bool = false):
	var card_scene = preload(CARD_SCENE_PATH)
	var proxy_card = card_scene.instantiate()
	proxy_card.uuid = card_uuid
	get_tree().current_scene.add_child(proxy_card)
	proxy_card.set_meta("slug", slug)
	proxy_card.global_position = global_position
	proxy_card.scale = Vector2(0.35, 0.35)
	proxy_card.z_index = 1000 
	var card_image_path = "res://Assets/Grand Archive/Card Images/" + slug + ".png"
	if ResourceLoader.exists(card_image_path):
		proxy_card.get_node("CardImage").texture = load(card_image_path)
	var ci = proxy_card.get_node_or_null("CardImage")
	var cib = proxy_card.get_node_or_null("CardImageBack")
	if ci and cib:
		if play_flip:
			ci.visible = true
			cib.visible = true
			ci.z_index = -1
			cib.z_index = 0
		elif face_down:
			ci.visible = false
			cib.visible = true
			ci.z_index = -1
			cib.z_index = 0
		else:
			ci.visible = true
			cib.visible = false
			ci.z_index = 0
			cib.z_index = -1
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(proxy_card, "global_position", target_pos, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if zone_node.name == "BANISH":
		tween.tween_property(proxy_card, "rotation_degrees", 90.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if play_flip:
		var anim_player = proxy_card.get_node_or_null("AnimationPlayer")
		if anim_player:
			anim_player.play("card_flip")
	tween.set_parallel(false)
	if block_interaction and proxy_card.has_method("set_tweening"):
		proxy_card.set_tweening(true)
	await tween.finished
	if is_instance_valid(proxy_card) and proxy_card.has_method("set_tweening"):
		proxy_card.set_tweening(false)
	if zone_node.has_method(zone_method):
		if zone_node.name == "BANISH":
			zone_node.call(zone_method, proxy_card, face_down)
		elif zone_node.name == "MEMORY":
			zone_node.call(zone_method, proxy_card, true)
		else:
			zone_node.call(zone_method, proxy_card)

func _on_deck_view_close():
	deck_view_window.hide()
	if has_node("Sprite2D"):
		$Sprite2D.modulate = Color(1, 1, 1, 1)
	selected_card_uuid = ""

func shuffle_deck():
	player_deck.shuffle()
	update_deck_view()

func update_deck_state():
	if player_deck.size() > 0:
		$Area2D/CollisionShape2D.disabled = false
		$Sprite2D.visible = true
		visible = true
	else:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		visible = false

func add_to_top(slug: String, uuid: String = ""):
	if slug == "":
		return
	var card_uuid = uuid
	if card_uuid == "":
		card_uuid = str(Time.get_unix_time_from_system()) + "_" + str(get_instance_id()) + "_" + str(randi())
	player_deck.insert(0, {"slug": slug, "uuid": card_uuid})
	update_deck_view()
	update_deck_state()

func add_to_bottom(slug: String, uuid: String = ""):
	if slug == "":
		return
	var card_uuid = uuid
	if card_uuid == "":
		card_uuid = str(Time.get_unix_time_from_system()) + "_" + str(get_instance_id()) + "_" + str(randi())
	player_deck.append({"slug": slug, "uuid": card_uuid})
	update_deck_view()
	update_deck_state()

func remove_card_by_uuid(target_uuid: String):
	var card_index = -1
	for i in range(player_deck.size()):
		if player_deck[i]["uuid"] == target_uuid:
			card_index = i
			break
	if card_index != -1:
		player_deck.remove_at(card_index)
		update_deck_view()
		update_deck_state()

func draw_card(card_drawn_name, card_uuid := ""):
	if player_deck.size() == 0:
		return
	var final_uuid = card_uuid
	var card_index = -1
	for i in range(player_deck.size()):
		if player_deck[i]["slug"] == card_drawn_name:
			if card_uuid == "" or player_deck[i]["uuid"] == card_uuid:
				card_index = i
				if final_uuid == "":
					final_uuid = player_deck[i]["uuid"]
				break
	if card_index != -1:
		player_deck.remove_at(card_index)
	else:
		if final_uuid == "":
			final_uuid = str(Time.get_unix_time_from_system()) + "_" + str(get_instance_id()) + "_" + str(randi())
	update_deck_view()
	if player_deck.size() == 0:
		update_deck_state()
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	new_card.uuid = final_uuid
	var card_image_path = "res://Assets/Grand Archive/Card Images/" + card_drawn_name + ".png"
	if ResourceLoader.exists(card_image_path):
		new_card.get_node("CardImage").texture = load(card_image_path)
	new_card.set_meta("slug", card_drawn_name)
	var unique_name = card_drawn_name
	var counter = 2
	while $"../CardManager".has_node(unique_name):
		unique_name = "%s (%d)" % [card_drawn_name, counter]
		counter += 1
	new_card.name = unique_name
	$"../CardManager".add_child(new_card)
	$"../PlayerHand".add_card_to_hand(new_card)
	new_card.get_node("AnimationPlayer").play("card_flip")
