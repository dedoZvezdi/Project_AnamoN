extends Node2D

func host_set_up():
	var opponent_deck_node = get_parent().get_node("OpponentField/OpponentDeck")
	get_parent().get_node("OpponentField/OpponentDeck").deck_size = opponent_deck_node.opponent_deck.size()
	

func client_set_up():
	var opponent_deck_node = get_parent().get_node("OpponentField/OpponentDeck")
	get_parent().get_node("OpponentField/OpponentDeck").deck_size = opponent_deck_node.opponent_deck.size()
