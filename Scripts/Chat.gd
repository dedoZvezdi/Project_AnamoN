extends Node2D

@onready var message: LineEdit = $Message
@onready var text_edit: TextEdit = $TextEdit
@onready var Send_edit: Button = $Send

var msg: String
var player_name: String = "Player"
var opponent_name: String = "Opponent"

func _ready():
	var config = ConfigFile.new()
	var err = config.load("user://player_config.cfg")
	if err == OK:
		player_name = config.get_value("Player", "Name", "Player")
	text_edit.editable = false
	Send_edit.pressed.connect(_on_send_pressed)
	message.text_submitted.connect(_on_message_submitted)

func _on_send_pressed():
	send_message()

func _on_message_submitted(_text):
	send_message()

func send_message():
	msg = message.text.strip_edges()
	if msg != "":
		add_message(player_name, msg)
		message.text = ""
		message.grab_focus()
		text_edit.scroll_vertical = text_edit.get_line_count()
		send_message_to_peer()

func send_message_to_peer():
	rpc("receive_message", player_name, msg)

@rpc("any_peer", "reliable")
func receive_message(sender: String, received_msg: String):
	add_message(sender, received_msg)

func send_system_message(system_msg: String):
	add_message("System", system_msg)
	rpc("receive_system_message", system_msg)

@rpc("any_peer", "reliable")
func receive_system_message(system_msg: String):
	add_message("System", system_msg)

func add_message(sender: String, content: String, _color: Color = Color.WHITE):
	text_edit.text += sender + ": " + content + "\n"
	text_edit.scroll_vertical = text_edit.get_line_count()

func set_opponent_name(names: String):
	opponent_name = names
