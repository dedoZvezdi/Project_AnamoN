extends Control

func _ready() -> void:
	_cleanup_temp_opponent_photo()
	_ensure_decks_folder_exists()
	fade()

func _ensure_decks_folder_exists():
	GamePaths.ensure_decks_dir_exists()

func _cleanup_temp_opponent_photo():
	var base_path = ""
	if OS.has_feature("editor"):
		base_path = ProjectSettings.globalize_path("res://Data/")
	else:
		base_path = OS.get_executable_path().get_base_dir().path_join("Data")
	var file_path = base_path.path_join("temp_opponent_photo.png")
	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(file_path)

func fade() -> void:
	await get_tree().process_frame
	if has_node("LoadingBar/ChunksContainer"):
		var container = $LoadingBar/ChunksContainer
		var label = $LoadingBar/VBox/StatusLabel
		var percent_label = $LoadingBar/VBox/PercentLabel
		var chunks = container.get_children()
		_load_database()
		var loading_tween = self.create_tween()
		var time_per_chunk = 0.03
		var c1 = Color("524121ff")
		var c2 = Color("c9a96e")
		for i in range(chunks.size()):
			var chunk = chunks[i]
			var t = float(i) / float(max(1, chunks.size() - 1))
			var target_color = c1.lerp(c2, t)
			var target_node = chunk
			if chunk.has_node("Polygon2D"):
				target_node = chunk.get_node("Polygon2D")
			loading_tween.tween_interval(time_per_chunk)
			loading_tween.tween_property(target_node, "color", target_color, 0.01)
			var update_pct = func(pct): percent_label.text = str(pct) + "%"
			loading_tween.tween_callback(update_pct.bind(int((float(i+1) / float(chunks.size())) * 100)))
			if i == 0:
				loading_tween.tween_callback(func(): label.text = "Loading Cards Images")
			elif i == 7:
				loading_tween.tween_callback(func(): label.text = "Loading Scripts")
			elif i == 15:
				loading_tween.tween_callback(func(): label.text = "Loading Scenes")
			elif i == 20:
				loading_tween.tween_callback(func(): label.text = "Preparing UI")
			elif i == 24:
				loading_tween.tween_callback(func(): label.text = "Starting The Game")
		await loading_tween.finished
		while SceneCache._thread != null or SceneCache._needs_compile:
			await get_tree().process_frame
	else:
		_load_database()
		while SceneCache._thread != null or SceneCache._needs_compile:
			await get_tree().process_frame
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _load_database() -> void:
	Engine.set_meta("KeepCardDatabaseAlive", preload("res://Scripts/CardDatabase.gd"))
	var temp_db = preload("res://Scripts/CardDatabase.gd").new()
	temp_db.initialize_database()
	temp_db.load_all_cards_data()
	var elements_set = {}
	var types_set = {}
	var subtypes_set = {}
	var classes_set = {}
	var db = temp_db.cards_db
	for key in db:
		var card_data = db[key]
		if card_data.has("element") and card_data["element"] != null:
			var element = str(card_data["element"]).strip_edges()
			if element != "" and element != "null":
				elements_set[element] = true
		if card_data.has("types") and card_data["types"] is Array:
			for type in card_data["types"]:
				var type_str = str(type).strip_edges()
				var type_upper = type_str.to_upper()
				if type_str != "" and type_str != "null" and type_upper != "TOKEN" and type_upper != "MASTERY" and type_upper != "STATUS":
					types_set[type_str] = true
		if card_data.has("subtypes") and card_data["subtypes"] is Array:
			for subtype in card_data["subtypes"]:
				var sub_str = str(subtype).strip_edges()
				if sub_str != "" and sub_str != "null":
					subtypes_set[sub_str] = true
		if card_data.has("classes") and card_data["classes"] is Array:
			for classes in card_data["classes"]:
				var class_str = str(classes).strip_edges()
				if class_str != "" and class_str != "null":
					classes_set[class_str] = true
	var all_elements = elements_set.keys()
	all_elements.sort()
	var all_types = types_set.keys()
	all_types.sort()
	var all_subtypes = subtypes_set.keys()
	all_subtypes.sort()
	var all_classes = classes_set.keys()
	all_classes.sort()
	Engine.set_meta("DeckBuilderFilters", {
		"elements": all_elements,
		"types": all_types,
		"subtypes": all_subtypes,
		"classes": all_classes})
	SceneCache.start_preload()
