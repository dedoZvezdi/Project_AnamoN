extends Control

@export var grid_type: String = "main_deck"
@export var max_columns: int = 15
@export var grid_pixel_width: float = 1023.0
@export var has_scrollbar_padding: bool = true
@export var smooth_scroll_speed := 15.0
@export var scroll_step := 80.0

const CARD_WIDTH := 74.0
const CARD_HEIGHT := 104.0
const MARGIN_LEFT := 2.0
const MARGIN_RIGHT_SCROLL := 8.0
const MARGIN_RIGHT_NO_SCROLL := 2.0
const V_GAP := 2.0

static var _texture_cache := {}
static var _loading_slugs := {}

var _back_texture: Texture2D = null
var target_scroll_y: float = 0.0
var current_scroll_y: float = 0.0
var scroll_container: ScrollContainer = null
var card_slugs: Array = []
var card_displays: Array = []
var _phantom_index: int = -1
var _is_drag_hovering: bool = false
var _card_tweens: Dictionary = {}
var _illegal_highlight_keys: Dictionary = {}

func _ready():
	_back_texture = _get_back_texture()
	scroll_container = get_parent() as ScrollContainer
	if scroll_container:
		target_scroll_y = scroll_container.scroll_vertical
		current_scroll_y = scroll_container.scroll_vertical
		scroll_container.gui_input.connect(_on_scroll_container_gui_input)
		gui_input.connect(_on_grid_gui_input)
	_rebuild_grid()

func _on_scroll_container_gui_input(event: InputEvent):
	_handle_scroll_input(event)

func _on_grid_gui_input(event: InputEvent):
	_handle_scroll_input(event)

func _handle_scroll_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if event.pressed:
				_adjust_target_scroll(-scroll_step)
				accept_event()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if event.pressed:
				_adjust_target_scroll(scroll_step)
				accept_event()

func _adjust_target_scroll(amount: float):
	if not scroll_container:
		return
	var max_scroll = scroll_container.get_v_scroll_bar().max_value - scroll_container.size.y
	if abs(current_scroll_y - scroll_container.scroll_vertical) > 2.0:
		current_scroll_y = scroll_container.scroll_vertical
		target_scroll_y = scroll_container.scroll_vertical
	target_scroll_y = clamp(target_scroll_y + amount, 0, max(0, max_scroll))

func _get_back_texture() -> Texture2D:
	if _texture_cache.has("__back"):
		return _texture_cache["__back"]
	var back_path = "res://Assets/Textures/ga_back.png"
	var texture = load(back_path)
	_texture_cache["__back"] = texture
	return texture

func _request_texture(slug: String):
	if _texture_cache.has(slug):
		return
	if _loading_slugs.has(slug):
		return
	var image_path = "res://Assets/Grand Archive/Card Images/" + slug + ".png"
	if ResourceLoader.exists(image_path) or FileAccess.file_exists(image_path + ".import"):
		ResourceLoader.load_threaded_request(image_path)
		_loading_slugs[slug] = image_path
	else:
		_texture_cache[slug] = _get_back_texture()

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
		elif status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			_texture_cache[slug] = _get_back_texture()
			done.append(slug)
	for slug in done:
		_loading_slugs.erase(slug)

func _apply_loaded_textures():
	for card in card_displays:
		if is_instance_valid(card) and card.visible:
			var texture_rect = card.get_node_or_null("TextureRect")
			if texture_rect and texture_rect.texture == _back_texture:
				var slug = card.get_meta("slug") if card.has_meta("slug") else ""
				if slug != "" and _texture_cache.has(slug):
					var tex = _texture_cache[slug]
					if tex != _back_texture:
						texture_rect.texture = tex

func _get_cached_texture(slug: String) -> Texture2D:
	if _texture_cache.has(slug):
		return _texture_cache[slug]
	_request_texture(slug)
	return _get_back_texture()

