extends Node2D

@export var player_field_scene : PackedScene
@export var opponent_field_scene : PackedScene

@onready var server: LineEdit = $IP_Address
@onready var port: LineEdit = $PORT

var peer = ENetMultiplayerPeer.new()
var peer_names = {}
var upnp: UPNP
var connect_timer: Timer

func _ready():
	var config = ConfigFile.new()
	var err = config.load("user://player_config.cfg")
	if err == OK:
		$Name.text = config.get_value("Player", "Name", "")
		server.text = config.get_value("Player", "ServerIP", "localhost")
		port.text = str(config.get_value("Player", "ServerPort", 8000))
	if not has_node("ConnectTimer"):
		connect_timer = Timer.new()
		connect_timer.name = "ConnectTimer"
		connect_timer.wait_time = 7.0
		connect_timer.one_shot = true
		connect_timer.timeout.connect(_on_connect_timeout)
		add_child(connect_timer)

func _on_host_button_pressed() -> void:
	var entered_name = $Name.text.strip_edges()
	var name_to_use = "Player" if entered_name == "" else entered_name
	if not validate_ip_and_port():
		return
	var config = ConfigFile.new()
	config.set_value("Player", "Name", name_to_use)
	config.set_value("Player", "ServerIP", server.text)
	config.set_value("Player", "ServerPort", int(port.text))
	config.save("user://player_config.cfg")
	disable_buttons()
	await setup_upnp_for_host(int(port.text))
	peer.create_server(int(port.text))
	multiplayer.multiplayer_peer = peer
	var player_scene = player_field_scene.instantiate()
	add_child(player_scene)
	multiplayer.peer_connected.connect(on_peer_connected)
	var chat_node = player_scene.get_node("Chat")
	if chat_node:
		chat_node.player_name = name_to_use
		peer_names[multiplayer.get_unique_id()] = name_to_use

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
	dialog.title = "ERROR"
	get_tree().current_scene.add_child(dialog)
	dialog.popup_centered()

func is_valid_ip(ip: String) -> bool:
	var parts = ip.split(".")
	if parts.size() != 4:
		return false
	for part in parts:
		if not part.is_valid_int() or int(part) < 0 or int(part) > 255:
			return false
	return true

func is_valid_port(p: int) -> bool:
	return p >= 0 and p <= 65535

func setup_upnp_for_host(host_port: int):
	upnp = UPNP.new()
	var discover_result = upnp.discover()
	if discover_result != UPNP.UPNP_RESULT_SUCCESS:
		show_popup("UPNP discovery failed. Try manual forwarding.")
		return
	var gateway = upnp.get_gateway()
	if gateway == null or not gateway.is_valid_gateway():
		show_popup("No UPNP gateway detected. Please manually forward port %d UDP." % host_port)
		return
	var add_result = upnp.add_port_mapping(host_port, 0, "Godot Multiplayer", "UDP", 0)
	if add_result != UPNP.UPNP_RESULT_SUCCESS:
		show_popup("Your router doesn't support UPNP. Please manually forward port %d on UDP protocol." % host_port)

func _on_join_button_pressed() -> void:
	var entered_name = $Name.text.strip_edges()
	var name_to_use = "Player" if entered_name == "" else entered_name
	if not validate_ip_and_port():
		return
	var config = ConfigFile.new()
	config.set_value("Player", "Name", name_to_use)
	config.set_value("Player", "ServerIP", server.text)
	config.set_value("Player", "ServerPort", int(port.text))
	config.save("user://player_config.cfg")
	disable_buttons()
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

func _on_connect_timeout():
	if multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		show_popup("There is no host with such IP and port. Exit by timeout")
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

func reset_ui():
	$HostButton.disabled = false
	$HostButton.visible = true
	$JoinButton.disabled = false
	$JoinButton.visible = true
	$Name.visible = true
	server.visible = true
	port.visible = true
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	peer.close()
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
