extends Node2D

signal hovered
signal hovered_off

@onready var popup_menu: PopupMenu = $PopupMenu
@onready var area: Area2D = $Area2D

var current_field = null
var original_rotation = 0.0
var is_rotated = false
var hand_position
var mouse_inside = false
var was_rotated_before_drag = false

func _ready() -> void:
	if get_parent() and get_parent().has_method("connect_card_signals"):
		get_parent().connect_card_signals(self)
	popup_menu.id_pressed.connect(_on_PopupMenu_id_pressed)
	area.input_event.connect(_on_area_2d_input_event)

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if mouse_inside:
			var logo_nodes = get_tree().get_nodes_in_group("logo")
			if logo_nodes.size() > 0:
				var logo_node = logo_nodes[0]
				if logo_node.has_method("has_active_status") and logo_node.has_active_status():
					logo_node.reset_all_status_values()
					return
			popup_menu.clear()
			popup_menu.add_item("Go to Graveyard", 0)
			popup_menu.add_item("Go to Banish FU", 1)
			popup_menu.add_item("Go to Banish FD", 2)
			popup_menu.add_item("Go to TD", 3)
			popup_menu.add_item("Go to BD", 4)
			if is_in_main_field():
				if is_rotated:
					popup_menu.add_item("Awake", 5)
				else:
					popup_menu.add_item("Rest", 5)
			popup_menu.add_item("Show", 6)
			popup_menu.add_item("Transform", 7)
			popup_menu.add_item("Give to your opponent", 8)
			popup_menu.reset_size()
			popup_menu.position = get_global_mouse_position()
			popup_menu.popup()

func _on_area_2d_mouse_entered() -> void:
	mouse_inside = true
	emit_signal("hovered", self)

func _on_area_2d_mouse_exited() -> void:
	mouse_inside = false
	emit_signal("hovered_off", self)

func _on_PopupMenu_id_pressed(id: int) -> void:
	match id:
		0: print("Go to Graveyard selected")
		1: print("Go to Banish FU selected")
		2: print("Go to Banish FD selected")
		3: print("Go to TD selected")
		4: print("Go to BD selected")
		5: if is_in_main_field(): rotate_card()
		6: print("Show selected")
		7: print("Transform selected")
		8: print("Give to your opponent")

func rotate_card():
	if not is_in_main_field():
		return
	if is_rotated:
		rotation_degrees = original_rotation
		is_rotated = false
	else:
		rotation_degrees = original_rotation + 90
		is_rotated = true

func on_drag_start():
	was_rotated_before_drag = is_rotated
	rotation_degrees = original_rotation

func on_drag_end():
	is_rotated = false
	rotation_degrees = original_rotation

func set_current_field(field):
	current_field = field

func is_in_main_field() -> bool:
	return current_field != null and current_field.is_in_group("main_fields")

func is_in_memory_slot() -> bool:
	return current_field != null and current_field.is_in_group("memory_slots")

func is_in_graveyard() -> bool:
	return current_field != null and current_field.is_in_group("single_card_slots")

func is_in_banish() -> bool:
	return current_field != null and current_field.is_in_group("rotated_slots")
