extends Node2D

@onready var popup_menu: PopupMenu = $PopupMenu

var status_label: Label
var showing_dice_menu := false
var showing_rps_menu := false
var showing_status_menu := false
var showing_level_menu := false
var showing_durability_menu := false
var showing_power_menu := false
var showing_life_menu := false
var level_value := 0
var durability_value := 0
var power_value := 0
var life_value := 0

func _ready():
	$Area2D.input_pickable = true
	$Area2D.connect("input_event", Callable(self, "_on_Area2D_input_event"))
	build_main_menu()
	popup_menu.connect("id_pressed", Callable(self, "_on_popup_menu_id_pressed"))
	setup_status_label()
	update_status_display()

func setup_status_label():
	if not has_node("StatusLabel"):
		status_label = Label.new()
		status_label.name = "StatusLabel"
		add_child(status_label)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.modulate = Color.WHITE
	status_label.z_index = 1000

func update_status_display():
	var status_parts = []
	if level_value != 0:
		var level_text = "Level " + ("+" if level_value > 0 else "") + str(level_value)
		status_parts.append(level_text)
	if durability_value != 0:
		var durability_text = "Durability " + ("+" if durability_value > 0 else "") + str(durability_value)
		status_parts.append(durability_text)
	if power_value != 0:
		var power_text = "Power " + ("+" if power_value > 0 else "") + str(power_value)
		status_parts.append(power_text)
	if life_value != 0:
		var life_text = "Life " + ("+" if life_value > 0 else "") + str(life_value)
		status_parts.append(life_text)
	if status_parts.size() == 0:
		status_label.visible = false
	else:
		status_label.visible = true
		status_label.text = "\n".join(status_parts)
		var mouse_pos = get_local_mouse_position()
		status_label.position = mouse_pos + Vector2(15, -15)

func _process(_delta):
	if status_label.visible:
		var mouse_pos = get_local_mouse_position()
		status_label.position = mouse_pos + Vector2(15, -15)

func build_main_menu():
	showing_dice_menu = false
	showing_rps_menu = false
	showing_status_menu = false
	showing_level_menu = false
	showing_durability_menu = false
	showing_power_menu = false
	showing_life_menu = false
	popup_menu.clear()
	popup_menu.add_item("Memory Random", 100)
	popup_menu.add_item("Coin Flip", 101)
	popup_menu.add_item("Roll Dice", 102)
	popup_menu.add_item("RPS", 104)
	popup_menu.add_item("Status Modification", 105)
	popup_menu.add_separator()
	popup_menu.add_item("Surrender", 103)
	$PopupMenu.reset_size()

func build_dice_menu():
	showing_dice_menu = true
	showing_rps_menu = false
	showing_status_menu = false
	showing_level_menu = false
	showing_durability_menu = false
	showing_power_menu = false
	showing_life_menu = false
	popup_menu.clear()
	popup_menu.add_item("D6", 6)
	popup_menu.add_item("D8", 8)
	popup_menu.add_item("D20", 20)
	popup_menu.add_separator()
	popup_menu.add_item("Back", 999)
	$PopupMenu.reset_size()

func build_rps_menu():
	showing_dice_menu = false
	showing_rps_menu = true
	showing_status_menu = false
	showing_level_menu = false
	showing_durability_menu = false
	showing_power_menu = false
	showing_life_menu = false
	popup_menu.clear()
	popup_menu.add_item("Rock", 201)
	popup_menu.add_item("Paper", 202)
	popup_menu.add_item("Scissors", 203)
	popup_menu.add_separator()
	popup_menu.add_item("Back", 999)
	$PopupMenu.reset_size()

func build_status_menu():
	showing_dice_menu = false
	showing_rps_menu = false
	showing_status_menu = true
	showing_level_menu = false
	showing_durability_menu = false
	showing_power_menu = false
	showing_life_menu = false
	popup_menu.clear()
	popup_menu.add_item("Level", 301)
	popup_menu.add_item("Durability", 302)
	popup_menu.add_item("Power", 303)
	popup_menu.add_item("Life", 304)
	popup_menu.add_separator()
	popup_menu.add_item("Back", 999)
	$PopupMenu.reset_size()

