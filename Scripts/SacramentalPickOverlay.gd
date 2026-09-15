extends CanvasLayer

signal picked(slug, uuid)

const PER_PAGE = 60

var _pickables := []
var _items := []
var _picked_uuid := ""
var _page := 0
var _page_count := 1

@onready var rows_box: VBoxContainer = $Center/Rows
@onready var pager_bar: HBoxContainer = $PagerBar
@onready var pager_panel: Panel = $Panel
@onready var prev_button: Button = %PrevButton
@onready var next_button: Button = %NextButton
@onready var page_label: Label = %PageLabel

func _ready() -> void:
	prev_button.pressed.connect(_on_prev_page)
	next_button.pressed.connect(_on_next_page)

func setup(pickables: Array) -> void:
	_pickables = pickables.filter(func(e): return typeof(e) == TYPE_DICTIONARY)
	_page_count = maxi(1, int(ceil(float(_pickables.size()) / float(PER_PAGE))))
	var multi_page = (_page_count > 1)
	pager_bar.visible = multi_page
	pager_panel.visible = multi_page
	show_page(0)

func show_page(page: int) -> void:
	_page = clampi(page, 0, _page_count - 1)
	for child in rows_box.get_children():
		rows_box.remove_child(child)
		child.queue_free()
	_items.clear()
	var start = _page * PER_PAGE
	for entry in _pickables.slice(start, start + PER_PAGE):
		var slug = str(entry.get("slug", ""))
		var uuid = str(entry.get("uuid", ""))
		if slug == "":
			continue
		var item = TextureRect.new()
		item.set_meta("slug", slug)
		item.set_meta("uuid", uuid)
		item.mouse_filter = Control.MOUSE_FILTER_STOP
		item.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		item.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var image_path = "res://Assets/Grand Archive/Card Images/" + slug + ".png"
		if ResourceLoader.exists(image_path):
			item.texture = load(image_path)
		item.gui_input.connect(_on_item_gui_input.bind(slug, uuid))
		item.mouse_entered.connect(_on_item_mouse_entered.bind(slug))
		rows_box.add_child(item)
		_items.append(item)
	CardRowLayout.arrange(rows_box, rows_box.get_children())
	_update_pager()

func _update_pager() -> void:
	if not pager_bar.visible:
		return
	page_label.text = "%d / %d" % [_page + 1, _page_count]
	prev_button.disabled = (_page <= 0)
	next_button.disabled = (_page >= _page_count - 1)

func _on_prev_page() -> void:
	if _page > 0:
		show_page(_page - 1)

func _on_next_page() -> void:
	if _page < _page_count - 1:
		show_page(_page + 1)

func _on_item_gui_input(event: InputEvent, slug: String, uuid: String) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_on_item_picked(slug, uuid)
		get_viewport().set_input_as_handled()

func _on_item_mouse_entered(slug: String) -> void:
	var card_info_node = get_tree().get_current_scene().get_node_or_null("CardInformation")
	if not card_info_node:
		card_info_node = get_tree().get_current_scene().get_node_or_null("PlayerField/CardInformation")
	if card_info_node and card_info_node.has_method("show_card_info"):
		card_info_node.show_card_info(slug)

func _on_item_picked(slug: String, uuid: String) -> void:
	if _picked_uuid != "":
		return
	_picked_uuid = uuid
	for it in _items:
		if is_instance_valid(it) and it.get_meta("uuid") != uuid:
			it.visible = false
	emit_signal("picked", slug, uuid)
	queue_free()

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = event.global_position
		for it in _items:
			if is_instance_valid(it) and it.visible and it.get_global_rect().has_point(mouse_pos):
				return
		if is_instance_valid(pager_bar) and pager_bar.visible and pager_bar.get_global_rect().has_point(mouse_pos):
			return
		get_viewport().set_input_as_handled()
