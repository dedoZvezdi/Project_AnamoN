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
	var decks_dir_path = ""
	if OS.has_feature("standalone"):
		decks_dir_path = OS.get_executable_path().get_base_dir().path_join("Decks")
	else:
		decks_dir_path = "res://Decks"
	var dir = DirAccess.open(decks_dir_path)
	if not dir:
		DirAccess.make_dir_absolute(decks_dir_path)

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
	tween.tween_interval(pause_time)
	tween.tween_property(splash_screen, "modulate:a", 0.0, fade_out_time)
	tween.tween_interval(out_time)
	await tween.finished
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
