extends Node2D

var cards_in_banish = []
var card_in_slot = false
var base_z_index = 0
var selected_card_slug: String = ""
var marked_uuids : Array = []
var hold_timer = 0.0
var is_holding_left = false
var progress_bar: TextureProgressBar

@onready var banish_view_window = $BanishViewWindow
@onready var grid_container = $BanishViewWindow/ScrollContainer/GridContainer
@onready var area2d = $Area2D

const HOLD_DURATION = 0.8

func _ready() -> void:
	add_to_group("rotated_slots")
	setup_deck_view()
	if area2d and not area2d.input_event.is_connected(_on_area_2d_input_event):
		area2d.input_event.connect(_on_area_2d_input_event)
	if area2d and not area2d.mouse_exited.is_connected(_on_mouse_exited):
		area2d.mouse_exited.connect(_on_mouse_exited)
	_setup_progress_bar()

func _setup_progress_bar():
	progress_bar = TextureProgressBar.new()
	progress_bar.fill_mode = TextureProgressBar.FILL_CLOCKWISE
	progress_bar.step = 0.01
	progress_bar.min_value = 0
	progress_bar.max_value = 1.0
	progress_bar.value = 0
	var progress_size = Vector2(100, 100)
	progress_bar.custom_minimum_size = progress_size
	progress_bar.size = progress_size
	progress_bar.position = -progress_size / 2
	progress_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	progress_bar.visible = false
	progress_bar.top_level = true
	progress_bar.z_index = 2000
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
	get_tree().root.add_child.call_deferred(progress_bar)

func _process(delta):
	if is_holding_left:
		hold_timer += delta
		if progress_bar:
			progress_bar.value = hold_timer / HOLD_DURATION
			progress_bar.visible = true
			progress_bar.global_position = get_global_mouse_position() - progress_bar.size / 2
		if hold_timer >= HOLD_DURATION:
			show_grid_view()
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

func update_deck_view():
	for child in grid_container.get_children():
		child.queue_free()
	for card in cards_in_banish:
		if not is_instance_valid(card):
			continue
		var card_slug = card.get_meta("slug") if card.has_meta("slug") else (card.card_name if card.has_method("card_name") else card.get_name())
		var card_uuid = card.uuid if "uuid" in card else ""
		var card_display = create_card_display(card_slug, card_uuid)
		if card_uuid in marked_uuids:
			card_display.modulate = Color(1.5, 0.5, 0.5, 0.9)
			card_display.set_meta("is_marked", true)
		grid_container.add_child(card_display)
		var tex_rect = card_display.get_node_or_null("TextureRect")
		if tex_rect:
			var image_path = "res://Assets/Grand Archive/Card Images/" + card_slug + ".png"
			if card.has_meta("is_face_down") and card.get_meta("is_face_down") == true:
				image_path = "res://Assets/Textures/ga_back.png"
			if ResourceLoader.exists(image_path):
				tex_rect.texture = load(image_path)
		grid_container.move_child(card_display, 0)

func setup_deck_view():
	banish_view_window.close_requested.connect(_on_deck_view_close)
	banish_view_window.hide()

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_holding_left = true
				hold_timer = 0.0
			else:
				_reset_hold()

func _on_mouse_exited():
	_reset_hold()

func create_card_display(card_name: String, card_uuid: String = ""):
	var card_display_scene = preload("res://Scenes/CardDisplay.tscn")
	var card_display = card_display_scene.instantiate()
	card_display.set_meta("slug", card_name)
	card_display.set_meta("uuid", card_uuid)
	card_display.set_meta("zone", "banish")
	if card_uuid != "" and card_uuid in marked_uuids:
		card_display.modulate = Color(1.5, 0.5, 0.5, 0.9)
		card_display.set_meta("is_marked", true)
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

func show_grid_view():
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
	if card.has_method("is_mastery") and card.is_mastery():
		if card.has_method("destroy_mastery"):
			card.destroy_mastery()
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
	reorder_z_indices()
	card_in_slot = true
	update_top_card_visual()
	if banish_view_window.visible:
		call_deferred("update_deck_view")

func remove_card_from_slot(card):
	if card in cards_in_banish:
		if card.has_method("set_current_field"):
			card.set_current_field(null)
		cards_in_banish.erase(card)
		var uuid = card.uuid if "uuid" in card else ""
		if uuid != "" and uuid in marked_uuids:
			marked_uuids.erase(uuid)
		if is_instance_valid(card):
			card.modulate = Color(1, 1, 1)
			if card.has_meta("is_marked"):
				card.set_meta("is_marked", false)
		reorder_z_indices()
		update_top_card_visual()
		if banish_view_window.visible:
			update_deck_view()

func reorder_z_indices():
	var idx := 0
	for card in cards_in_banish:
		if card and is_instance_valid(card):
			card.z_index = base_z_index + idx + 1
			idx += 1

func get_top_card():
	return null

func remove_card_by_slug(slug: String):
	var target_card = null
	for card in cards_in_banish:
		if not is_instance_valid(card):
			continue
		var card_slug = card.get_meta("slug") if card.has_meta("slug") else (card.card_name if card.has_method("card_name") else card.get_name())
		if card_slug == slug:
			target_card = card
			break
	if target_card and is_instance_valid(target_card):
		remove_card_from_slot(target_card)
		target_card.queue_free()
		if banish_view_window.visible:
			update_deck_view()

func set_card_marked(uuid: String, is_marked: bool):
	if is_marked:
		if not uuid in marked_uuids:
			marked_uuids.append(uuid)
	else:
		marked_uuids.erase(uuid)
	update_top_card_visual()
	if banish_view_window.visible:
		update_deck_view()

func update_top_card_visual():
	if cards_in_banish.is_empty():
		return
	var top_card = cards_in_banish[-1]
	if not is_instance_valid(top_card):
		return
	if marked_uuids.size() > 0:
		top_card.modulate = Color(1.5, 0.5, 0.5, 0.9)
	else:
		top_card.modulate = Color(1, 1, 1)
