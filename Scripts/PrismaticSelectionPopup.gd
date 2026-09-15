extends CanvasLayer

signal selection_confirmed(elements)

var selected_elements := []
var element_buttons := {}

@onready var confirm_button: Button = %ConfirmButton

func _ready():
	element_buttons = {
		"Fire": %FireButton,
		"Water": %WaterButton,
		"Wind": %WindButton,}
	for e_name in element_buttons:
		var button: Button = element_buttons[e_name]
		button.pressed.connect(_on_element_toggled.bind(e_name))
	confirm_button.pressed.connect(_on_confirm_pressed)

func _input(event):
	if event is InputEventMouse:
		var mouse_pos = event.global_position
		var over_button = false
		for button in element_buttons.values():
			if button.get_global_rect().has_point(mouse_pos):
				over_button = true
				break
		if confirm_button and confirm_button.get_global_rect().has_point(mouse_pos):
			over_button = true
		if not over_button:
			get_viewport().set_input_as_handled()

func _on_element_toggled(element_name: String):
	var button = element_buttons[element_name]
	if button.button_pressed:
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
