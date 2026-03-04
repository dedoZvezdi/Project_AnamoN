extends Node2D

@onready var message: LineEdit = $Message
@onready var text_edit: RichTextLabel = $TextEdit
@onready var Send_edit: Button = $Send

var msg: String
var player_name: String = "Player"
var opponent_name: String = "Opponent"
var player_rps_choice: String = ""
var opponent_rps_choice: String = ""
var rps_challenger_name: String = ""

func _ready():
	var config = ConfigFile.new()
	var err = config.load("user://player_config.cfg")
	if err == OK:
		player_name = config.get_value("Player", "Name", "Player")
	text_edit.bbcode_enabled = true
	text_edit.scroll_following = true
	text_edit.focus_mode = Control.FOCUS_NONE
	Send_edit.pressed.connect(_on_send_pressed)
	message.text_submitted.connect(_on_message_submitted)

func _on_send_pressed():
	send_message()

func _on_message_submitted(_text):
	send_message()

func send_message():
	msg = message.text.strip_edges()
	if msg != "":
		add_message(player_name, msg, false)
		message.text = ""
		send_message_to_peer()
	message.grab_focus()

func send_message_to_peer():
	rpc("receive_message", player_name, msg)

@rpc("any_peer", "reliable")
func receive_message(sender: String, received_msg: String):
	add_message(sender, received_msg, true)

func send_system_message(system_msg: String):
	add_message("System", system_msg)
	rpc("receive_system_message", system_msg)

@rpc("any_peer", "reliable")
func receive_system_message(system_msg: String):
	add_message("System", system_msg)

func add_message(sender: String, content: String, is_opponent: bool = false):
	var sender_bb: String = sender
	if sender == "System":
		sender_bb = "[color=white]" + sender + "[/color]"
	elif is_opponent:
		sender_bb = "[color=red]" + sender + "[/color]"
	else:
		sender_bb = "[color=blue]" + sender + "[/color]"
	text_edit.append_text(sender_bb + ": [color=white]" + content + "[/color]\n")

func set_opponent_name(names: String):
	opponent_name = names
	
func get_sender_name() -> String:
	return opponent_name
	
func start_rps_challenge():
	rps_challenger_name = player_name
	
func handle_rps_choice(choice: String):
	if player_rps_choice != "":
		return
	player_rps_choice = choice
	if rps_challenger_name == "":
		rps_challenger_name = player_name
	rpc("receive_rps_choice", choice, rps_challenger_name)
	if opponent_rps_choice != "":
		determine_rps_winner()

@rpc("any_peer", "reliable")
func receive_rps_choice(opponent_choice: String, challenger_name: String):
	if opponent_rps_choice != "":
		return
	opponent_rps_choice = opponent_choice
	rps_challenger_name = challenger_name
	if player_rps_choice != "":
		determine_rps_winner()
	else:
		add_message("System", rps_challenger_name + " challenged you to RPS")

func determine_rps_winner():
	var result_message: String = ""
	if player_rps_choice == opponent_rps_choice:
		result_message = "TIE"
	elif (player_rps_choice == "Rock" and opponent_rps_choice == "Scissors") or \
		 (player_rps_choice == "Paper" and opponent_rps_choice == "Rock") or \
		 (player_rps_choice == "Scissors" and opponent_rps_choice == "Paper"):
		result_message = player_name + " WON"
	else:
		result_message = opponent_name + " WON"
	add_message("System", "RPS Result: " + result_message)
	reset_rps_choices()
	rpc("reset_rps_choices")

@rpc("any_peer", "reliable") 
func reset_rps_choices():
	player_rps_choice = ""
	opponent_rps_choice = ""
	rps_challenger_name = ""
