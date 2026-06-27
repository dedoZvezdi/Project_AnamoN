extends Control

@onready var exit_button = $SearchPanel/ExitButton
@onready var search_button = $SearchPanel/SearchButton
@onready var results_grid = $ResultsArea/ResultsContent/ScrollContainer/GridContainer
@onready var card_info = $CardInformation
@onready var legality_option = $DeckPanel/legalityOptionButton
@onready var search_line_edit = $SearchPanel/SearchLineEdit
@onready var cost_mem_edit = $SearchPanel/CostMemLineEdit
@onready var cost_res_edit = $SearchPanel/CostResLineEdit
@onready var clear_search_button = $SearchPanel/ClearSearchButton
@onready var clear_button = $DeckPanel/ClearButton
@onready var sort_button = $DeckPanel/SortButton
@onready var shuffle_button = $DeckPanel/ShuffleButton
@onready var level_edit = $SearchPanel/levelOptionButton
@onready var durability_edit = $SearchPanel/DirabilityLineEdit
@onready var life_edit = $SearchPanel/LifeLineEdit
@onready var power_edit = $SearchPanel/PowerLineEdit
@onready var element_option = $SearchPanel/ElementOptionButton
@onready var type_option = $SearchPanel/TypeOptionButton
@onready var subtype_option = $SearchPanel/SupTypeOptionButton
@onready var class_option = $SearchPanel/ClassesOptionButton
@onready var main_deck_grid = $MainDeckContent/ScrollContainer/GridContainer
@onready var mat_deck_grid = $MatDeckContent/ScrollContainer/GridContainer
@onready var pantheon_deck_grid = $PantheonDeckContent/ScrollContainer/GridContainer
@onready var side_deck_grid = $SideDeckContent/ScrollContainer/GridContainer
@onready var main_deck_label = $MainDeckHeader/LabelLeft
@onready var mat_deck_label = $MatDeckHeader/LabelLeft
@onready var pantheon_deck_label = $PantheonDeckHeader/LabelLeft
@onready var side_deck_label = $SideDeckHeader/LabelLeft
@onready var name_edit_line = $DeckPanel/NameEditLine
@onready var deck_option_button = $DeckPanel/DeckOptionButton
@onready var delete_button = $DeckPanel/DeleteButton
@onready var save_button = $DeckPanel/SaveButton
@onready var save_as_button = $DeckPanel/SaveAsButton

const SAVE_PATH = "user://deck_builder_prefs.cfg"
const MAIN_NAME_LIMIT := 4
const MAT_NAME_LIMIT := 1

var _last_legality_idx: int = 0
var _drag_slug := ""
var _drag_source_zone := ""
var _drag_was_dropped := false
var _drag_original_index: int = -1
var _deck_version: int = 0
var _can_accept_cache: Dictionary = {}
var _decks_dir_path: String = ""
var _available_decks: Dictionary = {}
var _current_deck_filename: String = ""
var _last_deck_filename: String = ""
var _delete_confirm_dialog: ConfirmationDialog = null

func _increment_deck_version():
	_deck_version += 1
	_can_accept_cache.clear()

func _ready():
	if main_deck_grid:
		main_deck_grid.grid_type = "main_deck"
		main_deck_grid.max_columns = 15
		main_deck_grid.grid_pixel_width = 1023.0
		main_deck_grid.has_scrollbar_padding = true
		main_deck_grid._rebuild_grid()
	if mat_deck_grid:
		mat_deck_grid.grid_type = "mat_deck"
		mat_deck_grid.max_columns = 12
		mat_deck_grid.grid_pixel_width = 848.0
		mat_deck_grid.has_scrollbar_padding = true
		mat_deck_grid._rebuild_grid()
	if side_deck_grid:
		side_deck_grid.grid_type = "side_deck"
		side_deck_grid.max_columns = 15
		side_deck_grid.grid_pixel_width = 1023.0
		side_deck_grid.has_scrollbar_padding = true
		side_deck_grid._rebuild_grid()
	if pantheon_deck_grid:
		pantheon_deck_grid.grid_type = "pantheon_deck"
		pantheon_deck_grid.max_columns = 2
		pantheon_deck_grid.grid_pixel_width = 158.0
		pantheon_deck_grid.has_scrollbar_padding = false
		pantheon_deck_grid._rebuild_grid()
	_load_prefs()
	if legality_option:
		legality_option.add_item("N/A")
		legality_option.add_item("STANDARD")
		legality_option.add_item("DRAFT")
		legality_option.add_item("PANTHEON")
		legality_option.selected = _last_legality_idx
		legality_option.item_selected.connect(_on_legality_selected)
	var db = card_info.card_database_reference
	if element_option:
		element_option.add_item("Any")
		if db and db.cards_db:
			var elements_set = {}
			for key in db.cards_db:
				var card_data = db.cards_db[key]
				if card_data.has("element") and card_data["element"] != null:
					var element = str(card_data["element"]).strip_edges()
					if element != "" and element != "null":
						elements_set[element] = true
			var elements_list = elements_set.keys()
			elements_list.sort()
			for element in elements_list:
				element_option.add_item(element)
		element_option.selected = 0
		element_option.get_popup().max_size = Vector2i(1000, 165)
	if type_option:
		type_option.add_item("Any")
		if db and db.cards_db:
			var types_set = {}
			for key in db.cards_db:
				var card_data = db.cards_db[key]
				if card_data.has("types") and card_data["types"] is Array:
					for type in card_data["types"]:
						var type_str = str(type).strip_edges()
						var type_upper = type_str.to_upper()
						if type_str != "" and type_str != "null" and type_upper != "TOKEN" and type_upper != "MASTERY" and type_upper != "STATUS":
							types_set[type_str] = true
			var types_list = types_set.keys()
			types_list.sort()
			for type in types_list:
				type_option.add_item(type)
		type_option.selected = 0
		type_option.get_popup().max_size = Vector2i(1000, 165)
	if subtype_option:
		subtype_option.add_item("Any")
		if db and db.cards_db:
			var subtypes_set = {}
			for key in db.cards_db:
				var card_data = db.cards_db[key]
				if card_data.has("subtypes") and card_data["subtypes"] is Array:
					for subtype in card_data["subtypes"]:
						var sub_str = str(subtype).strip_edges()
						if sub_str != "" and sub_str != "null":
							subtypes_set[sub_str] = true
			var subtypes_list = subtypes_set.keys()
			subtypes_list.sort()
			for subtype in subtypes_list:
				subtype_option.add_item(subtype)
		subtype_option.selected = 0
		subtype_option.get_popup().max_size = Vector2i(1000, 165)
	if class_option:
		class_option.add_item("Any")
		if db and db.cards_db:
			var classes_set = {}
			for key in db.cards_db:
				var card_data = db.cards_db[key]
				if card_data.has("classes") and card_data["classes"] is Array:
					for classes in card_data["classes"]:
						var class_str = str(classes).strip_edges()
						if class_str != "" and class_str != "null":
							classes_set[class_str] = true
			var classes_list = classes_set.keys()
			classes_list.sort()
			for classes in classes_list:
				class_option.add_item(classes)
		class_option.selected = 0
		class_option.get_popup().max_size = Vector2i(1000, 165)
	if cost_mem_edit:
		cost_mem_edit.text_changed.connect(_on_cost_mem_changed)
	if cost_res_edit:
		cost_res_edit.text_changed.connect(_on_cost_res_changed)
	if level_edit:
		level_edit.text_changed.connect(_on_digits_only_changed.bind(level_edit))
	if durability_edit:
		durability_edit.text_changed.connect(_on_digits_only_changed.bind(durability_edit))
	if life_edit:
		life_edit.text_changed.connect(_on_digits_only_changed.bind(life_edit))
	if power_edit:
		power_edit.text_changed.connect(_on_digits_only_changed.bind(power_edit))
	if search_line_edit:
		search_line_edit.gui_input.connect(_on_field_gui_input)
	if cost_mem_edit:
		cost_mem_edit.gui_input.connect(_on_field_gui_input)
	if cost_res_edit:
		cost_res_edit.gui_input.connect(_on_field_gui_input)
	if level_edit:
		level_edit.gui_input.connect(_on_field_gui_input)
	if durability_edit:
		durability_edit.gui_input.connect(_on_field_gui_input)
	if life_edit:
		life_edit.gui_input.connect(_on_field_gui_input)
	if power_edit:
		power_edit.gui_input.connect(_on_field_gui_input)
	exit_button.pressed.connect(_on_exit_pressed)
	search_button.pressed.connect(_on_search_pressed)
	if clear_search_button:
		clear_search_button.pressed.connect(_on_clear_search_pressed)
	if clear_button:
		clear_button.pressed.connect(_on_clear_deck_pressed)
	if sort_button:
		sort_button.pressed.connect(_on_sort_main_deck_pressed)
	if shuffle_button:
		shuffle_button.pressed.connect(_on_shuffle_main_deck_pressed)
	if save_button:
		save_button.pressed.connect(_on_save_pressed)
	if save_as_button:
		save_as_button.pressed.connect(_on_save_as_pressed)
	if delete_button:
		delete_button.pressed.connect(_on_delete_pressed)
	if deck_option_button:
		deck_option_button.item_selected.connect(_on_deck_selected)
		deck_option_button.pressed.connect(_on_deck_option_pressed)
	_init_decks_dir()
	_create_deck_saved_label()
	_create_delete_dialog()
	_refresh_deck_options()
	if _current_deck_filename == "" and _last_deck_filename != "":
		for i in range(deck_option_button.get_item_count()):
			var deck_name = deck_option_button.get_item_text(i)
			if _available_decks.has(deck_name) and _available_decks[deck_name] == _last_deck_filename:
				deck_option_button.selected = i
				_on_deck_selected(i)
				break
	update_all_labels()

