extends Node2D

signal hovered
signal hovered_off
signal visuals_changed

var hand_position
var mouse_inside = false
var card_information_reference = null
var runtime_modifiers = {"level": 0, "power": 0, "life": 0, "durability": 0}
var attached_markers := {}
var attached_counters := {}
var uuid = ""
var current_field = null
var is_revealed_by_opponent = false
var champion_lineage := []
var selected_lineage_card_slug: String = ""
var selected_lineage_card_uuid: String = ""
var original_owner_id = 0
var is_marked = false
var hold_timer = 0.0
var is_holding_left = false
var progress_bar: TextureProgressBar

const HOLD_DURATION = 0.8

@onready var lineage_view_window = $LineageViewWindow
@onready var grid_container = $LineageViewWindow/ScrollContainer/GridContainer

func _ready() -> void:
	if get_parent() and get_parent().has_method("connect_card_signals"):
		get_parent().connect_card_signals(self)
	find_card_information_reference()
	if has_node("Area2D"):
		var area = get_node("Area2D")
		if not area.mouse_entered.is_connected(_on_area_2d_mouse_entered):
			area.mouse_entered.connect(_on_area_2d_mouse_entered)
		if not area.mouse_exited.is_connected(_on_area_2d_mouse_exited):
			area.mouse_exited.connect(_on_area_2d_mouse_exited)
		if not area.input_event.is_connected(_on_area_2d_input_event):
			area.input_event.connect(_on_area_2d_input_event)
	if lineage_view_window:
		if not lineage_view_window.close_requested.is_connected(_on_lineage_window_close):
			lineage_view_window.close_requested.connect(_on_lineage_window_close)
	_setup_progress_bar()
	update_visuals_based_on_mark()

func find_card_information_reference():
	var root = get_tree().current_scene
	if root:
		card_information_reference = find_node_by_script(root, "res://Scripts/CardInformation.gd")

func find_node_by_script(node: Node, script_path: String) -> Node:
	if node.get_script() and node.get_script().resource_path == script_path:
		return node
	for child in node.get_children():
		var result = find_node_by_script(child, script_path)
		if result:
			return result
	return null

func _on_area_2d_mouse_entered() -> void:
	mouse_inside = true
	if not _is_card_in_restricted_zones():
		emit_signal("hovered", self)
		if card_information_reference:
			card_information_reference.show_card_preview(self)

func _on_area_2d_mouse_exited() -> void:
	mouse_inside = false
	_reset_hold()
	emit_signal("hovered_off", self)

func _is_card_in_restricted_zones() -> bool:
	if is_revealed_by_opponent:
		return false
	var opponent_hand_nodes = get_tree().get_nodes_in_group("opponent_hand")
	for hand_node in opponent_hand_nodes:
		if hand_node.has_method("has_cards"):
			if self in hand_node.opponent_hand:
				return true
	var opponent_memory_nodes = get_tree().get_nodes_in_group("memory_slots")
	for memory_node in opponent_memory_nodes:
		if memory_node.name.contains("Opponent"):
			if self in memory_node.cards_in_slot:
				if is_revealed_by_opponent:
					return false
				return true
	if is_revealed_by_opponent:
		return false
	return false

func is_in_main_field() -> bool:
	return not _is_card_in_restricted_zones()

func get_runtime_modifiers() -> Dictionary:
	return runtime_modifiers.duplicate()

func get_attached_markers() -> Dictionary:
	return attached_markers.duplicate()

func get_attached_counters() -> Dictionary:
	return attached_counters.duplicate()

func get_slug_from_card() -> String:
	if has_meta("slug"):
		return get_meta("slug")
	return ""

func get_uuid() -> String:
	if uuid != "":
		return uuid
	if has_meta("uuid"):
		return get_meta("uuid")
	return ""

func is_token() -> bool:
	var slug = get_slug_from_card()
	var logos = get_tree().get_nodes_in_group("logo")
	if logos.size() > 0:
		var logo = logos[0]
		if logo.has_method("get") and "token_slugs" in logo:
			return slug in logo.token_slugs
		elif logo.get("token_slugs") != null:
			return slug in logo.token_slugs
	return false

