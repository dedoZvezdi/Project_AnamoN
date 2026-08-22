extends Control

@export var load_scene : PackedScene
@export var in_time : float =  0.5
@export var fade_in_time : float = 1.5
@export var pause_time : float = 1.5
@export var fade_out_time : float = 1.5
@export var out_time : float =  0.5
@export var splash_screen : TextureRect

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
	if splash_screen == null:
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
		return
	splash_screen.modulate.a = 0.0
	var tween = self.create_tween()
	tween.tween_interval(in_time)
	tween.tween_property(splash_screen, "modulate:a", 1.0, fade_in_time)
	tween.tween_callback(_load_database)
	tween.tween_interval(pause_time)
	tween.tween_property(splash_screen, "modulate:a", 0.0, fade_out_time)
	tween.tween_interval(out_time)
	await tween.finished
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
