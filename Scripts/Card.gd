extends Node2D

signal hovered
signal hovered_off

var current_field = null
var original_rotation = 0.0
var is_rotated = false
var hand_position
var mouse_inside = false

func _ready() -> void:
	if get_parent() and get_parent().has_method("connect_card_signals"):
		get_parent().connect_card_signals(self)
	$PopupMenu.id_pressed.connect(_on_PopupMenu_id_pressed)
	$Area2D.input_event.connect(_on_area_2d_input_event)

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if mouse_inside:
			$PopupMenu.clear()
			if $PopupMenu.has_theme_constant_override("separation"):
				$PopupMenu.add_theme_constant_override("separation", 1)
			$PopupMenu.add_item("Go to Graveyard", 0)
			$PopupMenu.add_item("Go to Banish FU", 1)
			$PopupMenu.add_item("Go to Banish FD", 2)
			$PopupMenu.add_item("Go to TD", 3)
			$PopupMenu.add_item("Go to BD", 4)
			if is_in_main_field():
				if is_rotated:
					$PopupMenu.add_item("Awake", 5)
				else:
					$PopupMenu.add_item("Rest", 5)
			$PopupMenu.add_item("Show", 6)
			$PopupMenu.add_item("Transform", 7)
			$PopupMenu.add_item("Give to your opponent", 8)
			$PopupMenu.reset_size()
			$PopupMenu.position = get_global_mouse_position()
			$PopupMenu.popup()

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
		5: if is_in_main_field():
			rotate_card()
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
