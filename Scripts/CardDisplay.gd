extends Control

var card_slug = ""
var card_image_path = ""
var zone = ""
var is_holding = false
var dragged_card = null

signal request_popup_menu(slug, uuid)
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
	if not card_info_node:
		card_info_node = get_tree().get_current_scene().get_node_or_null("PlayerField/CardInformation")
	if card_info_node and card_info_node.has_method("show_card_info"):
		card_info_node.show_card_info(card_slug)

func _on_mouse_exited():
	self.scale = Vector2(1, 1)
	self.z_index = 0

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if zone in ["graveyard", "banish", "ga_deck", "mat_deck", "logo_tokens", "logo_mastery", "lineage"]:
			var current_uuid = get_meta("uuid") if has_meta("uuid") else ""
			emit_signal("request_popup_menu", card_slug, current_uuid)
			accept_event()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and not is_holding:
			start_drag_from_grid()
			accept_event()
		elif not event.pressed and is_holding:
			finish_drag_from_grid()
			accept_event()

func start_drag_from_grid():
	if is_holding:
		return
	if zone == "lineage":
		return
	var real_card = create_real_card_for_drag()
	if real_card:
		is_holding = true
		dragged_card = real_card
		var card_manager = get_tree().current_scene.get_node("PlayerField/CardManager")
		if card_manager and card_manager.has_method("start_drag"):
			card_manager.start_drag(real_card)
			card_manager.set_dragged_from_grid_info(card_slug, zone, self)
			if zone != "logo_tokens" and zone != "logo_mastery":
				if zone == "lineage":
					var owner_node = get_parent()
					while owner_node != null and not owner_node.has_method("remove_from_lineage_by_uuid"):
						owner_node = owner_node.get_parent()
					
					if owner_node and owner_node.has_method("remove_from_lineage_by_uuid"):
						var u = get_meta("uuid") if has_meta("uuid") else ""
						owner_node.remove_from_lineage_by_uuid(u)
				update_grid_immediately()
				emit_signal("card_drag_started", self)
				card_image_path = ""
				texture_rect.texture = null
				custom_minimum_size = Vector2.ZERO

func finish_drag_from_grid():
	if not is_holding or not dragged_card:
		return
	var card_manager = get_tree().current_scene.get_node("PlayerField/CardManager")
	if card_manager and card_manager.has_method("finish_drag"):
		card_manager.finish_drag()
	is_holding = false
	dragged_card = null

func update_grid_immediately():
	var parent_window = get_parent().get_parent()
	if parent_window and parent_window.has_method("update_deck_view"):
		parent_window.update_deck_view()

func get_drag_data(_pos):
	if zone == "lineage":
		return null
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
	var card_scene = load("res://Scenes/Card.tscn")
	var real_card = card_scene.instantiate()
	if has_meta("uuid"):
		real_card.uuid = get_meta("uuid")
	real_card.set_meta("slug", card_slug)
	real_card.set_meta("is_dragged_from_grid", true)
	real_card.set_meta("original_zone", zone)
	if has_meta("uuid"):
		real_card.set_meta("uuid", get_meta("uuid"))
	card_image_path = "res://Assets/Grand Archive/Card Images/" + card_slug + ".png"
	if ResourceLoader.exists(card_image_path):
		var card_image = real_card.get_node("CardImage")
		var card_image_back = real_card.get_node("CardImageBack")
		card_image.texture = load(card_image_path)
		card_image.visible = true
		card_image_back.visible = false
		card_image.z_index = 0
	var card_manager = get_tree().current_scene.get_node("PlayerField/CardManager")
	card_manager.add_child(real_card)
	real_card.global_position = get_global_mouse_position()
	real_card.z_index = 1000
	real_card.add_to_group("cards")
	if card_manager.has_method("connect_card_signals"):
		card_manager.connect_card_signals(real_card)
	return real_card

func can_drop_data(_pos, data):
	return typeof(data) == TYPE_STRING and data != card_slug

func drop_data(_pos, data):
	card_slug = data
	card_image_path = "res://Assets/Grand Archive/Card Images/" + card_slug + ".png"
	if ResourceLoader.exists(card_image_path):
		texture_rect.texture = load(card_image_path)
