class_name SacramentalRiteEffect

static func activate_rite(card: Node):
	var root = card.get_tree().current_scene
	var main_field = root.find_child("MAINFIELD", true, false)
	
	if not main_field or not main_field.get("current_champion_card"):
		return
		
	main_field.sacramental_rite_active = true
	
	var multiplayer_node = root.get_node_or_null("Main")
	if not multiplayer_node and root.name == "Main":
		multiplayer_node = root
	
	if multiplayer_node and multiplayer_node.has_method("rpc"):
		var my_id = multiplayer_node.multiplayer.get_unique_id()
		multiplayer_node.rpc("sync_sacramental_rite_activate", my_id)

	if card and is_instance_valid(card) and card.has_method("go_to_banish_face_up"):
		card.go_to_banish_face_up()

static func apply_opponent_activation(root: Node):
	var opp_main_field = root.find_child("OpponentMainField", true, false)
	if opp_main_field:
		opp_main_field.sacramental_rite_active = true
