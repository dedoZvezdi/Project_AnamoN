extends Control

@onready var health_chunks_container = $HealthChunksContainer

var card_info_node = null
var opponent_main_field_node = null
var last_champion_instance = null
var cached_base_life = 0

func _ready():
	_find_nodes()

func _find_nodes():
	var root = get_tree().current_scene
	if root:
		card_info_node = find_node_by_script(root, "res://Scripts/CardInformation.gd")
		opponent_main_field_node = root.find_child("OpponentMainField", true, false)

func find_node_by_script(node: Node, script_path: String) -> Node:
	if node.get_script() and node.get_script().resource_path == script_path:
		return node
	for child in node.get_children():
		var result = find_node_by_script(child, script_path)
		if result:
			return result
	return null

func _process(_delta):
	if not health_chunks_container:
		return
	if not opponent_main_field_node or not is_instance_valid(opponent_main_field_node):
		_find_nodes()
		if not opponent_main_field_node:
			_update_chunks(25)
			return
	var champion = opponent_main_field_node.get("current_champion_card")
	if not champion or not is_instance_valid(champion):
		_update_chunks(25)
		last_champion_instance = null
		return
	if champion != last_champion_instance:
		last_champion_instance = champion
		cached_base_life = get_base_life(champion)
	if cached_base_life <= 0:
		_update_chunks(25)
		return
	var current_life = calculate_current_life(champion, cached_base_life)
	var visible_count = _get_visible_chunks(current_life, cached_base_life)
	_update_chunks(visible_count)

func _get_visible_chunks(current: int, base: int) -> int:
	if current <= 0:
		return 0
	if current >= base:
		return 25
	var missing_health = base - current
	var missing_percent = (float(missing_health) / float(base)) * 100.0
	var removed = 0
	if missing_percent > 0:
		removed = max(1, floor(missing_percent / 4.0))
	return int(clamp(25 - removed, 0, 25))

func _update_chunks(visible_count: int):
	var children = health_chunks_container.get_children()
	var total = children.size()
	var hidden_count = total - visible_count
	for i in range(total):
		var chunk = children[i]
		if i < hidden_count:
			chunk.modulate.a = 0.0
		else:
			chunk.modulate.a = 1.0

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
