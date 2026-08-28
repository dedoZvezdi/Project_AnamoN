extends PanelContainer

@onready var creator_label = $MarginContainer/MainRow/InfoCol/CreatorName
@onready var mode_label = $MarginContainer/MainRow/InfoCol/ModeDetails
@onready var room_message_label = $MarginContainer/MainRow/RoomMessage
@onready var player_count_label = $MarginContainer/MainRow/PlayerCol/PlayerCount
@onready var p1_panel = $MarginContainer/MainRow/PlayerCol/Player1PanelIcon
@onready var p2_panel = $MarginContainer/MainRow/PlayerCol/Player2PanelIcon
@onready var vs_label = $MarginContainer/MainRow/PlayerCol/VSLabel
@onready var join_btn = $JoinButton

signal room_selected(data, node)
signal room_joined_double_click(data)

var room_data = {}
var is_selected = false
var normal_style = null
var selected_style = null

func _ready():
	join_btn.gui_input.connect(_on_join_btn_gui_input)
	join_btn.mouse_entered.connect(_on_hover)
	join_btn.mouse_exited.connect(_on_unhover)
	join_btn.button_down.connect(_on_press)
	join_btn.button_up.connect(_on_release)

func set_selected(selected: bool):
	is_selected = selected
	if is_selected:
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(1.8, 1.8, 1.8, 1.0), 0.15)
		if selected_style:
			add_theme_stylebox_override("panel", selected_style)
	else:
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.15)
		if normal_style:
			add_theme_stylebox_override("panel", normal_style)

func _on_hover():
	if is_selected: return
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1.5, 1.5, 1.5, 1.0), 0.1)

func _on_unhover():
	if is_selected: return
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)

func _on_press():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(0.4, 0.4, 0.4, 1.0), 0.05)
	tween.parallel().tween_property(self, "scale", Vector2(0.98, 0.98), 0.05)

func _on_release():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	if is_selected:
		tween.parallel().tween_property(self, "modulate", Color(1.8, 1.8, 1.8, 1.0), 0.1)
	else:
		tween.parallel().tween_property(self, "modulate", Color(1.5, 1.5, 1.5, 1.0), 0.1)

func setup(data):
	room_data = data
	creator_label.text = data.get("creator", "Unknown")
	var is_private = data.get("is_private", false)
	var privacy_text = "Private" if is_private else "Public"
	mode_label.text = "%s | %s | %s" % [data.get("mode", "Standard"), data.get("legality", "Match"), privacy_text]
	var players = data.get("players", 1)
	var max_p = data.get("max", 2)
	var style = get_theme_stylebox("panel").duplicate()
	if is_private:
		if players == 1:
			style.bg_color = Color("8c6f2e25")
			style.border_color = Color("8c6f2e")
		else:
			style.bg_color = Color("2b2b2b80")
			style.border_color = Color("404040")
	else:
		if players == 1:
			style.bg_color = Color("22bd3438")
			style.border_color = Color("22bd34")
		else:
			style.bg_color = Color("df27061f")
			style.border_color = Color("df2706")
	add_theme_stylebox_override("panel", style)
	if data.has("message") and data["message"] != "":
		room_message_label.text = '"' + data["message"] + '"'
	else:
		room_message_label.text = ""
	player_count_label.text = "%d/%d" % [players, max_p]
	_setup_avatar(p1_panel, data.get("photo_b64", ""))
	_setup_avatar(p2_panel, data.get("p2_photo_b64", ""))
	if players == 1:
		p2_panel.visible = false
		vs_label.visible = false
	else:
		p2_panel.visible = true
		vs_label.visible = true
	normal_style = style
	selected_style = style.duplicate()
	selected_style.border_color = Color(1.0, 1.0, 1.0, 1.0) 

func _on_join_btn_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if event.double_click:
			emit_signal("room_joined_double_click", room_data)
		else:
			emit_signal("room_selected", room_data, self)

func _setup_avatar(panel: Panel, image_b64: String):
	panel.clip_children = CanvasItem.CLIP_CHILDREN_DISABLED
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
	var profile_picture = TextureRect.new()
	profile_picture.material = circle_mat
	profile_picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	profile_picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	panel.add_child(profile_picture)
	profile_picture.set_anchors_preset(Control.PRESET_FULL_RECT)
	profile_picture.offset_left = 2
	profile_picture.offset_top = 2
	profile_picture.offset_right = -2
	profile_picture.offset_bottom = -2
	var texture = null
	if image_b64 != "":
		var buffer = Marshalls.base64_to_raw(image_b64)
		var img = Image.new()
		var err = img.load_webp_from_buffer(buffer)
		if err == OK:
			texture = ImageTexture.create_from_image(img)
	if not texture:
		var DEFAULT_PHOTO_PATH = "res://Assets/Textures/Player Info/Player_photos/Player_Image.png"
		if ResourceLoader.exists(DEFAULT_PHOTO_PATH):
			texture = ResourceLoader.load(DEFAULT_PHOTO_PATH, "", ResourceLoader.CACHE_MODE_REPLACE)
	if texture:
		profile_picture.texture = texture
