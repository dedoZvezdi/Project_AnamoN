extends Node2D

const PHASE_ORDER = ["WAKE UP", "MATERIALIZE", "RECOLLECTION", "DRAW", "MAIN", "END"]

var current_phase_index = 0

@onready var phases_label = $PhasesLabel
@onready var next_button = $RightArrowButton
@onready var back_button = $LeftArrowButton

func _ready():
	next_button.pressed.connect(next_phase)
	back_button.pressed.connect(back_phase)
	update_phase_visuals()

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
	phases_label.text = current_phase_name
	
	var is_wake_up = (current_phase_index == 0)
	back_button.visible = !is_wake_up
	var multiplayer_node = get_tree().get_root().get_node_or_null("Main")
	if multiplayer_node:
		var enough_players = multiplayer_node.multiplayer.get_peers().size() >= 1
		var my_turn = multiplayer_node.get("is_my_turn") == true
		var can_interact = enough_players and my_turn
		next_button.visible = can_interact
		back_button.visible = can_interact and !is_wake_up

func sync_phase_with_opponent():
	var phase_name = PHASE_ORDER[current_phase_index]
	var multiplayer_node = get_tree().get_root().get_node_or_null("Main")
	if multiplayer_node and multiplayer_node.has_method("rpc"):
		multiplayer_node.rpc("sync_opponent_phase", phase_name)

func receive_opponent_phase_sync(phase_name: String):
	for i in range(PHASE_ORDER.size()):
		if PHASE_ORDER[i].to_upper() == phase_name.to_upper():
			current_phase_index = i
			update_phase_visuals()
			return
