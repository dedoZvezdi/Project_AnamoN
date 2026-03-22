extends Node2D

@onready var logo_menu = $LogoMenu
@onready var scroll_vbox = $LogoMenu/MainVBox/ScrollSection/ScrollVBox
@onready var fixed_vbox = $LogoMenu/MainVBox/FixedVBox
@onready var separator = $LogoMenu/MainVBox/Separator
@onready var scroll_section = $LogoMenu/MainVBox/ScrollSection
@onready var Logo_view_window = $LogoViewWindow
@onready var grid_container = $LogoViewWindow/ScrollContainer/GridContainer
@onready var Logo_mastery_view_window = $LogoMasteryViewWindow
@onready var mastery_grid_container = $LogoMasteryViewWindow/ScrollContainer/GridContainer

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
var showing_counters_menu := false
var showing_specific_counter_menu := false
var current_counter_name := ""
var level_value := 0
var durability_value := 0
var power_value := 0
var life_value := 0
var custom_counters := {}
var counter_labels := {}
var chat_node = null
var add_counter_dialog: AcceptDialog
var counter_name_input: LineEdit
var original_menu_pos: Vector2 = Vector2.ZERO
var player_name: String = "Player"
var token_slugs : Array = []
var mastery_slugs : Array = []

func _ready():
	add_to_group("logo")
	$Area2D.input_pickable = true
	$Area2D.input_event.connect(_on_Area2D_input_event)
	custom_counters["Buff"] = 0
	custom_counters["Debuff"] = 0
	custom_counters["Enlighten"] = 0
	custom_counters["Omen"] = 0
	build_main_menu()
	setup_status_labels()
	setup_counter_input_dialog()
	for c_name in custom_counters.keys():
		create_counter_label(c_name)
	update_status_display()
	find_chat_node()
	Logo_view_window.close_requested.connect(_on_logo_view_close)
	Logo_view_window.visibility_changed.connect(_on_logo_view_visibility_changed)
	Logo_mastery_view_window.close_requested.connect(_on_logo_mastery_view_close)
	Logo_mastery_view_window.visibility_changed.connect(_on_logo_mastery_view_visibility_changed)
	call_deferred("populate_tokens")
	call_deferred("populate_mastery")
	Logo_view_window.hide()
	Logo_mastery_view_window.hide()
	var config = ConfigFile.new()
	var err = config.load("user://player_config.cfg")
	if err == OK:
		player_name = config.get_value("Player", "Name", "Player")

func setup_counter_input_dialog():
	add_counter_dialog = AcceptDialog.new()
	add_counter_dialog.title = "Add New Counter"
	add_counter_dialog.size = Vector2(300, 120)
	var vbox = VBoxContainer.new()
	var label = Label.new()
	label.text = "Enter counter name:"
	counter_name_input = LineEdit.new()
	counter_name_input.placeholder_text = "Counter name..."
	counter_name_input.max_length = 17
	vbox.add_child(label)
	vbox.add_child(counter_name_input)
	add_counter_dialog.add_child(vbox)
	add_child(add_counter_dialog)
	add_counter_dialog.confirmed.connect(_on_counter_name_confirmed)

func _on_counter_name_confirmed():
	var counter_name = counter_name_input.text.strip_edges()
	if counter_name != "" and not custom_counters.has(counter_name):
		custom_counters[counter_name] = 0
		create_counter_label(counter_name)
	counter_name_input.text = ""
	build_counters_menu()

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

func _on_logo_mastery_view_close():
	Logo_mastery_view_window.hide()

func _on_logo_mastery_view_visibility_changed():
	if Logo_mastery_view_window.visible:
		$LogoMasteryViewWindow/ScrollContainer.scroll_horizontal = 0
		$LogoMasteryViewWindow/ScrollContainer.scroll_vertical = 0

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
		chat_node.send_system_message(player_name + " " + message)

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
	if logo_menu.visible:
		var mouse_pos_global = get_global_mouse_position()
		var area_pos_global = $Area2D.global_position
		var menu_rect = logo_menu.get_global_rect()
		if not menu_rect.has_point(mouse_pos_global) and mouse_pos_global.distance_to(area_pos_global) > 250:
			logo_menu.hide()