func _process(delta):
	_check_pending_textures()
	_apply_loaded_textures()
	if scroll_container:
		var actual_scroll = scroll_container.scroll_vertical
		var last_set_scroll = int(round(current_scroll_y))
		if abs(actual_scroll - last_set_scroll) > 5:
			current_scroll_y = actual_scroll
			target_scroll_y = actual_scroll
		else:
			if abs(current_scroll_y - target_scroll_y) > 0.05:
				current_scroll_y = lerp(current_scroll_y, target_scroll_y, 1.0 - exp(-smooth_scroll_speed * delta))
				scroll_container.scroll_vertical = int(round(current_scroll_y))
			else:
				current_scroll_y = target_scroll_y
				scroll_container.scroll_vertical = int(round(current_scroll_y))
	if _is_drag_hovering:
		var local_mouse = get_global_transform().affine_inverse() * get_global_mouse_position()
		var inside_grid = Rect2(Vector2.ZERO, size).has_point(local_mouse)
		var inside_scroll = true
		if scroll_container:
			var scroll_mouse = scroll_container.get_global_transform().affine_inverse() * get_global_mouse_position()
			inside_scroll = Rect2(Vector2.ZERO, scroll_container.size).has_point(scroll_mouse)
		if not (inside_grid and inside_scroll):
			clear_phantom()

func get_usable_width() -> float:
	var right_margin = MARGIN_RIGHT_SCROLL if has_scrollbar_padding else MARGIN_RIGHT_NO_SCROLL
	return grid_pixel_width - MARGIN_LEFT - right_margin

func get_h_step() -> float:
	if max_columns <= 1:
		return CARD_WIDTH
	var usable = get_usable_width()
	return (usable - CARD_WIDTH) / (max_columns - 1)

func add_card(slug: String):
	card_slugs.append(slug)
	_rebuild_grid()

func insert_card(slug: String, index: int):
	index = clampi(index, 0, card_slugs.size())
	card_slugs.insert(index, slug)
	_rebuild_grid()

func remove_card_at(index: int) -> String:
	if index >= 0 and index < card_slugs.size():
		var slug = card_slugs[index]
		card_slugs.remove_at(index)
		_rebuild_grid()
		return slug
	return ""

func remove_card(slug: String) -> bool:
	var idx = card_slugs.find(slug)
	if idx >= 0:
		card_slugs.remove_at(idx)
		_rebuild_grid()
		return true
	return false

func clear_cards():
	card_slugs.clear()
	_rebuild_grid()

func shuffle_cards():
	if card_slugs.is_empty():
		return
	card_slugs.shuffle()
	_rebuild_grid()

func _reorder_existing_cards():
	if card_displays.size() != card_slugs.count(func(s): return s != ""):
		_rebuild_grid()
		return
	var valid_slugs = []
	var valid_indices = []
	for i in range(card_slugs.size()):
		if card_slugs[i] != "":
			valid_slugs.append(card_slugs[i])
			valid_indices.append(i)
	for i in range(card_displays.size()):
		if i >= valid_slugs.size():
			card_displays[i].hide()
			continue
		var card = card_displays[i]
		var slug = valid_slugs[i]
		var original_index = valid_indices[i]
		card.set_meta("deck_grid_index", original_index)
		if "card_slug" in card:
			card.card_slug = slug
		if "zone" in card:
			card.zone = grid_type
		var texture_rect = card.get_node_or_null("TextureRect")
		if texture_rect and texture_rect.texture == null:
			texture_rect.texture = _get_cached_texture(slug)
	_update_card_positions(true)
	_apply_stored_illegal_highlights()

func sort_cards_by_name(get_sort_name: Callable):
	if card_slugs.size() <= 1:
		return
	var sort_keys := {}
	for slug in card_slugs:
		if not sort_keys.has(slug):
			sort_keys[slug] = get_sort_name.call(slug)
	card_slugs.sort_custom(func(a: String, b: String) -> bool:
		var name_a: String = sort_keys[a]
		var name_b: String = sort_keys[b]
		if name_a == name_b:
			return a < b
		return name_a < name_b)
	_reorder_existing_cards()

