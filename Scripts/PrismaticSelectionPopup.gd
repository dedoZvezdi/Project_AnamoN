extends CanvasLayer

signal selection_confirmed(elements)

var selected_elements := []
var confirm_button: Button
var element_buttons := {}
var panel: PanelContainer

func _ready():
	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(400, 250)
	panel.set_anchor(SIDE_LEFT, 0.5)
	panel.set_anchor(SIDE_TOP, 0.5)
	panel.set_anchor(SIDE_RIGHT, 0.5)
	panel.set_anchor(SIDE_BOTTOM, 0.5)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.15, 1.0)
	style.set_border_width_all(2)
	style.border_color = Color(0.4, 0.4, 0.4)
	style.set_corner_radius_all(10)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	panel.add_child(margin)
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)
	margin.add_child(vbox)
	var title = Label.new()
	title.text = "Prismatic Spirit: Choose 2 Elements"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 20)
	vbox.add_child(hbox)
	for e_name in ["Fire", "Water", "Wind"]:
		var btn = Button.new()
		btn.text = e_name
		btn.toggle_mode = true
		btn.custom_minimum_size = Vector2(100, 50)
		btn.pressed.connect(func(): _on_element_toggled(e_name))
		hbox.add_child(btn)
		element_buttons[e_name] = btn
	confirm_button = Button.new()
	confirm_button.text = "Confirm"
	confirm_button.disabled = true
	confirm_button.custom_minimum_size = Vector2(150, 40)
	confirm_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	confirm_button.pressed.connect(_on_confirm_pressed)
	vbox.add_child(confirm_button)

func _input(event):
	if event is InputEventMouse:
		var mouse_pos = event.global_position
		var over_button = false
		for btn in element_buttons.values():
			if btn.get_global_rect().has_point(mouse_pos):
				over_button = true
				break
		if confirm_button and confirm_button.get_global_rect().has_point(mouse_pos):
			over_button = true
		if not over_button:
			get_viewport().set_input_as_handled()

func _on_element_toggled(element_name: String):
	var btn = element_buttons[element_name]
	if btn.button_pressed:
		if selected_elements.size() >= 2:
			var oldest = selected_elements.pop_front()
			if element_buttons.has(oldest):
				element_buttons[oldest].button_pressed = false
		selected_elements.append(element_name)
	else:
		selected_elements.erase(element_name)
	confirm_button.disabled = (selected_elements.size() != 2)

func _on_confirm_pressed():
	emit_signal("selection_confirmed", selected_elements)
	queue_free()
