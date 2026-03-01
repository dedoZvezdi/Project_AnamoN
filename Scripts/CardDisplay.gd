extends Control

var card_slug = ""
var card_image_path = ""
var zone = ""
var is_holding = false
var dragged_card = null
var hold_timer = 0.0
var is_holding_left = false
var progress_bar: TextureProgressBar

signal request_popup_menu(slug, uuid)
signal card_drag_started(card_display)
signal card_held(slug, uuid)

const HOLD_DURATION = 0.8
const CARD_DISPLAY_SIZE = Vector2(98, 98)

@onready var texture_rect = $TextureRect

func _ready():
	add_to_group("card_displays")
	if has_meta("zone"):
		zone = get_meta("zone")
	else:
		zone = ""
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	custom_minimum_size = CARD_DISPLAY_SIZE
	texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	texture_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	texture_rect.custom_minimum_size = CARD_DISPLAY_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if has_meta("slug"):
		card_slug = get_meta("slug")
	if card_slug != "":
		card_image_path = "res://Assets/Grand Archive/Card Images/" + card_slug + ".png"
	if card_image_path != "" and ResourceLoader.exists(card_image_path):
		texture_rect.texture = load(card_image_path)
		texture_rect.size = CARD_DISPLAY_SIZE
	if has_meta("deck_z_index"):
		self.z_index = get_meta("deck_z_index")
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_gui_input)
	_setup_progress_bar()

func _setup_progress_bar():
	progress_bar = TextureProgressBar.new()
	progress_bar.fill_mode = TextureProgressBar.FILL_CLOCKWISE
	progress_bar.step = 0.01
	progress_bar.min_value = 0
	progress_bar.max_value = 1.0
	progress_bar.value = 0
	progress_bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	progress_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	progress_bar.visible = false
	progress_bar.scale = Vector2(0.8, 0.8)
	progress_bar.position = (CARD_DISPLAY_SIZE - (Vector2(128, 128) * 0.8)) / 2
	var img = Image.create(128, 128, false, Image.FORMAT_RGBA8)
	for y in range(128):
		for x in range(128):
			var dist = Vector2(x-64, y-64).length()
			if dist > 25 and dist < 30:
				img.set_pixel(x, y, Color(1, 1, 1, 0.8))
	var tex = ImageTexture.create_from_image(img)
	progress_bar.texture_progress = tex
	progress_bar.modulate = Color(0.2, 0.8, 1.0)
	add_child(progress_bar)

func _process(delta):
	if is_holding_left:
		hold_timer += delta
		if progress_bar:
			progress_bar.value = hold_timer / HOLD_DURATION
			progress_bar.visible = true
		if hold_timer >= HOLD_DURATION:
			var current_uuid = get_meta("uuid") if has_meta("uuid") else ""
			emit_signal("card_held", card_slug, current_uuid)
			_reset_hold()
	else:
		if progress_bar and progress_bar.visible:
			progress_bar.visible = false

func _reset_hold():
	is_holding_left = false
	hold_timer = 0.0
	if progress_bar:
		progress_bar.value = 0
		progress_bar.visible = false

func _on_mouse_entered():
	self.scale = Vector2(1, 1)
	self.z_index = 100
	if _is_face_down_opponent_banish():
		return
	var card_info_node = get_tree().get_current_scene().get_node_or_null("CardInformation")
	if not card_info_node:
		card_info_node = get_tree().get_current_scene().get_node_or_null("PlayerField/CardInformation")
	if card_info_node and card_info_node.has_method("show_card_info"):
		card_info_node.show_card_info(card_slug)

func _on_mouse_exited():
	self.scale = Vector2(1, 1)
	_reset_hold()
	if has_meta("deck_z_index"):
		self.z_index = get_meta("deck_z_index")
	else:
		self.z_index = 0

func _is_face_down_opponent_banish() -> bool:
	if texture_rect and texture_rect.texture:
		var texture_path = texture_rect.texture.resource_path
		if "ga_back.png" in texture_path:
			var parent = get_parent()
			while parent:
				if parent.name == "GridContainer":
					var grandparent = parent.get_parent()
					if grandparent and grandparent.name == "ScrollContainer":
						var great_grandparent = grandparent.get_parent()
						if great_grandparent and great_grandparent.name == "BanishViewWindow":
							var banish_owner = great_grandparent.get_parent()
							if banish_owner and banish_owner.name.contains("Opponent"):
								return true
					break
				parent = parent.get_parent()
	return false

func _is_in_opponent_zone() -> bool:
	var parent = get_parent()
	while parent:
		if parent.name == "GridContainer":
			var grandparent = parent.get_parent()
			if grandparent and grandparent.name == "ScrollContainer":
				var great_grandparent = grandparent.get_parent()
				if great_grandparent:
					if great_grandparent.name == "GraveyardViewWindow":
						var grave_owner = great_grandparent.get_parent()
						if grave_owner and grave_owner.name.contains("Opponent"):
							return true
					elif great_grandparent.name == "BanishViewWindow":
						var banish_owner = great_grandparent.get_parent()
						if banish_owner and banish_owner.name.contains("Opponent"):
							return true
			break
		parent = parent.get_parent()
	return false

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if zone == "lineage":
			return
		if zone in ["graveyard", "banish", "ga_deck", "mat_deck", "logo_tokens", "logo_mastery", "lineage"]:
			var current_uuid = get_meta("uuid") if has_meta("uuid") else ""
			emit_signal("request_popup_menu", card_slug, current_uuid)
			accept_event()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if zone == "lineage":
			if event.pressed:
				is_holding_left = true
				hold_timer = 0.0
				accept_event()
			else:
				_reset_hold()
				accept_event()
			return	
		if event.pressed:
			if _is_in_opponent_zone():
				var is_marked = get_meta("is_marked") if has_meta("is_marked") else false
				is_marked = !is_marked
				set_meta("is_marked", is_marked)
				if is_marked:
					modulate = Color(1.5, 0.5, 0.5, 0.9)
				else:
					modulate = Color(1, 1, 1)
				var uuid = get_meta("uuid") if has_meta("uuid") else ""
				var card_manager = get_tree().current_scene.get_node("PlayerField/CardManager")
				if card_manager and card_manager.has_method("request_mark_opponent_card"):
					card_manager.request_mark_opponent_card(zone, uuid, is_marked)
				accept_event()
				return
			if not is_holding:
				start_drag_from_grid()
				accept_event()
		elif not event.pressed and is_holding:
			finish_drag_from_grid()
			accept_event()

