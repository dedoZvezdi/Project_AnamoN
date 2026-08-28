extends Node2D

@export var player_field_scene : PackedScene
@export var opponent_field_scene : PackedScene

@onready var server: LineEdit = $CanvasLayer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxHostContainer/IP_Address
@onready var port: LineEdit = $CanvasLayer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxHostContainer/PORT
@onready var check: CheckButton = $CanvasLayer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxNameContainer/HBoxContainer/CheckButton
@onready var cancel_button: Button = $CanvasLayer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxButtonsContainer/CancelButton
@onready var item_list: ItemList = $CanvasLayer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/ItemList
@onready var refresh_button: Button = $CanvasLayer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxButtonsContainer/RefreshButton

var lobby_scene = preload("res://Scenes/Lobby.tscn")
var current_lobby = null
var current_lobbies = []
var peer = null
var peer_names = {}
var upnp: UPNP
var connect_timer: Timer
var use_websocket: bool = false
var is_my_turn: bool = false
var USER_PHOTO_PATH = "user://Player_Image.png"
var DEFAULT_PHOTO_PATH = "res://Assets/Textures/Player Info/Player_photos/Player_Image.png"
var OPPONENT_PHOTO_FILENAME = "temp_opponent_photo.png"
var _registered_lobby_port: int = -1
var _rematch_requested_local: bool = false
var _rematch_requested_remote: bool = false
var _continue_requested_local: bool = false
var _continue_requested_remote: bool = false
var _game_mode: int = 0
var _wins_local: int = 0
var _wins_remote: int = 0
var _original_deck_data: Dictionary = {}
var _current_deck_data: Dictionary = {}
var _sideboard_ready_local: bool = false
var _sideboard_ready_remote: bool = false
var _deck_building_instance = null
var _series_started: bool = false
var _match_is_over: bool = false
var deck_building_scene = preload("res://Scenes/Deck_Building.tscn")

const LOBBY_FILE = "user://local_lobbies.json"

func _ready():
	var config = ConfigFile.new()
	var err = config.load("user://player_config.cfg")
	if err == OK:
		$CanvasLayer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxNameContainer/Name.text = config.get_value("Player", "Name", "")
	check.toggled.connect(_on_check_button_toggled)
	cancel_button.pressed.connect(_on_cancel_button_pressed)
	refresh_button.pressed.connect(_refresh_lobby_list)
	item_list.item_selected.connect(_on_item_selected)
	item_list.item_activated.connect(_on_item_activated)
	_on_check_button_toggled(check.button_pressed)
	_refresh_lobby_list()
	if FileAccess.file_exists(USER_PHOTO_PATH):
		var img = Image.load_from_file(USER_PHOTO_PATH)
		if img:
			$PhotoPreview.texture = ImageTexture.create_from_image(img)
	elif ResourceLoader.exists(DEFAULT_PHOTO_PATH):
		$PhotoPreview.texture = load(DEFAULT_PHOTO_PATH)
	if has_node("ConnectTimer"):
		connect_timer = get_node("ConnectTimer")
	else:
		connect_timer = Timer.new()
		connect_timer.name = "ConnectTimer"
		add_child(connect_timer)
	if GlobalData and "auto_host" in GlobalData:
		if GlobalData.auto_host:
			GlobalData.auto_host = false
			$CanvasLayer.hide()
			server.text = "127.0.0.1"
			port.text = str(GlobalData.target_port)
			_on_host_button_pressed()
		elif GlobalData.auto_join:
			GlobalData.auto_join = false
			$CanvasLayer.hide()
			server.text = GlobalData.target_ip
			port.text = str(GlobalData.target_port)
			_on_join_button_pressed()
	if GlobalData and GlobalData.has_signal("server_error"):
		if not GlobalData.server_error.is_connected(show_popup):
			GlobalData.server_error.connect(show_popup)
	if not connect_timer.timeout.is_connected(_on_connect_timeout):
		connect_timer.wait_time = 10.0
		connect_timer.one_shot = true
		connect_timer.timeout.connect(_on_connect_timeout)
	$FileDialog.add_filter("*.png", "PNG Images")
	$FileDialog.add_filter("*.jpg", "JPG Images")
	$FileDialog.add_filter("*.jpeg", "JPEG Images")
	$PhotoPreview.visible = false
	_cleanup_temp_files()
	SceneCache.start_preload()

func _notification(noti):
	if noti == NOTIFICATION_WM_CLOSE_REQUEST:
		_cleanup_temp_files()
		_unregister_lobby()

func _cleanup_temp_files():
	var opp_photo = _get_opponent_photo_path()
	if FileAccess.file_exists(opp_photo):
		DirAccess.remove_absolute(opp_photo)

func _on_check_button_toggled(is_pressed: bool):
	use_websocket = is_pressed
	if is_pressed:
		server.placeholder_text = "For JOIN: https://tunnel-url.com / For HOST: leave empty"
		port.visible = true
	else:
		server.placeholder_text = "localhost or IP address"
		port.visible = true

func _on_cancel_button_pressed():
	reset_ui()
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _exit_tree() -> void:
	SceneCache.clear_cache()
	_cleanup_temp_files()
	_unregister_lobby()

func _on_host_button_pressed() -> void:
	var entered_name = $CanvasLayer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxNameContainer/Name.text.strip_edges()
	var name_to_use = "Player" if entered_name == "" else entered_name
	if use_websocket:
		if not validate_websocket_host():
			return
		var config = ConfigFile.new()
		config.set_value("Player", "Name", name_to_use)
		config.save("user://player_config.cfg")
		disable_buttons()
		peer = WebSocketMultiplayerPeer.new()
		var error = peer.create_server(int(port.text))
		if error != OK:
			show_popup("Failed to create WebSocket server on port " + port.text)
			reset_ui()
			return
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(on_peer_connected)
		multiplayer.peer_disconnected.connect(on_peer_disconnected)
		current_lobby = lobby_scene.instantiate()
		add_child(current_lobby)
		peer_names[multiplayer.get_unique_id()] = name_to_use
		current_lobby.setup_host(name_to_use)
		show_popup("WebSocket server started on port " + port.text + "\n\nNow run in terminal:\ncloudflared tunnel --url http://localhost:" + port.text + "\n\nThen share the https:// URL with your friend!")
	else:
		if not validate_ip_and_port():
			return
		var lobbies = _load_lobbies()
		for lobby in lobbies:
			if lobby is Dictionary and int(lobby.get("port", -1)) == int(port.text) and lobby.get("player_count", 0) > 0:
				show_popup("A lobby is already active on port " + port.text + ".")
				reset_ui()
				return
		var config = ConfigFile.new()
		config.set_value("Player", "Name", name_to_use)
		config.save("user://player_config.cfg")
		disable_buttons()
		var is_online = false
		if "is_online_match" in GlobalData:
			is_online = GlobalData.is_online_match
		if is_online:
			peer = WebRTCMultiplayerPeer.new()
			peer.create_server()
			multiplayer.multiplayer_peer = peer
			GlobalData.peer_connected_webrtc.connect(func(peer_id):
				var p_conn = WebRTCPeerConnection.new()
				p_conn.initialize({"iceServers": [{"urls": ["stun:stun.l.google.com:19302"]}]})
				p_conn.session_description_created.connect(func(type, sdp):
					p_conn.set_local_description(type, sdp)
					GlobalData.send_webrtc_offer(peer_id, sdp))
				p_conn.ice_candidate_created.connect(func(media, index, ice_name):
					GlobalData.send_webrtc_candidate(peer_id, media, index, ice_name))
				peer.add_peer(p_conn, peer_id)
				p_conn.create_offer())
			GlobalData.webrtc_answer_received.connect(func(peer_id, sdp):
				if peer.has_peer(peer_id):
					peer.get_peer(peer_id).connection.set_remote_description("answer", sdp))
			GlobalData.webrtc_candidate_received.connect(func(peer_id, mid, index, sdp):
				if peer.has_peer(peer_id):
					peer.get_peer(peer_id).connection.add_ice_candidate(mid, index, sdp))
		else:
			peer = ENetMultiplayerPeer.new()
			var error = peer.create_server(int(port.text))
			if error != OK:
				show_popup("Failed to create ENet server on port " + port.text + ". Port might be in use.")
				reset_ui()
				return
			multiplayer.multiplayer_peer = peer
			_register_lobby(name_to_use, int(port.text))
		multiplayer.peer_connected.connect(on_peer_connected)
		multiplayer.peer_disconnected.connect(on_peer_disconnected)
		current_lobby = lobby_scene.instantiate()
		add_child(current_lobby)
		peer_names[multiplayer.get_unique_id()] = name_to_use
		current_lobby.setup_host(name_to_use)

