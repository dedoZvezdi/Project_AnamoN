extends Control

var card_slug = ""
var card_image_path = ""
var zone = ""

signal request_popup_menu(slug)

@onready var texture_rect = $TextureRect

const CARD_DISPLAY_SIZE = Vector2(98, 98)

func _ready():
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
		if zone in ["graveyard", "banish", "ga_deck", "mat_deck"]:
			emit_signal("request_popup_menu", card_slug)

func get_drag_data(_pos):
	set_drag_preview(texture_rect.duplicate())
	return card_slug

func can_drop_data(_pos, data):
	return typeof(data) == TYPE_STRING and data != card_slug

func drop_data(_pos, data):
	card_slug = data
	card_image_path = "res://Assets/Grand Archive/Card Images/" + card_slug + ".png"
	if ResourceLoader.exists(card_image_path):
		texture_rect.texture = load(card_image_path)
