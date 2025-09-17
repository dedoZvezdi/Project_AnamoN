extends Node2D

@onready var popup_menu: PopupMenu = $PopupMenu
@onready var Logo_view_window = $LogoViewWindow
@onready var grid_container = $LogoViewWindow/ScrollContainer/GridContainer

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
var showing_markers_menu := false
var showing_specific_marker_menu := false
var showing_counters_menu := false
var showing_specific_counter_menu := false
var current_marker_name := ""
var current_counter_name := ""
var level_value := 0
var durability_value := 0
var power_value := 0
var life_value := 0
var custom_markers := {}
var marker_labels := {}
var custom_counters := {}
var counter_labels := {}
var chat_node = null
var add_marker_dialog: AcceptDialog
var marker_name_input: LineEdit
var add_counter_dialog: AcceptDialog
var counter_name_input: LineEdit
var original_popup_pos: Vector2 = Vector2.ZERO
var token_slugs : Array = [
	"acerbica-hvn","astral-shard-dtr","astral-shard-dtrsd","atmos-shield-mrc",
	"atmos-shield-sp2","aurousteel-greatsword-alc","aurousteel-greatsword-alcsd","aurousteel-greatsword-sp2",
	"automaton-drone-alc","automaton-drone-alcsd","automaton-drone-mrc","automaton-drone-sp2",
	"baihua-hvn","baihua-rec-idy","blightroot-alc","blightroot-alcsd",
	"blightroot-mrc","blightroot-sp2","direwolf-hvn","fledgling-hvn",
	"floodbloom-hvn","floodbloom-rec-idy","flowerbud-hvn","flowerbud-rec-idy",
	"fraysia-alc","fraysia-alcsd","fraysia-mrc","fraysia-sp2","lycoria-hvn",
	"lycoria-rec-idy","manaroot-alc","manaroot-alcsd","manaroot-mrc","manaroot-sp2",
	"nightshade-hvn","nightshade-rec-idy","obelisk-of-armaments-alc","obelisk-of-armaments-alcsd",
	"obelisk-of-armaments-sp2","obelisk-of-fabrication-alc","obelisk-of-fabrication-alcsd",
	"obelisk-of-fabrication-sp2","obelisk-of-protection-alc","obelisk-of-protection-alcsd","obelisk-of-protection-sp2",
	"ominous-shadow-evp","ominous-shadow-mrc","ominous-shadow-rec-shd",
	"ominous-shadow-sp2","powercell-mrc-a","powercell-mrc-b","powercell-sp2",
	"razorvine-alc","razorvine-alcsd","razorvine-mrc","razorvine-sp2",
	"silvershine-alc","silvershine-alcsd","silvershine-mrc","silvershine-sp2",
	"spirit-shard-mrc","spirit-shard-sp2","springleaf-alc","springleaf-alcsd",
	"springleaf-mrc","springleaf-sp2","vacuous-servant-dtr","washuru-hvn"
]

func _ready():
	add_to_group("logo")
	$Area2D.input_pickable = true
	$Area2D.input_event.connect(_on_Area2D_input_event)
	build_main_menu()
	popup_menu.id_pressed.connect(_on_popup_menu_id_pressed)
	setup_status_labels()
	setup_marker_input_dialog()
	setup_counter_input_dialog()
	update_status_display()
	find_chat_node()
	Logo_view_window.close_requested.connect(_on_logo_view_close)
	Logo_view_window.visibility_changed.connect(_on_logo_view_visibility_changed)
	populate_tokens()
	Logo_view_window.hide()

func setup_marker_input_dialog():
	add_marker_dialog = AcceptDialog.new()
	add_marker_dialog.title = "Add New Marker"
	add_marker_dialog.size = Vector2(300, 120)
	var vbox = VBoxContainer.new()
	var label = Label.new()
	label.text = "Enter marker name:"
	marker_name_input = LineEdit.new()
	marker_name_input.placeholder_text = "Marker name..."
	vbox.add_child(label)
	vbox.add_child(marker_name_input)
	add_marker_dialog.add_child(vbox)
	add_child(add_marker_dialog)
	add_marker_dialog.confirmed.connect(_on_marker_name_confirmed)

func setup_counter_input_dialog():
	add_counter_dialog = AcceptDialog.new()
	add_counter_dialog.title = "Add New Counter"
	add_counter_dialog.size = Vector2(300, 120)
	var vbox = VBoxContainer.new()
	var label = Label.new()
	label.text = "Enter counter name:"
	counter_name_input = LineEdit.new()
	counter_name_input.placeholder_text = "Counter name..."
	vbox.add_child(label)
	vbox.add_child(counter_name_input)
	add_counter_dialog.add_child(vbox)
	add_child(add_counter_dialog)
	add_counter_dialog.confirmed.connect(_on_counter_name_confirmed)

