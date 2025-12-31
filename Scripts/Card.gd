extends Node2D

signal hovered
signal hovered_off

@onready var popup_menu: PopupMenu = $PopupMenu
@onready var area: Area2D = $Area2D
@onready var card_level_lable = $Level
@onready var card_PLDS_lable = $PowerLifeDurSpeed
@onready var crystal_node: Sprite2D = $Crystal
@onready var crystal_collision: CollisionShape2D = $Crystal/Area2D2/CollisionShape2D
@onready var banish_view_window = $LineageViewWindow
@onready var grid_container = $LineageViewWindow/ScrollContainer/GridContainer

var champion_lineage := []
var was_removed = false
var current_field = null
var original_rotation = 0.0
var is_rotated = false
var uuid = ""
var hand_position
var mouse_inside = false
var was_rotated_before_drag = false
var is_dragging = false
var card_information_reference = null
var runtime_modifiers = {"level": 0, "power": 0, "life": 0, "durability": 0}
var attached_markers := {}
var attached_counters := {}
var is_publicly_revealed = false
var current_direction = "North"

const SHIFTING_CURRENTS_SLUGS := ["shifting-currents-p24", "shifting-currents-ambsd"]
const TRANSFORMABLE_SLUGS := [
	"huaji-of-heavens-rise-hvn1e","huaji-of-abyssal-fall-hvn1e","fatestone-of-balance-hvn",
	"woodland-shoats-hvn","fatestone-of-progress-hvn","airborne-squirrel-hvn",
	"fluvial-fatestone-hvn","mocking-otter-hvn","cyclonic-fatestone-hvn",
	"windstalker-wolf-hvn","wildgrowth-fatestone-hvn","elder-mandrill-hvn",
	"companion-fatestone-rec-hvf","fatebound-caracal-rec-hvf","companion-fatestone-p25",
	"fatebound-caracal-p25","fatestone-of-revelations-rec-hvf","young-wyrmling-rec-hvf",
	"fatestone-of-revelations-p25","young-wyrmling-p25","submerged-fatestone-hvn",
	"commanding-sea-titan-hvn","fatestone-of-unrelenting-rec-hvf","cheetah-of-bound-fury-rec-hvf",
	"fatestone-of-unrelenting-p25","cheetah-of-bound-fury-p25","lavaplume-fatestone-rec-hvf",
	"firebird-trailblazer-rec-hvf","lavaplume-fatestone-p25","firebird-trailblazer-p25",
	"idle-fatestone-hvn","bolstered-boar-hvn","coiled-fatestone-hvn",
	"serpentine-judicator-hvn","pelagic-fatestone-hvn","slick-torrentrider-hvn",
	"beseeched-fatestone-hvn","daunting-panda-hvn",
	"craggy-fatestone-rec-hvf","obstinate-cragback-rec-hvf","craggy-fatestone-p25",
	"obstinate-cragback-p25","fatestone-of-heaven-rec-hvf","heavenly-drake-rec-hvf",
	"fatestone-of-heaven-p25","heavenly-drake-p25","fabled-ruby-fatestone-hvn1e",
	"suzaku-vermillion-phoenix-hvn1e","fabled-ruby-fatestone-hvn1e-csr","suzaku-vermillion-phoenix-hvn1e-csr",
	"fabled-sapphire-fatestone-hvn1e","genbu-black-tortoise-hvn1e","fabled-sapphire-fatestone-hvn1e-csr",
	"genbu-black-tortoise-hvn1e-csr","fabled-emerald-fatestone-hvn1e","byakko-white-tiger-hvn1e",
	"fabled-emerald-fatestone-hvn1e-csr","byakko-white-tiger-hvn1e-csr","lu-bu-indomitable-titan-hvn1e",
	"lu-bu-wrath-incarnate-hvn1e","lu-bu-indomitable-titan-hvn1e-cur","lu-bu-wrath-incarnate-hvn1e-cur",
	"fabled-azurite-fatestone-rec-hvf","seiryuu-azure-dragon-rec-hvf","fabled-azurite-fatestone-p25",
	"seiryuu-azure-dragon-p25","fabled-azurite-fatestone-hvn1e-csr","seiryuu-azure-dragon-hvn1e-csr"
]