func start_drag_from_grid():
	if is_holding:
		return
	if zone == "lineage" or zone == "lineage_opponent":
		return
	if _is_in_opponent_zone():
		return
	var real_card = create_real_card_for_drag()
	if real_card:
		is_holding = true
		dragged_card = real_card
		var card_manager = get_tree().current_scene.get_node("PlayerField/CardManager")
		if card_manager and card_manager.has_method("start_drag"):
			card_manager.start_drag(real_card)
			card_manager.set_dragged_from_grid_info(card_slug, zone, self)
			if zone != "logo_tokens" and zone != "logo_mastery":
				if zone == "lineage":
					var owner_node = get_parent()
					while owner_node != null and not owner_node.has_method("remove_from_lineage_by_uuid"):
						owner_node = owner_node.get_parent()
					if owner_node and owner_node.has_method("remove_from_lineage_by_uuid"):
						var uuid = get_meta("uuid") if has_meta("uuid") else ""
						owner_node.remove_from_lineage_by_uuid(uuid)
				var source_node = null
				var grid_index = -1
				var face_down = false
				var left_uuid = ""
				var right_uuid = ""
				var parent_node = get_parent()
				while parent_node:
					if parent_node.is_in_group("single_card_slots") or parent_node.is_in_group("rotated_slots") or parent_node.is_in_group("mat_deck_zones"):
						source_node = parent_node
						break
					parent_node = parent_node.get_parent()
				var parent_grid = get_parent()
				if parent_grid:
					grid_index = get_index()
					if grid_index > 0:
						var left_sibling = parent_grid.get_child(grid_index - 1)
						if left_sibling and left_sibling.has_meta("uuid"):
							left_uuid = left_sibling.get_meta("uuid")
					if grid_index < parent_grid.get_child_count() - 1:
						var right_sibling = parent_grid.get_child(grid_index + 1)
						if right_sibling and right_sibling.has_meta("uuid"):
							right_uuid = right_sibling.get_meta("uuid")
				if texture_rect and texture_rect.texture:
					face_down = "ga_back.png" in texture_rect.texture.resource_path
				card_manager.set_dragged_from_grid_info(card_slug, zone, self, grid_index, source_node, face_down, left_uuid, right_uuid)
				if zone != "logo_tokens" and zone != "logo_mastery":
					if zone == "lineage":
						pass
					update_grid_immediately()
					emit_signal("card_drag_started", self)
					card_image_path = ""
					texture_rect.texture = null
					custom_minimum_size = Vector2.ZERO

func finish_drag_from_grid():
	if not is_holding or not dragged_card:
		return
	var card_manager = get_tree().current_scene.get_node("PlayerField/CardManager")
	if card_manager and card_manager.has_method("finish_drag"):
		card_manager.finish_drag()
	is_holding = false
	dragged_card = null

func update_grid_immediately():
	var parent_window = get_parent().get_parent()
	if parent_window and parent_window.has_method("update_deck_view"):
		parent_window.update_deck_view()

func get_drag_data(_pos):
	if zone == "lineage" or zone == "lineage_opponent":
		return null
	var real_card = create_real_card_for_drag()
	if real_card:
		set_drag_preview(real_card)
		return {"type": "real_card", "card": real_card, "original_slug": card_slug, "zone": zone}
	else:
		set_drag_preview(texture_rect.duplicate())
		return card_slug

func create_real_card_for_drag():
	if card_slug == "":
		return null
	var card_scene = load("res://Scenes/Card.tscn")
	var real_card = card_scene.instantiate()
	if has_meta("uuid"):
		real_card.uuid = get_meta("uuid")
	real_card.set_meta("slug", card_slug)
	real_card.set_meta("is_dragged_from_grid", true)
	real_card.set_meta("original_zone", zone)
	if has_meta("uuid"):
		real_card.set_meta("uuid", get_meta("uuid"))
	card_image_path = "res://Assets/Grand Archive/Card Images/" + card_slug + ".png"
	if ResourceLoader.exists(card_image_path):
		var card_image = real_card.get_node("CardImage")
		var card_image_back = real_card.get_node("CardImageBack")
		card_image.texture = load(card_image_path)
		card_image.visible = true
		card_image_back.visible = false
		card_image.z_index = 0
	var card_manager = get_tree().current_scene.get_node("PlayerField/CardManager")
	card_manager.add_child(real_card)
	real_card.global_position = get_global_mouse_position()
	real_card.z_index = 1000
	real_card.add_to_group("cards")
	if card_manager.has_method("connect_card_signals"):
		card_manager.connect_card_signals(real_card)
	return real_card

func can_drop_data(_pos, data):
	return typeof(data) == TYPE_STRING and data != card_slug

func drop_data(_pos, data):
	card_slug = data
	card_image_path = "res://Assets/Grand Archive/Card Images/" + card_slug + ".png"
	if ResourceLoader.exists(card_image_path):
		texture_rect.texture = load(card_image_path)
