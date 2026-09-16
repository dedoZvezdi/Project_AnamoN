extends CanvasLayer

signal chosen(index: int)

var _buttons := []

@onready var title_label: Label = %TitleLabel
@onready var message_label: Label = %MessageLabel
@onready var button_row: HBoxContainer = %ButtonRow

func setup(title_text: String, message_text: String, buttons: Array) -> void:
	title_label.text = title_text
	message_label.text = message_text
	for i in range(buttons.size()):
		var button = Button.new()
		button.text = str(buttons[i])
		button.custom_minimum_size = Vector2(140, 44)
		button.pressed.connect(_on_button_pressed.bind(i))
		button_row.add_child(button)
		_buttons.append(button)

func _on_button_pressed(index: int) -> void:
	emit_signal("chosen", index)
	queue_free()

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = event.global_position
		for button in _buttons:
			if is_instance_valid(button) and button.get_global_rect().has_point(mouse_pos):
				return
		get_viewport().set_input_as_handled()
