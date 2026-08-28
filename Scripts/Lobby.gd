extends Control

@onready var p1_ready_btn: Button = $RootVBox/Arena/Player1Half/Margin/VBox/ReadyButton
@onready var p1_status_label: Label = $RootVBox/Arena/Player1Half/Margin/VBox/StatusRow/StatusLabel
@onready var p1_status_dot: ColorRect = $RootVBox/Arena/Player1Half/Margin/VBox/StatusRow/Dot
@onready var p1_progress_fill: Panel = $RootVBox/Arena/Player1Half/Margin/VBox/ProgressBar/Fill
@onready var p1_name_input: LineEdit = $RootVBox/Arena/Player1Half/Margin/VBox/PlayerIdentity/NameInput
@onready var p1_avatar_frame: Panel = $RootVBox/Arena/Player1Half/Margin/VBox/AvatarFrame
@onready var p2_ready_btn: Button = $RootVBox/Arena/Player2Half/Margin/VBox/ReadyButton
@onready var p2_status_label: Label = $RootVBox/Arena/Player2Half/Margin/VBox/StatusRow/StatusLabel
@onready var p2_status_dot: ColorRect = $RootVBox/Arena/Player2Half/Margin/VBox/StatusRow/Dot
@onready var p2_progress_fill: Panel = $RootVBox/Arena/Player2Half/Margin/VBox/ProgressBar/Fill
@onready var p2_name_input: LineEdit = $RootVBox/Arena/Player2Half/Margin/VBox/PlayerIdentity/NameInput
@onready var p2_avatar_frame: Panel = $RootVBox/Arena/Player2Half/Margin/VBox/AvatarFrame
@onready var start_button: Button = $RootVBox/Arena/CenterCol/MarginCenter/InnerVBox/StartButton
@onready var exit_button: Button = $RootVBox/Arena/CenterCol/MarginCenter/InnerVBox/ExitButton
@onready var deck_option: OptionButton = $RootVBox/Arena/CenterCol/MarginCenter/InnerVBox/DeckOption
@onready var mode_option: OptionButton = $RootVBox/Arena/CenterCol/MarginCenter/InnerVBox/ModeRow/OptionButton
@onready var legality_option: OptionButton = $RootVBox/Arena/CenterCol/MarginCenter/InnerVBox/LegalityRow/LegalityButton
@onready var p2_kick_overlay: Control = $RootVBox/Arena/Player2Half/Margin/VBox/AvatarFrame/Label

const READY_COLOR = Color(0.133, 0.741, 0.204, 1.0)
const NOT_READY_COLOR = Color(0.941, 0, 0.106, 1.0)
const DOT_DEFAULT_COLOR = Color(1.0, 1.0, 1.0, 0.15)
const FILL_DURATION = 0.6

var p1_ready := false
var p2_ready := false
var p1_has_deck := false
var p2_has_deck := false
var p1_photo_rect: TextureRect
var p2_photo_rect: TextureRect

