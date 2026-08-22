class_name GamePaths
extends RefCounted

static func get_decks_dir_path() -> String:
	if OS.has_feature("editor"):
		return "res://Decks"
	return OS.get_executable_path().get_base_dir().path_join("Decks")

static func ensure_decks_dir_exists() -> String:
	var decks_dir_path = get_decks_dir_path()
	if not DirAccess.dir_exists_absolute(decks_dir_path):
		DirAccess.make_dir_recursive_absolute(decks_dir_path)
	return decks_dir_path
