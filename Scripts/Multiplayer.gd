extends Node2D

@export var player_field_scene : PackedScene
@export var opponent_field_scene : PackedScene

@onready var server: LineEdit = $IP_Address
@onready var port: LineEdit = $PORT
@onready var check: CheckButton = $CheckButton

var peer = null
var peer_names = {}
var upnp: UPNP
var connect_timer: Timer
var use_websocket: bool = false

func _ready():
	var config = ConfigFile.new()
	var err = config.load("user://player_config.cfg")
	if err == OK:
		$Name.text = config.get_value("Player", "Name", "")
		server.text = config.get_value("Player", "ServerIP")
		port.text = str(config.get_value("Player", "ServerPort"))
		check.button_pressed = config.get_value("Player", "UseWebSocket", false)
	check.toggled.connect(_on_check_button_toggled)
	_on_check_button_toggled(check.button_pressed)
	if not has_node("ConnectTimer"):
		connect_timer = Timer.new()
		connect_timer.name = "ConnectTimer"
		connect_timer.wait_time = 10.0
		connect_timer.one_shot = true
		connect_timer.timeout.connect(_on_connect_timeout)
		add_child(connect_timer)

func _on_check_button_toggled(is_pressed: bool):
	use_websocket = is_pressed
	if is_pressed:
		server.placeholder_text = "For JOIN: https://tunnel-url.com / For HOST: leave empty"
		port.visible = true
	else:
		server.placeholder_text = "localhost or IP address"
		port.visible = true

func _on_host_button_pressed() -> void:
	var entered_name = $Name.text.strip_edges()
	var name_to_use = "Player" if entered_name == "" else entered_name
	if use_websocket:
		if not validate_websocket_host():
			return
		var config = ConfigFile.new()
		config.set_value("Player", "Name", name_to_use)
		config.set_value("Player", "ServerPort", int(port.text))
		config.set_value("Player", "UseWebSocket", true)
		config.save("user://player_config.cfg")
		disable_buttons()
		peer = WebSocketMultiplayerPeer.new()
		var error = peer.create_server(int(port.text))
		if error != OK:
			show_popup("Failed to create WebSocket server on port " + port.text)
			reset_ui()
			return
		multiplayer.multiplayer_peer = peer
		var player_scene = player_field_scene.instantiate()
		add_child(player_scene)
		multiplayer.peer_connected.connect(on_peer_connected)
		var chat_node = player_scene.get_node("Chat")
		if chat_node:
			chat_node.player_name = name_to_use
			peer_names[multiplayer.get_unique_id()] = name_to_use
		show_popup("WebSocket server started on port " + port.text + "\n\nNow run in terminal:\ncloudflared tunnel --url http://localhost:" + port.text + "\n\nThen share the https:// URL with your friend!")
	else:
		if not validate_ip_and_port():
			return
		var config = ConfigFile.new()
		config.set_value("Player", "Name", name_to_use)
		config.set_value("Player", "ServerIP", server.text)
		config.set_value("Player", "ServerPort", int(port.text))
		config.set_value("Player", "UseWebSocket", false)
		config.save("user://player_config.cfg")
		disable_buttons()
		peer = ENetMultiplayerPeer.new()
		peer.create_server(int(port.text))
		multiplayer.multiplayer_peer = peer
		var player_scene = player_field_scene.instantiate()
		add_child(player_scene)
		multiplayer.peer_connected.connect(on_peer_connected)
		var chat_node = player_scene.get_node("Chat")
		if chat_node:
			chat_node.player_name = name_to_use
			peer_names[multiplayer.get_unique_id()] = name_to_use