const TRANSFORM_PAIRS := {
	"huaji-of-heavens-rise-hvn1e": "huaji-of-abyssal-fall-hvn1e",
	"huaji-of-abyssal-fall-hvn1e": "huaji-of-heavens-rise-hvn1e",
	"fatestone-of-balance-hvn": "woodland-shoats-hvn",
	"woodland-shoats-hvn": "fatestone-of-balance-hvn",
	"fatestone-of-progress-hvn": "airborne-squirrel-hvn",
	"airborne-squirrel-hvn": "fatestone-of-progress-hvn",
	"fluvial-fatestone-hvn": "mocking-otter-hvn",
	"mocking-otter-hvn": "fluvial-fatestone-hvn",
	"cyclonic-fatestone-hvn": "windstalker-wolf-hvn",
	"windstalker-wolf-hvn": "cyclonic-fatestone-hvn",
	"wildgrowth-fatestone-hvn": "elder-mandrill-hvn",
	"elder-mandrill-hvn": "wildgrowth-fatestone-hvn",
	"companion-fatestone-rec-hvf": "fatebound-caracal-rec-hvf",
	"fatebound-caracal-rec-hvf": "companion-fatestone-rec-hvf",
	"companion-fatestone-p25": "fatebound-caracal-p25",
	"fatebound-caracal-p25": "companion-fatestone-p25",
	"fatestone-of-revelations-rec-hvf": "young-wyrmling-rec-hvf",
	"young-wyrmling-rec-hvf": "fatestone-of-revelations-rec-hvf",
	"fatestone-of-revelations-p25": "young-wyrmling-p25",
	"young-wyrmling-p25": "fatestone-of-revelations-p25",
	"submerged-fatestone-hvn": "commanding-sea-titan-hvn",
	"commanding-sea-titan-hvn": "submerged-fatestone-hvn",
	"fatestone-of-unrelenting-rec-hvf": "cheetah-of-bound-fury-rec-hvf",
	"cheetah-of-bound-fury-rec-hvf": "fatestone-of-unrelenting-rec-hvf",
	"fatestone-of-unrelenting-p25": "cheetah-of-bound-fury-p25",
	"cheetah-of-bound-fury-p25": "fatestone-of-unrelenting-p25",
	"lavaplume-fatestone-rec-hvf": "firebird-trailblazer-rec-hvf",
	"firebird-trailblazer-rec-hvf": "lavaplume-fatestone-rec-hvf",
	"lavaplume-fatestone-p25": "firebird-trailblazer-p25",
	"firebird-trailblazer-p25": "lavaplume-fatestone-p25",
	"idle-fatestone-hvn": "bolstered-boar-hvn",
	"bolstered-boar-hvn": "idle-fatestone-hvn",
	"coiled-fatestone-hvn": "serpentine-judicator-hvn",
	"serpentine-judicator-hvn": "coiled-fatestone-hvn",
	"pelagic-fatestone-hvn": "slick-torrentrider-hvn",
	"slick-torrentrider-hvn": "pelagic-fatestone-hvn",
	"beseeched-fatestone-hvn": "daunting-panda-hvn",
	"daunting-panda-hvn": "beseeched-fatestone-hvn",
	"craggy-fatestone-rec-hvf": "obstinate-cragback-rec-hvf",
	"obstinate-cragback-rec-hvf": "craggy-fatestone-rec-hvf",
	"craggy-fatestone-p25": "obstinate-cragback-p25",
	"obstinate-cragback-p25": "craggy-fatestone-p25",
	"fatestone-of-heaven-rec-hvf": "heavenly-drake-rec-hvf",
	"heavenly-drake-rec-hvf": "fatestone-of-heaven-rec-hvf",
	"fatestone-of-heaven-p25": "heavenly-drake-p25",
	"heavenly-drake-p25": "fatestone-of-heaven-p25",
	"fabled-ruby-fatestone-hvn1e": "suzaku-vermillion-phoenix-hvn1e",
	"suzaku-vermillion-phoenix-hvn1e": "fabled-ruby-fatestone-hvn1e",
	"fabled-ruby-fatestone-hvn1e-csr": "suzaku-vermillion-phoenix-hvn1e-csr",
	"suzaku-vermillion-phoenix-hvn1e-csr": "fabled-ruby-fatestone-hvn1e-csr",
	"fabled-sapphire-fatestone-hvn1e": "genbu-black-tortoise-hvn1e",
	"genbu-black-tortoise-hvn1e": "fabled-sapphire-fatestone-hvn1e",
	"fabled-sapphire-fatestone-hvn1e-csr": "genbu-black-tortoise-hvn1e-csr",
	"genbu-black-tortoise-hvn1e-csr": "fabled-sapphire-fatestone-hvn1e-csr",
	"fabled-emerald-fatestone-hvn1e": "byakko-white-tiger-hvn1e",
	"byakko-white-tiger-hvn1e": "fabled-emerald-fatestone-hvn1e",
	"fabled-emerald-fatestone-hvn1e-csr": "byakko-white-tiger-hvn1e-csr",
	"byakko-white-tiger-hvn1e-csr": "fabled-emerald-fatestone-hvn1e-csr",
	"lu-bu-indomitable-titan-hvn1e": "lu-bu-wrath-incarnate-hvn1e",
	"lu-bu-wrath-incarnate-hvn1e": "lu-bu-indomitable-titan-hvn1e",
	"lu-bu-indomitable-titan-hvn1e-cur": "lu-bu-wrath-incarnate-hvn1e-cur",
	"lu-bu-wrath-incarnate-hvn1e-cur": "lu-bu-indomitable-titan-hvn1e-cur",
	"fabled-azurite-fatestone-rec-hvf": "seiryuu-azure-dragon-rec-hvf",
	"seiryuu-azure-dragon-rec-hvf": "fabled-azurite-fatestone-rec-hvf",
	"fabled-azurite-fatestone-p25": "seiryuu-azure-dragon-p25",
	"seiryuu-azure-dragon-p25": "fabled-azurite-fatestone-p25",
	"fabled-azurite-fatestone-hvn1e-csr": "seiryuu-azure-dragon-hvn1e-csr",
	"seiryuu-azure-dragon-hvn1e-csr": "fabled-azurite-fatestone-hvn1e-csr"
}

func _ready() -> void:
	if uuid == "":
		uuid = str(Time.get_unix_time_from_system()) + "_" + str(get_instance_id()) + "_" + str(randi())
	if get_parent() and get_parent().has_method("connect_card_signals"):
		get_parent().connect_card_signals(self)
	popup_menu.id_pressed.connect(_on_PopupMenu_id_pressed)
	area.input_event.connect(_on_area_2d_input_event)
	find_card_information_reference()
	if card_level_lable:
		card_level_lable.clear()
	update_crystal_visibility()
	if crystal_node and crystal_node.has_node("Area2D2"):
		var crystal_area_node = crystal_node.get_node("Area2D2")
		if not crystal_area_node.input_event.is_connected(_on_crystal_input_event):
			crystal_area_node.input_event.connect(_on_crystal_input_event)
	if banish_view_window:
		if not banish_view_window.close_requested.is_connected(_on_lineage_window_close):
			banish_view_window.close_requested.connect(_on_lineage_window_close)

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

