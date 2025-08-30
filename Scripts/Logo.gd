extends Node2D

@onready var popup_menu: PopupMenu = $PopupMenu

var level_label: Label
var durability_label: Label
var power_label: Label
var life_label: Label
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
	add_to_group("logo")
	$Area2D.input_pickable = true
	$Area2D.input_event.connect(_on_Area2D_input_event)
	build_main_menu()
	popup_menu.id_pressed.connect(_on_popup_menu_id_pressed)
	setup_status_labels()
	update_status_display()

func setup_status_labels():
	if not has_node("LevelLabel"):
		level_label = Label.new()
		level_label.name = "LevelLabel"
		add_child(level_label)
	else:
		level_label = $LevelLabel
	if not has_node("DurabilityLabel"):
		durability_label = Label.new()
		durability_label.name = "DurabilityLabel"
		add_child(durability_label)
	else:
		durability_label = $DurabilityLabel
	if not has_node("PowerLabel"):
		power_label = Label.new()
		power_label.name = "PowerLabel"
		add_child(power_label)
	else:
		power_label = $PowerLabel
	if not has_node("LifeLabel"):
		life_label = Label.new()
		life_label.name = "LifeLabel"
		add_child(life_label)
	else:
		life_label = $LifeLabel
	var labels = [level_label, durability_label, power_label, life_label]
	for label in labels:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 16)
		label.z_index = 1000

func update_status_display():
	var mouse_pos = get_local_mouse_position()
	var offset_y = 0
	var line_height = 20
	if level_value != 0:
		var level_text = "Level " + ("+" if level_value > 0 else "") + str(level_value)
		level_label.text = level_text
		level_label.modulate = Color.GREEN if level_value > 0 else Color.RED
		level_label.position = mouse_pos + Vector2(15, -15 + offset_y)
		level_label.visible = true
		offset_y += line_height
	else:
		level_label.visible = false
	if durability_value != 0:
		var durability_text = "Durability " + ("+" if durability_value > 0 else "") + str(durability_value)
		durability_label.text = durability_text
		durability_label.modulate = Color.GREEN if durability_value > 0 else Color.RED
		durability_label.position = mouse_pos + Vector2(15, -15 + offset_y)
		durability_label.visible = true
		offset_y += line_height
	else:
		durability_label.visible = false
	if power_value != 0:
		var power_text = "Power " + ("+" if power_value > 0 else "") + str(power_value)
		power_label.text = power_text
		power_label.modulate = Color.GREEN if power_value > 0 else Color.RED
		power_label.position = mouse_pos + Vector2(15, -15 + offset_y)
		power_label.visible = true
		offset_y += line_height
	else:
		power_label.visible = false
	if life_value != 0:
		var life_text = "Life " + ("+" if life_value > 0 else "") + str(life_value)
		life_label.text = life_text
		life_label.modulate = Color.GREEN if life_value > 0 else Color.RED
		life_label.position = mouse_pos + Vector2(15, -15 + offset_y)
		life_label.visible = true
	else:
		life_label.visible = false

func _process(delta: float) -> void:
	if has_active_status():
		update_status_display()
	if popup_menu.visible:
		var mouse_pos_global = get_global_mouse_position()
		var area_pos_global = $Area2D.global_position
		if mouse_pos_global.distance_to(area_pos_global) > 150:
			popup_menu.hide()

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
	adjust_popup_position()

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
	adjust_popup_position()

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
	adjust_popup_position()

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
	adjust_popup_position()

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
	adjust_popup_position()

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
	adjust_popup_position()

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
	adjust_popup_position()

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
	adjust_popup_position()

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

func adjust_popup_position():
	var screen_size = get_viewport().get_visible_rect().size
	var menu_size = popup_menu.get_contents_minimum_size()
	var pos = popup_menu.position
	if pos.x + menu_size.x > screen_size.x:
		pos.x = screen_size.x - menu_size.x
	if pos.x < 0:
		pos.x = 0
	if pos.y + menu_size.y > screen_size.y:
		pos.y = screen_size.y - menu_size.y
	if pos.y < 0:
		pos.y = 0
	popup_menu.set_position(pos)

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
