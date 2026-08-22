extends Node

var _thread: Thread = null
var _preloaded_data = null
var _needs_compile = false
var _compile_timer = 0
var _shaders_compiled = false

func _ready():
	set_process(false)

func start_preload():
	if _thread and _thread.is_started():
		return 
	if _preloaded_data != null:
		return
	_thread = Thread.new()
	_thread.start(_thread_func)
	set_process(true)

func _thread_func():
	var player_field_scene = load("res://Scenes/Player_Field.tscn")
	var opponent_field_scene = load("res://Scenes/Opponent_Field.tscn")
	var player_field = player_field_scene.instantiate() if player_field_scene else null
	var opponent_field = opponent_field_scene.instantiate() if opponent_field_scene else null
	return {"player_field": player_field, "opponent_field": opponent_field}

func _process(_delta):
	if _thread and not _thread.is_alive() and _thread.is_started():
		_preloaded_data = _thread.wait_to_finish()
		_thread = null
		if _preloaded_data != null and typeof(_preloaded_data) == TYPE_DICTIONARY:
			if not _shaders_compiled:
				_needs_compile = true
				_compile_timer = 2
			else:
				set_process(false)
			return

	if _needs_compile:
		if _compile_timer == 2:
			if _preloaded_data.get("player_field"):
				_preloaded_data["player_field"].modulate.a = 0.001
				add_child(_preloaded_data["player_field"])
			if _preloaded_data.get("opponent_field"):
				_preloaded_data["opponent_field"].modulate.a = 0.001
				add_child(_preloaded_data["opponent_field"])
		elif _compile_timer == 0:
			if _preloaded_data.get("player_field") and _preloaded_data["player_field"].get_parent() == self:
				remove_child(_preloaded_data["player_field"])
				_preloaded_data["player_field"].modulate.a = 1.0
			if _preloaded_data.get("opponent_field") and _preloaded_data["opponent_field"].get_parent() == self:
				remove_child(_preloaded_data["opponent_field"])
				_preloaded_data["opponent_field"].modulate.a = 1.0
			_needs_compile = false
			_shaders_compiled = true
			set_process(false)
		_compile_timer -= 1

func get_preloaded():
	if _thread and _thread.is_started():
		_preloaded_data = _thread.wait_to_finish()
		_thread = null
	if _needs_compile:
		if _preloaded_data.get("player_field") and _preloaded_data["player_field"].get_parent() == self:
			remove_child(_preloaded_data["player_field"])
			_preloaded_data["player_field"].modulate.a = 1.0
		if _preloaded_data.get("opponent_field") and _preloaded_data["opponent_field"].get_parent() == self:
			remove_child(_preloaded_data["opponent_field"])
			_preloaded_data["opponent_field"].modulate.a = 1.0
		_needs_compile = false
		_shaders_compiled = true
		set_process(false)
	var data = _preloaded_data
	_preloaded_data = null
	return data
	
func clear_cache():
	if _thread and _thread.is_started():
		_preloaded_data = _thread.wait_to_finish()
		_thread = null
	if _preloaded_data != null and typeof(_preloaded_data) == TYPE_DICTIONARY:
		if _preloaded_data.get("player_field"): 
			if _preloaded_data["player_field"].get_parent(): _preloaded_data["player_field"].get_parent().remove_child(_preloaded_data["pf"])
			_preloaded_data["player_field"].queue_free()
		if _preloaded_data.get("opponent_field"): 
			if _preloaded_data["opponent_field"].get_parent(): _preloaded_data["opponent_field"].get_parent().remove_child(_preloaded_data["of"])
			_preloaded_data["opponent_field"].queue_free()
	_preloaded_data = null
	_needs_compile = false
	set_process(false)
