extends Node2D

func refresh_layout() -> void:
	var active_elements = []
	for child in get_children():
		if child is Node2D:
			var sprite = child.find_child("Sprite2D", true)
			if sprite and sprite.modulate.a > 0.9:
				active_elements.append(child)
	if active_elements.is_empty():
		return
	var area = _find_layout_area()
	var area_width = 213.0
	var center_pos = Vector2(110.5, 114.0)
	if area:
		var collision_shape = area.find_child("CollisionShape2D", true)
		if collision_shape and collision_shape.shape is RectangleShape2D:
			var rect_shape = collision_shape.shape as RectangleShape2D
			area_width = rect_shape.size.x
			center_pos = collision_shape.global_position
	var count = active_elements.size()
	var positions = []
	if count == 1:
		positions = [0.5]
	elif count == 2:
		positions = [0.4, 0.6]
	elif count == 3:
		positions = [0.3, 0.5, 0.7]
	elif count == 4:
		positions = [0.2, 0.4, 0.6, 0.8]
	elif count == 5:
		positions = [0.15, 0.325, 0.5, 0.675, 0.85]
	elif count == 6:
		positions = [0.125, 0.275, 0.425, 0.575, 0.725, 0.875]
	else:
		var min_pos = 0.07
		var max_pos = 0.93
		for i in range(count):
			var normalized_pos = min_pos + (max_pos - min_pos) * i / (count - 1)
			positions.append(normalized_pos)
	for i in range(count):
		var normalized_x = positions[i]
		var actual_x = center_pos.x - area_width/2.0 + normalized_x * area_width
		active_elements[i].global_position = Vector2(actual_x, center_pos.y)

func _find_layout_area() -> Area2D:
	var opp_info = get_parent().get_node_or_null("Opponents_Info")
	if opp_info:
		return opp_info.get_node_or_null("ElementsArea2D") as Area2D
	var root = get_tree().current_scene
	if root:
		return root.find_child("ElementsArea2D", true) as Area2D
	return null
