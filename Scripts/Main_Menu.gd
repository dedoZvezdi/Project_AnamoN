extends Control

@onready var info_panel = $InfoPanel
@onready var settings_button = $SettingsButton
@onready var volume_button = $VolumeButton
@onready var music_button = $MusicButton

var tex_vol_on = preload("res://Assets/Textures/Main Menu Buttons/volume-on.png")
var tex_vol_off = preload("res://Assets/Textures/Main Menu Buttons/volume-off.png")
var tex_music_on = preload("res://Assets/Textures/Main Menu Buttons/music-on.png")
var tex_music_off = preload("res://Assets/Textures/Main Menu Buttons/music-off.png")
var is_music_on = true
var is_volume_on = true

func _ready():
	$Menu_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toggle_info()
	$OnlineButton.pressed.connect(_on_online_pressed)
	$LocalButton.pressed.connect(_on_local_pressed)
	$DecksButton.pressed.connect(_on_decks_pressed)
	$QuitButton.pressed.connect(_on_quit_pressed)
	$InfoButton.pressed.connect(_toggle_info)
	settings_button.pressed.connect(_on_settings_pressed)
	volume_button.pressed.connect(_on_volume_pressed)
	music_button.pressed.connect(_on_music_pressed)

func _toggle_info():
	info_panel.visible = !info_panel.visible
	if info_panel.visible:
		await get_tree().process_frame
		info_panel.global_position = $InfoButton.global_position - Vector2(info_panel.size.x, info_panel.size.y)

func _on_online_pressed():
	print("Online button pressed")

func _on_local_pressed():
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")

func _on_decks_pressed():
	get_tree().change_scene_to_file("res://Scenes/Deck_Building.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _on_settings_pressed():
	print("Settings button pressed")

func _on_volume_pressed():
	is_volume_on = !is_volume_on
	if is_volume_on:
		volume_button.icon = tex_vol_on
		print("Volume is ON")
	else:
		volume_button.icon = tex_vol_off
		print("Volume is OFF")

func _on_music_pressed():
	is_music_on = !is_music_on
	if is_music_on:
		music_button.icon = tex_music_on
		print("Music is ON")
	else:
		music_button.icon = tex_music_off
		print("Music is OFF")
