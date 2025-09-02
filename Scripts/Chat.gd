extends Node2D

@onready var message: LineEdit = $Message
@onready var text_edit: TextEdit = $TextEdit
@onready var Send_edit: Button = $Send

var msg: String

func _ready():
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
		text_edit.text += "Player: " + msg + "\n"
		message.text = ""
		message.grab_focus()
		text_edit.scroll_vertical = text_edit.get_line_count()

func send_system_message(system_msg: String):
	text_edit.text += "System: " + system_msg + "\n"
	text_edit.scroll_vertical = text_edit.get_line_count()

func add_message(sender: String, content: String, color: Color = Color.WHITE):
	text_edit.text += sender + ": " + content + "\n"
	text_edit.scroll_vertical = text_edit.get_line_count()
