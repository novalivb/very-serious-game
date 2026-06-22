extends Control

signal start_game

# buttons
@onready var start_button: Button = %StartButton
@onready var levels_button: Button = %LevelsButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	start_button.pressed.connect(_on_menu_button_pressed, CONNECT_APPEND_SOURCE_OBJECT)


func _on_menu_button_pressed(button : Button):
	match button.name:
		"StartButton":
			start_game.emit()
		"LevelsButton":
			pass
		"SettingsButton":
			pass
		"QuitButton":
			get_tree().quit()