func _on_join_button_pressed() -> void:
	var entered_name = $CanvasLayer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxNameContainer/Name.text.strip_edges()
	var name_to_use = "Player" if entered_name == "" else entered_name
	if use_websocket:
		if not validate_websocket_url():
			return
		var config = ConfigFile.new()
		config.set_value("Player", "Name", name_to_use)
		config.save("user://player_config.cfg")
		disable_buttons()
		peer = WebSocketMultiplayerPeer.new()
		var ws_url = server.text.replace("https://", "wss://").replace("http://", "ws://")
		var error = peer.create_client(ws_url)
		if error != OK:
			show_popup("Failed to connect to WebSocket URL: " + ws_url)
			reset_ui()
			return
		multiplayer.multiplayer_peer = peer
		multiplayer.connected_to_server.connect(func():
			if connect_timer and connect_timer.is_stopped() == false:
				connect_timer.stop()
			current_lobby = lobby_scene.instantiate()
			add_child(current_lobby)
			peer_names[multiplayer.get_unique_id()] = name_to_use
			current_lobby.setup_client(name_to_use)
			_send_my_photo_to_lobby(1)
			rpc("receive_opponent_name_lobby", name_to_use))
		multiplayer.connection_failed.connect(func():
			if connect_timer and connect_timer.is_stopped() == false:
				connect_timer.stop()
			show_popup("Failed to connect to WebSocket server. Check the URL.")
			reset_ui())
		multiplayer.server_disconnected.connect(func():
			if not (has_node("PlayerField") or has_node("OpponentField")):
				reset_ui()
			else:
				show_popup("The Host closed the lobby.")
				reset_ui())
		connect_timer.start()
	else:
		if not validate_ip_and_port():
			return
		var is_online = false
		if "is_online_match" in GlobalData:
			is_online = GlobalData.is_online_match
		if not is_online:
			var lobbies = _load_lobbies()
			var target_lobby = null
			for lobby in lobbies:
				if lobby is Dictionary and int(lobby.get("port", -1)) == int(port.text):
					target_lobby = lobby
					break
			if target_lobby:
				if target_lobby.player_count >= 2:
					show_popup("Lobby is full (2/2 players).")
					_refresh_lobby_list()
					return
				if not _is_lobby_alive(target_lobby):
					show_popup("Lobby is old and closed.")
					_refresh_lobby_list()
					return
			else:
				show_popup("Lobby is old and closed.")
				_refresh_lobby_list()
				return
		var config = ConfigFile.new()
		config.set_value("Player", "Name", name_to_use)
		config.save("user://player_config.cfg")
		disable_buttons()
		if is_online:
			peer = WebRTCMultiplayerPeer.new()
			peer.create_client(GlobalData.my_webrtc_id)
			multiplayer.multiplayer_peer = peer
			GlobalData.webrtc_offer_received.connect(func(peer_id, sdp):
				var p_conn = WebRTCPeerConnection.new()
				p_conn.initialize({"iceServers": [{"urls": ["stun:stun.l.google.com:19302"]}]})
				p_conn.session_description_created.connect(func(type, lsdp):
					p_conn.set_local_description(type, lsdp)
					GlobalData.send_webrtc_answer(peer_id, lsdp))
				p_conn.ice_candidate_created.connect(func(media, index, ice_name):
					GlobalData.send_webrtc_candidate(peer_id, media, index, ice_name))
				peer.add_peer(p_conn, peer_id, 1)
				p_conn.set_remote_description("offer", sdp))
			GlobalData.webrtc_candidate_received.connect(func(peer_id, mid, index, sdp):
				if peer.has_peer(peer_id):
					peer.get_peer(peer_id).connection.add_ice_candidate(mid, index, sdp))
		else:
			peer = ENetMultiplayerPeer.new()
			peer.create_client(server.text, int(port.text))
			multiplayer.multiplayer_peer = peer
		multiplayer.connected_to_server.connect(func():
			if connect_timer and connect_timer.is_stopped() == false:
				connect_timer.stop()
			current_lobby = lobby_scene.instantiate()
			add_child(current_lobby)
			peer_names[multiplayer.get_unique_id()] = name_to_use
			current_lobby.setup_client(name_to_use)
			_send_my_photo_to_lobby(1)
			rpc("receive_opponent_name_lobby", name_to_use))
		multiplayer.connection_failed.connect(func():
			if connect_timer and connect_timer.is_stopped() == false:
				connect_timer.stop()
			show_popup("There is no host with such IP and port.")
			reset_ui())
		multiplayer.server_disconnected.connect(func():
			if not (has_node("PlayerField") or has_node("OpponentField")):
				reset_ui()
			else:
				show_popup("The Host closed the lobby.")
				reset_ui())
		connect_timer.start()

func validate_websocket_host() -> bool:
	var port_text = port.text.strip_edges()
	if port_text == "":
		show_popup("Please enter a port number for WebSocket server.")
		return false
	if not is_valid_port(int(port_text)):
		show_popup("Invalid port number.")
		return false
	return true

func validate_websocket_url() -> bool:
	var url = server.text.strip_edges()
	if url == "":
		show_popup("Please enter the WebSocket URL[](https://...).")
		return false
	if not url.begins_with("https://") and not url.begins_with("http://"):
		show_popup("URL must start with https:// or http://")
		return false
	return true

func validate_ip_and_port() -> bool:
	var ip_text = server.text.strip_edges()
	var port_text = port.text.strip_edges()
	if ip_text == "" or port_text == "":
		show_popup("Please fill in IP address and port before proceeding.")
		return false
	if not is_valid_ip(ip_text) or not is_valid_port(int(port_text)):
		show_popup("Invalid IP address or port. Check again.")
		return false
	return true

func _close_existing_dialogs():
	_close_dialogs_recursive(get_tree().current_scene)

func _close_dialogs_recursive(node: Node):
	for child in node.get_children():
		if child is AcceptDialog and child.name != "LogoCounterDialog":
			child.exclusive = false
			child.hide()
			child.queue_free()
		else:
			_close_dialogs_recursive(child)

func show_popup(message: String):
	if GlobalData and GlobalData.get("origin_scene") == "res://Scenes/Server_Lobby.tscn":
		GlobalData.set("last_error_message", message)
	_close_existing_dialogs()
	var dialog = AcceptDialog.new()
	dialog.dialog_text = message
	dialog.title = "INFO" if message.contains("started") else "ERROR"
	get_tree().current_scene.add_child(dialog)
	dialog.popup_centered()

func is_valid_ip(ip: String) -> bool:
	if ip == "localhost":
		return true
	var parts = ip.split(".")
	if parts.size() != 4:
		return false
	for part in parts:
		if not part.is_valid_int() or int(part) < 0 or int(part) > 255:
			return false
	return true

func is_valid_port(valid_port: int) -> bool:
	return valid_port >= 0 and valid_port <= 65535

func _on_connect_timeout():
	if multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		show_popup("Connection timeout. Could not reach the server.")
		reset_ui()

func _on_change_photo_button_pressed():
	$FileDialog.popup_centered()

func _on_file_selected(path: String):
	var image = Image.load_from_file(path)
	if image:
		image.resize(85, 85)
		var err = image.save_png(USER_PHOTO_PATH)
		if err == OK:
			pass
		else:
			show_popup("Failed to save image to user folder. Error code: " + str(err))
	else:
		show_popup("Failed to load image from " + path)

func _apply_player_photo_to_field(field_node: Node):
	var texture = null
	if FileAccess.file_exists(USER_PHOTO_PATH):
		var image = Image.load_from_file(USER_PHOTO_PATH)
		if image:
			texture = ImageTexture.create_from_image(image)
	if not texture and ResourceLoader.exists(DEFAULT_PHOTO_PATH):
		texture = ResourceLoader.load(DEFAULT_PHOTO_PATH, "", ResourceLoader.CACHE_MODE_REPLACE)
	if texture:
		var player_info = field_node.find_child("Player_Info", true, false)
		if player_info:
			var polygon = player_info.get_node_or_null("Polygon2D")
			if polygon:
				polygon.texture = texture

func _get_opponent_photo_path() -> String:
	return "user://Opponent_Image_" + str(OS.get_process_id()) + ".png"

func _send_my_photo_to_peer(peer_id: int):
	var data = _get_my_photo_as_png_bytes()
	if data.size() > 0:
		rpc_id(peer_id, "receive_opponent_photo", data)

@rpc("any_peer", "reliable")
func receive_opponent_photo(photo_data: PackedByteArray):
	var save_path = _get_opponent_photo_path()
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_buffer(photo_data)
		file.close()
		var opp_field = get_node_or_null("OpponentField")
		if opp_field:
			_apply_opponent_photo_to_field(opp_field)

func _apply_opponent_photo_to_field(field_node: Node):
	var texture = null
	var opp_photo_path = _get_opponent_photo_path()
	if FileAccess.file_exists(opp_photo_path):
		var photo_data = FileAccess.get_file_as_bytes(opp_photo_path)
		var image = Image.new()
		var err = image.load_png_from_buffer(photo_data)
		if err != OK:
			err = image.load_jpg_from_buffer(photo_data)
		if err != OK:
			err = image.load_webp_from_buffer(photo_data)
		if err == OK:
			texture = ImageTexture.create_from_image(image)
	if not texture and ResourceLoader.exists(DEFAULT_PHOTO_PATH):
		texture = ResourceLoader.load(DEFAULT_PHOTO_PATH, "", ResourceLoader.CACHE_MODE_REPLACE)
	if texture:
		var opp_info = field_node.find_child("Opponents_Info", true, false)
		if opp_info:
			var polygon = opp_info.get_node_or_null("Polygon2D")
			if polygon:
				polygon.texture = texture

func on_peer_connected(peer_id):
	if multiplayer.is_server():
		if multiplayer.get_peers().size() > 1:
			rpc_id(peer_id, "lobby_is_full_callback")
			(func(): 
				if peer and peer_id in multiplayer.get_peers():
					peer.disconnect_peer(peer_id)).call_deferred()
			return
		_update_lobby_player_count(multiplayer.get_peers().size() + 1)
		if current_lobby:
			_send_my_photo_to_lobby(peer_id)
			rpc_id(peer_id, "receive_opponent_name_lobby", peer_names.get(multiplayer.get_unique_id(), "Host"))
			rpc_id(peer_id, "receive_host_ready_state", current_lobby.p1_ready)
			if current_lobby.mode_option and current_lobby.legality_option:
				current_lobby.rpc_id(peer_id, "sync_lobby_settings", current_lobby.mode_option.selected, current_lobby.legality_option.selected)

func on_peer_disconnected(peer_id):
	var in_game = has_node("PlayerField") or has_node("OpponentField") or _deck_building_instance != null
	if multiplayer.is_server():
		_update_lobby_player_count(multiplayer.get_peers().size() + 1)
		if in_game:
			var opp_name = peer_names.get(peer_id, "Opponent")
			show_popup(opp_name + " left the game.")
			_free_sideboard_instance()
			if current_lobby:
				current_lobby.queue_free()
				current_lobby = null
			if has_node("PlayerField"):
				get_node("PlayerField").queue_free()
			if has_node("OpponentField"):
				get_node("OpponentField").queue_free()
			_reset_series_state()
			reset_ui()
		elif current_lobby:
			current_lobby.on_client_disconnected()
	else:
		if peer_id == 1:
			if in_game:
				show_popup("Host left the game.")
				_free_sideboard_instance()
				if current_lobby:
					current_lobby.queue_free()
					current_lobby = null
				if has_node("PlayerField"):
					get_node("PlayerField").queue_free()
				if has_node("OpponentField"):
					get_node("OpponentField").queue_free()
				_reset_series_state()
			reset_ui()
	if peer_names.has(peer_id):
		peer_names.erase(peer_id)
	_cleanup_temp_files()

func _send_my_photo_to_lobby(peer_id: int):
	var data = _get_my_photo_as_png_bytes()
	if data.size() > 0:
		rpc_id(peer_id, "receive_opponent_photo_lobby", data)

func _get_my_photo_as_png_bytes() -> PackedByteArray:
	var image: Image = null
	if FileAccess.file_exists(USER_PHOTO_PATH):
		image = Image.load_from_file(USER_PHOTO_PATH)
	if not image and ResourceLoader.exists(DEFAULT_PHOTO_PATH):
		var texture = ResourceLoader.load(DEFAULT_PHOTO_PATH, "", ResourceLoader.CACHE_MODE_REPLACE)
		if texture is Texture2D:
			image = texture.get_image()
	if image:
		return image.save_png_to_buffer()
	return PackedByteArray()