func build_level_menu():
	showing_dice_menu = false
	showing_rps_menu = false
	showing_status_menu = false
	showing_level_menu = true
	showing_durability_menu = false
	showing_power_menu = false
	showing_life_menu = false
	popup_menu.clear()
	popup_menu.add_item("Level +1", 401)
	popup_menu.add_item("Level -1", 402)
	popup_menu.add_separator()
	popup_menu.add_item("Back", 999)
	$PopupMenu.reset_size()

func build_durability_menu():
	showing_dice_menu = false
	showing_rps_menu = false
	showing_status_menu = false
	showing_level_menu = false
	showing_durability_menu = true
	showing_power_menu = false
	showing_life_menu = false
	popup_menu.clear()
	popup_menu.add_item("Durability +1", 403)
	popup_menu.add_item("Durability -1", 404)
	popup_menu.add_separator()
	popup_menu.add_item("Back", 999)
	$PopupMenu.reset_size()

func build_power_menu():
	showing_dice_menu = false
	showing_rps_menu = false
	showing_status_menu = false
	showing_level_menu = false
	showing_durability_menu = false
	showing_power_menu = true
	showing_life_menu = false
	popup_menu.clear()
	popup_menu.add_item("Power +1", 405)
	popup_menu.add_item("Power -1", 406)
	popup_menu.add_separator()
	popup_menu.add_item("Back", 999)
	$PopupMenu.reset_size()

func build_life_menu():
	showing_dice_menu = false
	showing_rps_menu = false
	showing_status_menu = false
	showing_level_menu = false
	showing_durability_menu = false
	showing_power_menu = false
	showing_life_menu = true
	popup_menu.clear()
	popup_menu.add_item("Life +1", 407)
	popup_menu.add_item("Life -1", 408)
	popup_menu.add_separator()
	popup_menu.add_item("Back", 999)
	$PopupMenu.reset_size()

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
	if not showing_dice_menu and not showing_rps_menu and not showing_status_menu and not showing_level_menu and not showing_durability_menu and not showing_power_menu and not showing_life_menu:
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
		elif id == 105:
			build_status_menu()
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
	elif showing_status_menu:
		if id == 999:
			build_main_menu()
		elif id == 301:
			build_level_menu()
		elif id == 302:
			build_durability_menu()
		elif id == 303:
			build_power_menu()
		elif id == 304:
			build_life_menu()
	elif showing_level_menu:
		if id == 999:
			build_status_menu()
		elif id == 401:
			level_value += 1
			update_status_display()
		elif id == 402:
			level_value -= 1
			update_status_display()
	elif showing_durability_menu:
		if id == 999:
			build_status_menu()
		elif id == 403:
			durability_value += 1
			update_status_display()
		elif id == 404:
			durability_value -= 1
			update_status_display()
	elif showing_power_menu:
		if id == 999:
			build_status_menu()
		elif id == 405:
			power_value += 1
			update_status_display()
		elif id == 406:
			power_value -= 1
			update_status_display()
	elif showing_life_menu:
		if id == 999:
			build_status_menu()
		elif id == 407:
			life_value += 1
			update_status_display()
		elif id == 408:
			life_value -= 1
			update_status_display()
	$PopupMenu.reset_size()

func has_active_status() -> bool:
	return level_value != 0 or durability_value != 0 or power_value != 0 or life_value != 0

func reset_all_status_values():
	level_value = 0
	durability_value = 0
	power_value = 0
	life_value = 0
	update_status_display()

func find_node_recursive(node, target_name):
	if node.name == target_name:
		return node
	for child in node.get_children():
		var found = find_node_recursive(child, target_name)
		if found:
			return found
	return null