func is_champion_card() -> bool:
	var card_slug = get_slug_from_card()
	if card_slug == "":
		return false
	if not card_information_reference or not card_information_reference.card_database_reference:
		return false
	var card_database = card_information_reference.card_database_reference
	if not card_database.cards_db.has(card_slug):
		return false
	var data = card_database.cards_db[card_slug]
	if data.has("types") and data["types"] is Array:
		for card_type in data["types"]:
			if str(card_type).to_upper() == "CHAMPION":
				return true
	if data.has("edition_id") and not data.has("parent_orientation_slug"):
		var base_slug = find_base_card_for_edition(data["edition_id"], card_database)
		if base_slug and card_database.cards_db.has(base_slug):
			var base_data = card_database.cards_db[base_slug]
			if base_data.has("types") and base_data["types"] is Array:
				for card_type in base_data["types"]:
					if str(card_type).to_upper() == "CHAMPION":
						return true
	elif data.has("parent_orientation_slug"):
		var parent_slug = data["parent_orientation_slug"]
		if card_database.cards_db.has(parent_slug):
			var parent_data = card_database.cards_db[parent_slug]
			if parent_data.has("types") and parent_data["types"] is Array:
				for card_type in parent_data["types"]:
					if str(card_type).to_upper() == "CHAMPION":
						return true
	return false

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_dragging:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if mouse_inside:
			if is_in_graveyard() or is_in_banish():
				return
			var logo_nodes = get_tree().get_nodes_in_group("logo")
			if logo_nodes.size() > 0:
				var logo_node = logo_nodes[0]
				if logo_node.has_method("has_active_status") and logo_node.has_active_status():
					apply_logo_status_to_self(logo_node)
					return
			popup_menu.clear()
			if is_token():
				if is_in_main_field():
					popup_menu.add_item("Destroy", 6)
					if is_rotated:
						popup_menu.add_item("Awake", 4)
					else:
						popup_menu.add_item("Rest", 4)
					var slug = get_slug_from_card()
					if slug in TRANSFORMABLE_SLUGS:
						popup_menu.add_item("Transform", 5)
					if slug in TRANSFORMABLE_SLUGS:
						popup_menu.add_item("Transform", 5)
			elif is_mastery():
				if is_in_main_field():
					popup_menu.add_item("Destroy", 7)
					var slug = get_slug_from_card()
					if slug in SHIFTING_CURRENTS_SLUGS:
						if current_direction != "North": popup_menu.add_item("North", 20)
						if current_direction != "East": popup_menu.add_item("East", 21)
						if current_direction != "South": popup_menu.add_item("South", 22)
						if current_direction != "West": popup_menu.add_item("West", 23)
					if slug in TRANSFORMABLE_SLUGS:
						popup_menu.add_item("Transform", 5)
			else:
				if is_in_memory_slot() or is_in_hand():
					if not is_publicly_revealed:
						popup_menu.add_item("Show", 10)
					else:
						popup_menu.add_item("Hide", 11)
					if is_in_memory_slot():
						var has_hidden = _has_hidden_cards_in_container()
						var has_revealed = _has_revealed_cards_in_container()
						if has_hidden:
							popup_menu.add_item("Show All", 12)
						if has_revealed:
							popup_menu.add_item("Hide All", 13)
				if not is_champion_card() or is_in_hand() or is_in_memory_slot():
					popup_menu.add_item("Banish Face Down", 1)
					popup_menu.add_item("Go to Top Deck", 2)
					popup_menu.add_item("Go to Bottom Deck", 3)
				if is_in_main_field():
					if is_rotated:
						popup_menu.add_item("Awake", 4)
					else:
						popup_menu.add_item("Rest", 4)
				if is_in_main_field():
					var slug = get_slug_from_card()
					if slug in TRANSFORMABLE_SLUGS:
						popup_menu.add_item("Transform", 5)
			var mouse_pos = get_global_mouse_position()
			popup_menu.reset_size()
			var screen_size = get_viewport().get_visible_rect().size
			var menu_size = popup_menu.get_contents_minimum_size()
			if mouse_pos.x + menu_size.x > screen_size.x:
				mouse_pos.x = screen_size.x - menu_size.x
			if mouse_pos.x < 0:
				mouse_pos.x = 0
			if mouse_pos.y + menu_size.y > screen_size.y:
				mouse_pos.y = screen_size.y - menu_size.y
			if mouse_pos.y < 0:
				mouse_pos.y = 0
			popup_menu.position = mouse_pos
			popup_menu.popup()

func _on_area_2d_mouse_entered() -> void:
	mouse_inside = true
	emit_signal("hovered", self)
	if is_in_main_field() and not is_dragging:
		show_card_info()

func _on_area_2d_mouse_exited() -> void:
	mouse_inside = false
	emit_signal("hovered_off", self)
	if is_in_main_field():
		hide_card_info()

func _on_crystal_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if crystal_node and crystal_node.visible:
			open_lineage_window()

func open_lineage_window():
	if not banish_view_window or not grid_container:
		return
	var children = grid_container.get_children()
	if children.size() > 0:
		children[0].visible = false
	for i in range(1, children.size()):
		children[i].queue_free()
	for lineage_data in champion_lineage:
		var card_display_scene = preload("res://Scenes/CardDisplay.tscn")
		var card_display = card_display_scene.instantiate()
		card_display.set_meta("slug", lineage_data.get("slug", ""))
		card_display.set_meta("uuid", lineage_data.get("uuid", ""))
		card_display.set_meta("zone", "lineage")
		grid_container.add_child(card_display)
	banish_view_window.popup_centered()

