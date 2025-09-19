extends Node2D

@export var player_field_scene : PackedScene
@export var opponent_field_scene : PackedScene

const PORT = 8000
const SERVER_ADDRESS = "localhost"

var peer = ENetMultiplayerPeer.new()

func _on_host_button_pressed() -> void:
	disable_buttons()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	var player_scene = player_field_scene.instantiate()
	add_child(player_scene)
	multiplayer.peer_connected.connect(on_peer_connected)

func _on_join_button_pressed() -> void:
	disable_buttons()
	peer.create_client(SERVER_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	var player_scene = player_field_scene.instantiate()
	add_child(player_scene)
	var opponent_scene = opponent_field_scene.instantiate()
	add_child(opponent_scene)
	player_scene.client_set_up()
	
func on_peer_connected(peer_id):
	if not has_node("OpponentField"):
		var opponent_scene = opponent_field_scene.instantiate()
		add_child(opponent_scene)
		get_node("PlayerField").host_set_up()

func disable_buttons():
	$HostButton.disabled = true
	$HostButton.visible = false
	$JoinButton.disabled = true
	$JoinButton.visible = false