func _on_marker_name_confirmed():
	var marker_name = marker_name_input.text.strip_edges()
	if marker_name != "" and not custom_markers.has(marker_name):
		custom_markers[marker_name] = 0
		create_marker_label(marker_name)
	marker_name_input.text = ""
	build_markers_menu()

func _on_counter_name_confirmed():
	var counter_name = counter_name_input.text.strip_edges()
	if counter_name != "" and not custom_counters.has(counter_name):
		custom_counters[counter_name] = 0
		create_counter_label(counter_name)
	counter_name_input.text = ""
	build_counters_menu()

func create_marker_label(marker_name: String):
	var label = Label.new()
	label.name = "MarkerLabel_" + marker_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.z_index = 1000
	label.visible = false
	add_child(label)
	marker_labels[marker_name] = label

func create_counter_label(counter_name: String):
	var label = Label.new()
	label.name = "CounterLabel_" + counter_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.z_index = 1000
	label.visible = false
	add_child(label)
	counter_labels[counter_name] = label

func _on_logo_view_close():
	Logo_view_window.hide()

func _on_logo_view_visibility_changed():
	if Logo_view_window.visible:
		$LogoViewWindow/ScrollContainer.scroll_horizontal = 0
		$LogoViewWindow/ScrollContainer.scroll_vertical = 0

func find_chat_node():
	chat_node = find_node_recursive(get_tree().get_root(), "Chat")
	if not chat_node:
		chat_node = find_node_by_script(get_tree().get_root(), "res://Scripts/Chat.gd")

func find_node_by_script(node, script_path: String):
	if node.get_script() and node.get_script().resource_path == script_path:
		return node
	for child in node.get_children():
		var found = find_node_by_script(child, script_path)
		if found:
			return found
	return null

func send_to_chat(message: String):
	if chat_node and chat_node.has_method("send_system_message"):
		chat_node.send_system_message(message)

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
		offset_y += line_height
	else:
		life_label.visible = false
	for marker_name in custom_markers.keys():
		var value = custom_markers[marker_name]
		if value != 0 and marker_labels.has(marker_name):
			var label = marker_labels[marker_name]
			var marker_text = marker_name + " " + ("+" if value > 0 else "") + str(value)
			label.text = marker_text
			label.modulate = Color.GREEN if value > 0 else Color.RED
			label.position = mouse_pos + Vector2(15, -15 + offset_y)
			label.visible = true
			offset_y += line_height
		elif marker_labels.has(marker_name):
			marker_labels[marker_name].visible = false
	for counter_name in custom_counters.keys():
		var value = custom_counters[counter_name]
		if value != 0 and counter_labels.has(counter_name):
			var label = counter_labels[counter_name]
			var counter_text = counter_name + " " + ("+" if value > 0 else "") + str(value)
			label.text = counter_text
			label.modulate = Color.GREEN if value > 0 else Color.RED
			label.position = mouse_pos + Vector2(15, -15 + offset_y)
			label.visible = true
			offset_y += line_height
		elif counter_labels.has(counter_name):
			counter_labels[counter_name].visible = false
			
func _process(_delta: float) -> void:
	if has_active_status():
		update_status_display()
	if popup_menu.visible:
		var mouse_pos_global = get_global_mouse_position()
		var area_pos_global = $Area2D.global_position
		if mouse_pos_global.distance_to(area_pos_global) > 200:
			popup_menu.hide()

func build_main_menu():
	showing_dice_menu = false
	showing_rps_menu = false
	showing_status_menu = false
	showing_level_menu = false
	showing_durability_menu = false
	showing_power_menu = false
	showing_life_menu = false
	showing_markers_menu = false
	showing_specific_marker_menu = false
	showing_counters_menu = false
	showing_specific_counter_menu = false
	popup_menu.set_position(original_popup_pos)
	popup_menu.clear()
	popup_menu.add_item("Memory Random", 100)
	popup_menu.add_item("Coin Flip", 101)
	popup_menu.add_item("Roll Dice", 102)
	popup_menu.add_item("RPS", 104)
	popup_menu.add_item("Status Modification", 105)
	popup_menu.add_item("Add Markers", 107)
	popup_menu.add_item("Add Counters", 108)
	popup_menu.add_item("Summon Token", 106)
	popup_menu.add_separator()
	popup_menu.add_item("Surrender", 103)
	$PopupMenu.reset_size()
	adjust_popup_position()

