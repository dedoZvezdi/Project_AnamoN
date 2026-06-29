extends Control

@onready var p1_ready_btn: Button = $RootVBox/Arena/Player1Half/Margin/VBox/ReadyButton
@onready var p1_status_label: Label = $RootVBox/Arena/Player1Half/Margin/VBox/StatusRow/StatusLabel
@onready var p1_status_dot: ColorRect = $RootVBox/Arena/Player1Half/Margin/VBox/StatusRow/Dot
@onready var p1_progress_fill: Panel = $RootVBox/Arena/Player1Half/Margin/VBox/ProgressBar/Fill
@onready var p1_name_input: LineEdit = $RootVBox/Arena/Player1Half/Margin/VBox/PlayerIdentity/NameInput
@onready var p1_avatar_frame: Panel = $RootVBox/Arena/Player1Half/Margin/VBox/AvatarFrame
@onready var p2_ready_btn: Button = $RootVBox/Arena/Player2Half/Margin/VBox/ReadyButton
@onready var p2_status_label: Label = $RootVBox/Arena/Player2Half/Margin/VBox/StatusRow/StatusLabel
@onready var p2_status_dot: ColorRect = $RootVBox/Arena/Player2Half/Margin/VBox/StatusRow/Dot
@onready var p2_progress_fill: Panel = $RootVBox/Arena/Player2Half/Margin/VBox/ProgressBar/Fill
@onready var p2_name_input: LineEdit = $RootVBox/Arena/Player2Half/Margin/VBox/PlayerIdentity/NameInput
@onready var p2_avatar_frame: Panel = $RootVBox/Arena/Player2Half/Margin/VBox/AvatarFrame
@onready var start_button: Button = $RootVBox/Arena/CenterCol/MarginCenter/InnerVBox/StartButton
@onready var exit_button: Button = $RootVBox/Arena/CenterCol/MarginCenter/InnerVBox/ExitButton

const READY_COLOR = Color(0.133, 0.741, 0.204, 1.0)
const NOT_READY_COLOR = Color(0.941, 0, 0.106, 1.0)
const DOT_DEFAULT_COLOR = Color(1.0, 1.0, 1.0, 0.15)
const FILL_DURATION = 0.6

