extends Control

@onready var exit_button = $SearchPanel/ExitButton
@onready var search_button = $SearchPanel/SearchButton
@onready var results_grid = $ResultsArea/ResultsContent/ScrollContainer/GridContainer
@onready var card_info = $CardInformation

func _ready():
	exit_button.pressed.connect(_on_exit_pressed)
	search_button.pressed.connect(_on_search_pressed)

func _on_exit_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _on_search_pressed():
	var db = card_info.card_database_reference
	if not db or not db.cards_db:
		return
	var slugs_to_show = []
	for key in db.cards_db:
		var card_data = db.cards_db[key]
		if card_data.has("legalities") and card_data.has("types"):
			var is_valid = true
			if card_data.has("types"):
				for t in card_data["types"]:
					var t_upper = str(t).to_upper()
					if t_upper == "TOKEN" or t_upper == "MASTERY" or t_upper == "STATUS":
						is_valid = false
						break
			if card_data.has("subtypes"):
				for t in card_data["subtypes"]:
					var t_upper = str(t).to_upper()
					if t_upper == "TOKEN" or t_upper == "MASTERY" or t_upper == "STATUS":
						is_valid = false
						break
			if card_data.has("classes"):
				for t in card_data["classes"]:
					var t_upper = str(t).to_upper()
					if t_upper == "TOKEN" or t_upper == "MASTERY" or t_upper == "STATUS":
						is_valid = false
						break
			if is_valid and card_data.has("editions"):
				for edition in card_data["editions"]:
					var slug = edition["slug"]
					if not slugs_to_show.has(slug):
						slugs_to_show.append(slug)
	slugs_to_show.sort()
	var results_header_label = $ResultsArea/ResultsHeader/LabelLeft
	if results_header_label:
		results_header_label.text = "Results: " + str(slugs_to_show.size())
	if results_grid.has_method("set_data"):
		results_grid.set_data(slugs_to_show)
