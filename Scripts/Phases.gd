extends Node2D

const PHASE_ORDER = ["Wake up", "Materialize", "Recollection", "Draw", "Main", "End"]
const PHASE_TEXTURES = {
	"Wake up": "res://Assets/Textures/Phases/Wake_up_phase.png",
	"Materialize": "res://Assets/Textures/Phases/Materialize_phase.png",
	"Recollection": "res://Assets/Textures/Phases/Recollection_phase.png",
	"Draw": "res://Assets/Textures/Phases/Draw_phase.png",
	"Main": "res://Assets/Textures/Phases/Main_phase.png",
	"End": "res://Assets/Textures/Phases/End_phase.png"}

var current_phase_index = 0

@onready var phases_sprite = $Phases
@onready var next_button_area = $NextSquareButton/NextArea2D
@onready var back_button_area = $BackSquareButton/BackArea2D

func _ready():
	update_phase_visuals()

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if is_mouse_over_area(next_button_area):
				next_button_area.get_parent().modulate = Color(0.2, 0.2, 0.2)
				next_phase()
			elif is_mouse_over_area(back_button_area):
				back_button_area.get_parent().modulate = Color(0.2, 0.2, 0.2)
				back_phase()
		else:
			next_button_area.get_parent().modulate.r = 1.0
			next_button_area.get_parent().modulate.g = 1.0
			next_button_area.get_parent().modulate.b = 1.0
			back_button_area.get_parent().modulate.r = 1.0
			back_button_area.get_parent().modulate.g = 1.0
			back_button_area.get_parent().modulate.b = 1.0

func is_mouse_over_area(area: Area2D) -> bool:
	var collision_shape = area.get_node("CollisionShape2D")
	if not collision_shape or not collision_shape.shape or collision_shape.disabled:
		return false
	var local_point = area.get_local_mouse_position()
	var shape = collision_shape.shape
	if shape is RectangleShape2D:
		var rect = Rect2(-shape.size / 2, shape.size)
		return rect.has_point(local_point)
	return false

func next_phase():
	var is_end_phase = (current_phase_index == PHASE_ORDER.size() - 1)
	if is_end_phase:
		var multiplayer_node = get_tree().get_root().get_node_or_null("Main")
		if multiplayer_node and multiplayer_node.has_method("rpc"):
			multiplayer_node.rpc("swap_turns")
	else:
		current_phase_index = (current_phase_index + 1) % PHASE_ORDER.size()
		update_phase_visuals()
		sync_phase_with_opponent()

func back_phase():
	current_phase_index = (current_phase_index - 1)
	if current_phase_index < 0:
		current_phase_index = PHASE_ORDER.size() - 1
	update_phase_visuals()
	sync_phase_with_opponent()

func update_phase_visuals():
	var current_phase_name = PHASE_ORDER[current_phase_index]
	var texture_path = PHASE_TEXTURES[current_phase_name]
	if ResourceLoader.exists(texture_path):
		phases_sprite.texture = load(texture_path)
	var is_wake_up = (current_phase_index == 0)
	var back_button = back_button_area.get_parent()
	back_button.visible = !is_wake_up
	var back_collision = back_button_area.get_node_or_null("CollisionShape2D")
	if back_collision:
		back_collision.disabled = is_wake_up
	var multiplayer_node = get_tree().get_root().get_node_or_null("Main")
	if multiplayer_node:
		var enough_players = multiplayer_node.multiplayer.get_peers().size() >= 1
		var my_turn = multiplayer_node.get("is_my_turn") == true
		var can_interact = enough_players and my_turn
		var next_button = $NextSquareButton
		next_button.visible = can_interact
		back_button.visible = can_interact and !is_wake_up
		var next_collision = next_button_area.get_node_or_null("CollisionShape2D")
		if next_collision:
			next_collision.disabled = !can_interact
		if back_collision:
			back_collision.disabled = is_wake_up or !can_interact

func sync_phase_with_opponent():
	var phase_name = PHASE_ORDER[current_phase_index]
	var multiplayer_node = get_tree().get_root().get_node_or_null("Main")
	if multiplayer_node and multiplayer_node.has_method("rpc"):
		multiplayer_node.rpc("sync_opponent_phase", phase_name)

func receive_opponent_phase_sync(phase_name: String):
	var index = PHASE_ORDER.find(phase_name)
	if index != -1:
		current_phase_index = index
		update_phase_visuals()