func build_markers_menu():
	showing_dice_menu = false
	showing_rps_menu = false
	showing_status_menu = false
	showing_level_menu = false
	showing_durability_menu = false
	showing_power_menu = false
	showing_life_menu = false
	showing_markers_menu = true
	showing_specific_marker_menu = false
	showing_counters_menu = false
	showing_specific_counter_menu = false
	popup_menu.set_position(original_popup_pos)
	popup_menu.clear()
	popup_menu.add_item("Add", 500)
	var marker_id = 600
	for marker_name in custom_markers.keys():
		popup_menu.add_item(marker_name + " +", marker_id)
		popup_menu.set_item_metadata(popup_menu.get_item_count() - 1, {"action": "increase", "marker": marker_name})
		marker_id += 1
		popup_menu.add_item(marker_name + " -", marker_id)
		popup_menu.set_item_metadata(popup_menu.get_item_count() - 1, {"action": "decrease", "marker": marker_name})
		marker_id += 1
	popup_menu.add_separator()
	popup_menu.add_item("Back", 999)
	$PopupMenu.reset_size()
	adjust_popup_position()

func build_counters_menu():
	showing_dice_menu = false
	showing_rps_menu = false
	showing_status_menu = false
	showing_level_menu = false
	showing_durability_menu = false
	showing_power_menu = false
	showing_life_menu = false
	showing_markers_menu = false
	showing_specific_marker_menu = false
	showing_counters_menu = true
	showing_specific_counter_menu = false
	popup_menu.set_position(original_popup_pos)
	popup_menu.clear()
	popup_menu.add_item("Add", 501)
	var counter_id = 700
	for counter_name in custom_counters.keys():
		popup_menu.add_item(counter_name + " +", counter_id)
		popup_menu.set_item_metadata(popup_menu.get_item_count() - 1, {"action": "increase", "counter": counter_name})
		counter_id += 1
		popup_menu.add_item(counter_name + " -", counter_id)
		popup_menu.set_item_metadata(popup_menu.get_item_count() - 1, {"action": "decrease", "counter": counter_name})
		counter_id += 1
	popup_menu.add_separator()
	popup_menu.add_item("Back", 999)
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
	showing_markers_menu = false
	showing_specific_marker_menu = false
	showing_counters_menu = false
	showing_specific_counter_menu = false
	popup_menu.set_position(original_popup_pos)
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
	showing_markers_menu = false
	showing_specific_marker_menu = false
	showing_counters_menu = false
	showing_specific_counter_menu = false
	popup_menu.set_position(original_popup_pos)
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
	showing_markers_menu = false
	showing_specific_marker_menu = false
	showing_counters_menu = false
	showing_specific_counter_menu = false
	popup_menu.set_position(original_popup_pos)
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
	showing_markers_menu = false
	showing_specific_marker_menu = false
	showing_counters_menu = false
	showing_specific_counter_menu = false
	popup_menu.set_position(original_popup_pos)
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
	showing_markers_menu = false
	showing_specific_marker_menu = false
	showing_counters_menu = false
	showing_specific_counter_menu = false
	popup_menu.set_position(original_popup_pos)
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
	showing_markers_menu = false
	showing_specific_marker_menu = false
	showing_counters_menu = false
	showing_specific_counter_menu = false
	popup_menu.set_position(original_popup_pos)
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
	showing_markers_menu = false
	showing_specific_marker_menu = false
	showing_counters_menu = false
	showing_specific_counter_menu = false
	popup_menu.set_position(original_popup_pos)
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
		original_popup_pos = get_global_mouse_position()
		popup_menu.set_position(original_popup_pos)
		popup_menu.popup()
		$PopupMenu.reset_size()
		adjust_popup_position()