var p1_ready := false
var p2_ready := false
var p1_photo_rect: TextureRect
var p2_photo_rect: TextureRect

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT, Control.PRESET_MODE_MINSIZE, 0)
	size = get_viewport_rect().size
	get_tree().root.size_changed.connect(func(): size = get_viewport_rect().size)
	p1_progress_fill.anchor_left = 0.0
	p1_progress_fill.anchor_right = 0.0
	p2_progress_fill.anchor_right = 1.0
	p2_progress_fill.anchor_left = 1.0
	p1_ready_btn.pressed.connect(_on_p1_ready_pressed)
	p2_ready_btn.pressed.connect(_on_p2_ready_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	start_button.pressed.connect(_on_start_pressed)
	var circle_shader = Shader.new()
	circle_shader.code = """
shader_type canvas_item;
void fragment() {
	vec2 uv = UV - vec2(0.5);
	float dist = length(uv);
	float alpha = 1.0 - smoothstep(0.48, 0.5, dist);
	vec4 tex_color = texture(TEXTURE, UV);
	COLOR = vec4(tex_color.rgb, tex_color.a * alpha);
}
	"""
	var circle_mat = ShaderMaterial.new()
	circle_mat.shader = circle_shader
	p1_avatar_frame.clip_children = CanvasItem.CLIP_CHILDREN_DISABLED
	p2_avatar_frame.clip_children = CanvasItem.CLIP_CHILDREN_DISABLED
	p1_photo_rect = TextureRect.new()
	p1_photo_rect.material = circle_mat
	p1_photo_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	p1_photo_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	p1_avatar_frame.add_child(p1_photo_rect)
	p1_photo_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	p1_photo_rect.offset_left = 2
	p1_photo_rect.offset_top = 2
	p1_photo_rect.offset_right = -2
	p1_photo_rect.offset_bottom = -2
	p2_photo_rect = TextureRect.new()
	p2_photo_rect.material = circle_mat
	p2_photo_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	p2_photo_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	p2_avatar_frame.add_child(p2_photo_rect)
	p2_photo_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	p2_photo_rect.offset_left = 2
	p2_photo_rect.offset_top = 2
	p2_photo_rect.offset_right = -2
	p2_photo_rect.offset_bottom = -2
	check_start_button()

func setup_host(player_name: String):
	p1_name_input.text = player_name
	p1_ready_btn.disabled = false
	p2_ready_btn.disabled = true
	start_button.visible = true
	_apply_local_photo(p1_photo_rect)
	p2_name_input.text = "Waiting..."
	
func setup_client(player_name: String):
	p2_name_input.text = player_name
	p1_ready_btn.disabled = true
	p2_ready_btn.disabled = false
	start_button.visible = false
	_apply_local_photo(p2_photo_rect)
	p1_name_input.text = "Waiting..."

func set_opponent_name(player_name: String):
	if multiplayer.is_server():
		p2_name_input.text = player_name
	else:
		p1_name_input.text = player_name

func _apply_local_photo(rect: TextureRect):
	var multiplayer_node = get_parent()
	if not multiplayer_node or not multiplayer_node.has_method("_get_opponent_photo_path"): return
	var texture = null
	if FileAccess.file_exists(multiplayer_node.USER_PHOTO_PATH):
		var img = Image.load_from_file(multiplayer_node.USER_PHOTO_PATH)
		if img:
			texture = ImageTexture.create_from_image(img)
	if not texture and ResourceLoader.exists(multiplayer_node.DEFAULT_PHOTO_PATH):
		texture = ResourceLoader.load(multiplayer_node.DEFAULT_PHOTO_PATH, "", ResourceLoader.CACHE_MODE_REPLACE)
	if texture:
		rect.texture = texture

func apply_opponent_photo():
	var multiplayer_node = get_parent()
	if not multiplayer_node or not multiplayer_node.has_method("_get_opponent_photo_path"): return
	var texture = null
	var opp_photo_path = multiplayer_node._get_opponent_photo_path()
	if FileAccess.file_exists(opp_photo_path):
		var img = Image.load_from_file(opp_photo_path)
		if img:
			texture = ImageTexture.create_from_image(img)
	if not texture and ResourceLoader.exists(multiplayer_node.DEFAULT_PHOTO_PATH):
		texture = ResourceLoader.load(multiplayer_node.DEFAULT_PHOTO_PATH, "", ResourceLoader.CACHE_MODE_REPLACE)
	if texture:
		if multiplayer.is_server():
			p2_photo_rect.texture = texture
		else:
			p1_photo_rect.texture = texture

func apply_opponent_photo_direct(texture: Texture2D):
	if texture:
		if multiplayer.is_server():
			p2_photo_rect.texture = texture
		else:
			p1_photo_rect.texture = texture

func on_client_disconnected():
	p2_name_input.text = "Waiting..."
	p2_photo_rect.texture = null
	p2_ready = false
	_update_player_ui(p2_ready, p2_ready_btn, p2_status_label, p2_status_dot, p2_progress_fill, true)
	check_start_button()

func _on_p1_ready_pressed() -> void:
	p1_ready = !p1_ready
	_update_player_ui(p1_ready, p1_ready_btn, p1_status_label, p1_status_dot, p1_progress_fill, false)
	rpc("sync_ready_state", 1, p1_ready)
	check_start_button()

func _on_p2_ready_pressed() -> void:
	p2_ready = !p2_ready
	_update_player_ui(p2_ready, p2_ready_btn, p2_status_label, p2_status_dot, p2_progress_fill, true)
	rpc("sync_ready_state", 2, p2_ready)

@rpc("any_peer", "reliable")
func sync_ready_state(player_num: int, is_ready: bool):
	if player_num == 1:
		p1_ready = is_ready
		_update_player_ui(p1_ready, p1_ready_btn, p1_status_label, p1_status_dot, p1_progress_fill, false)
	else:
		p2_ready = is_ready
		_update_player_ui(p2_ready, p2_ready_btn, p2_status_label, p2_status_dot, p2_progress_fill, true)
	check_start_button()

func check_start_button():
	if multiplayer.is_server():
		start_button.disabled = not (p1_ready and p2_ready)

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

func _on_exit_pressed():
	var multiplayer_node = get_parent()
	if multiplayer_node and multiplayer_node.has_method("reset_ui"):
		multiplayer_node.reset_ui()

func _on_start_pressed():
	if multiplayer.is_server() and p1_ready and p2_ready:
		print("Start game clicked. (Placeholder for starting the game)")
		var dialog = AcceptDialog.new()
		dialog.dialog_text = "Game starting... (Test Mode)"
		dialog.title = "INFO"
		add_child(dialog)
		dialog.popup_centered()
		rpc("sync_start_game")

@rpc("any_peer", "reliable")
func sync_start_game():
	print("Sync Start game received. (Placeholder)")
	var dialog = AcceptDialog.new()
	dialog.dialog_text = "Game starting... (Test Mode)"
	dialog.title = "INFO"
	add_child(dialog)
	dialog.popup_centered()
