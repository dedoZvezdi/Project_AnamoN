extends Control

var card_width := 74.0
var card_height := 104.0
var item_size := Vector2(card_width, card_height)
var columns := 5
var h_spacing := 4.0
var v_spacing := 4.0
var margin_left := 2.0
var data := []
var pool := []

@onready var scroll_container: ScrollContainer = get_parent()

func set_data(new_data: Array):
	data = new_data
	var total_rows = ceil(data.size() / float(columns))
	custom_minimum_size.y = total_rows * (item_size.y + v_spacing)
	_update_pool_size()
	_update_visible_items()

func _update_pool_size():
	if not scroll_container:
		return
	var visible_rows = ceil(scroll_container.size.y / (item_size.y + v_spacing)) + 2
	var required_pool = int(visible_rows) * columns
	while pool.size() < required_pool:
		var card = preload("res://Scenes/CardDisplay.tscn").instantiate()
		card.set_meta("zone", "deck_building_results")
		add_child(card)
		card.custom_minimum_size = Vector2(card_width, card_height)
		card.size = Vector2(card_width, card_height)
		var t_rect = card.get_node_or_null("TextureRect")
		if t_rect:
			t_rect.scale = Vector2(1, 1)
			t_rect.custom_minimum_size = Vector2(card_width, card_height)
			t_rect.size = Vector2(card_width, card_height)
			t_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			t_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pool.append(card)

func _process(_delta):
	_update_visible_items()

func _update_visible_items():
	if data.is_empty():
		for card in pool:
			card.hide()
		return
	var scroll_y = scroll_container.scroll_vertical
	var start_row = int(scroll_y / (item_size.y + v_spacing))
	var start_index = start_row * columns
	for data_index in range(start_index, start_index + pool.size()):
		var card = pool[data_index % pool.size()]
		if data_index < data.size() and data_index >= 0:
			var slug = data[data_index]
			var row = int(data_index / float(columns))
			var col = data_index % columns
			card.position = Vector2(
				margin_left + col * (item_size.x + h_spacing),
				row * (item_size.y + v_spacing))
			if not card.has_meta("slug") or card.get_meta("slug") != slug:
				card.set_meta("slug", slug)
				card.set_meta("uuid", "")
				if "card_slug" in card:
					card.card_slug = slug
				var tex_rect = card.get_node_or_null("TextureRect")
				if tex_rect:
					var image_path = "res://Assets/Grand Archive/Card Images/" + slug + ".png"
					if ResourceLoader.exists(image_path) or FileAccess.file_exists(image_path) or FileAccess.file_exists(image_path + ".import"):
						tex_rect.texture = load(image_path)
					else:
						tex_rect.texture = load("res://Assets/Textures/ga_back.png")
			card.show()
		else:
			card.hide()
