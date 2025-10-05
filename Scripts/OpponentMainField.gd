extends Node2D

var cards_in_field: Array = []
var base_position := Vector2.ZERO

func _ready() -> void:
	base_position = Vector2.ZERO

func add_card_to_field(card: Node, target_pos: Vector2, target_rot_deg: float = 0.0) -> void:
	if not card or not is_instance_valid(card):
		return
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
	var ap: AnimationPlayer = card.get_node_or_null("AnimationPlayer")
	if ap and ap.has_animation("card_flip"):
		ap.play("card_flip")
	var tween = create_tween()
	tween.parallel().tween_property(card, "global_position", target_pos, 0.2)
	tween.parallel().tween_property(card, "rotation_degrees", target_rot_deg, 0.2)
	card.z_index = 200 + cards_in_field.size()

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