func _on_lineage_window_close():
	if banish_view_window:
		banish_view_window.hide()

func add_to_lineage(lineage_data: Dictionary):
	champion_lineage.append(lineage_data)
	update_crystal_visibility()

func remove_from_lineage_by_uuid(target_uuid: String):
	for i in range(champion_lineage.size() - 1, -1, -1):
		if champion_lineage[i].get("uuid", "") == target_uuid:
			champion_lineage.remove_at(i)
			update_crystal_visibility()
			break

func transform_card():
	var slug = get_slug_from_card()
	if slug == "" or not TRANSFORM_PAIRS.has(slug):
		return
	var new_slug = TRANSFORM_PAIRS[slug]
	set_meta("slug", new_slug)
	var card_image_path = "res://Assets/Grand Archive/Card Images/" + new_slug + ".png"
	if ResourceLoader.exists(card_image_path):
		$CardImage.texture = load(card_image_path)
	attached_markers.clear()
	attached_counters.clear()
	if current_field and current_field.has_method("notify_card_transformed"):
		current_field.notify_card_transformed(self)
	if has_node("AnimationPlayer"):
		var anim: AnimationPlayer = $AnimationPlayer
		if anim.has_animation("card_flip"):
			anim.play("card_flip")
	if is_in_main_field() and current_field:
		if current_field.has_method("is_champion_card") and current_field.is_champion_card(self):
			if current_field.current_champion_card and current_field.current_champion_card != self:
				var prev = current_field.current_champion_card
				if "champion_lineage" in prev:
					for entry in prev.champion_lineage:
						add_to_lineage(entry)
				var lineage_data = {
					"slug": current_field.get_card_slug(prev),
					"uuid": prev.uuid if "uuid" in prev else ""
				}
				add_to_lineage(lineage_data)
				current_field.remove_previous_champions()
			current_field.current_champion_card = self
			global_position = current_field.global_position + Vector2(0, -20)
			z_index = 400
			current_field.champion_life_delta = 0
			if has_method("apply_champion_life_delta"):
				apply_champion_life_delta(0)
	if is_in_main_field():
		clear_runtime_modifiers()
	update_crystal_visibility()
	if card_information_reference and mouse_inside and not is_dragging:
		hide_card_info()
		show_card_info()
		card_information_reference.show_card_preview(self)

func show_card_info():
	if not card_information_reference:
		return
	var card_slug = get_slug_from_card()
	if card_slug == "":
		return
	if card_level_lable:
		card_level_lable.clear()
	if card_PLDS_lable:
		card_PLDS_lable.clear()
	var card_database = card_information_reference.card_database_reference
	if not card_database or not card_database.cards_db.has(card_slug):
		return
	var level_to_display = null
	var plds_text_to_display = ""
	var data = card_database.cards_db[card_slug]
	if data.has("level") and data["level"] != null:
		level_to_display = data["level"]
	plds_text_to_display = _build_plds_text_effective(data)
	if data.has("edition_id") and not data.has("parent_orientation_slug"):
		var base_slug = find_base_card_for_edition(data["edition_id"], card_database)
		if base_slug and card_database.cards_db.has(base_slug):
			var base_data = card_database.cards_db[base_slug]
			if base_data.has("level") and base_data["level"] != null:
				level_to_display = base_data["level"]
			if plds_text_to_display == "":
				plds_text_to_display = _build_plds_text_effective(base_data)
	elif data.has("parent_orientation_slug"):
		var parent_slug = data["parent_orientation_slug"]
		if card_database.cards_db.has(parent_slug):
			var parent_data = card_database.cards_db[parent_slug]
			if parent_data.has("level") and parent_data["level"] != null:
				level_to_display = parent_data["level"]
			if plds_text_to_display == "":
				plds_text_to_display = _build_plds_text_effective(parent_data)
	if level_to_display != null:
		if is_in_main_field():
			var lvl_eff = int(level_to_display) + int(runtime_modifiers.get("level", 0))
			level_to_display = max(0, lvl_eff)
		if card_level_lable:
			card_level_lable.append_text("[left][font_size=32]LV. %s[/font_size][/left]" % str(level_to_display))
	if plds_text_to_display != "" and card_PLDS_lable:
		card_PLDS_lable.append_text("[right][font_size=26]%s[/font_size][/right]" % plds_text_to_display)

func hide_card_info():
	if card_level_lable:
		card_level_lable.clear()
	if card_PLDS_lable:
		card_PLDS_lable.clear()

func _build_plds_text(data: Dictionary) -> String:
	var parts: Array[String] = []
	if data.has("power") and data["power"] != null:
		parts.append("POW. %s" % str(data["power"]))
	if data.has("life") and data["life"] != null:
		parts.append("LIFE %s" % str(data["life"]))
	if data.has("durability") and data["durability"] != null:
		parts.append("DUR. %s" % str(data["durability"]))
	if data.has("speed") and data["speed"] != null:
		if typeof(data["speed"]) in [TYPE_INT, TYPE_FLOAT]:
			if data["speed"] == 1:
				parts.append("SPD. FAST")
			elif data["speed"] == 0:
				parts.append("SPD. SLOW")
			else:
				parts.append("SPEED %s" % str(data["speed"]))
		elif typeof(data["speed"]) == TYPE_BOOL:
			parts.append("FAST" if data["speed"] else "SLOW")
		else:
			parts.append("SPEED ?")
	return " - ".join(parts)

