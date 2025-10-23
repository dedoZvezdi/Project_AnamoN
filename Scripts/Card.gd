extends Node2D

signal hovered
signal hovered_off

@onready var popup_menu: PopupMenu = $PopupMenu
@onready var area: Area2D = $Area2D
@onready var card_level_lable = $Level
@onready var card_PLDS_lable = $PowerLifeDurSpeed

var was_removed = false
var current_field = null
var original_rotation = 0.0
var is_rotated = false
var hand_position
var mouse_inside = false
var was_rotated_before_drag = false
var is_dragging = false
var card_information_reference = null
var runtime_modifiers = {"level": 0, "power": 0, "life": 0, "durability": 0}
var attached_markers := {}
var attached_counters := {}

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
	if get_parent() and get_parent().has_method("connect_card_signals"):
		get_parent().connect_card_signals(self)
	popup_menu.id_pressed.connect(_on_PopupMenu_id_pressed)
	area.input_event.connect(_on_area_2d_input_event)
	find_card_information_reference()
	if card_level_lable:
		card_level_lable.clear()

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
			else:
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
				current_field.remove_previous_champions()
			current_field.current_champion_card = self
			global_position = current_field.global_position
			z_index = 400
			current_field.champion_life_delta = 0
			if has_method("apply_champion_life_delta"):
				apply_champion_life_delta(0)
	if is_in_main_field():
		clear_runtime_modifiers()
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

func rotate_card():
	if not is_in_main_field():
		return
	if is_rotated:
		rotation_degrees = original_rotation
		is_rotated = false
	else:
		rotation_degrees = original_rotation + 90
		is_rotated = true

func on_drag_start():
	is_dragging = true
	was_rotated_before_drag = is_rotated
	rotation_degrees = original_rotation
	hide_card_info()
	emit_signal("hovered_off", self)

func on_drag_end():
	is_dragging = false
	is_rotated = false
	rotation_degrees = original_rotation

func set_current_field(field):
	if is_token() and field and (field.is_in_group("player_hand") or field.is_in_group("single_card_slots") or field.is_in_group("rotated_slots") or field.is_in_group("memory_slots")):
		destroy_token()
		return
	var was_in_main = is_in_main_field()
	current_field = field
	if _is_hand_field(current_field):
		attached_markers.clear()
		attached_counters.clear()
	var now_in_main = is_in_main_field()
	if was_in_main and not now_in_main:
		clear_runtime_modifiers()

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
			multiplayer_node.rpc("sync_move_to_banish", multiplayer.get_unique_id(), slug, true)

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
	var deck_nodes = get_tree().get_nodes_in_group("deck_zones")
	if deck_nodes.size() == 0:
		return
	var deck_node = deck_nodes[0]
	if deck_node.has_method("add_to_top"):
		animate_card_to_deck(deck_node.global_position, slug, true)

func go_to_bottom_deck():
	var slug = get_slug_from_card()
	if slug == "":
		return
	var deck_nodes = get_tree().get_nodes_in_group("deck_zones")
	if deck_nodes.size() == 0:
		return
	var deck_node = deck_nodes[0]
	if deck_node.has_method("add_to_bottom"):
		animate_card_to_deck(deck_node.global_position, slug, false)

func animate_card_to_deck(deck_position: Vector2, slug: String, is_top: bool):
	$Area2D.input_event.disconnect(_on_area_2d_input_event)
	$Area2D.set_deferred("monitoring", false)
	var original_texture = $CardImage.texture
	$CardImage.texture = load("res://Assets/Grand Archive/ga_back.png")
	if is_top: z_index = 2
	else: z_index = 0
	rotation_degrees = 0.0
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", deck_position, 0.5)
	tween.tween_callback(_on_deck_animation_completed.bind(slug, is_top, original_texture)).set_delay(0.5)

func _on_deck_animation_completed(slug: String, is_top: bool, original_texture: Texture2D):
	$CardImage.texture = original_texture
	$Area2D.input_event.connect(_on_area_2d_input_event)
	$Area2D.set_deferred("monitoring", true)
	var deck_nodes = get_tree().get_nodes_in_group("deck_zones")
	if deck_nodes.size() > 0:
		var deck_node = deck_nodes[0]
		if is_top and deck_node.has_method("add_to_top"):
			deck_node.add_to_top(slug)
		elif not is_top and deck_node.has_method("add_to_bottom"):
			deck_node.add_to_bottom(slug)
	remove_from_current_position()

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

func destroy_token():
	if current_field and current_field.has_method("remove_card_from_field"):
		current_field.remove_card_from_field(self)
	elif current_field and current_field.has_method("remove_card_from_slot"):
		current_field.remove_card_from_slot(self)
	queue_free()
