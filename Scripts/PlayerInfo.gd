extends Control

@onready var texture_progress_bar = $TextureProgressBar
@onready var polygon_node = $Polygon2D

var card_info_node = null
var main_field_node = null
var last_champion_instance = null
var cached_base_life = 0
var game_over_triggered = false

func _ready():
	_find_nodes()

func _find_nodes():
	var root = get_tree().current_scene
	if root:
		card_info_node = find_node_by_script(root, "res://Scripts/CardInformation.gd")
	var parent = get_parent()
	if parent and parent.has_node("MAINFIELD"):
		main_field_node = parent.get_node("MAINFIELD")
	elif root:
		main_field_node = root.find_child("MAINFIELD", true, false)

func find_node_by_script(node: Node, script_path: String) -> Node:
	if node.get_script() and node.get_script().resource_path == script_path:
		return node
	for child in node.get_children():
		var result = find_node_by_script(child, script_path)
		if result:
			return result
	return null

func _process(_delta):
	if not texture_progress_bar:
		return
	if not main_field_node or not is_instance_valid(main_field_node):
		_find_nodes()
		if not main_field_node:
			texture_progress_bar.value = 100
			return
	var champion = main_field_node.get("current_champion_card")
	if not champion or not is_instance_valid(champion):
		texture_progress_bar.value = 100
		last_champion_instance = null
		return
	if champion != last_champion_instance:
		last_champion_instance = champion
		cached_base_life = get_base_life(champion)
	if cached_base_life <= 0:
		texture_progress_bar.value = 100
		return
	var current_life = calculate_current_life(champion, cached_base_life)
	if current_life <= 0:
		if LuBuIndomitableTitanEffect.check_and_apply(champion, main_field_node):
			texture_progress_bar.value = 0
			return
		texture_progress_bar.value = 0
		_trigger_game_over()
		return
	if current_life >= cached_base_life:
		texture_progress_bar.value = 100
	else:
		texture_progress_bar.value = (float(current_life) / float(cached_base_life)) * 100

func _trigger_game_over():
	if game_over_triggered:
		return
	game_over_triggered = true
	var root = get_tree().current_scene
	if root and root.has_method("surrender_game"):
		root.surrender_game()

func get_base_life(card) -> int:
	if not card_info_node or not is_instance_valid(card_info_node):
		var root = get_tree().current_scene
		card_info_node = find_node_by_script(root, "res://Scripts/CardInformation.gd")
		if not card_info_node: return 0
	var slug = ""
	if card.has_meta("slug"):
		slug = card.get_meta("slug")
	if slug == "": return 0
	var db = card_info_node.card_database_reference
	if not db or not db.cards_db.has(slug):
		return 0
	var data = db.cards_db[slug]
	var life = data.get("life")
	if life == null:
		if data.has("edition_id") and not data.has("parent_orientation_slug"):
			var base_slug = card_info_node.find_base_card_for_edition(data["edition_id"])
			if base_slug and db.cards_db.has(base_slug):
				life = db.cards_db[base_slug].get("life")
		elif data.has("parent_orientation_slug"):
			var parent_slug = data["parent_orientation_slug"]
			if db.cards_db.has(parent_slug):
				life = db.cards_db[parent_slug].get("life")
	return int(life) if life != null else 0

func calculate_current_life(card, base_life: int) -> int:
	var mods = card.get("runtime_modifiers")
	var counters = card.get("attached_counters")
	var life_mod = 0
	if mods and mods is Dictionary:
		life_mod = int(mods.get("life", 0))
	var counter_mod = 0
	if counters and counters is Dictionary:
		counter_mod = int(counters.get("Buff", 0)) - int(counters.get("Debuff", 0)) + int(counters.get("Life", 0)) - int(counters.get("Damage", 0))
	return max(0, base_life + life_mod + counter_mod)