func is_mastery() -> bool:
	var slug = get_slug_from_card()
	var logos = get_tree().get_nodes_in_group("logo")
	if logos.size() > 0:
		var logo = logos[0]
		if logo.has_method("get") and "mastery_slugs" in logo:
			return slug in logo.mastery_slugs
		elif logo.get("mastery_slugs") != null:
			return slug in logo.mastery_slugs
	return false

func destroy_token():
	var slug = get_slug_from_card()
	var multiplayer_node = get_tree().get_root().get_node_or_null("Main")
	if multiplayer_node and multiplayer_node.has_method("rpc"):
		multiplayer_node.rpc("sync_destroy_token", multiplayer.get_unique_id(), uuid, slug)
	queue_free()

func destroy_mastery():
	var slug = get_slug_from_card()
	var multiplayer_node = get_tree().get_root().get_node_or_null("Main")
	if multiplayer_node and multiplayer_node.has_method("rpc"):
		multiplayer_node.rpc("sync_destroy_mastery", multiplayer.get_unique_id(), uuid, slug)
	queue_free()

func set_current_field(field):
	if is_token() and field and (field.is_in_group("player_hand") or field.is_in_group("opponent_hand") or field.is_in_group("single_card_slots") or field.is_in_group("rotated_slots") or field.is_in_group("memory_slots")):
		destroy_token()
		return
	if is_mastery() and field and (field.is_in_group("player_hand") or field.is_in_group("opponent_hand") or field.is_in_group("single_card_slots") or field.is_in_group("rotated_slots") or field.is_in_group("memory_slots")):
		destroy_mastery()
		return
	if is_marked and current_field != null and field != null:
		if current_field != field:
			set_marked(false)
	current_field = field

func set_opponent_reveal_status(revealed: bool, skip_animation: bool = false):
	is_revealed_by_opponent = revealed
	if mouse_inside:
		if revealed:
			if not _is_card_in_restricted_zones():
				emit_signal("hovered", self)
				if card_information_reference:
					card_information_reference.show_card_preview(self)
		else:
			emit_signal("hovered_off", self)
	var parent_node = get_parent()
	if parent_node and parent_node.has_method("enforce_z_ordering"):
		parent_node.enforce_z_ordering()
	var front = get_node_or_null("CardImage")
	var back = get_node_or_null("CardImageBack")
	if not front or not back:
		if revealed:
			if front: front.visible = true
			if back: back.visible = false
		else:
			if front: front.visible = false
			if back: back.visible = true
		return
	var is_already_revealed = front.visible and not back.visible
	var is_already_hidden = not front.visible and back.visible
	if revealed and is_already_revealed:
		return
	if not revealed and is_already_hidden:
		return
	if skip_animation:
		if revealed:
			front.visible = true
			back.visible = false
			back.z_index = -1
			front.z_index = 0
		else:
			front.visible = false
			back.visible = true
			back.z_index = 0
			front.z_index = -1
		emit_signal("visuals_changed")
		return
	var anim_player = get_node_or_null("AnimationPlayer")
	if anim_player and anim_player.has_animation("card_flip"):
		front.visible = true
		back.visible = true
		if revealed:
			back.z_index = 0
			front.z_index = -1
		else:
			front.z_index = 0
			back.z_index = -1
		anim_player.play("card_flip")
		var timer = get_tree().create_timer(0.1)
		timer.timeout.connect(func():
			if revealed:
				front.visible = true
				back.visible = false
			else:
				front.visible = false
				back.visible = true
			emit_signal("visuals_changed"))
	else:
		if revealed:
			front.visible = true
			back.visible = false
		else:
			front.visible = false
			back.visible = true
		emit_signal("visuals_changed")

func remote_transform(new_slug: String):
	set_meta("slug", new_slug)
	if is_marked:
		set_marked(false)
	var card_image_path = "res://Assets/Grand Archive/Card Images/" + new_slug + ".png"
	if ResourceLoader.exists(card_image_path):
		var img = get_node_or_null("CardImage")
		if img:
			img.texture = load(card_image_path)
	var anim_player = get_node_or_null("AnimationPlayer")
	if anim_player and anim_player.has_animation("card_flip"):
		anim_player.play("card_flip")
	runtime_modifiers = {"level": 0, "power": 0, "life": 0, "durability": 0}
	attached_markers.clear()
	attached_counters.clear()
	if current_field and current_field.has_method("notify_card_transformed"):
		current_field.notify_card_transformed(self)
	emit_signal("visuals_changed")

