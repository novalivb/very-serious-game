extends Node

var mainScene : Main = null

func set_main(main : Main):
	mainScene = main as Main

#region global controls
func _input(event: InputEvent) -> void:
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
	mainScene.start_menu_or_game()
	

func reload_current_level():
	if mainScene == null:
		return

func toggle_mouse_capture():
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
