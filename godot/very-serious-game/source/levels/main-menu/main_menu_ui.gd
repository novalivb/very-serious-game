extends Control

signal start_game

@onready var button_animations: AnimationPlayer = %ButtonAnimations
@onready var high_value_label: RichTextLabel = %HighValueLabel

# buttons
@onready var start_button: Button = %StartButton
@onready var levels_button: Button = %LevelsButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	start_button.pressed.connect(_on_menu_button_pressed, CONNECT_APPEND_SOURCE_OBJECT)
	var high_score : int = ConfigFileHandler.load_player_settings()["high_score"] as int
	high_value_label.text = "%d" %high_score

func _on_menu_button_pressed(button : Button):
	match button.name:
		"StartButton":
			button_animations.play("start_pressed")
			start_game.emit()
		"LevelsButton":
			pass
		"SettingsButton":
			pass
		"QuitButton":
			get_tree().quit()
