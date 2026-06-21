class_name MainMenuUI extends Control

signal start


func _on_start_button_pressed() -> void:
	AudioManager.create_sound_effect(SoundEffectSettings.SOUND_EFFECT_TYPE.UI_ACCEPT)
	start.emit()


func _on_levels_button_pressed() -> void:
	pass # Replace with function body.


func _on_settings_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().quit()