@rpc("any_peer", "reliable")
func receive_opponent_photo_lobby(photo_data: PackedByteArray):
	var save_path = _get_opponent_photo_path()
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_buffer(photo_data)
		file.close()
	var image = Image.new()
	var err = image.load_png_from_buffer(photo_data)
	if err != OK:
		err = image.load_jpg_from_buffer(photo_data)
	if err != OK:
		err = image.load_webp_from_buffer(photo_data)
	if err == OK:
		var texture = ImageTexture.create_from_image(image)
		if current_lobby:
			current_lobby.apply_opponent_photo_direct(texture)

@rpc("any_peer", "reliable")
func receive_opponent_name_lobby(names: String):
	peer_names[multiplayer.get_remote_sender_id()] = names
	if current_lobby:
		current_lobby.set_opponent_name(names)

@rpc("any_peer", "reliable")
func receive_host_ready_state(is_ready: bool):
	if current_lobby and not multiplayer.is_server():
		current_lobby.sync_ready_state(1, is_ready)

@rpc("any_peer", "reliable")
func show_turn_popup(message: String):
	if message.contains("FIRST"):
		is_my_turn = true
	else:
		is_my_turn = false
	var player_field = get_node_or_null("PlayerField")
	if player_field:
		var phases = player_field.get_node_or_null("Phases")
		if phases and phases.has_method("update_phase_visuals"):
			phases.update_phase_visuals()
	_close_existing_dialogs()
	var dialog = AcceptDialog.new()
	dialog.dialog_text = message
	dialog.title = "TURN ORDER"
	get_tree().current_scene.add_child(dialog)
	dialog.popup_centered()

@rpc("any_peer", "call_local", "reliable")
func swap_turns():
	var player_field = get_node_or_null("PlayerField")
	if player_field:
		var main_field = player_field.get_node_or_null("MAINFIELD")
		if main_field and main_field.has_method("clear_imperial_seal_activations"):
			main_field.clear_imperial_seal_activations()
	var opponent_field = get_node_or_null("OpponentField")
	if opponent_field:
		var opp_main_field = opponent_field.get_node_or_null("OpponentMainField")
		if opp_main_field and opp_main_field.has_method("clear_imperial_seal_activations"):
			opp_main_field.clear_imperial_seal_activations()
	is_my_turn = !is_my_turn
	if player_field:
		var phases = player_field.get_node_or_null("Phases")
		if phases:
			phases.receive_opponent_phase_sync("Wake up")

@rpc("any_peer", "reliable")
func receive_opponent_name(names: String):
	var chat_node = get_node("PlayerField/Chat")
	if chat_node:
		chat_node.set_opponent_name(names)
		peer_names[multiplayer.get_remote_sender_id()] = names

@rpc("any_peer", "reliable")
func notify_host_of_join(client_name: String):
	if multiplayer.is_server():
		var host_chat_node = get_node("PlayerField/Chat")
		if host_chat_node:
			host_chat_node.add_message("System", client_name + " joined the game")

@rpc("any_peer", "reliable")
func sync_deck_data(player_id: int, ga_deck: Array, mat_deck: Array):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var opp_field = get_node_or_null("OpponentField")
	if opp_field:
		var opp_deck = opp_field.find_child("OpponentDeck", true, false)
		if not opp_deck:
			opp_deck = opp_field.get_node_or_null("OpponentDeck")
		if opp_deck and opp_deck.has_method("set_deck"):
			opp_deck.set_deck(ga_deck)
		var opp_mat_deck = opp_field.find_child("OpponentMaterialDeck", true, false)
		if not opp_mat_deck:
			opp_mat_deck = opp_field.get_node_or_null("OpponentMatDeck")
		if opp_mat_deck and opp_mat_deck.has_method("set_deck"):
			opp_mat_deck.set_deck(mat_deck)

@rpc("any_peer", "reliable")
func sync_element(element_name: String, alpha: float):
	var opp_element_path = "OpponentField/OpponentElements/Opponent" + element_name
	var opp_element = get_node_or_null(opp_element_path)
	if opp_element:
		opp_element.get_node("Sprite2D").modulate.a = alpha
		var elements_container = opp_element.get_parent()
		if elements_container and elements_container.has_method("refresh_layout"):
			elements_container.refresh_layout()

@rpc("any_peer", "reliable")
func sync_opponent_phase(phase_name: String):
	var player_field = get_node_or_null("PlayerField")
	if player_field:
		var player_phases = player_field.get_node_or_null("Phases")
		if player_phases:
			player_phases.receive_opponent_phase_sync(phase_name)
	if multiplayer.is_server():
		var sender_id = multiplayer.get_remote_sender_id()
		if sender_id != 0:
			for peer_id in multiplayer.get_peers():
				if peer_id != sender_id:
					rpc_id(peer_id, "sync_opponent_phase", phase_name)

@rpc("any_peer", "reliable")
func sync_move_to_graveyard(player_id: int, uuid: String, slug: String, from_deck: bool = false):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var opp_field = get_node_or_null("OpponentField")
	if opp_field and opp_field.has_node("OpponentHand") and opp_field.has_node("OpponentGraveyard"):
		var opp_hand = opp_field.get_node("OpponentHand")
		var opp_grave = opp_field.get_node("OpponentGraveyard")
		var card_manager = opp_field.get_node_or_null("CardManager") if opp_field else null
		if card_manager:
			var card = get_or_create_opponent_card(card_manager, uuid, slug)
			if card:
				if opp_hand and opp_hand.has_method("remove_card_from_hand"):
					opp_hand.remove_card_from_hand(card)
				var opp_memory = opp_field.get_node_or_null("OpponentMemory")
				if opp_memory and opp_memory.has_method("remove_card_from_memory"):
					opp_memory.remove_card_from_memory(card)
				var opp_banish = opp_field.get_node_or_null("OpponentBanish")
				if opp_banish and opp_banish.has_method("remove_card_from_slot"):
					opp_banish.remove_card_from_slot(card)
				var opp_main = opp_field.get_node_or_null("OpponentMainField")
				if opp_main and opp_main.has_method("remove_card_from_field"):
					opp_main.remove_card_from_field(card)
				if from_deck:
					var target_pos = opp_grave.global_position
					if opp_grave.has_node("Area2D/CollisionShape2D"):
						target_pos = opp_grave.get_node("Area2D/CollisionShape2D").global_position
					_animate_opponent_card_from_deck(card, target_pos, true, false, opp_grave, "add_card_to_slot", false)
				elif opp_grave and opp_grave.has_method("add_card_to_slot"):
					card.visible = true
					opp_grave.add_card_to_slot(card)

@rpc("any_peer", "reliable")
func sync_move_to_banish(player_id: int, uuid: String, slug: String, face_down: bool, from_deck: bool = false, from_mat_deck: bool = false):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var opp_field = get_node_or_null("OpponentField")
	if opp_field and opp_field.has_node("OpponentHand") and opp_field.has_node("OpponentBanish"):
		var opp_hand = opp_field.get_node("OpponentHand")
		var opp_banish = opp_field.get_node("OpponentBanish")
		var card_manager = opp_field.get_node_or_null("CardManager") if opp_field else null
		if card_manager:
			var card = get_or_create_opponent_card(card_manager, uuid, slug)
			if card:
				if opp_hand and opp_hand.has_method("remove_card_from_hand"):
					opp_hand.remove_card_from_hand(card)
				var opp_memory = opp_field.get_node_or_null("OpponentMemory")
				if opp_memory and opp_memory.has_method("remove_card_from_memory"):
					opp_memory.remove_card_from_memory(card)
				var opp_grave = opp_field.get_node_or_null("OpponentGraveyard")
				if opp_grave and opp_grave.has_method("remove_card_from_slot"):
					opp_grave.remove_card_from_slot(card)
				var opp_main = opp_field.get_node_or_null("OpponentMainField")
				if opp_main and opp_main.has_method("remove_card_from_field"):
					opp_main.remove_card_from_field(card)
				if from_deck or from_mat_deck:
					var target_pos = opp_banish.global_position
					if opp_banish.has_node("Area2D/CollisionShape2D"):
						target_pos = opp_banish.get_node("Area2D/CollisionShape2D").global_position
					_animate_opponent_card_from_deck(card, target_pos, !face_down, true, opp_banish, "add_card_to_slot", face_down, 0.0, from_mat_deck)
				elif opp_banish and opp_banish.has_method("add_card_to_slot"):
					card.visible = true
					opp_banish.add_card_to_slot(card, face_down)

@rpc("any_peer", "reliable")
func sync_banish_flip(player_id: int, uuid: String, is_face_down: bool):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var opp_field = get_node_or_null("OpponentField")
	if not opp_field:
		return
	var card = _find_opponent_card_by_uuid(opp_field, uuid)
	if not card:
		card = _find_opponent_card_by_uuid(get_tree().current_scene, uuid)
	if card:
		card.set_meta("is_face_down", is_face_down)
		var front = card.get_node_or_null("CardImage")
		var back = card.get_node_or_null("CardImageBack")
		if front and back:
			if is_face_down:
				front.visible = false
				back.visible = true
				back.z_index = 0
				front.z_index = -1
			else:
				front.visible = true
				back.visible = false
				back.z_index = -1
				front.z_index = 0
		var opp_banish = opp_field.get_node_or_null("OpponentBanish")
		if opp_banish and opp_banish.has_method("update_deck_view"):
			if opp_banish.has_node("BanishViewWindow") and opp_banish.get_node("BanishViewWindow").visible:
				opp_banish.update_deck_view()

@rpc("any_peer", "reliable")
func sync_banish_omen_count(player_id: int, count: int):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var opp_field = get_node_or_null("OpponentField")
	if opp_field:
		var opp_banish = opp_field.get_node_or_null("OpponentBanish")
		if opp_banish and opp_banish.has_method("remote_set_omen_count"):
			opp_banish.remote_set_omen_count(count)

