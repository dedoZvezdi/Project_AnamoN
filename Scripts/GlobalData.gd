extends Node

var origin_scene: String = "res://Scenes/Main_Menu.tscn"
var auto_host: bool = false
var auto_join: bool = false
var target_ip: String = ""
var target_port: int = 8910
var is_online_match: bool = false
var socket := WebSocketPeer.new()
var active_rooms = []
var my_webrtc_id = 1
var last_error_message: String = ""

signal rooms_updated
signal room_created
signal room_joined
signal server_error(message: String)
signal peer_connected_webrtc(peer_id: int)
signal peer_disconnected_webrtc(peer_id: int)
signal webrtc_offer_received(peer_id: int, offer: String)
signal webrtc_answer_received(peer_id: int, answer: String)
signal webrtc_candidate_received(peer_id: int, mid: String, index: int, sdp: String)

func _ready():
	socket.connect_to_url("ws://164.92.251.69:8000")

func _process(_delta):
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count() > 0:
			var packet = socket.get_packet().get_string_from_utf8()
			var data = JSON.parse_string(packet)
			_handle_server_message(data)

func _handle_server_message(data):
	var action = data.get("action")
	if action == "room_list":
		active_rooms = data.get("rooms", [])
		emit_signal("rooms_updated")
	elif action == "room_joined":
		my_webrtc_id = int(data.get("my_id", 1))
		emit_signal("room_joined")
	elif action == "error":
		emit_signal("server_error", data.get("message", "Unknown error occurred."))
	elif action == "banned":
		var reason = data.get("reason", "You have been banned.")
		if get_tree().current_scene.name != "ServerLobby":
			if multiplayer.multiplayer_peer:
				multiplayer.multiplayer_peer.close()
			last_error_message = reason
			get_tree().change_scene_to_file("res://Scenes/Server_Lobby.tscn")
		else:
			emit_signal("server_error", reason)
	elif action == "room_created":
		emit_signal("room_created")
	elif action == "peer_connected":
		emit_signal("peer_connected_webrtc", int(data.get("peer_id")))
	elif action == "peer_disconnected":
		emit_signal("peer_disconnected_webrtc", int(data.get("peer_id")))
	elif action == "offer":
		emit_signal("webrtc_offer_received", int(data.get("peer_id")), data.get("sdp"))
	elif action == "answer":
		emit_signal("webrtc_answer_received", int(data.get("peer_id")), data.get("sdp"))
	elif action == "candidate":
		emit_signal("webrtc_candidate_received", int(data.get("peer_id")), data.get("mid"), int(data.get("index")), data.get("sdp"))

func create_room(room_id, host_info):
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		socket.send_text(JSON.stringify({
			"action": "create_room",
			"room_id": room_id,
			"host_info": host_info}))

func get_my_photo_b64() -> String:
	var photo_b64 = ""
	if FileAccess.file_exists("user://Player_Image.png"):
		var img = Image.load_from_file("user://Player_Image.png")
		if img:
			img.resize(128, 128)
			var buffer = img.save_webp_to_buffer()
			photo_b64 = Marshalls.raw_to_base64(buffer)
	return photo_b64

func join_room(room_id):
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		var config = ConfigFile.new()
		var p_name = "Unknown"
		if config.load("user://player_config.cfg") == OK:
			p_name = config.get_value("Player", "Name", "Unknown")
		socket.send_text(JSON.stringify({
			"action": "join_room",
			"room_id": room_id,
			"client_info": {
				"photo_b64": get_my_photo_b64(),
				"player_name": p_name}}))

func get_rooms():
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		socket.send_text(JSON.stringify({"action": "get_rooms"}))

func update_room_info(mode: String, legality: String):
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		socket.send_text(JSON.stringify({
			"action": "update_room",
			"mode": mode,
			"legality": legality}))

func leave_room():
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		socket.send_text(JSON.stringify({"action": "leave_room"}))

func send_webrtc_offer(target_peer_id: int, sdp: String):
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		socket.send_text(JSON.stringify({
			"action": "offer",
			"target_peer_id": target_peer_id,
			"sdp": sdp}))

func send_webrtc_answer(target_peer_id: int, sdp: String):
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		socket.send_text(JSON.stringify({
			"action": "answer",
			"target_peer_id": target_peer_id,
			"sdp": sdp}))

func send_webrtc_candidate(target_peer_id: int, mid: String, index: int, sdp: String):
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		socket.send_text(JSON.stringify({
			"action": "candidate",
			"target_peer_id": target_peer_id,
			"mid": mid,
			"index": index,
			"sdp": sdp}))

func send_chat_copy(sender_name: String, msg: String):
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		socket.send_text(JSON.stringify({
			"action": "chat_message",
			"sender_name": sender_name,
			"message": msg}))

func send_chat_event(event_type: String, number: int):
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		if event_type == "new_game":
			socket.send_text(JSON.stringify({"action": "chat_event", "type": "new_game", "game_number": number}))
		elif event_type == "new_round":
			socket.send_text(JSON.stringify({"action": "chat_event", "type": "new_round", "round_number": number}))
