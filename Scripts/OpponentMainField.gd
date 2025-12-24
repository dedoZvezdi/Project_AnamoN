extends Node2D

var cards_in_field: Array = []
var base_position := Vector2.ZERO
var current_mastery_card: Node = null

func _ready() -> void:
	base_position = Vector2.ZERO

func add_card_to_field(card: Node, target_pos: Vector2, target_rot_deg: float = 0.0) -> void:
	if not card or not is_instance_valid(card):
		return
	if is_mastery_card(card):
		if current_mastery_card != null and current_mastery_card != card:
			remove_previous_mastery()
		current_mastery_card = card
	if card.has_method("set_current_field"):
		card.set_current_field(self)
	if card not in cards_in_field:
		cards_in_field.append(card)
	var card_image = card.get_node_or_null("CardImage")
	var card_image_back = card.get_node_or_null("CardImageBack")
	if card_image and card_image_back:
		card_image_back.z_index = -1
		card_image.z_index = 0
		card_image_back.visible = false
		card_image.visible = true
	var tween = create_tween()
	tween.parallel().tween_property(card, "global_position", target_pos, 0.2)
	tween.parallel().tween_property(card, "rotation_degrees", target_rot_deg, 0.2)
	card.z_index = 200 + cards_in_field.size()

func remove_previous_mastery():
	if current_mastery_card and is_instance_valid(current_mastery_card):
		cards_in_field.erase(current_mastery_card)
		current_mastery_card.queue_free()
		current_mastery_card = null

func is_mastery_card(card) -> bool:
	if not card or not is_instance_valid(card):
		return false
	if card.has_method("is_mastery"):
		return card.is_mastery()
	var slug = ""
	if card.has_meta("slug"):
		slug = card.get_meta("slug")
	var logos = get_tree().get_nodes_in_group("logo")
	if logos.size() > 0:
		var logo = logos[0]
		if "mastery_slugs" in logo:
			return slug in logo.mastery_slugs
	return false

func remove_card_from_field(card: Node) -> void:
	if card in cards_in_field:
		cards_in_field.erase(card)
		if card.has_method("set_current_field"):
			card.set_current_field(null)

func bring_card_to_front(card: Node) -> void:
	var idx := cards_in_field.find(card)
	if idx == -1:
		return
	for i in range(cards_in_field.size()):
		var c = cards_in_field[i]
		if c and is_instance_valid(c):
			if i >= idx:
				c.z_index = 200 + i + 50
			else:
				c.z_index = 200 + i + 1

func clear_hovered_card() -> void:
	for i in range(cards_in_field.size()):
		var c = cards_in_field[i]
		if c and is_instance_valid(c):
			c.z_index = 200 + i + 1

func connect_card_signals(card):
	var card_manager = get_tree().get_root().find_child("CardManager", true, false)
	if card_manager and card_manager.has_method("connect_card_signals"):
		card_manager.connect_card_signals(card)
