class_name PrismaticSpiritEffect

static func apply_activation(card: Node, elements_node: Node, is_opponent: bool = false):
	if not elements_node:
		return
	var prefix = "Opponent" if is_opponent else ""
	var norm = elements_node.get_node_or_null(prefix + "Norm")
	if norm and norm.has_method("activate"):
		norm.activate()
	if not is_opponent:
		var original_owner = 0
		if "original_owner_id" in card:
			original_owner = card.original_owner_id
		var my_id = 0
		var multiplayer_node = card.get_tree().get_root().get_node_or_null("Main")
		if multiplayer_node and multiplayer_node.has_method("multiplayer"):
			my_id = multiplayer_node.multiplayer.get_unique_id()
		elif card.multiplayer:
			my_id = card.multiplayer.get_unique_id()
		if original_owner == 0 or original_owner == my_id:
			_show_prismatic_selection(card)

static func apply_lineage_activation(elements_node: Node, chosen_elements: Array, is_opponent: bool = false):
	if not elements_node:
		return
	var prefix = "Opponent" if is_opponent else ""
	for element_name in chosen_elements:
		var element_node = elements_node.get_node_or_null(prefix + element_name)
		if element_node and element_node.has_method("activate"):
			element_node.activate()

static func remove_lineage_activation(elements_node: Node, chosen_elements: Array, is_opponent: bool = false):
	if not elements_node:
		return
	var prefix = "Opponent" if is_opponent else ""
	for element_name in chosen_elements:
		var element_node = elements_node.get_node_or_null(prefix + element_name)
		if element_node and element_node.has_method("deactivate"):
			element_node.deactivate()

static func _show_prismatic_selection(card: Node):
	var popup_script = load("res://Scripts/PrismaticSelectionPopup.gd")
	if popup_script:
		var popup = CanvasLayer.new()
		popup.layer = 100
		popup.set_script(popup_script)
		card.get_tree().root.add_child(popup)
		popup.selection_confirmed.connect(func(elements):
			if "chosen_elements" in card:
				card.chosen_elements = elements
			if card.has_method("set_meta"):
				card.set_meta("chosen_elements", elements)
			var root = card.get_tree().current_scene
			var multiplayer_node = root.get_node_or_null("Main") if root else null
			if not multiplayer_node and root and root.name == "Main":
				multiplayer_node = root
			if multiplayer_node and multiplayer_node.has_method("rpc") and "uuid" in card:
				var my_id = multiplayer_node.multiplayer.get_unique_id()
				multiplayer_node.rpc("sync_prismatic_elements", my_id, card.uuid, elements))
