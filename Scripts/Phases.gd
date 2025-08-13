extends Node2D

var area_line_mapping = {
	"WakeUpArea2D": ["LineWakeUpR", "LineWakeUpL"],
	"MaterializeArea2D": ["LineMaterializeL", "LineMaterializeR"], 
	"RecollectionArea2D": ["LineRecollectionL", "LineRecollectionR"],
	"DrawArea2D": ["LineDrawR", "LineDrawL"],
	"MainArea2D": ["LineMainL", "LineMainR"],
	"EndArea2D": ["LineEndL", "LineEndR"]
}
var areas = {}
var all_lines = []

func _ready():
	collect_areas_and_lines()
	hide_all_lines()
	show_lines_for_area("MaterializeArea2D")

func collect_areas_and_lines():
	for area_name in area_line_mapping:
		var area_node = get_node_or_null(area_name)
		if area_node:
			areas[area_name] = area_node
	for area_name in area_line_mapping:
		for line_name in area_line_mapping[area_name]:
			var line_node = get_node_or_null(line_name)
			if line_node:
				all_lines.append(line_node)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		check_click_on_areas(event.position)

func check_click_on_areas(click_pos: Vector2):
	for area_name in areas:
		var area = areas[area_name]
		if is_point_in_area(area, click_pos):
			show_lines_for_area(area_name)
			break

func is_point_in_area(area: Area2D, point: Vector2) -> bool:
	var collision_shape = area.get_node("CollisionShape2D")
	if not collision_shape or not collision_shape.shape:
		return false
	var local_point = area.to_local(point)
	return collision_shape.shape.get_rect().has_point(local_point)

func show_lines_for_area(area_name: String):
	hide_all_lines()
	if area_name in area_line_mapping:
		for line_name in area_line_mapping[area_name]:
			var line_node = get_node_or_null(line_name)
			if line_node:
				line_node.visible = true

func hide_all_lines():
	for line in all_lines:
		if line and is_instance_valid(line):
			line.visible = false