func _build_plds_text_effective(data: Dictionary) -> String:
	var parts: Array[String] = []
	var mods = runtime_modifiers if is_in_main_field() else {"level": 0, "power": 0, "life": 0, "durability": 0}
	if data.has("power") and data["power"] != null:
		var val = int(data["power"]) + int(mods.get("power", 0))
		val = max(0, val)
		parts.append("POW. %s" % str(val))
	if data.has("life") and data["life"] != null:
		var val2 = int(data["life"]) + int(mods.get("life", 0))
		val2 = max(0, val2)
		parts.append("LIFE %s" % str(val2))
	if data.has("durability") and data["durability"] != null:
		var val3 = int(data["durability"]) + int(mods.get("durability", 0))
		val3 = max(0, val3)
		parts.append("DUR. %s" % str(val3))
	if data.has("speed") and data["speed"] != null:
		if typeof(data["speed"]) in [TYPE_INT, TYPE_FLOAT]:
			if data["speed"] == 1:
				parts.append("SPD. FAST")
			elif data["speed"] == 0:
				parts.append("SPD. SLOW")
			else:
				parts.append("SPEED %s" % str(data["speed"]))
		elif typeof(data["speed"]) == TYPE_BOOL:
			parts.append("FAST" if data["speed"] else "SLOW")
		else:
			parts.append("SPEED ?")
	return " - ".join(parts)

func get_slug_from_card() -> String:
	if has_meta("slug"):
		return get_meta("slug")
	return ""

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

func _on_PopupMenu_id_pressed(id: int) -> void:
	match id:
		1: go_to_banish_face_down()
		2: go_to_top_deck()
		3: go_to_bottom_deck()
		4: if is_in_main_field(): rotate_card()
		5: transform_card()
		6: destroy_token()
		7: destroy_mastery()
		10: reveal_to_opponent()
		11: hide_from_opponent()
		12: reveal_all_in_memory()
		13: hide_all_in_memory()
		20: set_direction("North")
		21: set_direction("East")
		22: set_direction("South")
		23: set_direction("West")

func rotate_card():
	if not is_in_main_field():
		return
	if is_rotated:
		rotation_degrees = original_rotation
		is_rotated = false
	else:
		rotation_degrees = original_rotation + 90
		is_rotated = true

func set_direction(dir: String):
	current_direction = dir
	match dir:
		"North": rotation_degrees = original_rotation
		"East": rotation_degrees = original_rotation + 90
		"South": rotation_degrees = original_rotation + 180
		"West": rotation_degrees = original_rotation + 270
	sync_stats_to_opponent()

func on_drag_start():
	is_dragging = true
	was_rotated_before_drag = is_rotated
	var slug = get_slug_from_card()
	if not (slug in SHIFTING_CURRENTS_SLUGS):
		if not is_in_main_field():
			is_rotated = false
			rotation_degrees = original_rotation
	hide_card_info()
	emit_signal("hovered_off", self)

func on_drag_end():
	is_dragging = false
	if is_in_hand() and current_field and current_field.has_method("sync_hand_order"):
		current_field.sync_hand_order()

func set_current_field(field):
	if is_token() and field and (field.is_in_group("player_hand") or field.is_in_group("single_card_slots") or field.is_in_group("rotated_slots") or field.is_in_group("memory_slots")):
		destroy_token()
		return
	if is_mastery() and field and (field.is_in_group("player_hand") or field.is_in_group("single_card_slots") or field.is_in_group("rotated_slots") or field.is_in_group("memory_slots")):
		destroy_mastery()
		return
	var was_in_main = is_in_main_field()
	current_field = field
	if _is_hand_field(current_field):
		attached_markers.clear()
		attached_counters.clear()
	var now_in_main = is_in_main_field()
	if was_in_main and not now_in_main:
		clear_runtime_modifiers()
	var slug = get_slug_from_card()
	if not now_in_main and not (slug in SHIFTING_CURRENTS_SLUGS):
		is_rotated = false
		if field != null and not field.is_in_group("rotated_slots"):
			rotation_degrees = original_rotation
	update_crystal_visibility()

func is_in_main_field() -> bool:
	return current_field != null and current_field.is_in_group("main_fields")

func is_in_memory_slot() -> bool:
	return current_field != null and current_field.is_in_group("memory_slots")

func is_in_graveyard() -> bool:
	return current_field != null and current_field.is_in_group("single_card_slots")

func is_in_hand() -> bool:
	return _is_hand_field(current_field)

func clear_runtime_modifiers():
	runtime_modifiers["level"] = 0
	runtime_modifiers["power"] = 0
	runtime_modifiers["life"] = 0
	runtime_modifiers["durability"] = 0

func get_runtime_modifiers() -> Dictionary:
	return runtime_modifiers.duplicate()

func _resolve_data_for_stats() -> Dictionary:
	if not card_information_reference:
		return {}
	var card_database = card_information_reference.card_database_reference
	var slug = get_slug_from_card()
	if not card_database or not card_database.cards_db.has(slug):
		return {}
	var data = card_database.cards_db[slug]
	if data.has("edition_id") and not data.has("parent_orientation_slug"):
		var base_slug = find_base_card_for_edition(data["edition_id"], card_database)
		if base_slug and card_database.cards_db.has(base_slug):
			return card_database.cards_db[base_slug]
	elif data.has("parent_orientation_slug"):
		var parent_slug = data["parent_orientation_slug"]
		if card_database.cards_db.has(parent_slug):
			return card_database.cards_db[parent_slug]
	return data

