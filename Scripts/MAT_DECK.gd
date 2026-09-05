extends Node2D

var player_deck = []
var card_database_reference
var hold_timer = 0.0
var is_holding_left = false
var progress_bar: TextureProgressBar
var selected_card_uuid: String = ""

const CARD_SCENE_PATH = "res://Scenes/Card.tscn"
const HOLD_DURATION = 0.8

@onready var deck_view_window = $MAT_DECK_VIEW_WINDOW
@onready var grid_container = $MAT_DECK_VIEW_WINDOW/ScrollContainer/GridContainer

func _ready() -> void:
	add_to_group("mat_deck_zones")
	card_database_reference = preload("res://Scripts/CardDatabase.gd")
	setup_deck_view()
	$Area2D.input_event.connect(_on_area_2d_input_event)
	if not $Area2D.mouse_exited.is_connected(_on_mouse_exited):
		$Area2D.mouse_exited.connect(_on_mouse_exited)
	update_deck_state()
	_setup_progress_bar()

func load_deck_data(slugs: Array):
	player_deck = []
	for slug in slugs:
		var card_uuid = str(Time.get_unix_time_from_system()) + "_" + str(get_instance_id()) + "_" + str(randi())
		player_deck.append({"slug": slug, "uuid": card_uuid})
	update_deck_state()

func _setup_progress_bar():
	progress_bar = TextureProgressBar.new()
	progress_bar.fill_mode = TextureProgressBar.FILL_CLOCKWISE
	progress_bar.step = 0.01
	progress_bar.min_value = 0
	progress_bar.max_value = 1.0
	progress_bar.value = 0
	var progress_size = Vector2(128, 128)
	progress_bar.custom_minimum_size = progress_size
	progress_bar.size = progress_size
	progress_bar.position = -progress_size / 2
	progress_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	progress_bar.visible = false
	progress_bar.top_level = true
	progress_bar.z_index = max(1, player_deck.size() + 1)
	progress_bar.z_as_relative = false
	var img = Image.create(128, 128, false, Image.FORMAT_RGBA8)
	for y in range(128):
		for x in range(128):
			var dist = Vector2(x-64, y-64).length()
			if dist > 25 and dist < 30:
				img.set_pixel(x, y, Color(1, 1, 1, 0.8))
	var tex = ImageTexture.create_from_image(img)
	progress_bar.texture_progress = tex
	progress_bar.modulate = Color(0.2, 0.8, 1.0)
	add_child.call_deferred(progress_bar)

func _process(delta):
	if is_holding_left:
		hold_timer += delta
		if progress_bar:
			progress_bar.z_index = max(1, player_deck.size() + 1)
			progress_bar.value = hold_timer / HOLD_DURATION
			progress_bar.visible = true
			progress_bar.global_position = get_global_mouse_position() - progress_bar.size / 2
		if hold_timer >= HOLD_DURATION:
			show_deck_view()
			_reset_hold()
	else:
		if progress_bar and progress_bar.visible:
			progress_bar.visible = false

func _reset_hold():
	is_holding_left = false
	hold_timer = 0.0
	if progress_bar:
		progress_bar.value = 0
		progress_bar.visible = false

func setup_deck_view():
	deck_view_window.close_requested.connect(_on_deck_view_close)
	deck_view_window.hide()
	$MAT_DECK_VIEW_WINDOW/PopupMenu.id_pressed.connect(_on_deck_view_popup_menu_pressed)

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_holding_left = true
			else:
				_reset_hold()

func _on_mouse_exited():
	_reset_hold()

func update_deck_view():
	if not deck_view_window.visible:
		return
	var current_update = Time.get_ticks_msec()
	set_meta("update_id", current_update)
	for child in grid_container.get_children():
		child.queue_free()
	var count = 0
	for card_data in player_deck:
		if get_meta("update_id") != current_update or not deck_view_window.visible:
			return
		var card_display = create_card_display(card_data["slug"], card_data["uuid"])
		grid_container.add_child(card_display)
		count += 1
		if count >= 8:
			count = 0
			await get_tree().process_frame