func _load_prefs():
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		_last_legality_idx = config.get_value("filters", "legality_idx", 0)
		_last_deck_filename = config.get_value("filters", "last_deck_filename", "")
	else:
		_last_legality_idx = 0
		_last_deck_filename = ""

func _save_prefs():
	var config = ConfigFile.new()
	config.set_value("filters", "legality_idx", _last_legality_idx)
	config.set_value("filters", "last_deck_filename", _current_deck_filename)
	config.save(SAVE_PATH)

func _strip_non_digits(text: String) -> String:
	var result = ""
	for chars in text:
		if chars >= "0" and chars <= "9":
			result += chars
	return result

func _on_legality_selected(index: int):
	_last_legality_idx = index
	_save_prefs()
	_increment_deck_version()
	update_all_labels()

func _on_digits_only_changed(new_text: String, field: LineEdit):
	var clean = _strip_non_digits(new_text)
	if clean != new_text:
		field.text = clean
		field.caret_column = clean.length()

func _on_cost_mem_changed(new_text: String):
	var clean = _strip_non_digits(new_text)
	if clean != new_text and cost_mem_edit:
		cost_mem_edit.text = clean
		cost_mem_edit.caret_column = clean.length()
	if cost_res_edit and clean != "" and cost_res_edit.text != "":
		cost_res_edit.text = ""

func _on_cost_res_changed(new_text: String):
	var clean = _strip_non_digits(new_text)
	if clean != new_text and cost_res_edit:
		cost_res_edit.text = clean
		cost_res_edit.caret_column = clean.length()
	if cost_mem_edit and clean != "" and cost_mem_edit.text != "":
		cost_mem_edit.text = ""

func _on_field_gui_input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			_on_search_pressed()

func _deck_has_any_cards() -> bool:
	if main_deck_grid and main_deck_grid.get_card_count() > 0:
		return true
	if mat_deck_grid and mat_deck_grid.get_card_count() > 0:
		return true
	if side_deck_grid and side_deck_grid.get_card_count() > 0:
		return true
	if pantheon_deck_grid:
		for slug in pantheon_deck_grid.card_slugs:
			if slug != "":
				return true
	return false

func _get_card_sort_name(slug: String) -> String:
	var data = _get_base_card_data(slug)
	if data.has("name"):
		return str(data["name"]).to_lower()
	return slug.to_lower()

func _get_selected_legality() -> String:
	if legality_option and legality_option.selected >= 0:
		return legality_option.get_item_text(legality_option.selected)
	return "N/A"

func _is_name_limits_active() -> bool:
	var legality = _get_selected_legality()
	return legality != "N/A" and legality != "DRAFT"

func _get_card_name(slug: String) -> String:
	var data = _get_base_card_data(slug)
	if data.has("name"):
		return str(data["name"])
	return slug

func _uses_memory_name_pool(slug: String) -> bool:
	return _has_cost_memory(slug) and not _is_boon(slug)

func _get_shared_name_limit(slug: String) -> int:
	if not _is_name_limits_active() or _is_boon(slug):
		return -1
	var legality = _get_selected_legality()
	if _uses_memory_name_pool(slug):
		return MAT_NAME_LIMIT
	if legality == "PANTHEON":
		return 1
	return MAIN_NAME_LIMIT