func apply_logo_status_to_self(logo_node):
	if not is_in_main_field():
		logo_node.reset_all_status_values()
		return
	var data = _resolve_data_for_stats()
	if data.size() == 0:
		logo_node.reset_all_status_values()
		return
	if data.has("level") and data["level"] != null and logo_node.level_value != 0:
		var base_lvl = int(data["level"]) 
		var old = int(runtime_modifiers.get("level", 0))
		var proposed = old + int(logo_node.level_value)
		var new_mod = max(-base_lvl, proposed)
		runtime_modifiers["level"] = new_mod
	if data.has("durability") and data["durability"] != null and logo_node.durability_value != 0:
		var base_dur = int(data["durability"]) 
		var oldd = int(runtime_modifiers.get("durability", 0))
		var proposedd = oldd + int(logo_node.durability_value)
		var new_modd = max(-base_dur, proposedd)
		runtime_modifiers["durability"] = new_modd
	if data.has("power") and data["power"] != null and logo_node.power_value != 0:
		var base_pow = int(data["power"]) 
		var oldp = int(runtime_modifiers.get("power", 0))
		var proposedp = oldp + int(logo_node.power_value)
		var new_modp = max(-base_pow, proposedp)
		runtime_modifiers["power"] = new_modp
	if data.has("life") and data["life"] != null and logo_node.life_value != 0:
		var base_life = int(data["life"]) 
		var oldl = int(runtime_modifiers.get("life", 0))
		var proposedl = oldl + int(logo_node.life_value)
		var new_modl = max(-base_life, proposedl)
		runtime_modifiers["life"] = new_modl
		var applied_delta = new_modl - oldl
		if applied_delta != 0 and current_field and current_field.has_method("is_champion_card") and current_field.is_champion_card(self):
			if current_field.has_method("adjust_champion_life_delta"):
				current_field.adjust_champion_life_delta(applied_delta)
	if logo_node.custom_markers.size() > 0:
		for marker_name in logo_node.custom_markers.keys():
			var delta_val = int(logo_node.custom_markers[marker_name])
			if delta_val == 0:
				continue
			if not attached_markers.has(marker_name):
				attached_markers[marker_name] = 0
			attached_markers[marker_name] = int(attached_markers[marker_name]) + delta_val
	if logo_node.custom_counters.size() > 0:
		for counter_name in logo_node.custom_counters.keys():
			var delta_valc = int(logo_node.custom_counters[counter_name])
			if delta_valc == 0:
				continue
			if not attached_counters.has(counter_name):
				attached_counters[counter_name] = 0
			attached_counters[counter_name] = int(attached_counters[counter_name]) + delta_valc
	logo_node.reset_all_status_values()
	if card_level_lable:
		card_level_lable.clear()
	if card_PLDS_lable:
		card_PLDS_lable.clear()
	show_card_info()
	if card_information_reference and mouse_inside and not is_dragging:
		card_information_reference.show_card_preview(self)
	sync_stats_to_opponent()

func get_attached_markers() -> Dictionary:
	return attached_markers.duplicate()

func get_attached_counters() -> Dictionary:
	return attached_counters.duplicate()

func apply_champion_life_delta(delta):
	var data = _resolve_data_for_stats()
	if data.size() == 0:
		return
	if data.has("life") and data["life"] != null:
		var base_life = int(data["life"]) 
		var new_modl = max(-base_life, int(delta))
		runtime_modifiers["life"] = new_modl
		if card_level_lable:
			card_level_lable.clear()
		if card_PLDS_lable:
			card_PLDS_lable.clear()
		show_card_info()
		if card_information_reference and mouse_inside and not is_dragging:
			card_information_reference.show_card_preview(self)
		sync_stats_to_opponent()

func is_in_banish() -> bool:
	return current_field != null and current_field.is_in_group("rotated_slots")

func go_to_banish_face_down():
	var scene = get_tree().get_current_scene()
	if scene == null:
		return
	var banish_node = scene.find_child("BANISH", true, false)
	if banish_node == null:
		return
	var player_hand_node = scene.find_child("PlayerHand", true, false)
	if player_hand_node and player_hand_node.has_method("remove_card_from_hand"):
		player_hand_node.remove_card_from_hand(self)
	if current_field:
		if current_field.is_in_group("main_fields") and current_field.has_method("remove_card_from_field"):
			current_field.remove_card_from_field(self)
		elif current_field.is_in_group("memory_slots") and current_field.has_method("remove_card_from_memory"):
			current_field.remove_card_from_memory(self)
		elif current_field.has_method("remove_card_from_slot"):
			current_field.remove_card_from_slot(self)
	if banish_node.has_method("add_card_to_slot"):
		banish_node.add_card_to_slot(self, true)
	var multiplayer_node = get_tree().get_root().get_node("Main")
	if multiplayer_node:
		var slug = get_slug_from_card()
		if slug != "":
			multiplayer_node.rpc("sync_move_to_banish", multiplayer.get_unique_id(), uuid, slug, true)

func remove_from_current_position():
	var scene = get_tree().get_current_scene()
	if scene == null:
		return
	var player_hand_node = scene.find_child("PlayerHand", true, false)
	if player_hand_node and player_hand_node.has_method("remove_card_from_hand"):
		player_hand_node.remove_card_from_hand(self)
		was_removed = true
	if current_field:
		if current_field.is_in_group("main_fields") and current_field.has_method("remove_card_from_field"):
			current_field.remove_card_from_field(self)
			was_removed = true
		elif current_field.is_in_group("memory_slots") and current_field.has_method("remove_card_from_memory"):
			current_field.remove_card_from_memory(self)
			was_removed = true
		elif current_field.has_method("remove_card_from_slot"):
			current_field.remove_card_from_slot(self)
			was_removed = true
	queue_free()

