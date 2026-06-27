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
var _back_texture: Texture2D = null
var target_scroll_y: float = 0.0
var current_scroll_y: float = 0.0
var velocity: float = 0.0
var friction := 0.85

static var _texture_cache := {}
static var _loading_slugs := {}

@export var smooth_scroll_speed := 5.0
@export var scroll_step := 150.0

@onready var scroll_container: ScrollContainer = get_parent()

func _ready():
	_back_texture = _get_back_texture()
	if scroll_container:
		target_scroll_y = scroll_container.scroll_vertical
		current_scroll_y = scroll_container.scroll_vertical
		scroll_container.gui_input.connect(_on_scroll_container_gui_input)
		gui_input.connect(_on_grid_gui_input)

func _get_back_texture() -> Texture2D:
	if _texture_cache.has("__back"):
		return _texture_cache["__back"]
	var back_path = "res://Assets/Textures/ga_back.png"
	var texture = load(back_path)
	_texture_cache["__back"] = texture
	return texture

func _on_scroll_container_gui_input(event: InputEvent):
	_handle_scroll_input(event)

func _on_grid_gui_input(event: InputEvent):
	_handle_scroll_input(event)

func _handle_scroll_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			velocity -= scroll_step * 0.4
			accept_event()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			velocity += scroll_step * 0.4
			accept_event()

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
		var texture_rect = card.get_node_or_null("TextureRect")
		if texture_rect:
			texture_rect.scale = Vector2(1, 1)
			texture_rect.custom_minimum_size = Vector2(card_width, card_height)
			texture_rect.size = Vector2(card_width, card_height)
			texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pool.append(card)

func _request_texture(slug: String):
	if _texture_cache.has(slug):
		return
	if _loading_slugs.has(slug):
		return
	var image_path = "res://Assets/Grand Archive/Card Images/" + slug + ".png"
	if ResourceLoader.exists(image_path):
		ResourceLoader.load_threaded_request(image_path)
		_loading_slugs[slug] = image_path
	else:
		_texture_cache[slug] = _back_texture

func _check_pending_textures():
	if _loading_slugs.is_empty():
		return
	var done := []
	for slug in _loading_slugs:
		var path = _loading_slugs[slug]
		var status = ResourceLoader.load_threaded_get_status(path)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var tex = ResourceLoader.load_threaded_get(path)
			_texture_cache[slug] = tex
			done.append(slug)
		elif status == ResourceLoader.THREAD_LOAD_FAILED:
			_texture_cache[slug] = _back_texture
			done.append(slug)
	for slug in done:
		_loading_slugs.erase(slug)

func _get_cached_texture(slug: String) -> Texture2D:
	if _texture_cache.has(slug):
		return _texture_cache[slug]
	return _back_texture

func _process(delta):
	if scroll_container:
		var actual_scroll = scroll_container.scroll_vertical
		if abs(actual_scroll - int(round(current_scroll_y))) > 5:
			current_scroll_y = actual_scroll
			target_scroll_y = actual_scroll
			velocity = 0.0
		else:
			if abs(velocity) > 0.5:
				velocity *= friction
				target_scroll_y += velocity * delta * 60.0
				var max_scroll = scroll_container.get_v_scroll_bar().max_value - scroll_container.size.y
				target_scroll_y = clamp(target_scroll_y, 0.0, max(0.0, max_scroll))
			else:
				velocity = 0.0
			current_scroll_y = lerp(current_scroll_y, target_scroll_y, 1.0 - exp(-smooth_scroll_speed * delta))
			scroll_container.scroll_vertical = int(round(current_scroll_y))
	_check_pending_textures()
	_update_visible_items()

func _update_visible_items():
	if data.is_empty():
		for card in pool:
			card.hide()
		return
	var scroll_y = scroll_container.scroll_vertical
	var start_row = int(scroll_y / (item_size.y + v_spacing))
	var start_index = start_row * columns
	for i in range(pool.size()):
		var data_index = start_index + i
		var card = pool[i]
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
				_request_texture(slug)
				var texture_rect = card.get_node_or_null("TextureRect")
				if texture_rect:
					texture_rect.texture = _get_cached_texture(slug)
			else:
				var texture_rect = card.get_node_or_null("TextureRect")
				if texture_rect and texture_rect.texture == _back_texture:
					var real_tex = _get_cached_texture(slug)
					if real_tex != _back_texture:
						texture_rect.texture = real_tex
			card.show()
		else:
			card.hide()

func _can_drop_data(_pos, drop_data_value) -> bool:
	if drop_data_value is Dictionary and drop_data_value.get("type") == "deck_builder":
		var source_zone = drop_data_value.get("zone", "")
		return source_zone != "deck_building_results"
	return false

func _drop_data(_pos, drop_data_value):
	if drop_data_value is Dictionary and drop_data_value.get("type") == "deck_builder":
		var slug = drop_data_value.get("slug", "")
		var source_zone = drop_data_value.get("zone", "")
		if source_zone != "deck_building_results":
			var deck_building = get_tree().current_scene
			if deck_building and deck_building.has_method("handle_drop_on_results"):
				deck_building.handle_drop_on_results(slug, source_zone, null)
