extends Node2D

var player_deck = ["alice-golden-queen-dtr1e-cur","aetheric-calibration-dtrsd","alice-golden-queen-dtr","academy-guide-p24", "absolving-flames-amb","acolyte-of-cultivation-amb","acolyte-of-cultivation-amb"
,"suzaku-vermillion-phoenix-hvn1e-csr","acolyte-of-cultivation-amb","arcane-disposition-doap","arthur-young-heir-evp","suzaku-vermillion-phoenix-hvn1e"]

var card_database_reference
const CARD_SCENE_PATH = "res://Scenes/Card.tscn"

@onready var context_menu = $PopupMenu
@onready var deck_view_window = $MAT_DECK_VIEW_WINDOW
@onready var grid_container = $MAT_DECK_VIEW_WINDOW/ScrollContainer/GridContainer

func _ready() -> void:
	add_to_group("mat_deck_zones")
	card_database_reference = preload("res://Scripts/CardDatabase.gd")
	setup_context_menu()
	setup_deck_view()
	$Area2D.input_event.connect(_on_area_2d_input_event)

func setup_context_menu():
	context_menu.add_item("View Deck", 0)
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
	deck_view_window.popup_centered()
	update_deck_view()
	$MAT_DECK_VIEW_WINDOW/ScrollContainer.call_deferred("set", "scroll_horizontal", 0)
	$MAT_DECK_VIEW_WINDOW/ScrollContainer.call_deferred("set", "scroll_vertical", 0)

func create_card_display(card_name: String):
	var card_display_scene = preload("res://Scenes/CardDisplay.tscn")
	var card_display = card_display_scene.instantiate()
	card_display.set_meta("slug", card_name)
	card_display.set_meta("zone", "mat_deck")
	card_display.request_popup_menu.connect(_on_card_display_popup_menu)
	return card_display

func _on_card_display_popup_menu(_slug):
	var popup_menu = $MAT_DECK_VIEW_WINDOW/PopupMenu
	popup_menu.clear()
	popup_menu.add_item("test7")
	popup_menu.add_item("test8")
	popup_menu.popup(Rect2(get_viewport().get_mouse_position(), Vector2(0, 0)))

func _on_deck_view_close():
	deck_view_window.hide()
