class_name MainMenuUI extends Control

signal start_game

@export var default_menu_button : Button
@export var default_settings_button : Button
@export var default_credits_button : Button

@onready var button_animations: AnimationPlayer = %ButtonAnimations
@onready var logo_animations: AnimationPlayer = %LogoAnimations
@onready var high_value_label: RichTextLabel = %HighValueLabel

# buttons
@onready var start_button: Button = %StartButton
@onready var settings_button: Button = %SettingsButton
@onready var credits_button: Button = %CreditsButton
@onready var quit_button: Button = %QuitButton
@onready var back_button: Button = %BackButton
@onready var delete_high_score_button: Button = %DeleteHighScoreButton
@onready var credits_back_button: Button = %CreditsBackButton
@onready var intro_button: Button = %IntroButton

# ui panels
@onready var settings_menu: MarginContainer = %SettingsMenu
@onready var main_buttons: VBoxContainer = %MainButtons
@onready var credits: MarginContainer = %Credits
@onready var menu: MarginContainer = %Menu

# volume sliders
@onready var sfx_slider: VolumeSlider = %SFXSlider
@onready var music_slider: VolumeSlider = %MusicSlider
@onready var master_slider: VolumeSlider = %MasterSlider


const MENU_OFFSCREEN_OFFSET : float = 1069



func _ready() -> void:
	Global.input_device_switched.connect(switch_input_device)
	get_viewport().gui_release_focus()
	if not Global.using_mouse_and_keyboard:
		default_menu_button.grab_focus()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	
	logo_animations.play("wiggle")
	settings_menu.offset_transform_position.x = MENU_OFFSCREEN_OFFSET
	update_high_score_label()
	update_audio_settings()
	
	# connect buttons pressed
	start_button.pressed.connect(_on_menu_button_pressed, CONNECT_APPEND_SOURCE_OBJECT)
	settings_button.pressed.connect(_on_menu_button_pressed, CONNECT_APPEND_SOURCE_OBJECT)
	credits_button.pressed.connect(_on_menu_button_pressed, CONNECT_APPEND_SOURCE_OBJECT)
	quit_button.pressed.connect(_on_menu_button_pressed, CONNECT_APPEND_SOURCE_OBJECT)
	back_button.pressed.connect(_on_menu_button_pressed, CONNECT_APPEND_SOURCE_OBJECT)
	delete_high_score_button.pressed.connect(_on_menu_button_pressed, CONNECT_APPEND_SOURCE_OBJECT)
	credits_back_button.pressed.connect(_on_menu_button_pressed, CONNECT_APPEND_SOURCE_OBJECT)
	intro_button.pressed.connect(_on_menu_button_pressed, CONNECT_APPEND_SOURCE_OBJECT)
	
	
	# connect buttons mouse entered to grab focus
	start_button.mouse_entered.connect(focus_button, CONNECT_APPEND_SOURCE_OBJECT)
	settings_button.mouse_entered.connect(focus_button, CONNECT_APPEND_SOURCE_OBJECT)
	credits_button.mouse_entered.connect(focus_button, CONNECT_APPEND_SOURCE_OBJECT)
	quit_button.mouse_entered.connect(focus_button, CONNECT_APPEND_SOURCE_OBJECT)
	back_button.mouse_entered.connect(focus_button, CONNECT_APPEND_SOURCE_OBJECT)
	delete_high_score_button.mouse_entered.connect(focus_button, CONNECT_APPEND_SOURCE_OBJECT)
	credits_back_button.mouse_entered.connect(focus_button, CONNECT_APPEND_SOURCE_OBJECT)
	intro_button.mouse_entered.connect(focus_button, CONNECT_APPEND_SOURCE_OBJECT)
	
	
	# connect buttons focused
	start_button.focus_entered.connect(_on_menu_button_focused)
	settings_button.focus_entered.connect(_on_menu_button_focused)
	credits_button.focus_entered.connect(_on_menu_button_focused)
	quit_button.focus_entered.connect(_on_menu_button_focused)
	back_button.focus_entered.connect(_on_menu_button_focused)
	delete_high_score_button.focus_entered.connect(_on_menu_button_focused)
	credits_back_button.focus_entered.connect(_on_menu_button_focused)
	intro_button.focus_entered.connect(_on_menu_button_focused)
	
	
	# connect sliders
	master_slider.drag_ended.connect(_on_master_slider_drag_ended)
	sfx_slider.drag_ended.connect(_on_sfx_slider_drag_ended)
	music_slider.drag_ended.connect(_on_music_slider_drag_ended)
	