func _get_name_pool_zones(slug: String) -> Array:
	if _is_boon(slug) or not _is_name_limits_active():
		return []
	if _uses_memory_name_pool(slug):
		return ["mat_deck", "side_deck"]
	return ["main_deck", "side_deck"]

func _count_card_name_in_zones(card_name: String, zones: Array) -> int:
	var count := 0
	for zone_name in zones:
		var grid = _get_grid_for_type(zone_name)
		if not grid:
			continue
		for slug in grid.card_slugs:
			if slug != "" and _get_card_name(slug) == card_name:
				count += 1
	return count

func can_add_card_to_zone(slug: String, target_zone: String) -> bool:
	var legality = _get_selected_legality()
	if legality != "N/A":
		if legality == "STANDARD":
			if target_zone == "mat_deck":
				if mat_deck_grid:
					var count = mat_deck_grid.get_card_count()
					if count >= 12:
						return false
					if count == 11 and not _is_level_0_champion(slug):
						var has_champ = false
						for slugs in mat_deck_grid.card_slugs:
							if _is_level_0_champion(slugs):
								has_champ = true
								break
						if not has_champ:
							return false
			elif target_zone == "side_deck":
				if _is_boon(slug):
					return false
				if side_deck_grid:
					var current_pts = 0
					for slugs in side_deck_grid.card_slugs:
						if slugs != "": current_pts += _get_side_deck_cost(slugs)
					if current_pts + _get_side_deck_cost(slug) > 15:
						return false
			elif target_zone == "pantheon_deck":
				return false
		elif legality == "DRAFT":
			if target_zone == "mat_deck":
				if mat_deck_grid:
					var count = mat_deck_grid.get_card_count()
					if count >= 10:
						return false
					if count == 9 and not _is_level_0_champion(slug):
						var has_champ = false
						for slugs in mat_deck_grid.card_slugs:
							if _is_level_0_champion(slugs):
								has_champ = true
								break
						if not has_champ:
							return false
			elif target_zone == "side_deck":
				if _is_boon(slug):
					return false
			elif target_zone == "pantheon_deck":
				return false
		elif legality == "PANTHEON":
			if target_zone == "mat_deck":
				if mat_deck_grid:
					var count = mat_deck_grid.get_card_count()
					if count >= 12:
						return false
					if count == 11 and not _is_level_0_champion(slug):
						var has_champ = false
						for slugs in mat_deck_grid.card_slugs:
							if _is_level_0_champion(slugs):
								has_champ = true
								break
						if not has_champ:
							return false
			elif target_zone == "side_deck":
				return false
	if not _is_name_limits_active() or _is_boon(slug):
		return true
	var limit = _get_shared_name_limit(slug)
	if limit < 0:
		return true
	var pool_zones = _get_name_pool_zones(slug)
	if target_zone not in pool_zones:
		return true
	var card_name = _get_card_name(slug)
	var current_count = _count_card_name_in_zones(card_name, pool_zones)
	return current_count + 1 <= limit

func _compute_illegal_card_keys() -> Dictionary:
	var illegal: Dictionary = {}
	if not _is_name_limits_active():
		return illegal
	var legality = _get_selected_legality()
	var reserve_names: Dictionary = {}
	var memory_names: Dictionary = {}
	if main_deck_grid:
		for i in range(main_deck_grid.card_slugs.size()):
			var slug = main_deck_grid.card_slugs[i]
			if slug == "" or _is_boon(slug) or _uses_memory_name_pool(slug):
				continue
			var card_name = _get_card_name(slug)
			if not reserve_names.has(card_name):
				reserve_names[card_name] = {"main_deck": [], "side_deck": []}
			reserve_names[card_name]["main_deck"].append(i)
	if mat_deck_grid:
		for i in range(mat_deck_grid.card_slugs.size()):
			var slug = mat_deck_grid.card_slugs[i]
			if slug == "" or _is_boon(slug) or not _uses_memory_name_pool(slug):
				continue
			var card_name = _get_card_name(slug)
			if not memory_names.has(card_name):
				memory_names[card_name] = {"mat_deck": [], "side_deck": []}
			memory_names[card_name]["mat_deck"].append(i)
	if side_deck_grid:
		for i in range(side_deck_grid.card_slugs.size()):
			var slug = side_deck_grid.card_slugs[i]
			if slug == "" or _is_boon(slug):
				continue
			var card_name = _get_card_name(slug)
			if _uses_memory_name_pool(slug):
				if not memory_names.has(card_name):
					memory_names[card_name] = {"mat_deck": [], "side_deck": []}
				memory_names[card_name]["side_deck"].append(i)
			else:
				if not reserve_names.has(card_name):
					reserve_names[card_name] = {"main_deck": [], "side_deck": []}
				reserve_names[card_name]["side_deck"].append(i)
	var main_limit = MAIN_NAME_LIMIT
	if legality == "PANTHEON":
		main_limit = 1
	for card_name in reserve_names:
		var grouped = reserve_names[card_name]
		var ordered: Array = []
		for idx in grouped["main_deck"]:
			ordered.append(["main_deck", idx])
		for idx in grouped["side_deck"]:
			ordered.append(["side_deck", idx])
		for j in range(ordered.size()):
			if j >= main_limit:
				var entry = ordered[j]
				illegal[entry[0] + ":" + str(entry[1])] = true
	for card_name in memory_names:
		var grouped = memory_names[card_name]
		var ordered: Array = []
		for idx in grouped["mat_deck"]:
			ordered.append(["mat_deck", idx])
		for idx in grouped["side_deck"]:
			ordered.append(["side_deck", idx])
		for j in range(ordered.size()):
			if j >= MAT_NAME_LIMIT:
				var entry = ordered[j]
				illegal[entry[0] + ":" + str(entry[1])] = true
	if legality == "STANDARD":
		if mat_deck_grid:
			var has_champ = false
			for i in range(mat_deck_grid.card_slugs.size()):
				if i >= 12:
					illegal["mat_deck:" + str(i)] = true
				if _is_level_0_champion(mat_deck_grid.card_slugs[i]):
					has_champ = true
			if mat_deck_grid.card_slugs.size() > 11 and not has_champ:
				for i in range(mat_deck_grid.card_slugs.size()):
					illegal["mat_deck:" + str(i)] = true
		if side_deck_grid:
			var current_pts = 0
			for i in range(side_deck_grid.card_slugs.size()):
				var slug = side_deck_grid.card_slugs[i]
				if _is_boon(slug):
					illegal["side_deck:" + str(i)] = true
				else:
					var cost = _get_side_deck_cost(slug)
					if current_pts + cost > 15:
						illegal["side_deck:" + str(i)] = true
					else:
						current_pts += cost
		if pantheon_deck_grid:
			for i in range(pantheon_deck_grid.card_slugs.size()):
				illegal["pantheon_deck:" + str(i)] = true
	elif legality == "DRAFT":
		if mat_deck_grid:
			var has_champ = false
			for i in range(mat_deck_grid.card_slugs.size()):
				if i >= 10:
					illegal["mat_deck:" + str(i)] = true
				if _is_level_0_champion(mat_deck_grid.card_slugs[i]):
					has_champ = true
			if mat_deck_grid.card_slugs.size() > 9 and not has_champ:
				for i in range(mat_deck_grid.card_slugs.size()):
					illegal["mat_deck:" + str(i)] = true
		if side_deck_grid:
			for i in range(side_deck_grid.card_slugs.size()):
				if _is_boon(side_deck_grid.card_slugs[i]):
					illegal["side_deck:" + str(i)] = true
		if pantheon_deck_grid:
			for i in range(pantheon_deck_grid.card_slugs.size()):
				illegal["pantheon_deck:" + str(i)] = true
	elif legality == "PANTHEON":
		if mat_deck_grid:
			var has_champ = false
			for i in range(mat_deck_grid.card_slugs.size()):
				if i >= 12:
					illegal["mat_deck:" + str(i)] = true
				if _is_level_0_champion(mat_deck_grid.card_slugs[i]):
					has_champ = true
			if mat_deck_grid.card_slugs.size() > 11 and not has_champ:
				for i in range(mat_deck_grid.card_slugs.size()):
					illegal["mat_deck:" + str(i)] = true
		if side_deck_grid:
			for i in range(side_deck_grid.card_slugs.size()):
				illegal["side_deck:" + str(i)] = true
	return illegal

