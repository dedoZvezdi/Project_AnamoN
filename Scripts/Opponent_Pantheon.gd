extends Node2D

var pantheon_cards = ["", ""]
var is_flipped = [false, false]
var card_information_reference = null

@onready var left_image = $OpponentLeftCardImage
@onready var right_image = $OpponentRightCardImage
@onready var left_area = $OpponentLeftArea2D
@onready var right_area = $OpponentRightArea2D

const BACK_TEXTURE = preload("res://Assets/Textures/ga_back.png")
const CARD_IMAGE_PATH = "res://Assets/Grand Archive/Card Images/"

func _ready():
	if left_area:
		left_area.connect("mouse_entered", _on_mouse_entered.bind(0))
	if right_area:
		right_area.connect("mouse_entered", _on_mouse_entered.bind(1))
	_find_card_info()
	update_visuals(0)
	update_visuals(1)

func _find_card_info():
	var root = get_tree().current_scene
	if root:
		card_information_reference = _find_node_by_script(root, "res://Scripts/CardInformation.gd")

func _find_node_by_script(node, script_path):
	if node.get_script() and node.get_script().resource_path == script_path:
		return node
	for child in node.get_children():
		var res = _find_node_by_script(child, script_path)
		if res: return res
	return null

func remote_flip(side_index, flipped, slug):
	is_flipped[side_index] = flipped
	pantheon_cards[side_index] = slug
	animate_flip(side_index)

func set_initial_cards(slugs: Array):
	pantheon_cards = slugs
	update_visuals(0)
	update_visuals(1)

func animate_flip(side_index):
	var sprite = left_image if side_index == 0 else right_image
	var tween = create_tween()
	var original_scale_x = 0.17
	tween.tween_property(sprite, "scale:x", 0.01, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func(): update_visuals(side_index))
	tween.tween_property(sprite, "scale:x", original_scale_x, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

func update_visuals(side_index):
	var sprite = left_image if side_index == 0 else right_image
	var area = left_area if side_index == 0 else right_area
	if pantheon_cards[side_index] == "":
		sprite.visible = false
		if area:
			area.get_node("CollisionShape2D").disabled = true
		return
	sprite.visible = true
	if area:
		area.get_node("CollisionShape2D").disabled = false
	if is_flipped[side_index] and pantheon_cards[side_index] != "":
		var slug = pantheon_cards[side_index]
		var tex_path = CARD_IMAGE_PATH + slug + ".png"
		if ResourceLoader.exists(tex_path):
			sprite.texture = load(tex_path)
		else:
			sprite.texture = BACK_TEXTURE
	else:
		sprite.texture = BACK_TEXTURE

func _on_mouse_entered(side_index):
	if is_flipped[side_index] and pantheon_cards[side_index] != "" and card_information_reference:
		card_information_reference.show_card_info(pantheon_cards[side_index])
