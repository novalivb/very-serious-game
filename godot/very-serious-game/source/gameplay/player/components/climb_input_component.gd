class_name ClimbInputComponent extends Node

signal climb_left_pressed
signal climb_left_released
signal climb_right_pressed
signal climb_right_released


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left"):
		climb_left_pressed.emit()
	if event.is_action_pressed("right"):
		climb_right_pressed.emit()
	if event.is_action_released("left"):
		climb_left_released.emit()
	if event.is_action_released("right"):
		climb_right_released.emit()