func _refresh_name_limit_visuals():
	var illegal = _compute_illegal_card_keys()
	if main_deck_grid:
		main_deck_grid.apply_illegal_highlights(illegal)
	if mat_deck_grid:
		mat_deck_grid.apply_illegal_highlights(illegal)
	if side_deck_grid:
		side_deck_grid.apply_illegal_highlights(illegal)
	if pantheon_deck_grid:
		pantheon_deck_grid.apply_illegal_highlights(illegal)

func _on_clear_deck_pressed():
	if not _deck_has_any_cards():
		return
	if main_deck_grid:
		main_deck_grid.clear_cards()
	if mat_deck_grid:
		mat_deck_grid.clear_cards()
	if side_deck_grid:
		side_deck_grid.clear_cards()
	if pantheon_deck_grid:
		pantheon_deck_grid.clear_cards()
	_increment_deck_version()
	update_all_labels()

func _on_shuffle_main_deck_pressed():
	if not main_deck_grid or main_deck_grid.get_card_count() <= 1:
		return
	main_deck_grid.shuffle_cards()

func _on_sort_main_deck_pressed():
	if not main_deck_grid or main_deck_grid.get_card_count() <= 1:
		return
	main_deck_grid.sort_cards_by_name(_get_card_sort_name)

func _on_clear_search_pressed():
	if search_line_edit:
		search_line_edit.text = ""
	if cost_mem_edit:
		cost_mem_edit.text = ""
	if cost_res_edit:
		cost_res_edit.text = ""
	if level_edit:
		level_edit.text = ""
	if durability_edit:
		durability_edit.text = ""
	if life_edit:
		life_edit.text = ""
	if power_edit:
		power_edit.text = ""
	if element_option:
		element_option.selected = 0
	if type_option:
		type_option.selected = 0
	if subtype_option:
		subtype_option.selected = 0
	if class_option:
		class_option.selected = 0

func _on_exit_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _get_base_card_data(slug: String) -> Dictionary:
	var db = card_info.card_database_reference
	if not db or not db.cards_db or not db.cards_db.has(slug):
		return {}
	var data = db.cards_db[slug]
	if data.has("types") and data["types"] is Array and data["types"].size() > 0:
		return data
	if data.has("edition_id") and not data.has("parent_orientation_slug"):
		var base_slug = card_info.find_base_card_for_edition(data["edition_id"])
		if base_slug and db.cards_db.has(base_slug):
			return db.cards_db[base_slug]
	elif data.has("parent_orientation_slug"):
		var parent_slug = data["parent_orientation_slug"]
		if db.cards_db.has(parent_slug):
			return db.cards_db[parent_slug]
	return data

func _is_lesser_boon(slug: String) -> bool:
	return card_info.is_card_of_type(slug, "Lesser Boon")

func _is_greater_boon(slug: String) -> bool:
	return card_info.is_card_of_type(slug, "Greater Boon")

func _is_boon(slug: String) -> bool:
	return _is_lesser_boon(slug) or _is_greater_boon(slug)

func _has_cost_memory(slug: String) -> bool:
	var data = _get_base_card_data(slug)
	return data.has("cost_memory") and data["cost_memory"] != null

func _has_cost_reserve(slug: String) -> bool:
	var data = _get_base_card_data(slug)
	return data.has("cost_reserve") and data["cost_reserve"] != null

func _is_level_0_champion(slug: String) -> bool:
	var data = _get_base_card_data(slug)
	if not data.has("level") or data["level"] == null:
		return false
	if str(data["level"]).strip_edges() != "0":
		return false
	if data.has("types") and data["types"] is Array:
		for type in data["types"]:
			if str(type).to_upper().strip_edges() == "CHAMPION":
				return true
	return false

func _get_side_deck_cost(slug: String) -> int:
	if _has_cost_memory(slug):
		return 3
	return 1

func determine_deck_for_slug(slug: String) -> String:
	if _is_boon(slug):
		return "pantheon_deck"
	if _has_cost_memory(slug):
		return "mat_deck"
	if _has_cost_reserve(slug):
		return "main_deck"
	return "main_deck"

func update_all_labels():
	if main_deck_label and main_deck_grid:
		main_deck_label.text = "Deck: " + str(main_deck_grid.get_card_count())
	if mat_deck_label and mat_deck_grid:
		mat_deck_label.text = "Mat Deck: " + str(mat_deck_grid.get_card_count())
	if side_deck_label and side_deck_grid:
		var text = "Side Deck: " + str(side_deck_grid.get_card_count())
		var current_pts = 0
		for i in side_deck_grid.card_slugs:
			if i != "" and not _is_boon(i):
				current_pts += _get_side_deck_cost(i)
		if _get_selected_legality() == "STANDARD":
			text += " (" + str(current_pts) + "/15 pts)"
		else:
			text += " (" + str(current_pts) + " pts)"
		side_deck_label.text = text
	if pantheon_deck_label and pantheon_deck_grid:
		var lesser_count = 0
		var greater_count = 0
		for slug in pantheon_deck_grid.card_slugs:
			if _is_lesser_boon(slug):
				lesser_count += 1
			elif _is_greater_boon(slug):
				greater_count += 1
		pantheon_deck_label.text = "L/G Boon (" + str(lesser_count) + "/" + str(greater_count) + ")"
	_refresh_name_limit_visuals()

