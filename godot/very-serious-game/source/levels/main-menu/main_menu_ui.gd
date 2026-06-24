extends Control

signal start_game

@onready var button_animations: AnimationPlayer = %ButtonAnimations
@onready var high_value_label: RichTextLabel = %HighValueLabel

# buttons
@onready var start_button: Button = %StartButton
@onready var settings_button: Button = %SettingsButton
@onready var credits_button: Button = %CreditsButton
@onready var quit_button: Button = %QuitButton
@onready var back_button: Button = %BackButton
@onready var delete_high_score_button: Button = %DeleteHighScoreButton

# main buttons/settings pair
@onready var settings_menu: MarginContainer = $Panel/ScreenMargins/HBoxContainer/MarginContainer/SettingsMenu
@onready var main_buttons: VBoxContainer = $Panel/ScreenMargins/HBoxContainer/MarginContainer/MainButtons

# volume sliders
@onready var sfx_slider: VolumeSlider = %SFXSlider
@onready var music_slider: VolumeSlider = %MusicSlider
@onready var master_slider: VolumeSlider = %MasterSlider


const MENU_OFFSCREEN_OFFSET : float = 1069

func _ready() -> void:
	settings_menu.offset_transform_position.x = MENU_OFFSCREEN_OFFSET
	update_high_score_label()
	update_audio_settings()
	
	# connect buttons
	start_button.pressed.connect(_on_menu_button_pressed, CONNECT_APPEND_SOURCE_OBJECT)
	settings_button.pressed.connect(_on_menu_button_pressed, CONNECT_APPEND_SOURCE_OBJECT)
	credits_button.pressed.connect(_on_menu_button_pressed, CONNECT_APPEND_SOURCE_OBJECT)
	quit_button.pressed.connect(_on_menu_button_pressed, CONNECT_APPEND_SOURCE_OBJECT)
	back_button.pressed.connect(_on_menu_button_pressed, CONNECT_APPEND_SOURCE_OBJECT)
	delete_high_score_button.pressed.connect(_on_menu_button_pressed, CONNECT_APPEND_SOURCE_OBJECT)
	
	# connect sliders
	master_slider.drag_ended.connect(_on_master_slider_drag_ended)
	sfx_slider.drag_ended.connect(_on_sfx_slider_drag_ended)
	music_slider.drag_ended.connect(_on_music_slider_drag_ended)

#func load_settings():
	#var sound_settings = ConfigFileHandler.load_audio_settings()

func _on_menu_button_pressed(button : Button):
	match button:
		start_button:
			button_animations.play("start_pressed")
			start_game.emit()
		settings_button:
			swap_to_settings()
		back_button:
			swap_to_main_buttons()
		delete_high_score_button:
			delete_high_score()
		credits_button:
			show_credits()
		quit_button:
			get_tree().quit()

func swap_to_settings():
	button_animations.play("swap_to_settings")

func swap_to_main_buttons():
	button_animations.play("swap_to_main_buttons")

func delete_high_score():
	ConfigFileHandler.save_player_setting("high_score", 0.0)
	update_high_score_label()

func update_high_score_label():
	var high_score : int = ConfigFileHandler.load_player_settings()["high_score"] as int
	high_value_label.text = "%d" %high_score

func show_credits():
	pass


func update_audio_settings():
	var audio_settings : Dictionary = ConfigFileHandler.load_audio_settings()
	for key in audio_settings:
		match key:
			"master_volume":
				master_slider.value = master_slider.bus_to_bar(audio_settings[key])
			"sfx_volume":
				sfx_slider.value = sfx_slider.bus_to_bar(audio_settings[key])
			"music_volume":
				music_slider.value = music_slider.bus_to_bar(audio_settings[key])

func _on_master_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		ConfigFileHandler.save_audio_setting("master_volume", master_slider.bar_to_bus(master_slider.value))

func _on_sfx_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		ConfigFileHandler.save_audio_setting("sfx_volume", sfx_slider.bar_to_bus(sfx_slider.value))

func _on_music_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		ConfigFileHandler.save_audio_setting("music_volume", music_slider.bar_to_bus(music_slider.value))
