class_name PauseScreen extends Control

signal unpaused

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		unpause()

func unpause():
	Global.toggle_mouse_capture()
	unpaused.emit()
	get_tree().paused = false


func _on_button_pressed() -> void:
	unpause()
