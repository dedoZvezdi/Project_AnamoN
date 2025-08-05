extends Node2D

#var player_hand_node
#
#func _ready():
	#player_hand_node = get_parent().get_node("PlayerHand")
	#
	#if player_hand_node:
		#print("PlayerHand намерен успешно!")
	#
	## Свържи Area2D сигнала
	#if has_node("Area2D"):
		#var area = get_node("Area2D")
		#area.input_event.connect(_on_logo_clicked)
		#print("Area2D свързано!")
#
#func _on_logo_clicked(viewport, event, shape_idx):
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			#print("Логото е кликнато чрез Area2D!")
			#if player_hand_node:
				#player_hand_node.toggle_cards_visibility()
				#print("Картите са toggle-нати!")