@rpc("any_peer", "reliable")
func sync_move_to_main_field(player_id: int, uuid: String, slug: String, pos: Vector2, rot_deg: float, from_deck: bool = false, from_mat_deck: bool = false):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var opp_field = get_node_or_null("OpponentField")
	var player_field = get_node_or_null("PlayerField")
	if opp_field and opp_field.has_node("OpponentHand") and opp_field.has_node("OpponentMainField"):
		var opp_hand = opp_field.get_node("OpponentHand")
		var opp_main = opp_field.get_node("OpponentMainField")
		var card_manager = opp_field.get_node_or_null("CardManager") if opp_field else null
		var target_pos := pos
		var pf_main = player_field.get_node_or_null("MAINFIELD") if player_field else null
		if pf_main and opp_main:
			var pf_center = pf_main.global_position
			var opp_center = opp_main.global_position
			var relative_pos = pos - pf_center
			target_pos = opp_center - relative_pos
		if card_manager:
			var card = get_or_create_opponent_card(card_manager, uuid, slug)
			if card:
				card.visible = true
				if opp_hand and opp_hand.has_method("remove_card_from_hand"):
					opp_hand.remove_card_from_hand(card)
				var opp_grave = opp_field.get_node_or_null("OpponentGraveyard")
				if opp_grave and opp_grave.has_method("remove_card_from_slot"):
					opp_grave.remove_card_from_slot(card)
				var opp_banish = opp_field.get_node_or_null("OpponentBanish")
				if opp_banish and opp_banish.has_method("remove_card_from_slot"):
					opp_banish.remove_card_from_slot(card)
				var opp_memory = opp_field.get_node_or_null("OpponentMemory")
				if opp_memory and opp_memory.has_method("remove_card_from_memory"):
					opp_memory.remove_card_from_memory(card)
				if from_deck or from_mat_deck:
					_animate_opponent_card_from_deck(card, target_pos, true, false, opp_main, "add_card_to_field_with_rotation", false, rot_deg, from_mat_deck)
				elif opp_main and opp_main.has_method("add_card_to_field"):
					var is_token = false
					var is_mastery = false
					var is_status = false
					var logos = get_tree().get_nodes_in_group("logo")
					if logos.size() > 0:
						var local_logo = logos[0]
						if "token_slugs" in local_logo and slug in local_logo.token_slugs:
							is_token = true
						if "mastery_slugs" in local_logo and slug in local_logo.mastery_slugs:
							is_mastery = true
						if "status_slugs" in local_logo and slug in local_logo.status_slugs:
							is_status = true
					if (is_token or is_mastery or is_status) and not (card in opp_main.cards_in_field):
						var opp_logo = null
						for child in opp_field.get_children():
							if "Logo" in child.name:
								opp_logo = child
								break
						if not opp_logo:
							opp_logo = opp_field.find_child("OpponentLogo", true, false)
						if opp_logo:
							card.global_position = opp_logo.global_position
					opp_main.add_card_to_field(card, target_pos, rot_deg)

@rpc("any_peer", "reliable")
func sync_move_to_memory(player_id: int, uuid: String, slug: String, from_deck: bool = false, keep_reveal: bool = false):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var opp_field = get_node_or_null("OpponentField")
	if opp_field and opp_field.has_node("OpponentHand") and opp_field.has_node("OpponentMemory"):
		var opp_hand = opp_field.get_node("OpponentHand")
		var opp_memory = opp_field.get_node("OpponentMemory")
		var card_manager = opp_field.get_node_or_null("CardManager") if opp_field else null
		if card_manager:
			var card = get_or_create_opponent_card(card_manager, uuid, slug)
			if card:
				if opp_hand and opp_hand.has_method("remove_card_from_hand"):
					opp_hand.remove_card_from_hand(card)
				var opp_grave = opp_field.get_node_or_null("OpponentGraveyard")
				if opp_grave and opp_grave.has_method("remove_card_from_slot"):
					opp_grave.remove_card_from_slot(card)
				var opp_banish = opp_field.get_node_or_null("OpponentBanish")
				if opp_banish and opp_banish.has_method("remove_card_from_slot"):
					opp_banish.remove_card_from_slot(card)
				var opp_main = opp_field.get_node_or_null("OpponentMainField")
				if opp_main and opp_main.has_method("remove_card_from_field"):
					opp_main.remove_card_from_field(card)
				if from_deck:
					var target_pos = opp_memory.global_position
					if opp_memory.has_method("calculate_final_position_for_new_card"):
						target_pos = opp_memory.calculate_final_position_for_new_card()
					if opp_memory.has_method("_arrange_cards_symmetrically"):
						opp_memory._arrange_cards_symmetrically(true)
					elif opp_memory.has_method("arrange_cards_symmetrically"):
						opp_memory.arrange_cards_symmetrically(true)
					_animate_opponent_card_from_deck(card, target_pos, false, false, opp_memory, "add_card_to_memory", false)
				elif opp_memory and opp_memory.has_method("add_card_to_memory"):
					card.visible = true
					opp_memory.add_card_to_memory(card, false, -1, keep_reveal)

@rpc("any_peer", "reliable")
func sync_return_card_to_hand(player_id: int, uuid: String, slug: String):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var opp_field = get_node_or_null("OpponentField")
	if opp_field and opp_field.has_node("OpponentHand"):
		var opp_hand = opp_field.get_node("OpponentHand")
		var card_manager = opp_field.get_node_or_null("CardManager") if opp_field else null
		if card_manager:
			var card = get_or_create_opponent_card(card_manager, uuid, slug)
			if card:
				var opp_grave = opp_field.get_node_or_null("OpponentGraveyard")
				if opp_grave and opp_grave.has_method("remove_card_from_slot"):
					opp_grave.remove_card_from_slot(card)
				var opp_banish = opp_field.get_node_or_null("OpponentBanish")
				if opp_banish and opp_banish.has_method("remove_card_from_slot"):
					opp_banish.remove_card_from_slot(card)
				var opp_main = opp_field.get_node_or_null("OpponentMainField")
				if opp_main and opp_main.has_method("remove_card_from_field"):
					opp_main.remove_card_from_field(card)
				var opp_memory = opp_field.get_node_or_null("OpponentMemory")
				if opp_memory and opp_memory.has_method("remove_card_from_memory"):
					opp_memory.remove_card_from_memory(card)
				if opp_hand and opp_hand.has_method("add_card_to_hand"):
					opp_hand.add_card_to_hand(card)
				if card.has_method("set_opponent_reveal_status"):
					card.set_opponent_reveal_status(false, true)

@rpc("any_peer", "reliable")
func sync_card_returned_to_deck(player_id: int, uuid: String, _slug: String, is_top: bool = true):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var opp_field = get_node_or_null("OpponentField")
	if not opp_field:
		return
	var card_manager = opp_field.get_node_or_null("CardManager")
	if not card_manager:
		return
	var card = _find_opponent_card_by_uuid(card_manager, uuid)
	if card:
		var opp_deck = opp_field.find_child("OpponentDeck", true, false)
		if opp_deck:
			_animate_card_to_deck(card, opp_deck.global_position, opp_field, opp_deck, is_top)
		else:
			_remove_card_from_all_zones(card, opp_field)
			card.queue_free()

