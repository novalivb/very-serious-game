class_name PauseScreen extends Control

signal unpause_requested
signal menu_requested

@export var default_pause_button : Button

@onready var resume_button: Button = %ResumeButton
@onready var menu_button: Button = %MenuButton

func _ready() -> void:
	Global.input_device_switched.connect(switch_inputs)
	
	resume_button.pressed.connect(_on_pause_screen_button_pressed, CONNECT_APPEND_SOURCE_OBJECT)
	menu_button.pressed.connect(_on_pause_screen_button_pressed, CONNECT_APPEND_SOURCE_OBJECT)


func switch_inputs(is_mnk : bool):
	if not visible: return
	
	if is_mnk: enable_mouse_and_keyboard()
	else: enable_joypad()

func enable_mouse_and_keyboard():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_viewport().gui_release_focus()

func enable_joypad():
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if get_viewport().gui_get_focus_owner() == null:
		default_pause_button.grab_focus()



func _on_pause_screen_button_pressed(button : Button):
	match button:
		resume_button:
			unpause_requested.emit()
		menu_button:
			menu_requested.emit()


func _on_visibility_changed() -> void:
	if not visible:
		#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return
	
	elif not Global.using_mouse_and_keyboard:
		default_pause_button.grab_focus()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
