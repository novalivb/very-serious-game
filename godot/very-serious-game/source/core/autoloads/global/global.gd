extends Node

signal input_device_switched(is_mouse_and_keyboard : bool)

var mainScene : Main = null
var player : CharacterPlayer = null
var using_mouse_and_keyboard : bool = true:
	set(value):
		using_mouse_and_keyboard = value
		input_device_switched.emit(using_mouse_and_keyboard)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func set_main(main : Main):
	mainScene = main as Main

#region global controls
func _input(event: InputEvent) -> void:
	
	# detect when changing to a controller or back to mnk. emits a signal
	if event is InputEventMouse or event is InputEventKey:
		if not using_mouse_and_keyboard:
			using_mouse_and_keyboard = true
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if using_mouse_and_keyboard:
			using_mouse_and_keyboard = false
	
	if not OS.is_debug_build(): return
	
	if event.is_action_pressed("quit_game"):
		get_tree().quit()
	if event.is_action_pressed("quit_to_main_menu"):
		quit_to_main_menu()
	if event.is_action_pressed("reload_current_level"):
		reload_current_level()
	if event.is_action_pressed("toggle_mouse_capture"):
		toggle_mouse_capture()
		

#endregion

func quit_to_main_menu():
	if mainScene == null:
		return
	AudioManager.stop_ambient()
	mainScene.start_menu_or_game()
	

func reload_current_level():
	if mainScene == null:
		return

func toggle_mouse_capture():
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