func _on_join_button_pressed() -> void:
	var entered_name = $Name.text.strip_edges()
	var name_to_use = "Player" if entered_name == "" else entered_name
	if use_websocket:
		if not validate_websocket_url():
			return
		var config = ConfigFile.new()
		config.set_value("Player", "Name", name_to_use)
		config.set_value("Player", "ServerURL", server.text)
		config.set_value("Player", "UseWebSocket", true)
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
			var player_scene = player_field_scene.instantiate()
			add_child(player_scene)
			var opponent_scene = opponent_field_scene.instantiate()
			add_child(opponent_scene)
			player_scene.client_set_up()
			var chat_node = player_scene.get_node("Chat")
			if chat_node:
				chat_node.player_name = name_to_use
			rpc("receive_opponent_name", name_to_use)
			rpc_id(1, "notify_host_of_join", name_to_use)
			peer_names[multiplayer.get_unique_id()] = name_to_use
		)
		multiplayer.connection_failed.connect(func():
			if connect_timer and connect_timer.is_stopped() == false:
				connect_timer.stop()
			show_popup("Failed to connect to WebSocket server. Check the URL.")
			reset_ui()
		)
		connect_timer.start()
	else:
		if not validate_ip_and_port():
			return
		var config = ConfigFile.new()
		config.set_value("Player", "Name", name_to_use)
		config.set_value("Player", "ServerIP", server.text)
		config.set_value("Player", "ServerPort", int(port.text))
		config.set_value("Player", "UseWebSocket", false)
		config.save("user://player_config.cfg")
		disable_buttons()
		peer = ENetMultiplayerPeer.new()
		peer.create_client(server.text, int(port.text))
		multiplayer.multiplayer_peer = peer
		multiplayer.connected_to_server.connect(func():
			if connect_timer and connect_timer.is_stopped() == false:
				connect_timer.stop()
			var player_scene = player_field_scene.instantiate()
			add_child(player_scene)
			var opponent_scene = opponent_field_scene.instantiate()
			add_child(opponent_scene)
			player_scene.client_set_up()
			var chat_node = player_scene.get_node("Chat")
			if chat_node:
				chat_node.player_name = name_to_use
			rpc("receive_opponent_name", name_to_use)
			rpc_id(1, "notify_host_of_join", name_to_use)
			peer_names[multiplayer.get_unique_id()] = name_to_use
		)
		multiplayer.connection_failed.connect(func():
			if connect_timer and connect_timer.is_stopped() == false:
				connect_timer.stop()
			show_popup("There is no host with such IP and port.")
			reset_ui()
		)
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
		show_popup("Please enter the WebSocket URL (https://...).")
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

func show_popup(message: String):
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

func is_valid_port(p: int) -> bool:
	return p >= 0 and p <= 65535

func _on_connect_timeout():
	if multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		show_popup("Connection timeout. Could not reach the server.")
		reset_ui()

func on_peer_connected(peer_id):
	if not has_node("OpponentField"):
		var opponent_scene = opponent_field_scene.instantiate()
		add_child(opponent_scene)
		get_node("PlayerField").host_set_up()
	var host_chat = get_node("PlayerField/Chat")
	if host_chat:
		rpc_id(peer_id, "receive_opponent_name", host_chat.player_name)

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
func sync_element(element_name: String, alpha: float):
	var opp_element_path = "OpponentField/OpponentElements/Opponent" + element_name
	var opp_element = get_node(opp_element_path)
	if opp_element:
		opp_element.get_node("Sprite2D").modulate.a = alpha

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
func sync_move_to_graveyard(player_id: int, slug: String):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var opp_field = get_node_or_null("OpponentField")
	if opp_field and opp_field.has_node("OpponentHand") and opp_field.has_node("OpponentGraveyard"):
		var opp_hand = opp_field.get_node("OpponentHand")
		var opp_grave = opp_field.get_node("OpponentGraveyard")
		var card_manager = opp_field.get_node_or_null("CardManager") if opp_field else null
		if card_manager:
			for c in card_manager.get_children():
				if c and c.has_meta("slug") and c.get_meta("slug") == slug:
					if opp_hand and opp_hand.has_method("remove_card_from_hand"):
						opp_hand.remove_card_from_hand(c)
					if opp_grave and opp_grave.has_method("add_card_to_slot"):
						opp_grave.add_card_to_slot(c)
					break

