extends Node

var presence : DiscordRichPresence

func _ready():
	presence = DiscordRichPresence.new()
	presence.app_id = "1542636641204838510"
	add_child(presence)
	presence.set_activity({
		"details": "Playing AnamoN",
		"state": "Building a Deck",
		"large_image": "app_icon"})

func update_status(new_details: String, new_state: String):
	if presence:
		presence.set_activity({
			"details": new_details,
			"state": new_state})
