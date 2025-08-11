extends Node2D

@onready var popup_menu: PopupMenu = $PopupMenu

func _ready():
	$Area2D.input_pickable = true
	$Area2D.connect("input_event", Callable(self, "_on_Area2D_input_event"))
	
	popup_menu.clear()
	popup_menu.add_item("Memory Random", 0)
	popup_menu.connect("id_pressed", Callable(self, "_on_popup_menu_id_pressed"))

func find_node_recursive(node, target_name):
	if node.name == target_name:
		return node
	for child in node.get_children():
		var found = find_node_recursive(child, target_name)
		if found:
			return found
	return null

func _on_Area2D_input_event(viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var player_hand_node = find_node_recursive(get_tree().get_root(), "PlayerHand")
		if player_hand_node:
			player_hand_node.toggle_hand_visibility()

	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		popup_menu.set_position(get_global_mouse_position())
		popup_menu.popup()

func _on_popup_menu_id_pressed(id):
	if id == 0:
		var memory_slot = find_node_recursive(get_tree().get_root(), "MEMORY")
		if memory_slot:
			memory_slot.highlight_random_card()