func handle_right_click(card_display):
	var zone = ""
	if card_display.has_meta("zone"):
		zone = card_display.get_meta("zone")
	var slug = card_display.card_slug if card_display.card_slug != "" else ""
	if slug == "":
		if card_display.has_meta("slug"):
			slug = card_display.get_meta("slug")
	if slug == "":
		return
	if zone == "deck_building_results":
		_add_card_to_correct_deck_right_click(slug)
	elif zone == "main_deck":
		main_deck_grid.remove_card(slug)
		_increment_deck_version()
		update_all_labels()
	elif zone == "mat_deck":
		mat_deck_grid.remove_card(slug)
		_increment_deck_version()
		update_all_labels()
	elif zone == "pantheon_deck":
		pantheon_deck_grid.remove_card(slug)
		_reorder_pantheon()
		_increment_deck_version()
		update_all_labels()
	elif zone == "side_deck":
		side_deck_grid.remove_card(slug)
		_increment_deck_version()
		update_all_labels()

func _add_card_to_correct_deck_right_click(slug: String):
	if _is_lesser_boon(slug):
		var has_lesser = false
		for slugs in pantheon_deck_grid.card_slugs:
			if _is_lesser_boon(slugs):
				has_lesser = true
				break
		if has_lesser:
			if can_add_card_to_zone(slug, "side_deck"):
				side_deck_grid.add_card(slug)
		else:
			pantheon_deck_grid.add_card(slug)
			_reorder_pantheon()
	elif _is_greater_boon(slug):
		var has_greater = false
		for slugs in pantheon_deck_grid.card_slugs:
			if _is_greater_boon(slugs):
				has_greater = true
				break
		if has_greater:
			if can_add_card_to_zone(slug, "side_deck"):
				side_deck_grid.add_card(slug)
		else:
			pantheon_deck_grid.add_card(slug)
			_reorder_pantheon()
	elif _has_cost_memory(slug):
		if can_add_card_to_zone(slug, "mat_deck"):
			mat_deck_grid.add_card(slug)
	elif can_add_card_to_zone(slug, "main_deck"):
		main_deck_grid.add_card(slug)
	_increment_deck_version()
	update_all_labels()

func can_accept_in_grid(slug: String, source_zone: String, target_grid_type: String) -> bool:
	var cache_key = slug + "|" + source_zone + "|" + target_grid_type
	if _can_accept_cache.has(cache_key):
		return _can_accept_cache[cache_key]
	var result = false
	if source_zone == "deck_building_results" and target_grid_type == "deck_building_results":
		result = false
	elif source_zone != "deck_building_results" and target_grid_type == "deck_building_results":
		result = true
	elif source_zone == "pantheon_deck" and target_grid_type == "pantheon_deck":
		result = false
	elif source_zone == target_grid_type:
		result = true
	elif target_grid_type == "side_deck":
		if not can_add_card_to_zone(slug, "side_deck"):
			result = false
		else:
			result = true
	elif not can_add_card_to_zone(slug, target_grid_type):
		result = false
	else:
		var correct_deck = determine_deck_for_slug(slug)
		result = (correct_deck == target_grid_type)
	_can_accept_cache[cache_key] = result
	return result

func handle_drop_on_grid(slug: String, _source_zone: String, target_grid_type: String, drop_index = -1):
	if target_grid_type == "deck_building_results":
		register_drag_drop()
		return
	if not can_add_card_to_zone(slug, target_grid_type):
		return
	if target_grid_type == "pantheon_deck":
		_handle_pantheon_drag_add(slug)
		register_drag_drop()
		_increment_deck_version()
		update_all_labels()
		return
	var target_grid = _get_grid_for_type(target_grid_type)
	if target_grid:
		if typeof(drop_index) == TYPE_INT and drop_index >= 0:
			target_grid.insert_card(slug, drop_index)
		else:
			target_grid.add_card(slug)
	register_drag_drop()
	_increment_deck_version()
	update_all_labels()

func _get_grid_for_type(grid_type: String):
	match grid_type:
		"main_deck": return main_deck_grid
		"mat_deck": return mat_deck_grid
		"side_deck": return side_deck_grid
		"pantheon_deck": return pantheon_deck_grid
	return null

func _handle_pantheon_drag_add(slug: String):
	if _is_lesser_boon(slug):
		var existing_lesser_idx = -1
		for i in range(pantheon_deck_grid.card_slugs.size()):
			if _is_lesser_boon(pantheon_deck_grid.card_slugs[i]):
				existing_lesser_idx = i
				break
		if existing_lesser_idx >= 0:
			var old_slug = pantheon_deck_grid.remove_card_at(existing_lesser_idx)
			if old_slug != "" and can_add_card_to_zone(old_slug, "side_deck"):
				side_deck_grid.add_card(old_slug)
		pantheon_deck_grid.add_card(slug)
		_reorder_pantheon()
	elif _is_greater_boon(slug):
		var existing_greater_idx = -1
		for i in range(pantheon_deck_grid.card_slugs.size()):
			if _is_greater_boon(pantheon_deck_grid.card_slugs[i]):
				existing_greater_idx = i
				break
		if existing_greater_idx >= 0:
			var old_slug = pantheon_deck_grid.remove_card_at(existing_greater_idx)
			if old_slug != "" and can_add_card_to_zone(old_slug, "side_deck"):
				side_deck_grid.add_card(old_slug)
		pantheon_deck_grid.add_card(slug)
		_reorder_pantheon()

func _reorder_pantheon():
	var lesser_slug = ""
	var greater_slug = ""
	for slugs in pantheon_deck_grid.card_slugs:
		if slugs != "":
			if _is_lesser_boon(slugs) and lesser_slug == "":
				lesser_slug = slugs
			elif _is_greater_boon(slugs) and greater_slug == "":
				greater_slug = slugs
	pantheon_deck_grid.card_slugs.clear()
	if lesser_slug != "" or greater_slug != "":
		pantheon_deck_grid.card_slugs.append(lesser_slug)
		pantheon_deck_grid.card_slugs.append(greater_slug)
	pantheon_deck_grid._rebuild_grid()

