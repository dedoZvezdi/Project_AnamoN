extends Node2D

var player_deck = ["alice-golden-queen-dtr1e-cur","aetheric-calibration-dtrsd","alice-golden-queen-dtr","academy-guide-p24", "absolving-flames-amb","acolyte-of-cultivation-amb","acolyte-of-cultivation-amb"
,"suzaku-vermillion-phoenix-hvn1e-csr","acolyte-of-cultivation-amb","arcane-disposition-doap","arthur-young-heir-evp","suzaku-vermillion-phoenix-hvn1e"]

var card_database_reference
const CARD_SCENE_PATH = "res://Scenes/Card.tscn"

@onready var context_menu = $PopupMenu
@onready var deck_view_window = $MAT_DECK_VIEW_WINDOW
@onready var grid_container = $MAT_DECK_VIEW_WINDOW/ScrollContainer/GridContainer

func _ready() -> void:
	player_deck.shuffle()
	card_database_reference = preload("res://Scripts/CardDatabase.gd")
	setup_context_menu()
	setup_deck_view()
	$Area2D.input_event.connect(_on_area_2d_input_event)

func setup_context_menu():
	context_menu.add_item("View Deck", 0)
	context_menu.add_item("Shuffle Deck", 1)
	context_menu.id_pressed.connect(_on_context_menu_pressed)

func setup_deck_view():
	deck_view_window.close_requested.connect(_on_deck_view_close)
	deck_view_window.hide()

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			context_menu.position = get_global_mouse_position()
			context_menu.popup()

func _on_context_menu_pressed(id):
	match id:
		0:view_deck()
		1:shuffle_deck()

func view_deck():
	show_deck_view()

func update_deck_view():
	if not deck_view_window.visible:
		return
	for child in grid_container.get_children():
		child.queue_free()
	for card_name in player_deck:
		var card_display = create_card_display(card_name)
		grid_container.add_child(card_display)

func show_deck_view():
	update_deck_view()
	deck_view_window.popup_centered()
	for card_name in player_deck:
		var card_display = create_card_display(card_name)
		grid_container.add_child(card_display)
	deck_view_window.popup_centered()

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
	card_control.add_child(texture_rect)
	return card_control

func _on_deck_view_close():
	deck_view_window.hide()

func shuffle_deck():
	player_deck.shuffle()
	update_deck_view()
