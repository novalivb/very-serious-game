class_name PauseScreen extends Control

signal unpause_requested
signal menu_requested

@onready var resume_button: Button = %ResumeButton
@onready var menu_button: Button = %MenuButton

func _ready() -> void:
	resume_button.pressed.connect(_on_pause_screen_button_pressed, CONNECT_APPEND_SOURCE_OBJECT)
	menu_button.pressed.connect(_on_pause_screen_button_pressed, CONNECT_APPEND_SOURCE_OBJECT)


func _on_pause_screen_button_pressed(button : Button):
	match button:
		resume_button:
			unpause_requested.emit()
		menu_button:
			menu_requested.emit()