func sort_cards_custom(sort_func: Callable):
	if card_slugs.size() <= 1:
		return
	card_slugs.sort_custom(sort_func)
	_reorder_existing_cards()

func apply_sorted_slugs(new_slugs: Array):
	if new_slugs.size() != card_slugs.size():
		return
	card_slugs = new_slugs.duplicate()
	_reorder_existing_cards()

func get_card_count() -> int:
	return card_slugs.size()

func set_card_at(index: int, slug: String):
	if index >= 0 and index < card_slugs.size():
		card_slugs[index] = slug
		_rebuild_grid()

func get_card_at(index: int) -> String:
	if index >= 0 and index < card_slugs.size():
		return card_slugs[index]
	return ""

func _rebuild_grid():
	if scroll_container:
		target_scroll_y = scroll_container.scroll_vertical
		current_scroll_y = scroll_container.scroll_vertical
	for card in _card_tweens:
		var tween = _card_tweens[card]
		if tween and tween.is_valid():
			tween.kill()
	_card_tweens.clear()
	var scroll_parent = get_parent() as ScrollContainer
	var min_h = CARD_HEIGHT
	if scroll_parent:
		min_h = max(scroll_parent.size.y - 2, CARD_HEIGHT)
	var valid_slugs = []
	var valid_indices = []
	for i in range(card_slugs.size()):
		var slug = card_slugs[i]
		if slug != "":
			valid_slugs.append(slug)
			valid_indices.append(i)
	var required_count = valid_slugs.size()
	if required_count == 0:
		custom_minimum_size.y = min_h
		for card in card_displays:
			card.hide()
		return
	while card_displays.size() < required_count:
		var card = preload("res://Scenes/CardDisplay.tscn").instantiate()
		add_child(card)
		card_displays.append(card)
	for i in range(card_displays.size()):
		var card = card_displays[i]
		if i < required_count:
			var slug = valid_slugs[i]
			var original_index = valid_indices[i]
			card.set_meta("slug", slug)
			if "card_slug" in card:
				card.card_slug = slug
			card.set_meta("zone", grid_type)
			if "zone" in card:
				card.zone = grid_type
			card.set_meta("deck_grid_index", original_index)
			card.custom_minimum_size = Vector2(CARD_WIDTH, CARD_HEIGHT)
			card.size = Vector2(CARD_WIDTH, CARD_HEIGHT)
			var texture_rect = card.get_node_or_null("TextureRect")
			if texture_rect:
				texture_rect.scale = Vector2(1, 1)
				texture_rect.anchor_left = 0
				texture_rect.anchor_top = 0
				texture_rect.anchor_right = 0
				texture_rect.anchor_bottom = 0
				texture_rect.offset_left = 0
				texture_rect.offset_top = 0
				texture_rect.offset_right = CARD_WIDTH
				texture_rect.offset_bottom = CARD_HEIGHT
				texture_rect.custom_minimum_size = Vector2.ZERO
				texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				texture_rect.texture = _get_cached_texture(slug)
			card.show()
		else:
			card.hide()
	_update_card_positions(false)
	_apply_stored_illegal_highlights()

func set_illegal_highlight_keys(keys: Dictionary) -> void:
	_illegal_highlight_keys = keys
	_apply_stored_illegal_highlights()

func apply_illegal_highlights(illegal_keys: Dictionary) -> void:
	set_illegal_highlight_keys(illegal_keys)

func _apply_stored_illegal_highlights() -> void:
	for i in range(card_displays.size()):
		var card = card_displays[i]
		if not is_instance_valid(card) or not card.visible:
			continue
		var key = grid_type + ":" + str(i)
		if _illegal_highlight_keys.has(key):
			card.modulate = Color(1.5, 0.5, 0.5)
		else:
			card.modulate = Color(1, 1, 1)