func build_main_menu():
	showing_dice_menu = false
	showing_rps_menu = false
	showing_status_menu = false
	showing_level_menu = false
	showing_durability_menu = false
	showing_power_menu = false
	showing_life_menu = false
	showing_life_menu = false
	showing_counters_menu = false
	showing_specific_counter_menu = false
	clear_custom_menu()
	add_custom_item("Memory Random", 100)
	add_custom_item("Coin Flip", 101)
	add_custom_item("Roll Dice", 102)
	add_custom_item("RPS", 104)
	add_custom_item("Status Modification", 105)
	add_custom_item("Counters", 107)
	add_custom_item("Add Counters", 108)
	add_custom_item("Summon Token", 106)
	add_custom_item("Summon Mastery", 109)
	add_custom_item("Surrender", 103, {}, true)
	finalize_custom_menu()

func clear_custom_menu():
	for child in scroll_vbox.get_children():
		scroll_vbox.remove_child(child)
		child.queue_free()
	for child in fixed_vbox.get_children():
		fixed_vbox.remove_child(child)
		child.queue_free()
	separator.hide()
	scroll_section.custom_minimum_size = Vector2.ZERO
	scroll_section.size = Vector2.ZERO
	logo_menu.custom_minimum_size = Vector2.ZERO
	logo_menu.size = Vector2.ZERO

func add_custom_item(label_text: String, id: int, metadata: Dictionary = {}, is_fixed: bool = false):
	var button = Button.new()
	button.text = label_text
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_font_size_override("font_size", 14)
	button.pressed.connect(func(): _on_custom_item_pressed(id, metadata))
	button.flat = false
	if is_fixed:
		fixed_vbox.add_child(button)
	else:
		scroll_vbox.add_child(button)

func _on_custom_item_pressed(id: int, metadata: Dictionary):
	_handle_menu_action(id, metadata)

func finalize_custom_menu():
	scroll_section.custom_minimum_size = Vector2.ZERO
	logo_menu.custom_minimum_size = Vector2.ZERO
	logo_menu.size = Vector2.ZERO
	await get_tree().process_frame
	var scroll_item_count = scroll_vbox.get_child_count()
	var fixed_item_count = fixed_vbox.get_child_count()
	var total_items = scroll_item_count + fixed_item_count
	var max_visible_total = 9
	if scroll_item_count > 0 and fixed_item_count > 0:
		separator.show()
	else:
		separator.hide()
	if total_items > 0:
		var sample_item = null
		if scroll_item_count > 0:
			sample_item = scroll_vbox.get_child(0)
		elif fixed_item_count > 0:
			sample_item = fixed_vbox.get_child(0)
		if sample_item:
			var item_height = sample_item.get_combined_minimum_size().y + scroll_vbox.get_theme_constant("separation")
			if total_items > max_visible_total:
				var scroll_visible_count = max(1, max_visible_total - fixed_item_count)
				scroll_section.custom_minimum_size.y = item_height * scroll_visible_count
			else:
				scroll_section.custom_minimum_size.y = item_height * scroll_item_count
	else:
		scroll_section.custom_minimum_size.y = 0
	logo_menu.size = Vector2.ZERO
	await get_tree().process_frame
	logo_menu.size = Vector2.ZERO
	adjust_custom_menu_position()

func adjust_custom_menu_position():
	var screen_size = get_viewport().get_visible_rect().size
	var menu_size = logo_menu.get_combined_minimum_size()
	var pos = original_menu_pos
	if pos.x + menu_size.x > screen_size.x:
		pos.x = screen_size.x - menu_size.x
	if pos.x < 0:
		pos.x = 0
	if pos.y + menu_size.y > screen_size.y:
		pos.y = screen_size.y - menu_size.y
	if pos.y < 0:
		pos.y = 0
	logo_menu.global_position = pos

