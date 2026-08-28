extends Control

func _can_drop_data(_pos, data):
	if data is Dictionary and data.get("type") == "deck_builder":
		var source_zone = data.get("zone", "")
		return source_zone != "deck_building_results"
	return false

func _drop_data(_pos, data):
	if data is Dictionary and data.get("type") == "deck_builder":
		var slug = data.get("slug", "")
		var source_zone = data.get("zone", "")
		if source_zone != "deck_building_results":
			var deck_building = _find_deck_building()
			if deck_building and deck_building.has_method("handle_drop_on_results"):
				deck_building.handle_drop_on_results(slug, source_zone, null)

func _find_deck_building():
	var node = self
	while node:
		if node.get_script() and node.get_script().resource_path.ends_with("Deck_Building.gd"):
			return node
		node = node.get_parent()
	return null