func _remove_card_from_zone(slug: String, zone: String, index: int = -1):
	match zone:
		"main_deck":
			if index >= 0:
				main_deck_grid.remove_card_at(index)
			else:
				main_deck_grid.remove_card(slug)
		"mat_deck":
			if index >= 0:
				mat_deck_grid.remove_card_at(index)
			else:
				mat_deck_grid.remove_card(slug)
		"pantheon_deck":
			if index >= 0:
				pantheon_deck_grid.remove_card_at(index)
			else:
				pantheon_deck_grid.remove_card(slug)
			_reorder_pantheon()
		"side_deck":
			if index >= 0:
				side_deck_grid.remove_card_at(index)
			else:
				side_deck_grid.remove_card(slug)
	update_all_labels()

func _add_card_back_to_zone(slug: String, zone: String, original_index: int = -1):
	var grid = _get_grid_for_type(zone)
	if grid:
		if zone == "pantheon_deck":
			grid.add_card(slug)
			_reorder_pantheon()
		else:
			if original_index >= 0:
				grid.insert_card(slug, clampi(original_index, 0, grid.card_slugs.size()))
			else:
				grid.add_card(slug)
		update_all_labels()

func handle_drop_on_results(_slug: String, _source_zone: String, _card_display):
	register_drag_drop()
	update_all_labels()

func register_drag_start(slug: String, source_zone: String, original_index: int = -1):
	_drag_slug = slug
	_drag_source_zone = source_zone
	_drag_was_dropped = false
	_drag_original_index = original_index

func register_drag_drop():
	_drag_was_dropped = true

func _notification(noti):
	if noti == NOTIFICATION_DRAG_END:
		if not _drag_was_dropped and _drag_slug != "" and _drag_source_zone != "" and _drag_source_zone != "deck_building_results":
			_add_card_back_to_zone(_drag_slug, _drag_source_zone, _drag_original_index)
		_drag_slug = ""
		_drag_source_zone = ""
		_drag_was_dropped = false
		_drag_original_index = -1

func _on_search_pressed():
	var db = card_info.card_database_reference
	if not db or not db.cards_db:
		return
	var selected_legality = ""
	if legality_option and legality_option.selected >= 0:
		selected_legality = legality_option.get_item_text(legality_option.selected)
	var search_text = ""
	if search_line_edit:
		search_text = search_line_edit.text.to_lower().strip_edges()
	var filter_cost_mem = -1
	if cost_mem_edit and cost_mem_edit.text.strip_edges() != "":
		filter_cost_mem = int(cost_mem_edit.text.strip_edges())
	var filter_cost_res = -1
	if cost_res_edit and cost_res_edit.text.strip_edges() != "":
		filter_cost_res = int(cost_res_edit.text.strip_edges())
	var filter_level = -1
	if level_edit and level_edit.text.strip_edges() != "":
		filter_level = int(level_edit.text.strip_edges())
	var filter_durability = -1
	if durability_edit and durability_edit.text.strip_edges() != "":
		filter_durability = int(durability_edit.text.strip_edges())
	var filter_life = -1
	if life_edit and life_edit.text.strip_edges() != "":
		filter_life = int(life_edit.text.strip_edges())
	var filter_power = -1
	if power_edit and power_edit.text.strip_edges() != "":
		filter_power = int(power_edit.text.strip_edges())
	var filter_element = ""
	if element_option and element_option.selected > 0:
		filter_element = element_option.get_item_text(element_option.selected).to_upper()
	var filter_type = ""
	if type_option and type_option.selected > 0:
		filter_type = type_option.get_item_text(type_option.selected).to_upper()
	var filter_subtype = ""
	if subtype_option and subtype_option.selected > 0:
		filter_subtype = subtype_option.get_item_text(subtype_option.selected).to_upper()
	var filter_class = ""
	if class_option and class_option.selected > 0:
		filter_class = class_option.get_item_text(class_option.selected).to_upper()
	var slugs_to_show = []
	for key in db.cards_db:
		var card_data = db.cards_db[key]
		if card_data.has("legalities") and card_data.has("types"):
			var is_valid = true
			if card_data.has("types"):
				for type in card_data["types"]:
					var type_upper = str(type).to_upper()
					if type_upper == "TOKEN" or type_upper == "MASTERY" or type_upper == "STATUS":
						is_valid = false
						break
			if is_valid and card_data.has("subtypes"):
				for type in card_data["subtypes"]:
					var type_upper = str(type).to_upper()
					if type_upper == "TOKEN" or type_upper == "MASTERY" or type_upper == "STATUS":
						is_valid = false
						break
			if is_valid and card_data.has("classes"):
				for type in card_data["classes"]:
					var type_upper = str(type).to_upper()
					if type_upper == "TOKEN" or type_upper == "MASTERY" or type_upper == "STATUS":
						is_valid = false
						break
			if is_valid and search_text != "":
				var card_name = str(card_data.get("name", "")).to_lower()
				if not card_name.contains(search_text):
					is_valid = false
			if is_valid and selected_legality != "" and selected_legality != "N/A":
				var is_legal_in_format = true
				if card_data.has("legalities"):
					for legality in card_data["legalities"]:
						if legality.has("formats"):
							for format in legality["formats"]:
								if str(format.get("format", "")).to_upper() == selected_legality:
									if format.has("limit") and int(format["limit"]) == 0:
										is_legal_in_format = false
										break
						if not is_legal_in_format:
							break
				if not is_legal_in_format:
					is_valid = false
			if is_valid and filter_cost_mem >= 0:
				var card_cost_mem = card_data.get("cost_memory", null)
				if card_cost_mem == null or int(card_cost_mem) != filter_cost_mem:
					is_valid = false
			if is_valid and filter_cost_res >= 0:
				var card_cost_res = card_data.get("cost_reserve", null)
				if card_cost_res == null or int(card_cost_res) != filter_cost_res:
					is_valid = false
			if is_valid and filter_level >= 0:
				var card_level = card_data.get("level", null)
				if card_level == null or int(card_level) != filter_level:
					is_valid = false
			if is_valid and filter_durability >= 0:
				var card_dur = card_data.get("durability", null)
				if card_dur == null or int(card_dur) != filter_durability:
					is_valid = false
			if is_valid and filter_life >= 0:
				var card_life = card_data.get("life", null)
				if card_life == null or int(card_life) != filter_life:
					is_valid = false
			if is_valid and filter_power >= 0:
				var card_power = card_data.get("power", null)
				if card_power == null or int(card_power) != filter_power:
					is_valid = false
			if is_valid and filter_element != "":
				var card_element = str(card_data.get("element", "")).to_upper().strip_edges()
				if card_element != filter_element:
					is_valid = false
			if is_valid and filter_type != "":
				var has_type = false
				if card_data.has("types") and card_data["types"] is Array:
					for type in card_data["types"]:
						if str(type).to_upper().strip_edges() == filter_type:
							has_type = true
							break
				if not has_type:
					is_valid = false
			if is_valid and filter_subtype != "":
				var has_subtype = false
				if card_data.has("subtypes") and card_data["subtypes"] is Array:
					for subtype in card_data["subtypes"]:
						if str(subtype).to_upper().strip_edges() == filter_subtype:
							has_subtype = true
							break
				if not has_subtype:
					is_valid = false
			if is_valid and filter_class != "":
				var has_class = false
				if card_data.has("classes") and card_data["classes"] is Array:
					for classes in card_data["classes"]:
						if str(classes).to_upper().strip_edges() == filter_class:
							has_class = true
							break
				if not has_class:
					is_valid = false
			if is_valid and card_data.has("editions"):
				for edition in card_data["editions"]:
					var slug = edition["slug"]
					if not slugs_to_show.has(slug):
						slugs_to_show.append(slug)
	slugs_to_show.sort()
	var results_header_label = $ResultsArea/ResultsHeader/LabelLeft
	if results_header_label:
		results_header_label.text = "Results: " + str(slugs_to_show.size())
	if results_grid.has_method("set_data"):
		results_grid.set_data(slugs_to_show)