@rpc("any_peer", "reliable")
func sync_move_to_banish(player_id: int, slug: String, face_down: bool):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var opp_field = get_node_or_null("OpponentField")
	if opp_field and opp_field.has_node("OpponentHand") and opp_field.has_node("OpponentBanish"):
		var opp_hand = opp_field.get_node("OpponentHand")
		var opp_banish = opp_field.get_node("OpponentBanish")
		var card_manager = opp_field.get_node_or_null("CardManager") if opp_field else null
		if card_manager:
			for c in card_manager.get_children():
				if c and c.has_meta("slug") and c.get_meta("slug") == slug:
					if opp_hand and opp_hand.has_method("remove_card_from_hand"):
						opp_hand.remove_card_from_hand(c)
					var opp_memory = opp_field.get_node_or_null("OpponentMemory")
					if opp_memory and opp_memory.has_method("remove_card_from_memory"):
						opp_memory.remove_card_from_memory(c)
					var opp_grave = opp_field.get_node_or_null("OpponentGraveyard")
					if opp_grave and opp_grave.has_method("remove_card_from_slot"):
						opp_grave.remove_card_from_slot(c)
					if opp_banish and opp_banish.has_method("add_card_to_slot"):
						opp_banish.add_card_to_slot(c, face_down)
					break

@rpc("any_peer", "reliable")
func sync_move_to_main_field(player_id: int, slug: String, pos: Vector2, rot_deg: float):
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
			target_pos = opp_center + (pos - pf_center)
		if card_manager:
			for c in card_manager.get_children():
				if c and c.has_meta("slug") and c.get_meta("slug") == slug:
					if opp_hand and opp_hand.has_method("remove_card_from_hand"):
						opp_hand.remove_card_from_hand(c)
					var opp_grave = opp_field.get_node_or_null("OpponentGraveyard")
					if opp_grave and opp_grave.has_method("remove_card_from_slot"):
						opp_grave.remove_card_from_slot(c)
					var opp_banish = opp_field.get_node_or_null("OpponentBanish")
					if opp_banish and opp_banish.has_method("remove_card_from_slot"):
						opp_banish.remove_card_from_slot(c)
					var opp_memory = opp_field.get_node_or_null("OpponentMemory")
					if opp_memory and opp_memory.has_method("remove_card_from_memory"):
						opp_memory.remove_card_from_memory(c)
					if opp_main and opp_main.has_method("add_card_to_field"):
						opp_main.add_card_to_field(c, target_pos, rot_deg)
					break

@rpc("any_peer", "reliable")
func sync_move_to_memory(player_id: int, slug: String):
	var is_from_remote = multiplayer.get_remote_sender_id() == player_id
	if not is_from_remote:
		return
	var opp_field = get_node_or_null("OpponentField")
	if opp_field and opp_field.has_node("OpponentHand") and opp_field.has_node("OpponentMemory"):
		var opp_hand = opp_field.get_node("OpponentHand")
		var opp_memory = opp_field.get_node("OpponentMemory")
		var card_manager = opp_field.get_node_or_null("CardManager") if opp_field else null
		if card_manager:
			for c in card_manager.get_children():
				if c and c.has_meta("slug") and c.get_meta("slug") == slug:
					if opp_hand and opp_hand.has_method("remove_card_from_hand"):
						opp_hand.remove_card_from_hand(c)
					var opp_grave = opp_field.get_node_or_null("OpponentGraveyard")
					if opp_grave and opp_grave.has_method("remove_card_from_slot"):
						opp_grave.remove_card_from_slot(c)
					var opp_banish = opp_field.get_node_or_null("OpponentBanish")
					if opp_banish and opp_banish.has_method("remove_card_from_slot"):
						opp_banish.remove_card_from_slot(c)
					if opp_memory and opp_memory.has_method("add_card_to_memory"):
						opp_memory.add_card_to_memory(c)
					break

func reset_ui():
	$HostButton.disabled = false
	$HostButton.visible = true
	$JoinButton.disabled = false
	$JoinButton.visible = true
	$Name.visible = true
	server.visible = true
	port.visible = not use_websocket
	check.visible = true
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	if peer:
		peer.close()
		peer = null
	for child in get_children():
		if child.name == "PlayerField" or child.name == "OpponentField":
			child.queue_free()
	peer_names.clear()
	if connect_timer:
		connect_timer.stop()

func disable_buttons():
	$HostButton.disabled = true
	$HostButton.visible = false
	$JoinButton.disabled = true
	$JoinButton.visible = false
	$Name.visible = false
	server.visible = false
	port.visible = false
	check.visible = false
