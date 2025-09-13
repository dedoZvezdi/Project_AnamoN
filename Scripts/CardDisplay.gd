extends Control

var card_slug = ""
var card_image_path = ""
var zone = ""
var is_holding = false
var dragged_card = null

signal request_popup_menu(slug)
signal card_drag_started(card_display)

@onready var texture_rect = $TextureRect

const CARD_DISPLAY_SIZE = Vector2(98, 98)

func _ready():
	add_to_group("card_displays")
	if has_meta("zone"):
		zone = get_meta("zone")
	else:
		zone = ""
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	custom_minimum_size = CARD_DISPLAY_SIZE
	texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	texture_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	texture_rect.custom_minimum_size = CARD_DISPLAY_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if has_meta("slug"):
		card_slug = get_meta("slug")
	if card_slug != "":
		card_image_path = "res://Assets/Grand Archive/Card Images/" + card_slug + ".png"
	if card_image_path != "" and ResourceLoader.exists(card_image_path):
		texture_rect.texture = load(card_image_path)
		texture_rect.size = CARD_DISPLAY_SIZE
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_gui_input)

func _on_mouse_entered():
	self.scale = Vector2(1, 1)
	self.z_index = 100
	var card_info_node = get_tree().get_current_scene().get_node_or_null("CardInformation")
	if card_info_node and card_info_node.has_method("show_card_info"):
		card_info_node.show_card_info(card_slug)

func _on_mouse_exited():
	self.scale = Vector2(1, 1)
	self.z_index = 0

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if zone in ["graveyard", "banish", "ga_deck", "mat_deck", "logo_tokens"]:
			emit_signal("request_popup_menu", card_slug)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and not is_holding:
			start_drag_from_grid()
		elif not event.pressed and is_holding:
			finish_drag_from_grid()

func start_drag_from_grid():
	if is_holding:
		return
	var real_card = create_real_card_for_drag()
	if real_card:
		is_holding = true
		dragged_card = real_card
		var card_manager = get_tree().current_scene.get_node("CardManager")
		if card_manager and card_manager.has_method("start_drag"):
			card_manager.start_drag(real_card)
			card_manager.set_dragged_from_grid_info(card_slug, zone, self)
			update_grid_immediately()
			emit_signal("card_drag_started", self)
		#card_slug = ""
		card_image_path = ""
		texture_rect.texture = null
		custom_minimum_size = Vector2.ZERO

func finish_drag_from_grid():
	if not is_holding or not dragged_card:
		return
	var card_manager = get_tree().current_scene.get_node("CardManager")
	if card_manager and card_manager.has_method("finish_drag"):
		card_manager.finish_drag()
	is_holding = false
	dragged_card = null

func update_grid_immediately():
	var parent_window = get_parent().get_parent()
	if parent_window and parent_window.has_method("update_deck_view"):
		parent_window.update_deck_view()

func get_drag_data(_pos):
	var real_card = create_real_card_for_drag()
	if real_card:
		set_drag_preview(real_card)
		return {"type": "real_card", "card": real_card, "original_slug": card_slug, "zone": zone}
	else:
		set_drag_preview(texture_rect.duplicate())
		return card_slug

func create_real_card_for_drag():
	if card_slug == "":
		return null
	var card_scene = preload("res://Scenes/Card.tscn")
	var real_card = card_scene.instantiate()
	real_card.set_meta("slug", card_slug)
	real_card.set_meta("is_dragged_from_grid", true)
	real_card.set_meta("original_zone", zone)
	card_image_path = "res://Assets/Grand Archive/Card Images/" + card_slug + ".png"
	if ResourceLoader.exists(card_image_path):
		real_card.get_node("CardImage").texture = load(card_image_path)
		real_card.get_node("CardImage").visible = true
		real_card.get_node("CardImageBack").visible = false
	get_tree().current_scene.get_node("CardManager").add_child(real_card)
	real_card.global_position = get_global_mouse_position()
	real_card.z_index = 1000
	return real_card

func can_drop_data(_pos, data):
	return typeof(data) == TYPE_STRING and data != card_slug

func drop_data(_pos, data):
	card_slug = data
	card_image_path = "res://Assets/Grand Archive/Card Images/" + card_slug + ".png"
	if ResourceLoader.exists(card_image_path):
		texture_rect.texture = load(card_image_path)