func update_deck_state():
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
	else:
		$Area2D/CollisionShape2D.disabled = false
		$Sprite2D.visible = true

func show_deck_view():
	deck_view_window.popup_centered()
	update_deck_view()
	$MAT_DECK_VIEW_WINDOW/ScrollContainer.call_deferred("set", "scroll_horizontal", 0)
	$MAT_DECK_VIEW_WINDOW/ScrollContainer.call_deferred("set", "scroll_vertical", 0)

func create_card_display(card_name: String, card_uuid: String):
	var card_display_scene = preload("res://Scenes/CardDisplay.tscn")
	var card_display = card_display_scene.instantiate()
	card_display.set_meta("slug", card_name)
	card_display.set_meta("uuid", card_uuid)
	card_display.set_meta("zone", "mat_deck")
	card_display.request_popup_menu.connect(_on_card_display_popup_menu)
	return card_display

func add_to_top(slug: String, uuid: String = ""):
	if slug == "":
		return
	var card_uuid = uuid
	if card_uuid == "":
		card_uuid = str(Time.get_unix_time_from_system()) + "_" + str(get_instance_id()) + "_" + str(randi())
	player_deck.insert(0, {"slug": slug, "uuid": card_uuid})
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

func _on_deck_view_close():
	deck_view_window.hide()

func _on_card_display_popup_menu(_slug, card_uuid):
	selected_card_uuid = card_uuid
	var popup_menu = $MAT_DECK_VIEW_WINDOW/PopupMenu
	popup_menu.clear()
	popup_menu.add_item("Banish Face Down", 0)
	popup_menu.add_item("Banish Face Up", 1)
	popup_menu.popup(Rect2(get_viewport().get_mouse_position(), Vector2(0, 0)))

func _on_deck_view_popup_menu_pressed(id):
	match id:
		0: banish_card_fd()
		1: banish_card_fu()

func banish_card_fd():
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
	var slug = card_data["slug"]
	var card_uuid = card_data["uuid"]
	player_deck.remove_at(card_index)
	var banish_node = get_tree().current_scene.find_child("BANISH", true, false)
	if banish_node:
		var main_node = get_tree().get_root().get_node("Main")
		if main_node:
			main_node.rpc("sync_move_to_banish", multiplayer.get_unique_id(), card_uuid, slug, true, false, true)
		_animate_deck_card_to_zone(slug, card_uuid, banish_node.global_position, banish_node, "add_card_to_slot", true, "", false, true)
	update_deck_view()
	update_deck_state()
	selected_card_uuid = ""

func banish_card_fu():
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
	var slug = card_data["slug"]
	var card_uuid = card_data["uuid"]
	player_deck.remove_at(card_index)
	var banish_node = get_tree().current_scene.find_child("BANISH", true, false)
	if banish_node:
		var main_node = get_tree().get_root().get_node("Main")
		if main_node:
			main_node.rpc("sync_move_to_banish", multiplayer.get_unique_id(), card_uuid, slug, false, false, true)
		_animate_deck_card_to_zone(slug, card_uuid, banish_node.global_position, banish_node, "add_card_to_slot", false, "", true, true)
	update_deck_view()
	update_deck_state()
	selected_card_uuid = ""

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
	var card_image = proxy_card.get_node_or_null("CardImage")
	var card_image_back = proxy_card.get_node_or_null("CardImageBack")
	if card_image and card_image_back:
		if play_flip:
			card_image.visible = true
			card_image_back.visible = true
			card_image.z_index = -1
			card_image_back.z_index = 0
		elif face_down:
			card_image.visible = false
			card_image_back.visible = true
			card_image.z_index = -1
			card_image_back.z_index = 0
		else:
			card_image.visible = true
			card_image_back.visible = false
			card_image.z_index = 0
			card_image_back.z_index = -1
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
			zone_node.call(zone_method, proxy_card, false)
		else:
			zone_node.call(zone_method, proxy_card)