func _init_decks_dir():
	if OS.has_feature("standalone"):
		_decks_dir_path = OS.get_executable_path().get_base_dir().path_join("Decks")
	else:
		_decks_dir_path = "res://Decks"
	var dir = DirAccess.open(_decks_dir_path)
	if not dir:
		DirAccess.make_dir_absolute(_decks_dir_path)

var _deck_saved_tween: Tween
var _deck_saved_label: Label

func _create_deck_saved_label():
	_deck_saved_label = Label.new()
	_deck_saved_label.text = "Deck Saved"
	_deck_saved_label.add_theme_font_size_override("font_size", 18)
	_deck_saved_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_deck_saved_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_deck_saved_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_deck_saved_label.position = Vector2(-50, 200)
	_deck_saved_label.size = Vector2(100, 30)
	_deck_saved_label.modulate.a = 0.0
	add_child(_deck_saved_label)

func _show_deck_saved_message():
	if not _deck_saved_label:
		return
	if _deck_saved_tween and _deck_saved_tween.is_valid():
		_deck_saved_tween.kill()
	_deck_saved_label.modulate.a = 1.0
	_deck_saved_tween = create_tween()
	_deck_saved_tween.tween_property(_deck_saved_label, "modulate:a", 0.0, 1.5).set_delay(0.5)

func _create_delete_dialog():
	_delete_confirm_dialog = ConfirmationDialog.new()
	_delete_confirm_dialog.dialog_text = "Do you want to delete this deck?"
	_delete_confirm_dialog.confirmed.connect(_delete_confirmed)
	add_child(_delete_confirm_dialog)

func _refresh_deck_options():
	if not deck_option_button: return
	deck_option_button.clear()
	_available_decks.clear()
	var dir = DirAccess.open(_decks_dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".gad"):
				var file = FileAccess.open(_decks_dir_path.path_join(file_name), FileAccess.READ)
				if file:
					var json = JSON.new()
					var error = json.parse(file.get_as_text())
					if error == OK and typeof(json.data) == TYPE_DICTIONARY:
						var data = json.data
						if data.has("deck_name") and data.has("main_deck") and data.has("mat_deck") and data.has("side_deck") and data.has("pantheon_deck"):
							var deck_name = str(data["deck_name"])
							_available_decks[deck_name] = file_name
							deck_option_button.add_item(deck_name)
			file_name = dir.get_next()
	if _current_deck_filename != "":
		for i in range(deck_option_button.get_item_count()):
			var deck_name = deck_option_button.get_item_text(i)
			if _available_decks.has(deck_name) and _available_decks[deck_name] == _current_deck_filename:
				deck_option_button.selected = i
				break

func _on_deck_option_pressed():
	_refresh_deck_options()

func _on_deck_selected(index: int):
	var deck_name = deck_option_button.get_item_text(index)
	if not _available_decks.has(deck_name): return
	var file_name = _available_decks[deck_name]
	_current_deck_filename = file_name
	var file = FileAccess.open(_decks_dir_path.path_join(file_name), FileAccess.READ)
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		if error == OK:
			var data = json.data
			_load_deck_data(data)
			_save_prefs()

func _load_deck_data(data: Dictionary):
	_on_clear_deck_pressed()
	if main_deck_grid and data.has("main_deck"):
		for slug in data["main_deck"]:
			main_deck_grid.card_slugs.append(str(slug))
		main_deck_grid._rebuild_grid()
	if mat_deck_grid and data.has("mat_deck"):
		for slug in data["mat_deck"]:
			mat_deck_grid.card_slugs.append(str(slug))
		mat_deck_grid._rebuild_grid()
	if side_deck_grid and data.has("side_deck"):
		for slug in data["side_deck"]:
			side_deck_grid.card_slugs.append(str(slug))
		side_deck_grid._rebuild_grid()
	if pantheon_deck_grid and data.has("pantheon_deck"):
		for slug in data["pantheon_deck"]:
			pantheon_deck_grid.card_slugs.append(str(slug))
		pantheon_deck_grid._rebuild_grid()
	_increment_deck_version()
	update_all_labels()

func _has_deck_changed(deck_name: String) -> bool:
	if _current_deck_filename == "": return true
	var old_deck_name = ""
	for key in _available_decks:
		if _available_decks[key] == _current_deck_filename:
			old_deck_name = key
			break
	if deck_name != "" and deck_name != old_deck_name:
		return true
	var file = FileAccess.open(_decks_dir_path.path_join(_current_deck_filename), FileAccess.READ)
	if file:
		var json = JSON.new()
		if json.parse(file.get_as_text()) == OK:
			var old_data = json.data
			var main_current = _get_slugs_from_grid(main_deck_grid)
			var mat_current = _get_slugs_from_grid(mat_deck_grid)
			var side_current = _get_slugs_from_grid(side_deck_grid)
			var pantheon_current = _get_slugs_from_grid(pantheon_deck_grid)
			if str(old_data.get("main_deck", [])) != str(main_current): return true
			if str(old_data.get("mat_deck", [])) != str(mat_current): return true
			if str(old_data.get("side_deck", [])) != str(side_current): return true
			if str(old_data.get("pantheon_deck", [])) != str(pantheon_current): return true
	return false