func build_predefined_counters_menu():
	showing_dice_menu = false
	showing_rps_menu = false
	showing_status_menu = false
	showing_level_menu = false
	showing_durability_menu = false
	showing_power_menu = false
	showing_life_menu = false
	showing_counters_menu = true
	showing_specific_counter_menu = false
	clear_custom_menu()
	var predefined = ["Buff", "Debuff", "Enlighten", "Omen"]
	for c_name in predefined:
		add_custom_item(c_name + " +", 700, {"action": "increase", "counter": c_name})
		if c_name != "Buff" and c_name != "Debuff":
			add_custom_item(c_name + " -", 700, {"action": "decrease", "counter": c_name})
	add_custom_item("Back", 999, {}, true)
	finalize_custom_menu()

func build_counters_menu():
	showing_dice_menu = false
	showing_rps_menu = false
	showing_status_menu = false
	showing_level_menu = false
	showing_durability_menu = false
	showing_power_menu = false
	showing_life_menu = false
	showing_counters_menu = true
	showing_specific_counter_menu = false
	clear_custom_menu()
	add_custom_item("Add", 501)
	var predefined = ["Buff", "Debuff", "Enlighten", "Omen"]
	for counter_name in custom_counters.keys():
		if not predefined.has(counter_name):
			add_custom_item(counter_name + " +", 700, {"action": "increase", "counter": counter_name})
			add_custom_item(counter_name + " -", 700, {"action": "decrease", "counter": counter_name})
	add_custom_item("Back", 999, {}, true)
	finalize_custom_menu()

func build_dice_menu():
	showing_dice_menu = true
	showing_rps_menu = false
	showing_status_menu = false
	showing_level_menu = false
	showing_durability_menu = false
	showing_power_menu = false
	showing_life_menu = false
	showing_counters_menu = false
	showing_specific_counter_menu = false
	showing_specific_counter_menu = false
	clear_custom_menu()
	add_custom_item("D6", 6)
	add_custom_item("D8", 8)
	add_custom_item("D20", 20)
	add_custom_item("Back", 999, {}, true)
	finalize_custom_menu()

func build_rps_menu():
	showing_dice_menu = false
	showing_rps_menu = true
	showing_status_menu = false
	showing_level_menu = false
	showing_durability_menu = false
	showing_power_menu = false
	showing_life_menu = false
	showing_counters_menu = false
	showing_specific_counter_menu = false
	showing_specific_counter_menu = false
	clear_custom_menu()
	add_custom_item("Rock", 201)
	add_custom_item("Paper", 202)
	add_custom_item("Scissors", 203)
	add_custom_item("Back", 999, {}, true)
	finalize_custom_menu()

func build_status_menu():
	showing_dice_menu = false
	showing_rps_menu = false
	showing_status_menu = true
	showing_level_menu = false
	showing_durability_menu = false
	showing_power_menu = false
	showing_life_menu = false
	showing_counters_menu = false
	showing_specific_counter_menu = false
	showing_specific_counter_menu = false
	clear_custom_menu()
	add_custom_item("Level", 301)
	add_custom_item("Durability", 302)
	add_custom_item("Power", 303)
	add_custom_item("Life", 304)
	add_custom_item("Back", 999, {}, true)
	finalize_custom_menu()

func build_level_menu():
	showing_dice_menu = false
	showing_rps_menu = false
	showing_status_menu = false
	showing_level_menu = true
	showing_durability_menu = false
	showing_power_menu = false
	showing_life_menu = false
	showing_counters_menu = false
	showing_specific_counter_menu = false
	showing_specific_counter_menu = false
	clear_custom_menu()
	add_custom_item("Level +1", 401)
	add_custom_item("Level -1", 402)
	add_custom_item("Back", 999, {}, true)
	finalize_custom_menu()

