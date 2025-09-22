extends Node2D

func host_set_up():
	get_parent().get_node("OpponentField/OpponentDeck").deck_size = 16

	

func client_set_up():
	get_parent().get_node("OpponentField/OpponentDeck").deck_size = 16