func _on_save_pressed():
	if _current_deck_filename == "": return
	var deck_name = ""
	if name_edit_line:
		deck_name = name_edit_line.text.strip_edges()
	if not _has_deck_changed(deck_name):
		return
	var old_deck_name = ""
	for key in _available_decks:
		if _available_decks[key] == _current_deck_filename:
			old_deck_name = key
			break
	if deck_name == "":
		deck_name = old_deck_name
	if deck_name != old_deck_name:
		var pair = _get_unique_name_and_filename(deck_name)
		var new_deck_name = pair[0]
		var new_file_name = pair[1]
		var dir = DirAccess.open(_decks_dir_path)
		if dir and dir.file_exists(_current_deck_filename):
			dir.rename(_current_deck_filename, new_file_name)
		_current_deck_filename = new_file_name
		deck_name = new_deck_name
	_save_current_deck_state(deck_name, _current_deck_filename)
	_show_deck_saved_message()
	_refresh_deck_options()
	_save_prefs()

func _on_save_as_pressed():
	var deck_name = ""
	if name_edit_line:
		deck_name = name_edit_line.text.strip_edges()
	if deck_name == "": return
	var pair = _get_unique_name_and_filename(deck_name)
	var new_deck_name = pair[0]
	var new_filename = pair[1]
	_current_deck_filename = new_filename
	_save_current_deck_state(new_deck_name, new_filename)
	_refresh_deck_options()
	_save_prefs()

func _save_current_deck_state(deck_name: String, file_name: String):
	var data = {
		"deck_name": deck_name,
		"legal_formats": _get_legal_formats(),
		"main_deck": _get_slugs_from_grid(main_deck_grid),
		"mat_deck": _get_slugs_from_grid(mat_deck_grid),
		"side_deck": _get_slugs_from_grid(side_deck_grid),
		"pantheon_deck": _get_slugs_from_grid(pantheon_deck_grid)
	}
	var file = FileAccess.open(_decks_dir_path.path_join(file_name), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))

func _get_slugs_from_grid(grid) -> Array:
	if not grid: return []
	var result = []
	for slug in grid.card_slugs:
		if slug != "":
			result.append(slug)
	return result

func _sanitize_filename(file_name_str: String) -> String:
	var invalid_chars = ["<", ">", ":", "\"", "/", "\\", "|", "?", "*"]
	var result = file_name_str
	for chars in invalid_chars:
		result = result.replace(chars, "-")
	return result

func _get_unique_name_and_filename(base_name: String) -> Array:
	var current_name = base_name
	var name_counter = 1
	while _available_decks.has(current_name):
		current_name = base_name + "(" + str(name_counter) + ")"
		name_counter += 1
	var dir = DirAccess.open(_decks_dir_path)
	var final_sanitized = _sanitize_filename(current_name)
	var current_filename = final_sanitized + ".gad"	
	if dir:
		var file_counter = 1
		while dir.file_exists(current_filename):
			current_filename = final_sanitized + "(" + str(file_counter) + ").gad"
			file_counter += 1
	return [current_name, current_filename]

func _on_delete_pressed():
	if _current_deck_filename == "": return
	var deck_name = "this"
	if name_edit_line and name_edit_line.text != "":
		deck_name = "'" + name_edit_line.text + "'"
	if _delete_confirm_dialog:
		_delete_confirm_dialog.dialog_text = "Do you want to delete " + deck_name + " deck?"
		_delete_confirm_dialog.popup_centered()

func _delete_confirmed():
	if _current_deck_filename != "":
		var dir = DirAccess.open(_decks_dir_path)
		if dir and dir.file_exists(_current_deck_filename):
			dir.remove(_current_deck_filename)
		_current_deck_filename = ""
		_on_clear_deck_pressed()
		_refresh_deck_options()
		if deck_option_button and deck_option_button.get_item_count() > 0:
			deck_option_button.selected = 0
			_on_deck_selected(0)
		_save_prefs()

func _get_legal_formats() -> Array:
	var legal = []
	var main_slugs = _get_slugs_from_grid(main_deck_grid)
	var mat_slugs = _get_slugs_from_grid(mat_deck_grid)
	var side_slugs = _get_slugs_from_grid(side_deck_grid)
	var pantheon_slugs = _get_slugs_from_grid(pantheon_deck_grid)
	if main_slugs.size() > 0 or mat_slugs.size() > 0 or pantheon_slugs.size() > 0:
		legal.append("N/A")
	if _is_legal_format("STANDARD", main_slugs, mat_slugs, side_slugs, pantheon_slugs):
		legal.append("STANDARD")
	if _is_legal_format("DRAFT", main_slugs, mat_slugs, side_slugs, pantheon_slugs):
		legal.append("DRAFT")
	if _is_legal_format("PANTHEON", main_slugs, mat_slugs, side_slugs, pantheon_slugs):
		legal.append("PANTHEON")
	return legal

func _is_legal_format(format_name: String, main_slugs: Array, mat_slugs: Array, _side_slugs: Array, pantheon_slugs: Array) -> bool:
	var format_idx = -1
	for i in range(legality_option.get_item_count()):
		if legality_option.get_item_text(i) == format_name:
			format_idx = i
			break
	if format_idx == -1: return false
	var old_selected = legality_option.selected
	legality_option.selected = format_idx
	var illegal_keys = _compute_illegal_card_keys()
	legality_option.selected = old_selected
	if illegal_keys.size() > 0:
		return false
	var has_lvl_0_champ = false
	for slug in mat_slugs:
		if _is_level_0_champion(slug):
			has_lvl_0_champ = true
			break
	if format_name == "STANDARD":
		if main_slugs.size() < 60: return false
		if mat_slugs.size() != 12: return false
		if not has_lvl_0_champ: return false
		return true
	elif format_name == "DRAFT":
		if main_slugs.size() < 30: return false
		if mat_slugs.size() > 10: return false
		if not has_lvl_0_champ: return false
		return true
	elif format_name == "PANTHEON":
		if main_slugs.size() < 60: return false
		if mat_slugs.size() != 12: return false
		if not has_lvl_0_champ: return false
		var lesser_count = 0
		var greater_count = 0
		for slug in pantheon_slugs:
			if _is_lesser_boon(slug): lesser_count += 1
			elif _is_greater_boon(slug): greater_count += 1
		if lesser_count != 1 or greater_count != 1: return false
		return true
	return false