func _ready() -> void:
	DiscordManager.update_status("In Lobby", "Looking for Battle")
	if not get_parent() is Window and not get_parent() is CanvasLayer:
		set_anchors_preset(Control.PRESET_TOP_LEFT)
		size = get_viewport_rect().size
		position = Vector2.ZERO
		get_tree().root.size_changed.connect(func():
			size = get_viewport_rect().size
			position = Vector2.ZERO)
	else:
		set_anchors_preset(Control.PRESET_FULL_RECT)
	p1_progress_fill.anchor_left = 0.0
	p1_progress_fill.anchor_right = 0.0
	p2_progress_fill.anchor_right = 1.0
	p2_progress_fill.anchor_left = 1.0
	p1_ready_btn.pressed.connect(_on_p1_ready_pressed)
	p2_ready_btn.pressed.connect(_on_p2_ready_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	start_button.pressed.connect(_on_start_pressed)
	if mode_option:
		mode_option.item_selected.connect(_on_mode_selected)
	if legality_option:
		legality_option.item_selected.connect(_on_legality_selected)
	if deck_option:
		deck_option.item_selected.connect(_on_deck_selected)
	_refresh_deck_options()
	var circle_shader = Shader.new()
	circle_shader.code = """
shader_type canvas_item;
void fragment() {
	vec2 uv = UV - vec2(0.5);
	float dist = length(uv);
	float alpha = 1.0 - smoothstep(0.48, 0.5, dist);
	vec4 tex_color = texture(TEXTURE, UV);
	COLOR = vec4(tex_color.rgb, tex_color.a * alpha);
}
	"""
	var circle_mat = ShaderMaterial.new()
	circle_mat.shader = circle_shader
	p1_avatar_frame.clip_children = CanvasItem.CLIP_CHILDREN_DISABLED
	p2_avatar_frame.clip_children = CanvasItem.CLIP_CHILDREN_DISABLED
	p1_photo_rect = TextureRect.new()
	p1_photo_rect.material = circle_mat
	p1_photo_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	p1_photo_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	p1_avatar_frame.add_child(p1_photo_rect)
	p1_photo_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	p1_photo_rect.offset_left = 2
	p1_photo_rect.offset_top = 2
	p1_photo_rect.offset_right = -2
	p1_photo_rect.offset_bottom = -2
	p2_photo_rect = TextureRect.new()
	p2_photo_rect.material = circle_mat
	p2_photo_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	p2_photo_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	p2_avatar_frame.add_child(p2_photo_rect)
	p2_photo_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	p2_photo_rect.offset_left = 2
	p2_photo_rect.offset_top = 2
	p2_photo_rect.offset_right = -2
	p2_photo_rect.offset_bottom = -2
	check_start_button()
	p2_avatar_frame.gui_input.connect(_on_p2_avatar_gui_input)
	p2_avatar_frame.mouse_entered.connect(_on_p2_avatar_hover)
	p2_avatar_frame.mouse_exited.connect(_on_p2_avatar_unhover)
	if p2_kick_overlay:
		p2_kick_overlay.get_parent().remove_child(p2_kick_overlay)
		p2_avatar_frame.add_child(p2_kick_overlay)

func _on_p2_avatar_hover():
	if multiplayer.is_server() and multiplayer.get_peers().size() > 0:
		p2_kick_overlay.visible = true
	else:
		p2_avatar_frame.mouse_default_cursor_shape = Control.CURSOR_ARROW

func _on_p2_avatar_unhover():
	p2_kick_overlay.visible = false
	p2_kick_overlay.modulate = Color(1, 1, 1, 1)

func _on_p2_avatar_gui_input(event: InputEvent):
	if multiplayer.is_server() and multiplayer.get_peers().size() > 0:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				p2_kick_overlay.modulate = Color(0.5, 0.5, 0.5, 1)
			else:
				var opp_id = multiplayer.get_peers()[0]
				var multiplayer_node = get_parent()
				if multiplayer_node and multiplayer_node.has_method("kick_peer"):
					multiplayer_node.kick_peer(opp_id)
				p2_kick_overlay.visible = false
				p2_kick_overlay.modulate = Color(1, 1, 1, 1)

func setup_host(player_name: String):
	p1_name_input.text = player_name
	p1_ready_btn.disabled = false
	p2_ready_btn.disabled = true
	start_button.visible = true
	_apply_local_photo(p1_photo_rect)
	p2_name_input.text = "Waiting..."
	if mode_option: mode_option.disabled = false
	if legality_option: legality_option.disabled = false
	_update_master_server()
	
func setup_client(player_name: String):
	p2_name_input.text = player_name
	p1_ready_btn.disabled = true
	p2_ready_btn.disabled = false
	start_button.visible = false
	_apply_local_photo(p2_photo_rect)
	p1_name_input.text = "Waiting..."
	if mode_option: mode_option.disabled = true
	if legality_option: legality_option.disabled = true

func set_opponent_name(player_name: String):
	if multiplayer.is_server():
		p2_name_input.text = player_name
	else:
		p1_name_input.text = player_name

func _apply_local_photo(rect: TextureRect):
	var multiplayer_node = get_parent()
	if not multiplayer_node or not multiplayer_node.has_method("_get_opponent_photo_path"): return
	var texture = null
	if FileAccess.file_exists(multiplayer_node.USER_PHOTO_PATH):
		var img = Image.load_from_file(multiplayer_node.USER_PHOTO_PATH)
		if img:
			texture = ImageTexture.create_from_image(img)
	if not texture and ResourceLoader.exists(multiplayer_node.DEFAULT_PHOTO_PATH):
		texture = ResourceLoader.load(multiplayer_node.DEFAULT_PHOTO_PATH, "", ResourceLoader.CACHE_MODE_REPLACE)
	if texture:
		rect.texture = texture

func apply_opponent_photo():
	var multiplayer_node = get_parent()
	if not multiplayer_node or not multiplayer_node.has_method("_get_opponent_photo_path"): return
	var texture = null
	var opp_photo_path = multiplayer_node._get_opponent_photo_path()
	if FileAccess.file_exists(opp_photo_path):
		var img = Image.load_from_file(opp_photo_path)
		if img:
			texture = ImageTexture.create_from_image(img)
	if not texture and ResourceLoader.exists(multiplayer_node.DEFAULT_PHOTO_PATH):
		texture = ResourceLoader.load(multiplayer_node.DEFAULT_PHOTO_PATH, "", ResourceLoader.CACHE_MODE_REPLACE)
	if texture:
		if multiplayer.is_server():
			p2_photo_rect.texture = texture
		else:
			p1_photo_rect.texture = texture

func apply_opponent_photo_direct(texture: Texture2D):
	if texture:
		if multiplayer.is_server():
			p2_photo_rect.texture = texture
		else:
			p1_photo_rect.texture = texture

func on_client_disconnected():
	if p2_kick_overlay: p2_kick_overlay.visible = false
	p2_avatar_frame.mouse_default_cursor_shape = Control.CURSOR_ARROW
	p2_name_input.text = "Waiting..."
	p2_photo_rect.texture = null
	p2_ready = false
	p2_has_deck = false
	_update_player_ui(p2_ready, p2_ready_btn, p2_status_label, p2_status_dot, p2_progress_fill, true)
	check_start_button()

func _on_p1_ready_pressed() -> void:
	p1_ready = !p1_ready
	_update_player_ui(p1_ready, p1_ready_btn, p1_status_label, p1_status_dot, p1_progress_fill, false)
	deck_option.disabled = p1_ready
	if multiplayer.is_server():
		mode_option.disabled = p1_ready
		legality_option.disabled = p1_ready
	rpc("sync_ready_state", 1, p1_ready)
	check_start_button()

func _on_p2_ready_pressed() -> void:
	p2_ready = !p2_ready
	_update_player_ui(p2_ready, p2_ready_btn, p2_status_label, p2_status_dot, p2_progress_fill, true)
	deck_option.disabled = p2_ready
	rpc("sync_ready_state", 2, p2_ready)

@rpc("any_peer", "reliable")
func sync_ready_state(player_num: int, is_ready: bool):
	if player_num == 1:
		p1_ready = is_ready
		_update_player_ui(p1_ready, p1_ready_btn, p1_status_label, p1_status_dot, p1_progress_fill, false)
	else:
		p2_ready = is_ready
		_update_player_ui(p2_ready, p2_ready_btn, p2_status_label, p2_status_dot, p2_progress_fill, true)
	check_start_button()

func check_start_button():
	if multiplayer.is_server():
		var is_2_players = multiplayer.get_peers().size() == 1
		start_button.disabled = not (is_2_players and p1_ready and p2_ready and p1_has_deck and p2_has_deck)

func _update_player_ui(is_ready: bool, btn: Button, label: Label, dot: ColorRect, fill: Panel, is_right_to_left: bool) -> void:
	btn.text = "READY UP" if !is_ready else "READY!"
	if is_ready:
		label.text = "READY"
		label.add_theme_color_override("font_color", READY_COLOR)
		dot.color = READY_COLOR
	else:
		label.text = "NOT READY"
		label.add_theme_color_override("font_color", NOT_READY_COLOR)
		dot.color = DOT_DEFAULT_COLOR
	var tween = create_tween()
	if is_right_to_left:
		var target_left = 0.0 if is_ready else 1.0
		tween.tween_property(fill, "anchor_left", target_left, FILL_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	else:
		var target_right = 1.0 if is_ready else 0.0
		tween.tween_property(fill, "anchor_right", target_right, FILL_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

func _on_exit_pressed():
	var multiplayer_node = get_parent()
	if multiplayer_node and multiplayer_node.has_method("reset_ui"):
		multiplayer_node.reset_ui()

func _on_start_pressed():
	if multiplayer.is_server() and not start_button.disabled:
		var multiplayer_node = get_parent()
		rpc("sync_start_game")
		if multiplayer_node:
			var mode_idx = mode_option.selected if mode_option else 0
			if "_game_mode" in multiplayer_node:
				multiplayer_node._game_mode = mode_idx
			if multiplayer_node.has_method("rpc"):
				multiplayer_node.rpc("rpc_sync_game_mode", mode_idx)
			if multiplayer_node.has_method("start_game_instances"):
				multiplayer_node.start_game_instances()

@rpc("any_peer", "reliable")
func sync_start_game():
	var multiplayer_node = get_parent()
	if multiplayer_node and multiplayer_node.has_method("start_game_instances"):
		multiplayer_node.start_game_instances()

func _on_mode_selected(_index: int):
	if multiplayer.is_server():
		rpc("sync_lobby_settings", mode_option.selected, legality_option.selected)
		_update_master_server()

func _on_legality_selected(_index: int):
	_refresh_deck_options()
	if multiplayer.is_server():
		rpc("sync_lobby_settings", mode_option.selected, legality_option.selected)
		_update_master_server()
		
func _update_master_server():
	if GlobalData and GlobalData.has_method("update_room_info"):
		if mode_option and legality_option:
			var mode_text = mode_option.get_item_text(mode_option.selected)
			var legality_text = legality_option.get_item_text(legality_option.selected)
			GlobalData.update_room_info(mode_text, legality_text)

func _on_deck_selected(_index: int):
	var has_deck = deck_option.selected >= 0 and deck_option.get_item_count() > 0
	if multiplayer.is_server():
		p1_has_deck = has_deck
		rpc("sync_deck_state", 1, p1_has_deck)
	else:
		p2_has_deck = has_deck
		rpc("sync_deck_state", 2, p2_has_deck)
	check_start_button()

@rpc("any_peer", "reliable")
func sync_deck_state(player_num: int, has_deck: bool):
	if player_num == 1:
		p1_has_deck = has_deck
	else:
		p2_has_deck = has_deck
	check_start_button()

@rpc("authority", "reliable")
func sync_lobby_settings(mode_idx: int, legality_idx: int):
	if mode_option: mode_option.selected = mode_idx
	if legality_option: 
		var old_legality = legality_option.selected
		legality_option.selected = legality_idx
		if old_legality != legality_idx:
			_refresh_deck_options()

func _refresh_deck_options():
	if not deck_option or not legality_option: return
	var old_selected_name = ""
	if deck_option.get_item_count() > 0 and deck_option.selected >= 0:
		old_selected_name = deck_option.get_item_text(deck_option.selected)
	deck_option.clear()
	var legality_text = legality_option.get_item_text(legality_option.selected)
	var decks_dir_path = GamePaths.get_decks_dir_path()
	var dir = DirAccess.open(decks_dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".gad"):
				var full_path = decks_dir_path.path_join(file_name)
				var file = FileAccess.open(full_path, FileAccess.READ)
				if file:
					var json = JSON.new()
					var error = json.parse(file.get_as_text())
					if error == OK and typeof(json.data) == TYPE_DICTIONARY:
						var data = json.data
						var is_legal = false
						if data.has("legal_formats"):
							for format in data["legal_formats"]:
								if format == legality_text or legality_text == "N/A":
									is_legal = true
									break
						else:
							is_legal = true
						if is_legal and data.has("deck_name"):
							deck_option.add_item(str(data["deck_name"]))
							deck_option.set_item_metadata(deck_option.get_item_count() - 1, full_path)
			file_name = dir.get_next()
	if deck_option.get_item_count() > 0:
		var found_idx = -1
		for i in range(deck_option.get_item_count()):
			if deck_option.get_item_text(i) == old_selected_name:
				found_idx = i
				break
		if found_idx != -1:
			deck_option.selected = found_idx
			_on_deck_selected(found_idx)
		else:
			deck_option.selected = 0
			_on_deck_selected(0)
	else:
		deck_option.selected = -1
		_on_deck_selected(-1)

func get_selected_deck_data() -> Dictionary:
	if not deck_option or deck_option.selected < 0 or deck_option.get_item_count() == 0:
		return {}
	var file_path = deck_option.get_item_metadata(deck_option.selected)
	if file_path == null or file_path == "":
		return {}
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		if error == OK and typeof(json.data) == TYPE_DICTIONARY:
			var data = json.data
			return {
				"main_deck": data.get("main_deck", []),
				"mat_deck": data.get("mat_deck", []),
				"pantheon_deck": data.get("pantheon_deck", []),
				"side_deck": data.get("side_deck", []),}
	return {}
