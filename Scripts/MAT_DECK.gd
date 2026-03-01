extends Node2D

var player_deck = ["alice-golden-queen-dtr1e-cur","bellonas-runestone-ambdp",
"alice-golden-queen-dtr","apotheosis-rite-p24-cpr", "crimson-protective-trinket-ftc",
"assassins-mantle-rec-brv","polaris-twinkling-cauldron-prxy",
"lost-providence-ptm1e","fabled-azurite-fatestone-hvn1e-csr",
"huaji-of-heavens-rise-hvn1e","fabled-ruby-fatestone-hvn1e","kaleidoscope-barrette-rec-idy"]
var card_database_reference
var hold_timer = 0.0
var is_holding_left = false
var progress_bar: TextureProgressBar

const CARD_SCENE_PATH = "res://Scenes/Card.tscn"
const HOLD_DURATION = 0.8

@onready var deck_view_window = $MAT_DECK_VIEW_WINDOW
@onready var grid_container = $MAT_DECK_VIEW_WINDOW/ScrollContainer/GridContainer

func _ready() -> void:
	add_to_group("mat_deck_zones")
	var deck_with_uuids = []
	for slug in player_deck:
		var card_uuid = str(Time.get_unix_time_from_system()) + "_" + str(get_instance_id()) + "_" + str(randi())
		deck_with_uuids.append({"slug": slug, "uuid": card_uuid})
	player_deck = deck_with_uuids
	card_database_reference = preload("res://Scripts/CardDatabase.gd")
	setup_deck_view()
	$Area2D.input_event.connect(_on_area_2d_input_event)
	if not $Area2D.mouse_exited.is_connected(_on_mouse_exited):
		$Area2D.mouse_exited.connect(_on_mouse_exited)
	update_deck_state()
	_setup_progress_bar()

func _setup_progress_bar():
	progress_bar = TextureProgressBar.new()
	progress_bar.fill_mode = TextureProgressBar.FILL_CLOCKWISE
	progress_bar.step = 0.01
	progress_bar.min_value = 0
	progress_bar.max_value = 1.0
	progress_bar.value = 0
	var progress_size = Vector2(100, 100)
	progress_bar.custom_minimum_size = progress_size
	progress_bar.size = progress_size
	progress_bar.position = -progress_size / 2
	progress_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	progress_bar.visible = false
	progress_bar.top_level = true
	progress_bar.z_index = 2000
	progress_bar.z_as_relative = false
	var img = Image.create(128, 128, false, Image.FORMAT_RGBA8)
	for y in range(128):
		for x in range(128):
			var dist = Vector2(x-64, y-64).length()
			if dist > 25 and dist < 30:
				img.set_pixel(x, y, Color(1, 1, 1, 0.8))
	var tex = ImageTexture.create_from_image(img)
	progress_bar.texture_progress = tex
	progress_bar.modulate = Color(0.2, 0.8, 1.0)
	get_tree().root.add_child.call_deferred(progress_bar)

func _process(delta):
	if is_holding_left:
		hold_timer += delta
		if progress_bar:
			progress_bar.value = hold_timer / HOLD_DURATION
			progress_bar.visible = true
			progress_bar.global_position = get_global_mouse_position() - progress_bar.size / 2
		if hold_timer >= HOLD_DURATION:
			show_deck_view()
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

func setup_deck_view():
	deck_view_window.close_requested.connect(_on_deck_view_close)
	deck_view_window.hide()

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_holding_left = true
				hold_timer = 0.0
			else:
				_reset_hold()

func _on_mouse_exited():
	_reset_hold()

func update_deck_view():
	if not deck_view_window.visible:
		return
	for child in grid_container.get_children():
		child.queue_free()
	for card_data in player_deck:
		var card_display = create_card_display(card_data["slug"], card_data["uuid"])
		grid_container.add_child(card_display)

func update_deck_state():
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
	else:
		$Area2D/CollisionShape2D.disabled = false
		$Sprite2D.visible = true

func show_deck_view():
	deck_view_window.popup_centered()
	update_deck_view()
	$MAT_DECK_VIEW_WINDOW/ScrollContainer.call_deferred("set", "scroll_horizontal", 0)
	$MAT_DECK_VIEW_WINDOW/ScrollContainer.call_deferred("set", "scroll_vertical", 0)

func create_card_display(card_name: String, card_uuid: String):
	var card_display_scene = preload("res://Scenes/CardDisplay.tscn")
	var card_display = card_display_scene.instantiate()
	card_display.set_meta("slug", card_name)
	card_display.set_meta("uuid", card_uuid)
	card_display.set_meta("zone", "mat_deck")
	return card_display

func add_to_top(slug: String, uuid: String = ""):
	if slug == "":
		return
	var card_uuid = uuid
	if card_uuid == "":
		card_uuid = str(Time.get_unix_time_from_system()) + "_" + str(get_instance_id()) + "_" + str(randi())
	player_deck.insert(0, {"slug": slug, "uuid": card_uuid})
	update_deck_view()
	update_deck_state()

func remove_card_by_uuid(target_uuid: String):
	var card_index = -1
	for i in range(player_deck.size()):
		if player_deck[i]["uuid"] == target_uuid:
			card_index = i
			break
	if card_index != -1:
		player_deck.remove_at(card_index)
		update_deck_view()
		update_deck_state()

func _on_deck_view_close():
	deck_view_window.hide()