func _update_card_positions(animated: bool):
	var scroll_parent = get_parent() as ScrollContainer
	var min_h = CARD_HEIGHT
	if scroll_parent:
		min_h = max(scroll_parent.size.y - 2, CARD_HEIGHT)
	var total_positions = card_slugs.size()
	if _phantom_index != -1:
		total_positions += 1
	var h_step = get_h_step()
	var total_rows = ceili(total_positions / float(max_columns))
	var row_height = CARD_HEIGHT + V_GAP
	var content_height = total_rows * row_height
	custom_minimum_size.y = max(content_height, min_h)
	for i in range(card_displays.size()):
		var card = card_displays[i]
		if not is_instance_valid(card) or not card.visible:
			continue
		var slot_index = card.get_meta("deck_grid_index") if card.has_meta("deck_grid_index") else i
		var virtual_index = slot_index
		if _phantom_index != -1 and slot_index >= _phantom_index:
			virtual_index += 1
		var row = int(virtual_index / float(max_columns))
		var col = virtual_index % max_columns
		var target_pos = Vector2(MARGIN_LEFT + col * h_step, row * row_height)
		card.z_index = col
		if animated:
			if _card_tweens.has(card):
				var old_tween = _card_tweens[card]
				if old_tween and old_tween.is_valid():
					old_tween.kill()
			var tween = create_tween()
			_card_tweens[card] = tween
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(card, "position", target_pos, 0.15)
		else:
			if _card_tweens.has(card):
				var old_tween = _card_tweens[card]
				if old_tween and old_tween.is_valid():
					old_tween.kill()
				_card_tweens.erase(card)
			card.position = target_pos

func _calc_phantom_index(mouse_pos: Vector2) -> int:
	var h_step = get_h_step()
	var row_height = CARD_HEIGHT + V_GAP
	var row = int(mouse_pos.y / row_height)
	if row < 0:
		row = 0
	var col = int(round((mouse_pos.x - MARGIN_LEFT) / h_step))
	if col < 0:
		col = 0
	elif col > max_columns:
		col = max_columns
	var target_index = row * max_columns + col
	return clamp(target_index, 0, card_slugs.size())

func _find_deck_building():
	var node = self
	while node:
		if node.get_script() and node.get_script().resource_path.ends_with("Deck_Building.gd"):
			return node
		node = node.get_parent()
	return null

func clear_phantom():
	if _phantom_index != -1 or _is_drag_hovering:
		_phantom_index = -1
		_is_drag_hovering = false
		_update_card_positions(true)

func _can_drop_data(pos, data) -> bool:
	if data is Dictionary and data.get("type") == "deck_builder":
		var slug = data.get("slug", "")
		var source_zone = data.get("zone", "")
		var deck_building = _find_deck_building()
		if deck_building and deck_building.has_method("can_accept_in_grid"):
			var can_accept = deck_building.can_accept_in_grid(slug, source_zone, grid_type)
			if can_accept:
				_is_drag_hovering = true
				if grid_type != "pantheon_deck":
					var new_phantom = _calc_phantom_index(pos)
					if new_phantom != _phantom_index:
						_phantom_index = new_phantom
						_update_card_positions(true)
				return true
	return false

func _drop_data(_pos, data):
	if data is Dictionary and data.get("type") == "deck_builder":
		var slug = data.get("slug", "")
		var source_zone = data.get("zone", "")
		var deck_building = _find_deck_building()
		if deck_building and deck_building.has_method("handle_drop_on_grid"):
			var drop_idx = _phantom_index
			_phantom_index = -1
			_is_drag_hovering = false
			deck_building.handle_drop_on_grid(slug, source_zone, grid_type, drop_idx)

func _notification(noti):
	if noti == NOTIFICATION_DRAG_END:
		clear_phantom()

func _exit_tree():
	for card in _card_tweens:
		var tween = _card_tweens[card]
		if tween and tween.is_valid():
			tween.kill()
	_card_tweens.clear()
