extends Node2D

@export var player_field_scene : PackedScene
@export var opponent_field_scene : PackedScene

const PORT = 8000
const SERVER_ADDRESS = "localhost"

var peer = ENetMultiplayerPeer.new()
var peer_names = {}

func _ready():
	var config = ConfigFile.new()
	var err = config.load("user://player_config.cfg")
	if err == OK:
		$Name.text = config.get_value("Player", "Name", "")

func _on_host_button_pressed() -> void:
	var entered_name = $Name.text.strip_edges()
	var name_to_use = "Player" if entered_name == "" else entered_name
	var config = ConfigFile.new()
	config.set_value("Player", "Name", name_to_use)
	config.save("user://player_config.cfg")
	disable_buttons()
	peer.create_server(PORT)
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
	var config = ConfigFile.new()
	config.set_value("Player", "Name", name_to_use)
	config.save("user://player_config.cfg")
	disable_buttons()
	peer.create_client(SERVER_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	var player_scene = player_field_scene.instantiate()
	add_child(player_scene)
	var opponent_scene = opponent_field_scene.instantiate()
	add_child(opponent_scene)
	player_scene.client_set_up()
	var chat_node = player_scene.get_node("Chat")
	if chat_node:
		chat_node.player_name = name_to_use
	multiplayer.connected_to_server.connect(func():
		rpc("receive_opponent_name", name_to_use)
		rpc_id(1, "notify_host_of_join", name_to_use)
		peer_names[multiplayer.get_unique_id()] = name_to_use
	)

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

func disable_buttons():
	$HostButton.disabled = true
	$HostButton.visible = false
	$JoinButton.disabled = true
	$JoinButton.visible = false
	$Name.visible = false