func _on_popup_menu_id_pressed(id):
	if not showing_dice_menu and not showing_rps_menu and not showing_status_menu and not showing_level_menu and not showing_durability_menu and not showing_power_menu and not showing_life_menu and not showing_markers_menu and not showing_counters_menu:
		if id == 100:
			popup_menu.hide()
			var memory_slot = find_node_recursive(get_tree().get_root(), "MEMORY")
			if memory_slot:
				memory_slot.highlight_random_card()
		elif id == 101:
			popup_menu.hide()
			var result = ["HEAD", "TAIL"].pick_random()
			send_to_chat("COIN - " + result)
		elif id == 102:
			build_dice_menu()
		elif id == 104:
			build_rps_menu()
		elif id == 105:
			build_status_menu()
		elif id == 107:
			build_markers_menu()
		elif id == 108:
			build_counters_menu()
		elif id == 106:
			popup_menu.hide()
			Logo_view_window.popup_centered()
			$LogoViewWindow/ScrollContainer.call_deferred("set", "scroll_horizontal", 0)
			$LogoViewWindow/ScrollContainer.call_deferred("set", "scroll_vertical", 0)
		elif id == 103:
			popup_menu.hide()
			send_to_chat("Player surrendered")
	elif showing_dice_menu:
		if id == 999:
			build_main_menu()
		else:
			popup_menu.hide()
			var roll = randi_range(1, id)
			send_to_chat("D" + str(id) + " - " + str(roll))
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
			send_to_chat("RPS - " + choice)
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
	elif showing_markers_menu:
		if id == 999:
			build_main_menu()
		elif id == 500:
			popup_menu.hide()
			add_marker_dialog.popup_centered()
		elif id >= 600:
			var item_index = -1
			for i in range(popup_menu.get_item_count()):
				if popup_menu.get_item_id(i) == id:
					item_index = i
					break
			if item_index != -1:
				var metadata = popup_menu.get_item_metadata(item_index)
				if metadata and typeof(metadata) == TYPE_DICTIONARY:
					var marker_name = metadata.get("marker", "")
					var action = metadata.get("action", "")
					if custom_markers.has(marker_name):
						if action == "increase":
							custom_markers[marker_name] += 1
						elif action == "decrease":
							custom_markers[marker_name] -= 1
						update_status_display()
						build_markers_menu()
	elif showing_counters_menu:
		if id == 999:
			build_main_menu()
		elif id == 501:
			popup_menu.hide()
			add_counter_dialog.popup_centered()
		elif id >= 700:
			var item_index = -1
			for i in range(popup_menu.get_item_count()):
				if popup_menu.get_item_id(i) == id:
					item_index = i
					break
			if item_index != -1:
				var metadata = popup_menu.get_item_metadata(item_index)
				if metadata and typeof(metadata) == TYPE_DICTIONARY:
					var counter_name = metadata.get("counter", "")
					var action = metadata.get("action", "")
					if custom_counters.has(counter_name):
						if action == "increase":
							custom_counters[counter_name] += 1
						elif action == "decrease":
							custom_counters[counter_name] -= 1
						update_status_display()
						build_counters_menu()
	$PopupMenu.reset_size()

func populate_tokens():
	for child in grid_container.get_children():
		child.queue_free()
	token_slugs.sort()
	for slug in token_slugs:
		var card_display = create_card_display(slug)
		grid_container.add_child(card_display)
	grid_container.anchor_left = 0
	grid_container.anchor_top = 0
	grid_container.anchor_right = 1
	grid_container.anchor_bottom = 1
	grid_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_container.size_flags_vertical = Control.SIZE_EXPAND_FILL

func find_card_information_reference():
	var root = get_tree().current_scene
	if root:
		return find_node_by_script(root, "res://Scripts/CardInformation.gd")
	return null

func find_base_card_for_edition(edition_id, card_database):
	if not card_database:
		return null
	for slug in card_database.cards_db:
		var data = card_database.cards_db[slug]
		if data.has("editions"):
			for edition in data["editions"]:
				if edition.get("edition_id") == edition_id:
					return slug
	return null

func create_card_display(card_name: String):
	var card_display_scene = preload("res://Scenes/CardDisplay.tscn")
	var card_display = card_display_scene.instantiate()
	card_display.set_meta("slug", card_name)
	card_display.set_meta("zone", "logo_tokens")
	return card_display

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
	var has_basic_status = level_value != 0 or durability_value != 0 or power_value != 0 or life_value != 0
	var has_marker_status = false
	for value in custom_markers.values():
		if value != 0:
			has_marker_status = true
			break
	var has_counter_status = false
	for value in custom_counters.values():
		if value != 0:
			has_counter_status = true
			break
	return has_basic_status or has_marker_status or has_counter_status

func reset_all_status_values():
	level_value = 0
	durability_value = 0
	power_value = 0
	life_value = 0
	for key in custom_markers.keys():
		custom_markers[key] = 0
	for label in marker_labels.values():
		if is_instance_valid(label):
			label.visible = false
	for key in custom_counters.keys():
		custom_counters[key] = 0
	for label in counter_labels.values():
		if is_instance_valid(label):
			label.visible = false
	update_status_display()

func find_node_recursive(node, target_name):
	if node.name == target_name:
		return node
	for child in node.get_children():
		var found = find_node_recursive(child, target_name)
		if found:
			return found
	return null