func _animate_card_to_deck(card: Node, deck_position: Vector2, opp_field: Node, opp_deck: Node = null, is_top: bool = true):
	if not card or not is_instance_valid(card):
		return
	var front = card.get_node_or_null("CardImage")
	var back = card.get_node_or_null("CardImageBack")
	if front:
		front.visible = false
		front.z_index = -1
	if back:
		back.visible = true
		back.z_index = 0
	card.z_index = 1 if is_top else -1
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(card, "global_position", deck_position, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(card, "rotation_degrees", 0.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.set_parallel(false)
	tween.tween_callback(func():
		if opp_deck:
			var slug = card.get_meta("slug") if card.has_meta("slug") else ""
			if is_top and opp_deck.has_method("add_to_top"):
				opp_deck.add_to_top(slug, card.uuid)
			elif not is_top and opp_deck.has_method("add_to_bottom"):
				opp_deck.add_to_bottom(slug, card.uuid)
			elif opp_deck.has_method("increment_deck_size"):
				opp_deck.increment_deck_size()
		if opp_field:
			_remove_card_from_all_zones(card, opp_field)
		card.queue_free())

func _animate_opponent_card_from_deck(card: Node, target_pos: Vector2, play_flip: bool, is_banish: bool, zone_node: Node, zone_method: String, face_down: bool, target_rotation: float = 0.0, is_mat_deck: bool = false):
	var opp_field = card.get_parent().get_parent() 
	var deck_node = null
	if is_mat_deck:
		deck_node = opp_field.find_child("OpponentMaterialDeck", true, false)
		if not deck_node:
			deck_node = opp_field.get_node_or_null("OpponentMatDeck")
	else:
		deck_node = opp_field.find_child("OpponentDeck", true, false)
	if deck_node:
		card.global_position = deck_node.global_position
		card.visible = true
		if deck_node.has_method("decrement_deck_size"):
			deck_node.decrement_deck_size()
	card.scale = Vector2(0.35, 0.35)
	card.z_index = 1000
	if card.has_method("set_opponent_reveal_status"):
		card.set_opponent_reveal_status(false, true)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(card, "global_position", target_pos, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if is_banish:
		tween.tween_property(card, "rotation_degrees", 90.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	else:
		tween.tween_property(card, "rotation_degrees", target_rotation, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if play_flip:
		if card.has_method("set_opponent_reveal_status"):
			card.set_opponent_reveal_status(true)
	await tween.finished
	if zone_node.has_method(zone_method):
		if is_banish:
			zone_node.call(zone_method, card, face_down)
		else:
			zone_node.call(zone_method, card)
	elif zone_method == "add_card_to_field_with_rotation":
		if zone_node.has_method("add_card_to_field"):
			zone_node.add_card_to_field(card, target_pos, target_rotation)

func _remove_card_from_all_zones(card: Node, opp_field: Node):
	if not card or not is_instance_valid(card):
		return
	var opp_hand = opp_field.get_node_or_null("OpponentHand")
	if opp_hand and opp_hand.has_method("remove_card_from_hand"):
		opp_hand.remove_card_from_hand(card)
	var opp_grave = opp_field.get_node_or_null("OpponentGraveyard")
	if opp_grave and opp_grave.has_method("remove_card_from_slot"):
		opp_grave.remove_card_from_slot(card)
	var opp_banish = opp_field.get_node_or_null("OpponentBanish")
	if opp_banish and opp_banish.has_method("remove_card_from_slot"):
		opp_banish.remove_card_from_slot(card)
	var opp_main = opp_field.get_node_or_null("OpponentMainField")
	if opp_main and opp_main.has_method("remove_card_from_field"):
		opp_main.remove_card_from_field(card)
	var opp_memory = opp_field.get_node_or_null("OpponentMemory")
	if opp_memory and opp_memory.has_method("remove_card_from_memory"):
		opp_memory.remove_card_from_memory(card)

@rpc("any_peer", "reliable")
func sync_move_to_deck(player_id: int, uuid: String, _is_top: bool):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var opp_field = get_node_or_null("OpponentField")
	if not opp_field:
		return
	var card_manager = opp_field.get_node_or_null("CardManager")
	if not card_manager:
		return
	var card = _find_opponent_card_by_uuid(card_manager, uuid)
	if card:
		var opp_deck = opp_field.find_child("OpponentDeck", true, false)
		if opp_deck:
			_animate_card_to_deck(card, opp_deck.global_position, opp_field, opp_deck, _is_top)
		else:
			if card.get_parent():
				if card.get_parent().has_method("remove_card_from_hand"):
					card.get_parent().remove_card_from_hand(card)
				elif card.get_parent().has_method("remove_card_from_slot"):
					card.get_parent().remove_card_from_slot(card)
				elif card.get_parent().has_method("remove_card_from_field"):
					card.get_parent().remove_card_from_field(card)
				else:
					card.get_parent().remove_child(card)
			card.queue_free()

@rpc("any_peer", "reliable")
func sync_card_state(player_id: int, uuid: String, slug: String, modifiers: Dictionary, counters: Dictionary, direction: String, rot_deg: float, is_marked: bool = false):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var opp_field = get_node_or_null("OpponentField")
	if not opp_field:
		return
	var card_manager = opp_field.get_node_or_null("CardManager")
	if card_manager:
		var card = get_or_create_opponent_card(card_manager, uuid, slug)
		if card:
			if "is_marked" in card:
				card.is_marked = is_marked
				if card.has_method("update_visuals_based_on_mark"):
					card.update_visuals_based_on_mark()
			if "runtime_modifiers" in card:
				card.runtime_modifiers = modifiers
			if "attached_counters" in card:
				card.attached_counters = counters
			if "current_direction" in card:
				card.current_direction = direction
			var target_rot = rot_deg
			var tween = create_tween()
			tween.tween_property(card, "rotation_degrees", target_rot, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func disable_buttons():
	$Panel.visible = false
	$CanvasLayer.visible = false
	$CanvasLayer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxHostContainer/HostButton.disabled = true
	$CanvasLayer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxHostContainer/HostButton.visible = false
	$CanvasLayer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxButtonsContainer/JoinButton.disabled = true
	$CanvasLayer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxButtonsContainer/JoinButton.visible = false
	$CanvasLayer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxNameContainer/Name.visible = false
	server.visible = false
	port.visible = false
	check.visible = false
	$ChangePhotoButton.visible = false
	$PhotoPreview.visible = false

func kick_peer(peer_id: int):
	if peer and peer_id in multiplayer.get_peers():
		peer.disconnect_peer(peer_id)
		if current_lobby:
			current_lobby.on_client_disconnected()

func reset_ui():
	if GlobalData and GlobalData.has_method("leave_room"):
		GlobalData.leave_room()
		GlobalData.is_online_match = false
	if GlobalData.origin_scene == "res://Scenes/Server_Lobby.tscn":
		_unregister_lobby()
		if multiplayer.multiplayer_peer != null:
			multiplayer.multiplayer_peer.close()
			multiplayer.multiplayer_peer = null
		var early_signals_to_clear = [multiplayer.peer_connected, multiplayer.peer_disconnected, multiplayer.connected_to_server, multiplayer.connection_failed, multiplayer.server_disconnected]
		for signals in early_signals_to_clear:
			for connects in signals.get_connections():
				signals.disconnect(connects.callable)
		if peer:
			peer.close()
		get_tree().change_scene_to_file("res://Scenes/Server_Lobby.tscn")
		return
	_unregister_lobby()
	$Panel.visible = true
	$CanvasLayer.visible = true
	$CanvasLayer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxHostContainer/HostButton.disabled = false
	$CanvasLayer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxHostContainer/HostButton.visible = true
	$CanvasLayer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxButtonsContainer/JoinButton.disabled = false
	$CanvasLayer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxButtonsContainer/JoinButton.visible = true
	$CanvasLayer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxNameContainer/Name.visible = true
	server.visible = true
	port.visible = not use_websocket
	check.visible = true
	$ChangePhotoButton.visible = true
	$PhotoPreview.visible = false
	var opp_photo = _get_opponent_photo_path()
	if FileAccess.file_exists(opp_photo):
		DirAccess.remove_absolute(opp_photo)
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	var signals_to_clear = [multiplayer.peer_connected, multiplayer.peer_disconnected, multiplayer.connected_to_server, multiplayer.connection_failed, multiplayer.server_disconnected]
	for signals in signals_to_clear:
		for connects in signals.get_connections():
			signals.disconnect(connects.callable)
	if peer:
		peer.close()
		peer = null
	for child in get_children():
		if child.name == "PlayerField" or child.name == "OpponentField" or child.name == "Lobby":
			child.queue_free()
	if current_lobby:
		current_lobby.queue_free()
		current_lobby = null
	peer_names.clear()
	if connect_timer:
		connect_timer.stop()

func get_or_create_opponent_card(card_manager, uuid: String, slug: String) -> Node:
	var opp_field = card_manager.get_parent()
	if opp_field:
		var existing_card = _find_opponent_card_by_uuid(opp_field, uuid)
		if existing_card:
			return existing_card
	if uuid != "":
		for card in card_manager.get_children():
			if "uuid" in card and card.uuid == uuid:
				return card
	var scene = load("res://Scenes/OpponentCard.tscn")
	if scene:
		var new_card = scene.instantiate()
		new_card.visible = false
		new_card.set_meta("slug", slug)
		if "uuid" in new_card:
			new_card.uuid = uuid
		card_manager.add_child(new_card)
		var card_image_path = "res://Assets/Grand Archive/Card Images/" + slug + ".png"
		if ResourceLoader.exists(card_image_path):
			var card_image = new_card.get_node_or_null("CardImage")
			var card_image_back = new_card.get_node_or_null("CardImageBack")
			if card_image:
				card_image.texture = load(card_image_path)
				card_image.visible = true
				if card_image_back:
					card_image_back.visible = false
					card_image.z_index = 0
		return new_card
	return null

@rpc("any_peer", "reliable")
func sync_destroy_token(player_id: int, uuid: String, slug: String):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var opp_field = get_node_or_null("OpponentField")
	if not opp_field:
		return
	var card_manager = opp_field.get_node_or_null("CardManager")
	if card_manager:
		var card = get_or_create_opponent_card(card_manager, uuid, slug)
		if card:
			if card.get_parent():
				if card.get_parent().has_method("remove_card_from_field"):
					card.get_parent().remove_card_from_field(card)
				elif card.get_parent().has_method("remove_card_from_slot"):
					card.get_parent().remove_card_from_slot(card)
				elif card.get_parent().has_method("remove_card_from_memory"):
					card.get_parent().remove_card_from_memory(card)
				elif card.get_parent().has_method("remove_card_from_hand"):
					card.get_parent().remove_card_from_hand(card)
				else:
					card.get_parent().remove_child(card)
			card.queue_free()

@rpc("any_peer", "reliable")
func sync_destroy_mastery(player_id: int, uuid: String, slug: String):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var opp_field = get_node_or_null("OpponentField")
	if not opp_field:
		return
	var card_manager = opp_field.get_node_or_null("CardManager")
	if card_manager:
		var card = get_or_create_opponent_card(card_manager, uuid, slug)
		if card:
			if card.get_parent():
				if card.get_parent().has_method("remove_card_from_field"):
					card.get_parent().remove_card_from_field(card)
				elif card.get_parent().has_method("remove_card_from_slot"):
					card.get_parent().remove_card_from_slot(card)
				elif card.get_parent().has_method("remove_card_from_memory"):
					card.get_parent().remove_card_from_memory(card)
				elif card.get_parent().has_method("remove_card_from_hand"):
					card.get_parent().remove_card_from_hand(card)
				else:
					card.get_parent().remove_child(card)
			card.queue_free()

@rpc("any_peer", "reliable")
func rpc_start_memory_roulette(player_id: int, target_index: int, total_time: float):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var opp_field = get_node_or_null("OpponentField")
	if opp_field:
		if opp_field.has_node("OpponentMemory"):
			var opp_memory = opp_field.get_node("OpponentMemory")
			if opp_memory.has_method("start_synced_roulette"):
				opp_memory.start_synced_roulette(target_index, total_time)

@rpc("any_peer", "reliable")
func rpc_reset_memory_roulette(player_id: int):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var opp_field = get_node_or_null("OpponentField")
	if opp_field and opp_field.has_node("OpponentMemory"):
		var opp_memory = opp_field.get_node("OpponentMemory")
		if opp_memory and opp_memory.has_method("reset_card_colors"):
			opp_memory.reset_card_colors()

@rpc("any_peer", "reliable")
func rpc_set_card_reveal_status(player_id: int, card_uuid: String, revealed: bool, skip_animation: bool = false):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var opp_field = get_node_or_null("OpponentField")
	if not opp_field:
		return
	var found_card = _find_opponent_card_by_uuid(opp_field, card_uuid)
	if found_card and found_card.has_method("set_opponent_reveal_status"):
		found_card.set_opponent_reveal_status(revealed, skip_animation)

@rpc("any_peer", "reliable")
func rpc_set_all_cards_reveal_status(player_id: int, revealed: bool):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var opp_field = get_node_or_null("OpponentField")
	if not opp_field:
		return
	var opp_memory = opp_field.get_node_or_null("OpponentMemory")
	if opp_memory and opp_memory.has_method("set_all_cards_reveal_status"):
		opp_memory.set_all_cards_reveal_status(revealed)

@rpc("any_peer", "reliable")
func sync_card_transform(player_id: int, uuid: String, new_slug: String):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var opp_field = get_node_or_null("OpponentField")
	if not opp_field:
		return
	var card = _find_opponent_card_by_uuid(opp_field, uuid)
	if card and card.has_method("remote_transform"):
		card.remote_transform(new_slug)

func _find_opponent_card_by_uuid(root_node, target_uuid):
	if root_node.name.contains("CardDisplay") or root_node.name.contains("LineageViewWindow"):
		return null
	var is_match = false
	if root_node.has_method("get_uuid") and root_node.get_uuid() == target_uuid:
		is_match = true
	elif root_node.has_meta("uuid") and root_node.get_meta("uuid") == target_uuid:
		is_match = true
	if is_match:
		if root_node.has_method("get_runtime_modifiers") or root_node.name.contains("OpponentCard") or root_node.name.contains("Card"):
			return root_node
	for child in root_node.get_children():
		var result = _find_opponent_card_by_uuid(child, target_uuid)
		if result:
			return result
	return null

@rpc("any_peer", "reliable")
func rpc_sync_hand_order(player_id: int, uuid_list: Array):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var opp_field = get_node_or_null("OpponentField")
	if opp_field:
		var opp_hand = opp_field.get_node_or_null("OpponentHand")
		if opp_hand and opp_hand.has_method("reorder_by_uuids"):
			opp_hand.reorder_by_uuids(uuid_list)

@rpc("any_peer", "reliable")
func sync_banish_lineage_card(player_id: int, champion_uuid: String, lineage_uuid: String, lineage_slug: String):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var opp_field = get_node_or_null("OpponentField")
	if not opp_field:
		return
	var champion_card = _find_opponent_card_by_uuid(opp_field, champion_uuid)
	if champion_card and champion_card.has_method("animate_lineage_banish"):
		champion_card.animate_lineage_banish(lineage_slug, lineage_uuid)

@rpc("any_peer", "reliable")
func sync_move_to_lineage(player_id: int, champion_uuid: String, card_uuid: String, card_slug: String, chosen_elements: Array = [], element: String = ""):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var opp_field = get_node_or_null("OpponentField")
	if not opp_field:
		return
	var champion_card = _find_opponent_card_by_uuid(opp_field, champion_uuid)
	if not champion_card:
		return
	var card_to_move = _find_opponent_card_by_uuid(opp_field, card_uuid)
	if not card_to_move:
		pass
	if champion_card.has_method("animate_send_to_lineage"):
		champion_card.animate_send_to_lineage(card_to_move, card_slug, card_uuid, chosen_elements, element)

@rpc("any_peer", "reliable")
func sync_give_control(player_id: int, stats: Dictionary):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var opp_field = get_node_or_null("OpponentField")
	if not opp_field:
		return
	var card_uuid = stats.get("uuid", "")
	var opponent_card = _find_opponent_card_by_uuid(opp_field, card_uuid)
	if not opponent_card:
		return
	var player_field = get_node_or_null("PlayerField")
	var main_field = player_field.get_node_or_null("MAINFIELD") if player_field else null
	var opp_main_field = opp_field.get_node_or_null("OpponentMainField")
	if not main_field or not opp_main_field:
		return
	var relative_pos = opponent_card.global_position - opp_main_field.global_position
	var target_pos = main_field.global_position - relative_pos
	var target_rot = opponent_card.rotation_degrees + 180
	opponent_card.z_index = 1000
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(opponent_card, "global_position", target_pos, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(opponent_card, "rotation_degrees", target_rot, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel(false)
	tween.tween_callback(func():
		_convert_opponent_to_player_card(opponent_card, stats, target_pos, target_rot + 180))

@rpc("any_peer", "reliable")
func sync_set_card_marked(player_id: int, uuid: String, is_marked: bool):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var card_found = false
	var opp_field = get_node_or_null("OpponentField")
	if opp_field:
		var card = _find_opponent_card_by_uuid(opp_field, uuid)
		if card and card.has_method("set_marked"):
			card.set_marked(is_marked)
			card_found = true
	if not card_found:
		var player_field = get_node_or_null("PlayerField")
		if player_field:
			var _card_manager = player_field.get_node_or_null("CardManager")
			var local_card = _find_local_card_by_uuid(player_field, uuid)
			if local_card and local_card.has_method("set_marked"):
				local_card.set_marked(is_marked)

func _find_local_card_by_uuid(root_node, target_uuid):
	if ("uuid" in root_node and root_node.uuid == target_uuid) or (root_node.has_meta("uuid") and root_node.get_meta("uuid") == target_uuid):
		return root_node
	for child in root_node.get_children():
		var res = _find_local_card_by_uuid(child, target_uuid)
		if res:
			return res
	return null

@rpc("any_peer", "reliable")
func sync_return_to_owner_banish(target_owner_id: int, uuid: String, slug: String, face_down: bool):
	if multiplayer.get_unique_id() == target_owner_id:
		var opp_field = get_node_or_null("OpponentField")
		if not opp_field:
			return
		var card = _find_opponent_card_by_uuid(opp_field, uuid)
		if card:
			_convert_opponent_to_local_banish(card, slug, uuid, face_down)
	else:
		pass

func _convert_opponent_to_local_banish(opp_card: Node, slug: String, uuid: String, face_down: bool):
	var player_field = get_node_or_null("PlayerField")
	if not player_field:
		return
	var banish_node = player_field.get_node_or_null("BANISH")
	if not banish_node:
		return
	var card_manager = player_field.get_node_or_null("CardManager")
	var card_scene = load("res://Scenes/Card.tscn")
	var new_card = card_scene.instantiate()
	new_card.set_meta("slug", slug)
	new_card.uuid = uuid
	new_card.uuid = uuid
	new_card.original_owner_id = multiplayer.get_unique_id()
	var card_image_path = "res://Assets/Grand Archive/Card Images/" + slug + ".png"
	if ResourceLoader.exists(card_image_path):
		var image = new_card.get_node_or_null("CardImage")
		if image:
			image.texture = load(card_image_path)
			image.visible = not face_down
			var back = new_card.get_node_or_null("CardImageBack")
			if back: back.visible = face_down
	if card_manager:
		card_manager.add_child(new_card)
		if card_manager.has_method("connect_card_signals"):
			card_manager.connect_card_signals(new_card)
	new_card.global_position = opp_card.global_position
	new_card.rotation_degrees = opp_card.rotation_degrees + 180.0
	new_card.z_index = 1000
	if face_down:
		var front = new_card.get_node_or_null("CardImage")
		var back = new_card.get_node_or_null("CardImageBack")
		if front: front.visible = true
		if back: back.visible = false
		var anim = new_card.get_node_or_null("AnimationPlayer")
		if anim and anim.has_animation("card_flip"):
			anim.play("card_flip")
			var timer = get_tree().create_timer(0.1)
			timer.timeout.connect(func():
				if front: front.visible = false
				if back: back.visible = true)
		else:
			if front: front.visible = false
			if back: back.visible = true
	if opp_card.get_parent():
		if opp_card.get_parent().has_method("remove_card_from_field"):
			opp_card.get_parent().remove_card_from_field(opp_card)
		elif opp_card.get_parent().has_method("remove_card_from_slot"):
			opp_card.get_parent().remove_card_from_slot(opp_card)
		elif opp_card.get_parent().has_method("remove_card_from_memory"):
			opp_card.get_parent().remove_card_from_memory(opp_card)
		elif opp_card.get_parent().has_method("remove_card_from_hand"):
			opp_card.get_parent().remove_card_from_hand(opp_card)
		else:
			opp_card.get_parent().remove_child(opp_card)
	opp_card.queue_free()
	var target_pos = banish_node.global_position
	if banish_node.has_node("Area2D/CollisionShape2D"):
		target_pos = banish_node.get_node("Area2D/CollisionShape2D").global_position
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(new_card, "global_position", target_pos, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(new_card, "rotation_degrees", 90.0, 0.5) 
	tween.set_parallel(false)
	tween.tween_callback(func():
		if banish_node.has_method("add_card_to_slot"):
			banish_node.add_card_to_slot(new_card, face_down))

func _convert_opponent_to_player_card(opp_card: Node, stats: Dictionary, final_pos: Vector2, final_rot: float):
	var player_field = get_node_or_null("PlayerField")
	if not player_field:
		return
	var main_field = player_field.get_node_or_null("MAINFIELD")
	if not main_field:
		return
	var card_manager = player_field.get_node_or_null("CardManager")
	if not card_manager:
		return
	var card_scene = load("res://Scenes/Card.tscn")
	var new_card = card_scene.instantiate()
	new_card.set_meta("slug", stats.get("slug", ""))
	new_card.uuid = stats.get("uuid", "")
	if "original_owner_id" in new_card:
		new_card.original_owner_id = stats.get("original_owner_id", 0)
	new_card.runtime_modifiers = stats.get("modifiers", {}).duplicate()
	new_card.attached_counters = stats.get("counters", {}).duplicate()
	new_card.is_rotated = false
	if abs(fmod(final_rot, 360.0)) > 45 and abs(fmod(final_rot, 360.0)) < 135:
		new_card.is_rotated = true
	elif abs(fmod(final_rot, 360.0)) > 225 and abs(fmod(final_rot, 360.0)) < 315:
		new_card.is_rotated = true
	new_card.original_rotation = 0.0 
	new_card.rotation_degrees = final_rot
	var card_image_path = "res://Assets/Grand Archive/Card Images/" + stats.get("slug", "") + ".png"
	if ResourceLoader.exists(card_image_path):
		var image = new_card.get_node_or_null("CardImage")
		if image:
			image.texture = load(card_image_path)
			image.visible = true
			var back = new_card.get_node_or_null("CardImageBack")
			if back: back.visible = false
	card_manager.add_child(new_card)
	if stats.has("is_marked") and stats.get("is_marked", false):
		new_card.is_marked = true
		if new_card.has_method("update_visuals_based_on_mark"):
			new_card.update_visuals_based_on_mark()
	if card_manager.has_method("connect_card_signals"):
		card_manager.connect_card_signals(new_card)
	if main_field.has_method("add_card_to_field"):
		new_card.set_meta("is_given", true)
		main_field.add_card_to_field(new_card, final_pos)
		var normalized_rot = fmod(final_rot, 360.0)
		if normalized_rot < 0:
			normalized_rot += 360.0
		new_card.rotation_degrees = normalized_rot
		if abs(new_card.rotation_degrees - 360.0) < 1.0:
			new_card.rotation_degrees = 0.0
		new_card.original_rotation = 0.0
		new_card.is_rotated = (abs(fmod(final_rot, 180.0)) > 45 and abs(fmod(final_rot, 180.0)) < 135)
		new_card.z_index = 300 
		if main_field.has_method("bring_card_to_front"):
			main_field.bring_card_to_front(new_card)
	else:
		if new_card.has_method("set_current_field"):
			new_card.set_current_field(main_field)
		new_card.global_position = final_pos
		new_card.rotation_degrees = final_rot
		if abs(new_card.rotation_degrees - 360.0) < 1.0:
			new_card.rotation_degrees = 0.0
		new_card.z_index = 300
	if opp_card.get_parent():
		if opp_card.get_parent().has_method("remove_card_from_field"):
			opp_card.get_parent().remove_card_from_field(opp_card)
		else:
			opp_card.get_parent().remove_child(opp_card)
	opp_card.queue_free()

@rpc("any_peer", "reliable")
func sync_mark_card(player_id: int, zone_name: String, uuid: String, is_marked: bool):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var player_field = get_node_or_null("PlayerField")
	if not player_field:
		return
	var slot_name = ""
	match zone_name:
		"graveyard":
			slot_name = "GRAVEYARD"
		"banish":
			slot_name = "BANISH"
	if slot_name != "":
		var slot = player_field.get_node_or_null(slot_name)
		if slot and slot.has_method("set_card_marked"):
			slot.set_card_marked(uuid, is_marked)
	if multiplayer.is_server():
		var sender_id = multiplayer.get_remote_sender_id()
		if sender_id != 0:
			for peer_id in multiplayer.get_peers():
				if peer_id != sender_id:
					rpc_id(peer_id, "sync_mark_card", player_id, zone_name, uuid, is_marked)

@rpc("any_peer", "reliable")
func sync_deck_grid_to_hand(player_id: int, uuid: String, slug: String):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var opp_field = get_node_or_null("OpponentField")
	if not opp_field:
		return 
	var opp_deck = opp_field.find_child("OpponentDeck", true, false)
	if opp_deck and opp_deck.has_method("draw_card"):
		opp_deck.draw_card(slug, uuid)

@rpc("any_peer", "reliable")
func sync_move_to_mat_deck(player_id: int, uuid: String, _is_top: bool):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var opp_field = get_node_or_null("OpponentField")
	if not opp_field:
		return
	var card_manager = opp_field.get_node_or_null("CardManager")
	if not card_manager:
		return
	var card = _find_opponent_card_by_uuid(opp_field, uuid)
	if not card:
		card = _find_opponent_card_by_uuid(get_tree().current_scene, uuid)
	if card:
		var opp_mat_deck = opp_field.find_child("Opponent_MAT_DECK", true, false)
		if not opp_mat_deck:
			opp_mat_deck = opp_field.find_child("OpponentMaterialDeck", true, false)
		if not opp_mat_deck:
			opp_mat_deck = opp_field.get_node_or_null("OpponentMatDeck")	
		if opp_mat_deck:
			_animate_card_to_deck(card, opp_mat_deck.global_position, opp_field, opp_mat_deck)
		else:
			if card.get_parent():
				if card.get_parent().has_method("remove_card_from_hand"):
					card.get_parent().remove_card_from_hand(card)
				elif card.get_parent().has_method("remove_card_from_slot"):
					card.get_parent().remove_card_from_slot(card)
				elif card.get_parent().has_method("remove_card_from_field"):
					card.get_parent().remove_card_from_field(card)
				else:
					card.get_parent().remove_child(card)
			card.queue_free()

@rpc("any_peer", "reliable")
func sync_deck_highlight(player_id: int, is_highlighted: bool):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var opp_field = get_node_or_null("OpponentField")
	if not opp_field:
		return
	var opp_deck = opp_field.find_child("OpponentDeck", true, false)
	if opp_deck and opp_deck.has_method("set_highlight"):
		opp_deck.set_highlight(is_highlighted)

@rpc("any_peer", "reliable")
func sync_pantheon_flip(player_id: int, side: int, is_flipped: bool, slug: String):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var opp_field = get_node_or_null("OpponentField")
	if opp_field:
		var pantheon = opp_field.get_node_or_null("OpponentPANTHEON")
		if pantheon and pantheon.has_method("remote_flip"):
			pantheon.remote_flip(side, is_flipped, slug)

@rpc("any_peer", "reliable")
func sync_initial_pantheon(player_id: int, slugs: Array):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var opp_field = get_node_or_null("OpponentField")
	if opp_field:
		var pantheon = opp_field.get_node_or_null("OpponentPANTHEON")
		if pantheon and pantheon.has_method("set_initial_cards"):
			pantheon.set_initial_cards(slugs)

@rpc("any_peer", "reliable")
func lobby_is_full_callback():
	show_popup("Lobby is full (2/2 players).")
	reset_ui()

func _refresh_lobby_list():
	item_list.clear()
	_cleanup_dead_lobbies()
	current_lobbies = _load_lobbies()
	var visible_lobbies = []
	for lobby in current_lobbies:
		if lobby.player_count > 0:
			visible_lobbies.append(lobby)
	for lobby in visible_lobbies:
		var status = "Open"
		if lobby.get("in_game", false):
			status = "In game"
		elif lobby.player_count >= 2:
			status = "Closed"
		var count_str = str(int(lobby.player_count)) + "/2"
		var text = lobby.host_name + " (" + count_str + ") - Status: " + status
		item_list.add_item(text)
		item_list.set_item_metadata(item_list.get_item_count() - 1, lobby)

func _cleanup_dead_lobbies():
	var lobbies = _load_lobbies()
	var now = Time.get_unix_time_from_system()
	var alive = []
	for lobby in lobbies:
		var last = lobby.get("last_seen", 0)
		if now - last < 15.0:
			alive.append(lobby)
	_save_lobbies(alive)

func _load_lobbies() -> Array:
	if not FileAccess.file_exists(LOBBY_FILE):
		return []
	var file = FileAccess.open(LOBBY_FILE, FileAccess.READ)
	if not file:
		return []
	var content = file.get_as_text()
	file.close()
	var json = JSON.new()
	var err = json.parse(content)
	if err == OK:
		if json.data is Dictionary and json.data.has("lobbies"):
			return json.data.lobbies
	return []

func _save_lobbies(lobbies: Array):
	var file = FileAccess.open(LOBBY_FILE, FileAccess.WRITE)
	if not file:
		return
	var data = {"lobbies": lobbies}
	file.store_string(JSON.stringify(data))
	file.close()

func _register_lobby(host_name: String, host_port: int):
	_registered_lobby_port = host_port
	var lobbies = _load_lobbies()
	var found = false
	for lobby in lobbies:
		if lobby.port == host_port:
			lobby.host_name = host_name
			lobby.player_count = 1
			lobby.last_seen = Time.get_unix_time_from_system()
			found = true
			break
	if not found:
		lobbies.append({
		"host_id": multiplayer.get_unique_id(),
		"host_name": host_name,
		"ip": "localhost",
		"port": host_port,
		"player_count": 1,
		"last_seen": Time.get_unix_time_from_system()})
		_save_lobbies(lobbies)
		_start_heartbeat()

func _start_heartbeat():
	if has_node("HeartbeatTimer"):
		return
	var timer = Timer.new()
	timer.name = "HeartbeatTimer"
	timer.wait_time = 5.0
	timer.autostart = true
	timer.timeout.connect(_on_heartbeat)
	add_child(timer)

func _on_heartbeat():
	if _registered_lobby_port == -1:
		return
	var lobbies = _load_lobbies()
	for lobby in lobbies:
		if lobby.port == _registered_lobby_port:
			lobby.last_seen = Time.get_unix_time_from_system()
			break
	_save_lobbies(lobbies)
	
func _is_lobby_alive(lobby: Dictionary) -> bool:
	var last = lobby.get("last_seen", 0)
	var now = Time.get_unix_time_from_system()
	return (now - last) < 15.0

func _unregister_lobby():
	var target_port = _registered_lobby_port
	if target_port == -1:
		return
	if has_node("HeartbeatTimer"):
		get_node("HeartbeatTimer").queue_free()
	var lobbies = _load_lobbies()
	var new_lobbies = []
	for lobby in lobbies:
		if lobby.port != target_port:
			new_lobbies.append(lobby)
	_save_lobbies(new_lobbies)
	_registered_lobby_port = -1

func _update_lobby_player_count(count: int):
	var target_port = _registered_lobby_port
	if target_port == -1:
		return
	var lobbies = _load_lobbies()
	for lobby in lobbies:
		if lobby.port == target_port:
			lobby.player_count = count
			break
	_save_lobbies(lobbies)

func _on_item_selected(index: int):
	var lobby = item_list.get_item_metadata(index)
	if lobby:
		server.text = lobby.ip
		port.text = str(int(lobby.port))

func _on_item_activated(index: int):
	_on_item_selected(index)
	_on_join_button_pressed()

func _set_lobby_in_game():
	var target_port = _registered_lobby_port
	if target_port == -1:
		return
	var lobbies = _load_lobbies()
	for lobby in lobbies:
		if lobby.port == target_port:
			lobby.in_game = true
			break
	_save_lobbies(lobbies)

func start_game_instances():
	_match_is_over = false
	if multiplayer.is_server():
		_set_lobby_in_game()
	var deck_data = {}
	if _series_started and _current_deck_data.size() > 0:
		deck_data = _current_deck_data
	elif current_lobby and current_lobby.has_method("get_selected_deck_data"):
		deck_data = current_lobby.get_selected_deck_data()
	if not _series_started and deck_data.size() > 0:
		_original_deck_data = deck_data.duplicate(true)
		_current_deck_data = deck_data.duplicate(true)
		_series_started = true
	if current_lobby:
		current_lobby.visible = false
	_free_sideboard_instance()
	if has_node("PlayerField"):
		var old_pf = get_node("PlayerField")
		old_pf.name = "PlayerField_old"
		old_pf.queue_free()
	if has_node("OpponentField"):
		var old_of = get_node("OpponentField")
		old_of.name = "OpponentField_old"
		old_of.queue_free()
	await get_tree().process_frame
	var preloaded = SceneCache.get_preloaded()
	var player_field = null
	var opponent_field = null
	if preloaded != null and typeof(preloaded) == TYPE_DICTIONARY:
		player_field = preloaded.get("pf")
		opponent_field = preloaded.get("of")
	if player_field:
		player_field.name = "PlayerField"
		if not player_field.is_inside_tree():
			add_child(player_field)
	else:
		player_field = player_field_scene.instantiate()
		player_field.name = "PlayerField"
		add_child(player_field)
	player_field.visible = true
	player_field.process_mode = Node.PROCESS_MODE_INHERIT
	_apply_player_photo_to_field(player_field)
	if deck_data.size() > 0:
		var ga_deck = player_field.get_node_or_null("GA_DECK")
		if ga_deck and ga_deck.has_method("load_deck_data") and deck_data.has("main_deck"):
			ga_deck.load_deck_data(deck_data["main_deck"])
		var mat_deck = player_field.get_node_or_null("MAT_DECK")
		if mat_deck and mat_deck.has_method("load_deck_data") and deck_data.has("mat_deck"):
			mat_deck.load_deck_data(deck_data["mat_deck"])
		var pantheon = player_field.get_node_or_null("PANTHEON")
		if pantheon and pantheon.has_method("load_deck_data") and deck_data.has("pantheon_deck"):
			pantheon.load_deck_data(deck_data["pantheon_deck"])
	if opponent_field:
		opponent_field.name = "OpponentField"
		if not opponent_field.is_inside_tree():
			add_child(opponent_field)
	else:
		opponent_field = opponent_field_scene.instantiate()
		opponent_field.name = "OpponentField"
		add_child(opponent_field)
	opponent_field.visible = true
	opponent_field.process_mode = Node.PROCESS_MODE_INHERIT
	_apply_opponent_photo_to_field(opponent_field)
	if multiplayer.is_server():
		var host_first = (randi() % 2 == 0)
		var peers = multiplayer.get_peers()
		if peers.size() > 0:
			var client_id = peers[0]
			if host_first:
				show_turn_popup("You are going FIRST!")
				rpc_id(client_id, "show_turn_popup", "You are going SECOND!")
			else:
				show_turn_popup("You are going SECOND!")
				rpc_id(client_id, "show_turn_popup", "You are going FIRST!")
	_deferred_sync_pantheon()
	SceneCache.start_preload()

func _deferred_sync_pantheon():
	await get_tree().process_frame
	var player_field = get_node_or_null("PlayerField")
	if player_field:
		var pantheon = player_field.get_node_or_null("PANTHEON")
		if pantheon:
			var cards = pantheon.get_pantheon_cards()
			rpc("sync_initial_pantheon", multiplayer.get_unique_id(), cards)

func _disable_field_input(player_field: Node):
	var input_manager = player_field.get_node_or_null("InputManager")
	if input_manager:
		input_manager.set_process_input(false)
	var phases = player_field.get_node_or_null("Phases")
	if phases:
		phases.set_process_input(false)
	for child in player_field.get_children():
		if child.name == "Chat" or child.name == "EndGamePopup":
			continue
		_disable_area2d_recursive(child)

func _disable_area2d_recursive(node: Node):
	if node is Area2D:
		node.input_pickable = false
	for child in node.get_children():
		_disable_area2d_recursive(child)

func surrender_game():
	rpc("rpc_report_game_end", multiplayer.get_unique_id())

@rpc("any_peer", "call_local", "reliable")
func rpc_report_game_end(loser_id: int):
	if not multiplayer.is_server():
		return
	if _match_is_over:
		return
	_match_is_over = true
	var host_lost = (1 == loser_id)
	if host_lost:
		_wins_remote += 1
	else:
		_wins_local += 1
	rpc("rpc_show_end_game", loser_id, _wins_local, _wins_remote)

@rpc("any_peer", "call_local", "reliable")
func rpc_show_end_game(loser_id: int, host_wins_local: int, host_wins_remote: int):
	_rematch_requested_local = false
	_rematch_requested_remote = false
	_continue_requested_local = false
	_continue_requested_remote = false
	if not multiplayer.is_server():
		_match_is_over = true
		_wins_remote = host_wins_local
		_wins_local = host_wins_remote
	var i_lost = (multiplayer.get_unique_id() == loser_id)
	var series_over = (_game_mode == 0 or _is_series_over())
	var player_field = get_node_or_null("PlayerField")
	if not player_field or not player_field.has_node("EndGamePopup"):
		return
	var popup = player_field.get_node("EndGamePopup")
	var label = popup.get_node("Panel/CenterContainer/VBoxContainer/ResultLabel")
	var action_button = popup.get_node("Panel/CenterContainer/VBoxContainer/HBoxContainer/RematchButton")
	var leave_button = popup.get_node("Panel/CenterContainer/VBoxContainer/HBoxContainer/LeaveButton")
	if _game_mode == 0:
		if i_lost:
			label.text = "You Lose"
			label.add_theme_color_override("font_color", Color.RED)
		else:
			label.text = "You Win"
			label.add_theme_color_override("font_color", Color.GREEN)
	else:
		if series_over:
			if _wins_local > _wins_remote:
				label.text = "You Win (" + str(_wins_local) + "-" + str(_wins_remote) + ")"
				label.add_theme_color_override("font_color", Color.GREEN)
			else:
				label.text = "You Lose (" + str(_wins_local) + "-" + str(_wins_remote) + ")"
				label.add_theme_color_override("font_color", Color.RED)
		else:
			if i_lost:
				label.text = "You Lose (" + str(_wins_local) + "-" + str(_wins_remote) + ")"
				label.add_theme_color_override("font_color", Color.RED)
			else:
				label.text = "You Win (" + str(_wins_local) + "-" + str(_wins_remote) + ")"
				label.add_theme_color_override("font_color", Color.GREEN)
	if action_button.pressed.is_connected(_on_rematch_pressed):
		action_button.pressed.disconnect(_on_rematch_pressed)
	if action_button.pressed.is_connected(_on_continue_pressed):
		action_button.pressed.disconnect(_on_continue_pressed)
	if leave_button.pressed.is_connected(_on_leave_pressed):
		leave_button.pressed.disconnect(_on_leave_pressed)
	leave_button.pressed.connect(_on_leave_pressed)
	action_button.disabled = false	
	if series_over:
		action_button.pressed.connect(_on_rematch_pressed.bind(action_button))
		action_button.text = "Rematch"
	else:
		action_button.pressed.connect(_on_continue_pressed.bind(action_button))
		action_button.text = "Continue"
	popup.visible = true
	_disable_field_input(player_field)

func _get_wins_needed() -> int:
	if _game_mode == 1: return 2
	if _game_mode == 2: return 3
	return 1

func _is_series_over() -> bool:
	var needed = _get_wins_needed()
	return _wins_local >= needed or _wins_remote >= needed

func _enter_sideboard_phase():
	_sideboard_ready_local = false
	_sideboard_ready_remote = false
	var player_field = get_node_or_null("PlayerField")
	if player_field:
		player_field.visible = false
	var opponent_field = get_node_or_null("OpponentField")
	if opponent_field:
		opponent_field.visible = false
	var canvas = CanvasLayer.new()
	canvas.name = "SideboardCanvas"
	canvas.layer = 100
	_deck_building_instance = deck_building_scene.instantiate()
	canvas.add_child(_deck_building_instance)
	add_child(canvas)
	if _deck_building_instance.has_method("enter_sideboard_mode"):
		var mode_str = "Match" if _game_mode == 1 else "Best of 5"
		var score_text = "Mode: " + mode_str + "\nYou " + str(_wins_local) + " - " + str(_wins_remote) + " Opponent"
		_deck_building_instance.enter_sideboard_mode(_current_deck_data, Callable(self, "_on_sideboard_ok"), score_text)

func _on_sideboard_ok(modified_decks: Dictionary):
	DiscordManager.update_status("Side Decking", "Waiting for Opponent")
	_current_deck_data = modified_decks.duplicate(true)
	_sideboard_ready_local = true
	rpc("rpc_sideboard_ready")

func _exit_sideboard_phase():
	DiscordManager.update_status("In a Match", "Dueling")
	_free_sideboard_instance()
	start_game_instances()

@rpc("any_peer", "call_local", "reliable")
func rpc_sideboard_ready():
	var sender_id = multiplayer.get_remote_sender_id()
	if sender_id != multiplayer.get_unique_id():
		_sideboard_ready_remote = true
	if _sideboard_ready_local and _sideboard_ready_remote:
		_exit_sideboard_phase()

@rpc("any_peer", "reliable")
func rpc_sync_game_mode(mode: int):
	_game_mode = mode

func _on_rematch_pressed(button: Button):
	button.disabled = true
	button.text = "Waiting..."
	_rematch_requested_local = true
	rpc("rpc_request_rematch")

func _on_continue_pressed(button: Button):
	button.disabled = true
	button.text = "Waiting..."
	_continue_requested_local = true
	rpc("rpc_request_continue")

func _on_leave_pressed():
	rpc("rpc_leave_match")
	_cleanup_and_leave()

@rpc("any_peer", "reliable")
func sync_set_champion_lineage(player_id: int, uuid: String, lineage: Array):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var opp_field = get_node_or_null("OpponentField")
	if opp_field:
		var opp_main = opp_field.get_node_or_null("OpponentMainField")
		if opp_main and "cards_in_field" in opp_main:
			for card in opp_main.cards_in_field:
				if "uuid" in card and card.uuid == uuid:
					if "champion_lineage" in card:
						card.champion_lineage = lineage.duplicate(true)
					break

@rpc("any_peer", "reliable")
func sync_apply_damage_to_champion(player_id: int, damage_amount: int):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var player_field = get_node_or_null("PlayerField")
	if player_field:
		var current_champ = player_field.get("current_champion_card")
		if not current_champ:
			var main_field = player_field.get_node_or_null("MAINFIELD")
			if main_field:
				current_champ = main_field.get("current_champion_card")
		if current_champ and current_champ.has_method("add_damage_counters"):
			current_champ.add_damage_counters(damage_amount)

@rpc("any_peer", "call_local", "reliable")
func rpc_request_rematch():
	var sender_id = multiplayer.get_remote_sender_id()
	if sender_id != multiplayer.get_unique_id():
		_rematch_requested_remote = true
	if _rematch_requested_local and _rematch_requested_remote:
		restart_match()

@rpc("any_peer", "call_local", "reliable")
func rpc_request_continue():
	var sender_id = multiplayer.get_remote_sender_id()
	if sender_id != multiplayer.get_unique_id():
		_continue_requested_remote = true
	if _continue_requested_local and _continue_requested_remote:
		var player_field = get_node_or_null("PlayerField")
		if player_field and player_field.has_node("EndGamePopup"):
			player_field.get_node("EndGamePopup").visible = false
		_enter_sideboard_phase()

@rpc("any_peer", "call_local", "reliable")
func rpc_leave_match():
	var sender_id = multiplayer.get_remote_sender_id()
	if sender_id != multiplayer.get_unique_id():
		show_popup("Opponent left the match.")
		_cleanup_and_leave()

func _cleanup_and_leave():
	_free_sideboard_instance()
	if current_lobby:
		current_lobby.queue_free()
		current_lobby = null
	if has_node("PlayerField"):
		var player_field = get_node("PlayerField")
		player_field.name = "PlayerField_old"
		player_field.queue_free()
	if has_node("OpponentField"):
		var opponent_field = get_node("OpponentField")
		opponent_field.name = "OpponentField_old"
		opponent_field.queue_free()
	_reset_series_state()
	reset_ui()

func restart_match():
	_rematch_requested_local = false
	_rematch_requested_remote = false
	_continue_requested_local = false
	_continue_requested_remote = false
	_wins_local = 0
	_wins_remote = 0
	_match_is_over = false
	_current_deck_data = _original_deck_data.duplicate(true)
	_series_started = false
	start_game_instances()

func _reset_series_state():
	_game_mode = 0
	_wins_local = 0
	_wins_remote = 0
	_match_is_over = false
	_original_deck_data = {}
	_current_deck_data = {}
	_series_started = false
	_sideboard_ready_local = false
	_sideboard_ready_remote = false

func _free_sideboard_instance():
	if _deck_building_instance:
		_deck_building_instance.queue_free()
		_deck_building_instance = null
	if has_node("SideboardCanvas"):
		get_node("SideboardCanvas").queue_free()

@rpc("any_peer", "reliable")
func sync_prismatic_elements(player_id: int, card_uuid: String, elements: Array):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var opp_field = get_node_or_null("OpponentField")
	if opp_field:
		var card = _find_opponent_card_by_uuid(opp_field, card_uuid)
		if card:
			card.chosen_elements = elements
			if card.has_method("set_meta"):
				card.set_meta("chosen_elements", elements)

@rpc("any_peer", "reliable")
func sync_imperial_seal_activate(player_id: int, _card_uuid: String):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote: return
	ImperialSealEffect.apply_opponent_activation(get_tree().current_scene)

@rpc("any_peer", "reliable")
func sync_apotheosis_rite_activate(player_id: int):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote: return
	ApotheosisRiteEffect.apply_opponent_activation(get_tree().current_scene)

@rpc("any_peer", "reliable")
func sync_sacramental_rite_activate(player_id: int):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote: return
	SacramentalRiteEffect.apply_opponent_activation(get_tree().current_scene)

@rpc("any_peer", "reliable")
func sync_transcendental_rite_activate(player_id: int):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote: return
	TranscendentalRiteEffect.apply_opponent_activation(get_tree().current_scene)
