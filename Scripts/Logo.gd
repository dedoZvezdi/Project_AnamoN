extends Node2D

@onready var popup_menu: PopupMenu = $PopupMenu
var showing_dice_menu := false
var showing_rps_menu := false

func _ready():
	$Area2D.input_pickable = true
	$Area2D.connect("input_event", Callable(self, "_on_Area2D_input_event"))
	build_main_menu()
	popup_menu.connect("id_pressed", Callable(self, "_on_popup_menu_id_pressed"))

func build_main_menu():
	showing_dice_menu = false
	showing_rps_menu = false
	popup_menu.clear()
	popup_menu.add_item("Memory Random", 100)
	popup_menu.add_item("Coin Flip", 101)
	popup_menu.add_item("Roll Dice", 102)
	popup_menu.add_item("RPS", 104)
	popup_menu.add_separator()
	popup_menu.add_item("Surrender", 103)
	$PopupMenu.reset_size()

func build_dice_menu():
	showing_dice_menu = true
	showing_rps_menu = false
	popup_menu.clear()
	popup_menu.add_item("D6", 6)
	popup_menu.add_item("D8", 8)
	popup_menu.add_item("D20", 20)
	popup_menu.add_separator()
	popup_menu.add_item("Back", 999)

func build_rps_menu():
	showing_dice_menu = false
	showing_rps_menu = true
	popup_menu.clear()
	popup_menu.add_item("Rock", 201)
	popup_menu.add_item("Paper", 202)
	popup_menu.add_item("Scissors", 203)
	popup_menu.add_separator()
	popup_menu.add_item("Back", 999)

func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var player_hand_node = find_node_recursive(get_tree().get_root(), "PlayerHand")
		if player_hand_node:
			player_hand_node.toggle_hand_visibility()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		var mouse_pos = get_global_mouse_position()
		popup_menu.set_position(mouse_pos)
		popup_menu.popup()
		$PopupMenu.reset_size()
		var screen_size = get_viewport().get_visible_rect().size
		var menu_size = popup_menu.get_contents_minimum_size()
		if mouse_pos.y + menu_size.y > screen_size.y:
			var new_y = screen_size.y - menu_size.y
			if new_y < 0:
				new_y = 0
			popup_menu.set_position(Vector2(mouse_pos.x, new_y))

func _on_popup_menu_id_pressed(id):
	if not showing_dice_menu and not showing_rps_menu:
		if id == 100:
			popup_menu.hide()
			var memory_slot = find_node_recursive(get_tree().get_root(), "MEMORY")
			if memory_slot:
				memory_slot.highlight_random_card()
		elif id == 101:
			popup_menu.hide()
			var result = ["HEAD", "TAIL"].pick_random()
			print("SYSTEM: COIN - " + result)
		elif id == 102:
			build_dice_menu()
		elif id == 104:
			build_rps_menu()
		elif id == 103:
			popup_menu.hide()
			print("SYSTEM: Player surrendered")
	elif showing_dice_menu:
		if id == 999:
			build_main_menu()
		else:
			popup_menu.hide()
			var roll = randi_range(1, id)
			print("SYSTEM: D" + str(id) + " - " + str(roll))
	elif showing_rps_menu:
		if id == 999:
			build_main_menu()
		else:
			popup_menu.hide()
			var choice = ""
			if id == 201:
				choice = "Rock"
			elif id == 202:
				choice = "Paper"
			elif id == 203:
				choice = "Scissors"
			print("SYSTEM: RPS - " + choice)
	$PopupMenu.reset_size()

func find_node_recursive(node, target_name):
	if node.name == target_name:
		return node
	for child in node.get_children():
		var found = find_node_recursive(child, target_name)
		if found:
			return found
	return null
