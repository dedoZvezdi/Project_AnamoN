extends Control

@onready var player_name_label = $MainLayout/LeftPanelContainer/MarginContainer/LeftPanel/PlayerInfoPanel/Margin/PlayerInfo/Name
@onready var avatar_frame = $MainLayout/LeftPanelContainer/MarginContainer/LeftPanel/PlayerInfoPanel/Margin/PlayerInfo/Panel
@onready var room_list_container = $MainLayout/RightPanelContainer/MarginContainer/RightPanel/ScrollContainer/ScrollMargin/RoomList
@onready var search_input = $MainLayout/RightPanelContainer/MarginContainer/RightPanel/Header/SearchInput
@onready var filter_option = $MainLayout/RightPanelContainer/MarginContainer/RightPanel/Header/FilterOption
@onready var availability_filter = $MainLayout/RightPanelContainer/MarginContainer/RightPanel/Header/AvailabilityFilterOption
@onready var error_popup = $ErrorPopup
@onready var join_btn = $MainLayout/LeftPanelContainer/MarginContainer/LeftPanel/ButtonsVBox/JoinSelectedButton
@onready var host_visibility_option = $MainLayout/LeftPanelContainer/MarginContainer/LeftPanel/HostOptionsPanel/Margin/HostOptions/Visibility
@onready var host_password_input = $MainLayout/LeftPanelContainer/MarginContainer/LeftPanel/HostOptionsPanel/Margin/HostOptions/PasswordInput
@onready var host_message_input = $MainLayout/LeftPanelContainer/MarginContainer/LeftPanel/HostOptionsPanel/Margin/HostOptions/MessageInput
@onready var global_join_password = $MainLayout/RightPanelContainer/MarginContainer/RightPanel/Header/GlobalJoinPasswordInput

var room_item_scene = preload("res://Scenes/RoomItem.tscn")
var active_rooms = []
var selected_room = null

const USER_PHOTO_PATH = "user://Player_Image.png"
const DEFAULT_PHOTO_PATH = "res://Assets/Textures/Player Info/Player_photos/Player_Image.png"

func _ready():
	DiscordManager.update_status("In Server Lobby")
	join_btn.disabled = true
	error_popup.get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_load_player_info()
	if "last_error_message" in GlobalData and GlobalData.last_error_message != "":
		show_popup(GlobalData.last_error_message)
		GlobalData.last_error_message = ""
	GlobalData.rooms_updated.connect(_on_rooms_updated)
	GlobalData.room_created.connect(_on_room_created)
	GlobalData.room_joined.connect(_on_room_joined)
	if not GlobalData.server_error.is_connected(show_popup):
		GlobalData.server_error.connect(show_popup)
	GlobalData.get_rooms()
	player_name_label.text_changed.connect(_on_name_changed)
	player_name_label.text_submitted.connect(func(_new_text): player_name_label.release_focus())
	search_input.text_changed.connect(func(_text): _apply_filters())
	filter_option.item_selected.connect(_on_filter_changed)
	availability_filter.item_selected.connect(_on_filter_changed)
	search_input.text_submitted.connect(func(_new_text): search_input.release_focus())
	host_visibility_option.item_selected.connect(_on_visibility_selected)
	_on_visibility_selected(host_visibility_option.selected)
	global_join_password.text_submitted.connect(_on_global_password_submitted)

func _on_rooms_updated():
	if not is_inside_tree(): return
	active_rooms = GlobalData.active_rooms
	_apply_filters()

func _on_room_created():
	if not is_inside_tree(): return
	if not "auto_host" in GlobalData: return
	GlobalData.auto_host = true
	GlobalData.is_online_match = true
	GlobalData.target_port = 8910
	GlobalData.target_ip = "127.0.0.1"
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")

func _on_room_joined():
	if not is_inside_tree(): return
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")

func _on_visibility_selected(idx):
	if idx == 0:
		host_password_input.editable = false
		host_password_input.text = ""
	else:
		host_password_input.editable = true

func _on_name_changed(new_text):
	var config = ConfigFile.new()
	var err = config.load("user://player_config.cfg")
	if err != OK:
		pass
	config.set_value("Player", "Name", new_text)
	config.save("user://player_config.cfg")

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if player_name_label.has_focus():
			var rect = player_name_label.get_global_rect()
			if not rect.has_point(event.global_position):
				player_name_label.release_focus()
		if search_input.has_focus():
			var rect = search_input.get_global_rect()
			if not rect.has_point(event.global_position):
				search_input.release_focus()
		if global_join_password.has_focus():
			var rect = global_join_password.get_global_rect()
			if not rect.has_point(event.global_position):
				global_join_password.release_focus()