func add_to_lineage(lineage_data: Dictionary):
	champion_lineage.append(lineage_data)
	if lineage_view_window and lineage_view_window.visible:
		open_lineage_window()

func remove_from_lineage_by_uuid(target_uuid: String):
	for i in range(champion_lineage.size() - 1, -1, -1):
		if champion_lineage[i].get("uuid", "") == target_uuid:
			champion_lineage.remove_at(i)
			break

	return false

func _setup_progress_bar():
	progress_bar = TextureProgressBar.new()
	progress_bar.fill_mode = TextureProgressBar.FILL_CLOCKWISE
	progress_bar.step = 0.01
	progress_bar.min_value = 0
	progress_bar.max_value = 1.0
	progress_bar.value = 0
	progress_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	progress_bar.visible = false
	var ring_size = Vector2(128, 128)
	progress_bar.custom_minimum_size = ring_size
	progress_bar.size = ring_size
	progress_bar.scale = Vector2(1.5, 1.5)
	progress_bar.position = - (ring_size * 1.5) / 2
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
			open_lineage_window()
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

func find_base_card_for_edition(edition_id, card_database):
	if not card_database:
		return null
	for slug in card_database.cards_db:
		var data = card_database.cards_db[slug]
		if data.has("editions"):
			for edition in data["editions"]:
				if edition.get("edition_id") == edition_id:
					return slug
	return null

func is_champion_card() -> bool:
	var slug = get_slug_from_card()
	if slug == "":
		return false
	if not card_information_reference or not card_information_reference.card_database_reference:
		return false
	var db = card_information_reference.card_database_reference
	if not db.cards_db.has(slug):
		return false
	var data = db.cards_db[slug]
	if data.has("types") and data["types"] is Array:
		for t in data["types"]:
			if str(t).to_upper() == "CHAMPION":
				return true
	if data.has("edition_id") and not data.has("parent_orientation_slug"):
		var base_slug = find_base_card_for_edition(data["edition_id"], db)
		if base_slug and db.cards_db.has(base_slug):
			var base_data = db.cards_db[base_slug]
			if base_data.has("types") and base_data["types"] is Array:
				for card_type in base_data["types"]:
					if str(card_type).to_upper() == "CHAMPION":
						return true
	elif data.has("parent_orientation_slug"):
		var parent_slug = data["parent_orientation_slug"]
		if db.cards_db.has(parent_slug):
			var parent_data = db.cards_db[parent_slug]
			if parent_data.has("types") and parent_data["types"] is Array:
				for card_type in parent_data["types"]:
					if str(card_type).to_upper() == "CHAMPION":
						return true
	return false

func open_lineage_window():
	if not lineage_view_window or not grid_container:
		return
	var children = grid_container.get_children()
	for child in children:
		child.queue_free()
	for lineage_data in champion_lineage:
		var card_display_scene = load("res://Scenes/CardDisplay.tscn")
		if card_display_scene:
			var card_display = card_display_scene.instantiate()
			card_display.set_meta("slug", lineage_data.get("slug", ""))
			card_display.set_meta("uuid", lineage_data.get("uuid", ""))
			card_display.set_meta("zone", "lineage_opponent")
			grid_container.add_child(card_display)
	lineage_view_window.popup_centered()

func _on_lineage_window_close():
	if lineage_view_window:
		lineage_view_window.hide()

