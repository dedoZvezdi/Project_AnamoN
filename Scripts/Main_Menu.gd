extends Control

@onready var info_panel = null
@onready var info_area = $Info/Area2D
@onready var quit_area = $Quit_button/Area2D
@onready var local_area = $Local_button/Area2D
@onready var online_area = $Online_button/Area2D
@onready var decks_area = $Decks_button/Area2D
@onready var settings_area = $Settings/Area2D
@onready var volume_area = $Volume/Area2D
@onready var music_area = $Music/Area2D

const COLOR_NORMAL = Color(1.0, 1.0, 1.0)
const COLOR_HOVER = Color(0.7, 0.7, 0.7)
const COLOR_PRESSED = Color(0.2, 0.2, 0.2)

func _ready():
	$Menu_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_setup_info_panel()
	_toggle_info()

func _setup_info_panel():
	info_panel = PanelContainer.new()
	info_panel.name = "InfoPanel"
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.1, 0.95)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(20)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.8, 0.1, 0.1, 1.0)
	style.shadow_size = 15
	style.shadow_color = Color(0, 0, 0, 0.6)
	info_panel.add_theme_stylebox_override("panel", style)
	var label = RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.custom_minimum_size = Vector2(400, 0)
	var text = "[center]"
	text += "[color=red][font_size=26][b]Beta Version 0.2.0[/b][/font_size][/color]\n\n"
	text += "[color=white][font_size=18]"
	text += "AnamoN is a fan-based game aiming to allow players to play multiple TCGs in a single application. "
	text += "It is currently in beta, so many features are experimental and may not work as intended.\n\n"
	text += "[b]Future Plans:[/b]\n"
	text += "• [color=orange]Near Future:[/color] Servers, sound effects, and ease-of-use settings.\n"
	text += "• [color=orange]Distant Future:[/color] Support for 4 or more players."
	text += "[/font_size][/color]"
	text += "[/center]"
	label.text = text
	info_panel.add_child(label)
	add_child(info_panel)
	info_panel.hide()

func _process(_delta):
	_update_hover_states()

func _update_hover_states():
	var buttons = [$Online_button, $Local_button, $Decks_button, $Quit_button, $Settings, $Volume, $Music, $Info]
	for btn in buttons:
		var area = btn.get_node_or_null("Area2D")
		if area and is_mouse_over_area(area):
			if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				var target_color = COLOR_HOVER
				target_color.a = btn.modulate.a
				btn.modulate = target_color
		else:
			var target_color = COLOR_NORMAL
			target_color.a = btn.modulate.a
			btn.modulate = target_color

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if is_mouse_over_area(info_area):
				$Info.modulate = COLOR_PRESSED
				_toggle_info()
			elif is_mouse_over_area(quit_area):
				$Quit_button.modulate = COLOR_PRESSED
			elif is_mouse_over_area(local_area):
				$Local_button.modulate = COLOR_PRESSED
			elif is_mouse_over_area(online_area):
				$Online_button.modulate = COLOR_PRESSED
				print("Online button pressed")
			elif is_mouse_over_area(decks_area):
				$Decks_button.modulate = COLOR_PRESSED
				print("Decks button pressed")
			elif is_mouse_over_area(settings_area):
				$Settings.modulate = COLOR_PRESSED
				print("Settings button pressed")
			elif is_mouse_over_area(volume_area):
				$Volume.modulate = COLOR_PRESSED
				_apply_special_effect($Volume)
			elif is_mouse_over_area(music_area):
				$Music.modulate = COLOR_PRESSED
				_apply_special_effect($Music)
		else:
			if is_mouse_over_area(quit_area):
				get_tree().quit()
			elif is_mouse_over_area(local_area):
				get_tree().change_scene_to_file("res://Scenes/Main.tscn")
			var btns = [$Info, $Quit_button, $Local_button, $Online_button, $Decks_button, $Settings, $Volume, $Music]
			for b in btns:
				var c = COLOR_NORMAL
				c.a = b.modulate.a
				b.modulate = c

func _apply_special_effect(node: Sprite2D):
	if node.rotation_degrees != 0:
		node.modulate.a = 1.0
		node.rotation_degrees = 0
	else:
		node.modulate.a = 0.7
		var angle = randf_range(7.0, 15.0)
		if randf() > 0.5:
			angle = -angle
		node.rotation_degrees = angle

func _toggle_info():
	info_panel.visible = !info_panel.visible
	if info_panel.visible:
		await get_tree().process_frame
		info_panel.global_position = $Info.global_position - Vector2(info_panel.size.x + 20, info_panel.size.y + 20)

func is_mouse_over_area(area: Area2D) -> bool:
	var collision_shape = area.get_node_or_null("CollisionShape2D")
	if not collision_shape or not collision_shape.shape or collision_shape.disabled:
		return false
	var local_point = area.get_local_mouse_position()
	var shape = collision_shape.shape
	if shape is RectangleShape2D:
		var rect = Rect2(-shape.size / 2, shape.size)
		return rect.has_point(local_point)
	return false
