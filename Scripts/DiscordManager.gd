extends Node

var presence : DiscordRichPresence

func _ready():
	presence = DiscordRichPresence.new()
	presence.app_id = "1542636641204838510"
	add_child(presence)
	presence.set_activity({
		"details": "Playing AnamoN",
		"large_image": "app_icon"})

func update_status(status_text: String):
	if presence:
		presence.set_activity({
			"details": status_text,
			"large_image": "app_icon"})