func animate_lineage_banish(slug: String, lineage_uuid: String):
	remove_from_lineage_by_uuid(lineage_uuid)
	if lineage_view_window and lineage_view_window.visible:
		open_lineage_window()
	var scene = get_tree().get_current_scene()
	if not scene:
		return
	var opp_field = scene.find_child("OpponentField", true, false)
	var opp_banish = opp_field.find_child("OpponentBanish", true, false) if opp_field else scene.find_child("OpponentBanish", true, false)
	if not opp_banish:
		return
	var visual_card = load("res://Scenes/OpponentCard.tscn").instantiate()
	visual_card.set_meta("slug", slug)
	if lineage_uuid != "":
		visual_card.uuid = lineage_uuid	
	var card_info = card_information_reference
	if card_info and card_info.card_database_reference:
		var card_image_path = "res://Assets/Grand Archive/Card Images/" + slug + ".png"
		if ResourceLoader.exists(card_image_path):
			var img = visual_card.get_node_or_null("CardImage")
			if img:
				img.texture = load(card_image_path)
				img.visible = true
				var back = visual_card.get_node_or_null("CardImageBack")
				if back:
					back.visible = false
					img.z_index = 0		
	var card_manager = opp_field.get_node_or_null("CardManager") if opp_field else null
	if card_manager:
		card_manager.add_child(visual_card)
	else:
		scene.add_child(visual_card)
	visual_card.global_position = global_position
	visual_card.z_index = 1000
	var target_pos = opp_banish.global_position
	if opp_banish.has_node("Area2D/CollisionShape2D"):
		target_pos = opp_banish.get_node("Area2D/CollisionShape2D").global_position
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(visual_card, "global_position", target_pos, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(visual_card, "rotation_degrees", 90.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.set_parallel(false)
	tween.tween_callback(func():
		if opp_banish.has_method("add_card_to_slot"):
			opp_banish.add_card_to_slot(visual_card, false)
		else:
			visual_card.queue_free())

func animate_send_to_lineage(card_node: Node, card_slug: String, card_uuid: String):
	var final_callback = func():
		add_to_lineage({"slug": card_slug, "uuid": card_uuid})
		if card_node and is_instance_valid(card_node):
			if card_node.get_parent():
				if card_node.get_parent().has_method("remove_card_from_field"):
					card_node.get_parent().remove_card_from_field(card_node)
				elif card_node.get_parent().has_method("remove_card_from_slot"):
					card_node.get_parent().remove_card_from_slot(card_node)
				else:
					card_node.get_parent().remove_child(card_node)
			card_node.queue_free()
	if card_node and is_instance_valid(card_node):
		card_node.z_index = 1000
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(card_node, "global_position", global_position, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(card_node, "rotation_degrees", 0.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		tween.set_parallel(false)
		tween.tween_callback(final_callback)
	else:
		final_callback.call()

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		get_viewport().set_input_as_handled()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if is_champion_card() and is_in_main_field():
			if event.pressed:
				is_holding_left = true
				hold_timer = 0.0
			else:
				if is_holding_left and hold_timer < HOLD_DURATION:
					if can_be_marked():
						toggle_mark()
				_reset_hold()
			return
		if event.pressed:
			if is_in_memory_zone() or is_in_main_field() or is_in_hand():
				if can_be_marked():
					toggle_mark()

func is_in_memory_zone() -> bool:
	if current_field and current_field.is_in_group("memory_slots"):
		return true
	var parent = get_parent()
	if parent and parent.is_in_group("memory_slots"):
		return true
	return false

func is_in_hand() -> bool:
	var opponent_hand_nodes = get_tree().get_nodes_in_group("opponent_hand")
	for hand_node in opponent_hand_nodes:
		if "opponent_hand" in hand_node:
			if self in hand_node.opponent_hand:
				return true
	return false

func can_be_marked() -> bool:
	var parent = current_field if current_field else get_parent()
	if parent and parent.has_method("are_cards_blocked_for_marking"):
		if parent.are_cards_blocked_for_marking():
			return false
	return true

func toggle_mark():
	set_marked(!is_marked)

func set_marked(value: bool):
	if is_marked == value:
		return
	is_marked = value
	update_visuals_based_on_mark()
	if multiplayer.get_unique_id() != 0:
		var multiplayer_node = get_tree().get_root().get_node_or_null("Main")
		if multiplayer_node and multiplayer_node.has_method("rpc"):
			multiplayer_node.rpc("sync_set_card_marked", multiplayer.get_unique_id(), uuid, is_marked)

func update_visuals_based_on_mark():
	if is_marked:
		modulate = Color(1.5, 0.5, 0.5, 0.9)
	else:
		modulate = Color(1, 1, 1, 1)
