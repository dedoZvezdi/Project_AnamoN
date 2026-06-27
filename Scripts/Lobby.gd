extends Control

@onready var p1_ready_btn: Button = $RootVBox/Arena/Player1Half/Margin/VBox/ReadyButton
@onready var p1_status_label: Label = $RootVBox/Arena/Player1Half/Margin/VBox/StatusRow/StatusLabel
@onready var p1_status_dot: ColorRect = $RootVBox/Arena/Player1Half/Margin/VBox/StatusRow/Dot
@onready var p1_progress_fill: Panel = $RootVBox/Arena/Player1Half/Margin/VBox/ProgressBar/Fill
@onready var p2_ready_btn: Button = $RootVBox/Arena/Player2Half/Margin/VBox/ReadyButton
@onready var p2_status_label: Label = $RootVBox/Arena/Player2Half/Margin/VBox/StatusRow/StatusLabel
@onready var p2_status_dot: ColorRect = $RootVBox/Arena/Player2Half/Margin/VBox/StatusRow/Dot
@onready var p2_progress_fill: Panel = $RootVBox/Arena/Player2Half/Margin/VBox/ProgressBar/Fill

const READY_COLOR = Color(0.133, 0.741, 0.204, 1.0)
const NOT_READY_COLOR = Color(0.941, 0, 0.106, 1.0)
const DOT_DEFAULT_COLOR = Color(1.0, 1.0, 1.0, 0.15)
const FILL_DURATION = 0.6

var p1_ready := false
var p2_ready := false

func _ready() -> void:
	p1_progress_fill.anchor_left = 0.0
	p1_progress_fill.anchor_right = 0.0
	p2_progress_fill.anchor_right = 1.0
	p2_progress_fill.anchor_left = 1.0
	p1_ready_btn.pressed.connect(_on_p1_ready_pressed)
	p2_ready_btn.pressed.connect(_on_p2_ready_pressed)

func _on_p1_ready_pressed() -> void:
	p1_ready = !p1_ready
	_update_player_ui(p1_ready, p1_ready_btn, p1_status_label, p1_status_dot, p1_progress_fill, false)

func _on_p2_ready_pressed() -> void:
	p2_ready = !p2_ready
	_update_player_ui(p2_ready, p2_ready_btn, p2_status_label, p2_status_dot, p2_progress_fill, true)

func _update_player_ui(is_ready: bool, btn: Button, label: Label, dot: ColorRect, fill: Panel, is_right_to_left: bool) -> void:
	btn.text = "READY UP" if !is_ready else "READY!"
	if is_ready:
		label.text = "READY"
		label.add_theme_color_override("font_color", READY_COLOR)
		dot.color = READY_COLOR
	else:
		label.text = "NOT READY"
		label.add_theme_color_override("font_color", NOT_READY_COLOR)
		dot.color = DOT_DEFAULT_COLOR
	var tween = create_tween()
	if is_right_to_left:
		var target_left = 0.0 if is_ready else 1.0
		tween.tween_property(fill, "anchor_left", target_left, FILL_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	else:
		var target_right = 1.0 if is_ready else 0.0
		tween.tween_property(fill, "anchor_right", target_right, FILL_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
