class_name CardRowLayout

static func arrange(rows_box: VBoxContainer, items: Array, max_width: float = 1000.0, 
gap: float = 7.0, per_row: int = 12, card_size: Vector2 = Vector2(77, 108), 
row_overlap_ratio: float = 0.3) -> Vector2:
	var final_size = card_size
	if rows_box == null or items.is_empty() or per_row <= 0:
		return final_size
	var first_count = mini(per_row, items.size())
	var need = first_count * card_size.x + (first_count - 1) * gap
	if need > max_width and first_count > 0:
		var width = (max_width - (first_count - 1) * gap) / first_count
		var aspect = card_size.x / maxf(1.0, card_size.y)
		final_size = Vector2(width, width / aspect)
	var idx = 0
	while idx < items.size():
		var row = HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_theme_constant_override("separation", int(gap))
		rows_box.add_child(row)
		for _j in range(mini(per_row, items.size() - idx)):
			var item = items[idx]
			idx += 1
			if item == null or not is_instance_valid(item):
				continue
			if item.get_parent():
				item.get_parent().remove_child(item)
			row.add_child(item)
			if item is Control:
				item.scale = Vector2.ONE
				item.custom_minimum_size = final_size
				var texture = item.get_node_or_null("TextureRect")
				if texture and texture is Control:
					texture.scale = Vector2.ONE
					texture.position = Vector2.ZERO
					texture.custom_minimum_size = final_size
					texture.size = final_size
	if rows_box.get_child_count() > 1:
		rows_box.add_theme_constant_override("separation", -int(final_size.y * row_overlap_ratio))
	return final_size