func go_to_top_deck():
	var slug = get_slug_from_card()
	if slug == "":
		return
	_prepare_for_deck_move()
	var deck_nodes = get_tree().get_nodes_in_group("deck_zones")
	if deck_nodes.size() == 0:
		return
	var deck_node = deck_nodes[0]
	if deck_node.has_method("add_to_top"):
		animate_card_to_deck(deck_node.global_position, slug, uuid, true)

func go_to_bottom_deck():
	var slug = get_slug_from_card()
	if slug == "":
		return
	_prepare_for_deck_move()
	var deck_nodes = get_tree().get_nodes_in_group("deck_zones")
	if deck_nodes.size() == 0:
		return
	var deck_node = deck_nodes[0]
	if deck_node.has_method("add_to_bottom"):
		animate_card_to_deck(deck_node.global_position, slug, uuid, false)

func _prepare_for_deck_move():
	for tween in get_tree().get_processed_tweens():
		if tween.is_valid() and tween.is_running():
			pass 
	var scene = get_tree().get_current_scene()
	var player_hand_node = scene.find_child("PlayerHand", true, false)
	if player_hand_node and player_hand_node.has_method("remove_card_from_hand"):
		player_hand_node.remove_card_from_hand(self)
	if current_field:
		if current_field.is_in_group("main_fields") and current_field.has_method("remove_card_from_field"):
			current_field.remove_card_from_field(self)
		elif current_field.is_in_group("memory_slots") and current_field.has_method("remove_card_from_memory"):
			current_field.remove_card_from_memory(self)
		elif current_field.has_method("remove_card_from_slot"):
			current_field.remove_card_from_slot(self)

func _sync_move_to_deck(is_top: bool):
	var multiplayer_node = get_tree().get_root().get_node_or_null("Main")
	if multiplayer_node and multiplayer_node.has_method("rpc"):
		multiplayer_node.rpc("sync_move_to_deck", multiplayer.get_unique_id(), uuid, is_top)

func animate_card_to_deck(deck_position: Vector2, slug: String, card_uuid: String, is_top: bool):
	if $Area2D.input_event.is_connected(_on_area_2d_input_event):
		$Area2D.input_event.disconnect(_on_area_2d_input_event)
	$Area2D.set_deferred("monitoring", false)
	z_index = 1000
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", deck_position, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "rotation_degrees", 0.0, 0.3)
	tween.tween_property(self, "scale", Vector2(0.3, 0.3), 0.4)
	tween.set_parallel(false)
	var mid_timer = get_tree().create_timer(0.2)
	mid_timer.timeout.connect(func(): $CardImage.texture = load("res://Assets/Grand Archive/ga_back.png"))
	await tween.finished
	_on_deck_animation_completed(slug, card_uuid, is_top)

func _on_deck_animation_completed(slug: String, card_uuid: String, is_top: bool):
	var deck_nodes = get_tree().get_nodes_in_group("deck_zones")
	if deck_nodes.size() > 0:
		var deck_node = deck_nodes[0]
		if is_top and deck_node.has_method("add_to_top"):
			deck_node.add_to_top(slug, card_uuid)
		elif not is_top and deck_node.has_method("add_to_bottom"):
			deck_node.add_to_bottom(slug, card_uuid)
	var multiplayer_node = get_tree().get_root().get_node_or_null("Main")
	if multiplayer_node and multiplayer_node.has_method("rpc"):
		multiplayer_node.rpc("sync_card_returned_to_deck", multiplayer.get_unique_id(), card_uuid, slug)
	queue_free()

func _is_hand_field(field) -> bool:
	if field == null:
		return false
	return field.is_in_group("player_hand")

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
	var multiplayer_node = get_tree().get_root().get_node("Main")
	if multiplayer_node and multiplayer_node.has_method("rpc"):
		multiplayer_node.rpc("sync_destroy_token", multiplayer.get_unique_id(), uuid, slug)
	if current_field and current_field.has_method("remove_card_from_field"):
		current_field.remove_card_from_field(self)
	elif current_field and current_field.has_method("remove_card_from_slot"):
		current_field.remove_card_from_slot(self)
	queue_free()

func destroy_mastery():
	var slug = get_slug_from_card()
	var multiplayer_node = get_tree().get_root().get_node("Main")
	if multiplayer_node and multiplayer_node.has_method("rpc"):
		multiplayer_node.rpc("sync_destroy_mastery", multiplayer.get_unique_id(), uuid, slug)
	if current_field and current_field.has_method("remove_card_from_field"):
		current_field.remove_card_from_field(self)
	elif current_field and current_field.has_method("remove_card_from_slot"):
		current_field.remove_card_from_slot(self)
	queue_free()

func sync_stats_to_opponent():
	var slug = get_slug_from_card()
	if slug == "":
		return
	var multiplayer_node = get_tree().get_root().get_node("Main")
	if multiplayer_node and multiplayer_node.has_method("rpc"):
		multiplayer_node.rpc("sync_card_stats_v2", multiplayer.get_unique_id(), uuid, slug, runtime_modifiers, attached_markers, attached_counters, current_direction)

func update_crystal_visibility():
	if not crystal_node:
		return
	var contains_lineage = champion_lineage.size() > 0
	var should_be_visible = is_champion_card() and is_in_main_field() and contains_lineage
	crystal_node.visible = should_be_visible
	if crystal_collision:
		crystal_collision.set_deferred("disabled", !should_be_visible)
	if crystal_node.has_node("Area2D2"):
		var crystal_area = crystal_node.get_node("Area2D2")
		crystal_area.set_deferred("input_pickable", should_be_visible)