func build_durability_menu():
	showing_dice_menu = false
	showing_rps_menu = false
	showing_status_menu = false
	showing_level_menu = false
	showing_durability_menu = true
	showing_power_menu = false
	showing_life_menu = false
	showing_counters_menu = false
	showing_specific_counter_menu = false
	showing_specific_counter_menu = false
	clear_custom_menu()
	add_custom_item("Durability +1", 403)
	add_custom_item("Durability -1", 404)
	add_custom_item("Back", 999, {}, true)
	finalize_custom_menu()

func build_power_menu():
	showing_dice_menu = false
	showing_rps_menu = false
	showing_status_menu = false
	showing_level_menu = false
	showing_durability_menu = false
	showing_power_menu = true
	showing_life_menu = false
	showing_counters_menu = false
	showing_specific_counter_menu = false
	showing_specific_counter_menu = false
	clear_custom_menu()
	add_custom_item("Power +1", 405)
	add_custom_item("Power -1", 406)
	add_custom_item("Back", 999, {}, true)
	finalize_custom_menu()

func build_life_menu():
	showing_dice_menu = false
	showing_rps_menu = false
	showing_status_menu = false
	showing_level_menu = false
	showing_durability_menu = false
	showing_power_menu = false
	showing_life_menu = true
	showing_counters_menu = false
	showing_specific_counter_menu = false
	showing_specific_counter_menu = false
	clear_custom_menu()
	add_custom_item("Life +1", 407)
	add_custom_item("Life -1", 408)
	add_custom_item("Back", 999, {}, true)
	finalize_custom_menu()

func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var player_hand_node = find_node_recursive(get_tree().get_root(), "PlayerHand")
		if player_hand_node:
			player_hand_node.toggle_hand_visibility()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		original_menu_pos = get_global_mouse_position()
		logo_menu.global_position = original_menu_pos
		logo_menu.show()
		build_main_menu()

func _handle_menu_action(id, metadata = {}):
	if not showing_dice_menu and not showing_rps_menu and not showing_status_menu and not showing_level_menu and not showing_durability_menu and not showing_power_menu and not showing_life_menu and not showing_counters_menu:
		if id == 100:
			logo_menu.hide()
			var memory_slot = find_node_recursive(get_tree().get_root(), "MEMORY")
			if memory_slot:
				memory_slot.highlight_random_card()
		elif id == 101:
			logo_menu.hide()
			var result = ["HEAD", "TAIL"].pick_random()
			send_to_chat("Flipped Coin - " + result)
		elif id == 102:
			build_dice_menu()
		elif id == 104:
			build_rps_menu()
		elif id == 105:
			build_status_menu()
		elif id == 107:
			build_predefined_counters_menu()
		elif id == 108:
			build_counters_menu()
		elif id == 106:
			logo_menu.hide()
			Logo_view_window.popup_centered()
			$LogoViewWindow/ScrollContainer.call_deferred("set", "scroll_horizontal", 0)
			$LogoViewWindow/ScrollContainer.call_deferred("set", "scroll_vertical", 0)
		elif id == 109:
			logo_menu.hide()
			Logo_mastery_view_window.popup_centered()
			$LogoMasteryViewWindow/ScrollContainer.call_deferred("set", "scroll_horizontal", 0)
			$LogoMasteryViewWindow/ScrollContainer.call_deferred("set", "scroll_vertical", 0)
		elif id == 103:
			logo_menu.hide()
			send_to_chat("Surrendered")
	elif showing_dice_menu:
		if id == 999:
			build_main_menu()
		else:
			logo_menu.hide()
			var roll = randi_range(1, id)
			send_to_chat("Rolled D" + str(id) + " - " + str(roll))
	elif showing_rps_menu:
		if id == 999:
			build_main_menu()
		else:
			logo_menu.hide()
			var choice = ""
			if id == 201:
				choice = "Rock"
			elif id == 202:
				choice = "Paper"
			elif id == 203:
				choice = "Scissors"
			if chat_node and chat_node.has_method("handle_rps_choice"):
				chat_node.handle_rps_choice(choice)
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
	elif showing_counters_menu:
		if id == 999:
			build_main_menu()
		elif id == 501:
			logo_menu.hide()
			add_counter_dialog.popup_centered()
		elif id >= 700:
			var counter_name = metadata.get("counter", "")
			var action = metadata.get("action", "")
			if custom_counters.has(counter_name):
				if action == "increase":
					if counter_name == "Buff" and custom_counters["Debuff"] > 0:
						custom_counters["Debuff"] -= 1
					elif counter_name == "Debuff" and custom_counters["Buff"] > 0:
						custom_counters["Buff"] -= 1
					else:
						custom_counters[counter_name] += 1
				elif action == "decrease":
					custom_counters[counter_name] -= 1
				update_status_display()
				if ["Buff", "Debuff", "Enlighten", "Omen"].has(counter_name):
					build_predefined_counters_menu()
				else:
					build_counters_menu()