func switch_input_device(is_mnk : bool):
	if is_mnk: enable_mouse_and_keyboard()
	else: enable_joypad()

func enable_mouse_and_keyboard():
	get_viewport().gui_release_focus()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func enable_joypad():
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if get_viewport().gui_get_focus_owner() == null:
		if credits.visible:
			default_credits_button.grab_focus()
		elif settings_menu.visible:
			default_settings_button.grab_focus()
		else:
			default_menu_button.grab_focus()

func focus_button(button : Button):
	button.grab_focus()

func _on_menu_button_focused():
	AudioManager.create_sound_effect(SoundEffectSettings.SOUND_EFFECT_TYPE.UI_HOVER)

func _on_menu_button_pressed(button : Button):
	match button:
		start_button:
			AudioManager.create_sound_effect(SoundEffectSettings.SOUND_EFFECT_TYPE.UI_ACCEPT)
			button_animations.play("start_pressed")
			start_game.emit()
		settings_button:
			AudioManager.create_sound_effect(SoundEffectSettings.SOUND_EFFECT_TYPE.UI_SWOOP)
			swap_to_settings()
		back_button:
			AudioManager.create_sound_effect(SoundEffectSettings.SOUND_EFFECT_TYPE.UI_SWOOP)
			swap_to_main_buttons()
		delete_high_score_button:
			AudioManager.create_sound_effect(SoundEffectSettings.SOUND_EFFECT_TYPE.UI_ACCEPT)
			delete_high_score()
		credits_button:
			AudioManager.create_sound_effect(SoundEffectSettings.SOUND_EFFECT_TYPE.UI_ACCEPT)
			show_credits()
		quit_button:
			AudioManager.create_sound_effect(SoundEffectSettings.SOUND_EFFECT_TYPE.UI_CANCEL)
			await AudioManager.sfx.get_child(-1).finished
			get_tree().quit()
		credits_back_button:
			AudioManager.create_sound_effect(SoundEffectSettings.SOUND_EFFECT_TYPE.UI_CANCEL)
			hide_credits()
		intro_button:
			AudioManager.create_sound_effect(SoundEffectSettings.SOUND_EFFECT_TYPE.UI_ACCEPT)
			await Global.mainScene.play_intro()
			Global.mainScene.start_menu_or_game()

func swap_to_settings():
	button_animations.play("swap_to_settings")
	get_viewport().gui_release_focus()
	await button_animations.animation_finished
	if not Global.using_mouse_and_keyboard:
		default_settings_button.grab_focus()

func swap_to_main_buttons():
	button_animations.play("swap_to_main_buttons")
	get_viewport().gui_release_focus()
	await button_animations.animation_finished
	if not Global.using_mouse_and_keyboard:
		default_menu_button.grab_focus()

func delete_high_score():
	ConfigFileHandler.save_player_setting("high_score", 0.0)
	update_high_score_label()

func update_high_score_label():
	var high_score : int = ConfigFileHandler.load_player_settings()["high_score"] as int
	high_value_label.text = "%d00" %high_score

func show_credits():
	if credits == null or menu == null: return
	
	credits.show()
	get_viewport().gui_release_focus()
	if not Global.using_mouse_and_keyboard:
		default_credits_button.grab_focus()
	menu.hide()

func hide_credits():
	if credits == null or menu == null: return
	menu.show()
	get_viewport().gui_release_focus()
	if not Global.using_mouse_and_keyboard:
		default_menu_button.grab_focus()
	credits.hide()


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