func reveal_to_opponent():
	if (not is_in_memory_slot() and not is_in_hand()) or is_publicly_revealed:
		return
	is_publicly_revealed = true
	if is_in_hand():
		var parent = find_parent_container()
		if parent and parent.has_method("sync_hand_order"):
			parent.sync_hand_order()
	_update_local_card_visuals(true)
	sync_reveal_state(true)

func hide_from_opponent():
	if (not is_in_memory_slot() and not is_in_hand()) or not is_publicly_revealed:
		return
	is_publicly_revealed = false
	_update_local_card_visuals(false)
	sync_reveal_state(false)

func reveal_all_in_memory():
	var memory_slot = find_parent_container()
	if memory_slot:
		for card in memory_slot.cards_in_slot:
			if card.has_method("_update_local_card_visuals"):
				card.is_publicly_revealed = true
				card._update_local_card_visuals(true)
		sync_all_reveal_state(true)

func hide_all_in_memory():
	var memory_slot = find_parent_container()
	if memory_slot:
		for card in memory_slot.cards_in_slot:
			if card.has_method("_update_local_card_visuals"):
				card.is_publicly_revealed = false
				card._update_local_card_visuals(false)
		sync_all_reveal_state(false)

func find_parent_container():
	var p = get_parent()
	if p:
		if (p.is_in_group("memory_slots") or p.is_in_group("player_hand")) and not p.name.contains("Opponent"):
			return p
	var hand_nodes = get_tree().get_nodes_in_group("player_hand")
	for node in hand_nodes:
		if not node.name.contains("Opponent"):
			if "player_hand" in node and self in node.player_hand:
				return node
	var memory_nodes = get_tree().get_nodes_in_group("memory_slots")
	for node in memory_nodes:
		if not node.name.contains("Opponent"):
			if "cards_in_slot" in node and self in node.cards_in_slot:
				return node
	return null

func sync_reveal_state(revealed: bool):
	var main_node = get_tree().get_root().get_node_or_null("Main")
	if main_node:
		main_node.rpc("rpc_set_card_reveal_status", multiplayer.get_unique_id(), uuid, revealed)

func sync_all_reveal_state(revealed: bool):
	var main_node = get_tree().get_root().get_node_or_null("Main")
	if main_node:
		main_node.rpc("rpc_set_all_cards_reveal_status", multiplayer.get_unique_id(), revealed)

func _are_all_memory_cards_revealed() -> bool:
	var memory_slot = find_parent_container()
	if not memory_slot:
		return false
	for card in memory_slot.cards_in_slot:
		if card.has_method("get") and card.get("is_publicly_revealed") != null:
			if not card.is_publicly_revealed:
				return false
		elif card.has_meta("is_publicly_revealed"):
			if not card.get_meta("is_publicly_revealed"):
				return false
		else:
			return false
	return true

func _has_hidden_cards_in_container() -> bool:
	var container = find_parent_container()
	if not container:
		return false
	var cards = []
	if "cards_in_slot" in container:
		cards = container.cards_in_slot
	elif "player_hand" in container:
		cards = container.player_hand
	for card in cards:
		var is_revealed = false
		if card.has_method("get") and card.get("is_publicly_revealed") != null:
			is_revealed = card.is_publicly_revealed
		elif card.has_meta("is_publicly_revealed"):
			is_revealed = card.get_meta("is_publicly_revealed")
		if not is_revealed:
			return true
	return false

func _has_revealed_cards_in_container() -> bool:
	var container = find_parent_container()
	if not container:
		return false
	var cards = []
	if "cards_in_slot" in container:
		cards = container.cards_in_slot
	elif "player_hand" in container:
		cards = container.player_hand
	for card in cards:
		var is_revealed = false
		if card.has_method("get") and card.get("is_publicly_revealed") != null:
			is_revealed = card.is_publicly_revealed
		elif card.has_meta("is_publicly_revealed"):
			is_revealed = card.get_meta("is_publicly_revealed")
		if is_revealed:
			return true
	return false

func _update_local_card_visuals(revealed: bool):
	var front = get_node_or_null("CardImage")
	var back = get_node_or_null("CardImageBack")
	if not front or not back:
		var show_front = revealed
		if is_in_hand() and revealed:
			show_front = false
		elif is_in_hand() and not revealed:
			show_front = true
		if show_front:
			if front: front.visible = true
			if back: back.visible = false
		else:
			if front: front.visible = false
			if back: back.visible = true
		return
	var is_already_revealed = front.visible and not back.visible
	var is_already_hidden = not front.visible and back.visible
	var target_show_front = revealed
	var target_show_back = not revealed
	if is_in_hand():
		if revealed:
			target_show_front = false
			target_show_back = true
		else:
			target_show_front = true
			target_show_back = false
	if target_show_front and is_already_revealed:
		return
	if target_show_back and is_already_hidden:
		return
	var anim_player = get_node_or_null("AnimationPlayer")
	if anim_player and anim_player.has_animation("card_flip"):
		front.visible = true
		back.visible = true
		anim_player.play("card_flip")
		var timer = get_tree().create_timer(0.1)
		timer.timeout.connect(func():
			if target_show_front:
				front.visible = true
				back.visible = false
			else:
				front.visible = false
				back.visible = true
		)
	else:
		if target_show_front:
			front.visible = true
			back.visible = false
		else:
			front.visible = false
			back.visible = true