func fetch_slugs_by_type(target_type: String) -> Array:
	var slugs = []
	var card_info = find_card_information_reference()
	var db = null
	if card_info and card_info.get("card_database_reference"):
		db = card_info.card_database_reference
	else:
		db = load("res://Scripts/CardDatabase.gd").new()
		db.initialize_database()
		db.load_all_cards_data()
	if db and db.get("cards_db"):
		for key in db.cards_db:
			var data = db.cards_db[key]
			if data.has("types") and target_type in data["types"]:
				if data.has("editions"):
					for edition in data["editions"]:
						var slug = edition["slug"]
						if not slugs.has(slug):
							var image_path = "res://Assets/Grand Archive/Card Images/" + slug + ".png"
							if ResourceLoader.exists(image_path) or FileAccess.file_exists(image_path) or FileAccess.file_exists(image_path + ".import"):
								slugs.append(slug)
	return slugs

func populate_tokens():
	for child in grid_container.get_children():
		child.queue_free()
	if token_slugs.is_empty():
		token_slugs = fetch_slugs_by_type("TOKEN")
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
	card_display.set_meta("uuid", "")
	card_display.set_meta("zone", "logo_tokens")
	return card_display

func has_active_status() -> bool:
	var has_basic_status = level_value != 0 or durability_value != 0 or power_value != 0 or life_value != 0
	var has_counter_status = false
	for value in custom_counters.values():
		if value != 0:
			has_counter_status = true
			break
	return has_basic_status or has_counter_status

func reset_all_status_values():
	level_value = 0
	durability_value = 0
	power_value = 0
	life_value = 0
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

func populate_mastery():
	for child in mastery_grid_container.get_children():
		child.queue_free()
	if mastery_slugs.is_empty():
		mastery_slugs = fetch_slugs_by_type("MASTERY")
	mastery_slugs.sort()
	for slug in mastery_slugs:
		var card_display = create_card_display_mastery(slug)
		mastery_grid_container.add_child(card_display)
	mastery_grid_container.anchor_left = 0
	mastery_grid_container.anchor_top = 0
	mastery_grid_container.anchor_right = 1
	mastery_grid_container.anchor_bottom = 1
	mastery_grid_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mastery_grid_container.size_flags_vertical = Control.SIZE_EXPAND_FILL

func create_card_display_mastery(card_name: String):
	var card_display_scene = preload("res://Scenes/CardDisplay.tscn")
	var card_display = card_display_scene.instantiate()
	card_display.set_meta("slug", card_name)
	card_display.set_meta("uuid", "")
	card_display.set_meta("zone", "logo_mastery")
	return card_display