func _load_player_info():
	var config = ConfigFile.new()
	var err = config.load("user://player_config.cfg")
	if err == OK:
		player_name_label.text = config.get_value("Player", "Name", "Player")
		filter_option.selected = config.get_value("ServerLobby", "FilterType", 0)
		availability_filter.selected = config.get_value("ServerLobby", "FilterAvailability", 0)
	else:
		player_name_label.text = "Player"
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
	avatar_frame.clip_children = CanvasItem.CLIP_CHILDREN_DISABLED
	var profile_picture = TextureRect.new()
	profile_picture.material = circle_mat
	profile_picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	profile_picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	avatar_frame.add_child(profile_picture)
	profile_picture.set_anchors_preset(Control.PRESET_FULL_RECT)
	var texture = null
	if FileAccess.file_exists(USER_PHOTO_PATH):
		var img = Image.load_from_file(USER_PHOTO_PATH)
		if img:
			texture = ImageTexture.create_from_image(img)
	if not texture and ResourceLoader.exists(DEFAULT_PHOTO_PATH):
		texture = ResourceLoader.load(DEFAULT_PHOTO_PATH, "", ResourceLoader.CACHE_MODE_REPLACE)
	if texture:
		profile_picture.texture = texture
	profile_picture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _on_host_game_pressed():
	if GlobalData.socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		show_popup("Server is down!")
		return
	var is_private = host_visibility_option.selected == 1
	var pwd = host_password_input.text if is_private else ""
	var room_id = str(randi())
	var photo_b64 = ""
	if FileAccess.file_exists("user://Player_Image.png"):
		var img = Image.load_from_file("user://Player_Image.png")
		if img:
			img.resize(128, 128)
			var buffer = img.save_webp_to_buffer()
			photo_b64 = Marshalls.raw_to_base64(buffer)
	var host_info = {
		"creator": player_name_label.text,
		"photo_b64": photo_b64,
		"message": host_message_input.text,
		"mode": "Standard",
		"legality": "Match",
		"players": 1,
		"max": 2,
		"is_private": is_private,
		"password": pwd,
		"port": 8910}
	GlobalData.create_room(room_id, host_info)

func _on_exit_pressed():
	if GlobalData and "origin_scene" in GlobalData:
		GlobalData.origin_scene = "res://Scenes/Server_Lobby.tscn"
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _on_refresh_pressed():
	request_rooms_from_server()

func request_rooms_from_server():
	selected_room = null
	join_btn.disabled = true
	global_join_password.editable = false
	global_join_password.text = ""
	GlobalData.get_rooms()
	_apply_filters()

func _apply_filters():
	selected_room = null
	join_btn.disabled = true
	global_join_password.editable = false
	global_join_password.text = ""
	for child in room_list_container.get_children():
		child.queue_free()
	var search_text = search_input.text.to_lower()
	var filter_idx = filter_option.selected
	var avail_idx = availability_filter.selected
	var sorted_rooms = active_rooms.duplicate()
	sorted_rooms.sort_custom(func(a, b):
		if a.is_private != b.is_private:
			return not a.is_private
		return false)
	for room in sorted_rooms:
		if search_text != "" and not room.creator.to_lower().contains(search_text):
			continue
		if filter_idx == 1 and room.is_private:
			continue
		if filter_idx == 2 and not room.is_private:
			continue
		var is_full = room.get("players", 0) >= room.get("max", 2)
		if avail_idx == 1 and is_full:
			continue
		if avail_idx == 2 and not is_full:
			continue
		var room_inst = room_item_scene.instantiate()
		room_list_container.add_child(room_inst)
		room_inst.setup(room)
		room_inst.room_selected.connect(_on_room_selected)
		room_inst.room_joined_double_click.connect(_on_room_joined_double_click)

func _on_room_selected(room_info, room_node = null):
	for child in room_list_container.get_children():
		if child.has_method("set_selected"):
			child.set_selected(false)
	if room_node and room_node.has_method("set_selected"):
		room_node.set_selected(true)
	selected_room = room_info
	join_btn.disabled = false
	if room_info.get("is_private", false):
		global_join_password.editable = true
		global_join_password.grab_focus()
	else:
		global_join_password.editable = false
		global_join_password.text = ""

func _on_filter_changed(_idx):
	var config = ConfigFile.new()
	var err = config.load("user://player_config.cfg")
	if err != OK:
		pass
	config.set_value("ServerLobby", "FilterType", filter_option.selected)
	config.set_value("ServerLobby", "FilterAvailability", availability_filter.selected)
	config.save("user://player_config.cfg")
	_apply_filters()

func _on_room_joined_double_click(room_info):
	_on_room_selected(room_info)
	_attempt_join(room_info)

func _on_join_selected_pressed():
	if selected_room:
		_attempt_join(selected_room)

func _attempt_join(room_info):
	if room_info.get("is_closed", false):
		show_popup("This lobby no longer exists.")
		request_rooms_from_server()
		return
	var current_players = room_info.get("players", 0)
	var max_players = room_info.get("max", 2)
	if current_players >= max_players:
		show_popup("Lobby is full!")
		request_rooms_from_server()
		return
	if room_info.get("is_private", false):
		var entered_pwd = global_join_password.text
		var actual_pwd = room_info.get("password", "")
		if entered_pwd == actual_pwd:
			_join_room(room_info)
		else:
			show_popup("Incorrect password!")
	else:
		_join_room(room_info)

func show_popup(message: String):
	if message.length() <= 18:
		error_popup.dialog_autowrap = false
		error_popup.size = Vector2i(200, 100)
	elif message.length() <= 27:
		error_popup.dialog_autowrap = false
		error_popup.size = Vector2i(250, 100)
	else:
		error_popup.dialog_autowrap = true
		error_popup.size = Vector2i(300, 125)
	error_popup.dialog_text = message
	error_popup.popup_centered()

func _on_global_password_submitted(_pwd):
	if selected_room:
		_attempt_join(selected_room)

func _join_room(room_info):
	if not "auto_join" in GlobalData: return
	GlobalData.auto_join = true
	GlobalData.is_online_match = true
	GlobalData.target_ip = room_info.get("ip", "127.0.0.1")
	GlobalData.target_port = room_info.get("port", 8910)
	GlobalData.join_room(room_info.get("room_id", ""))
