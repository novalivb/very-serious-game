class_name MainMenu extends Node2D

signal start_game

@export var menu_music : AudioStream

@onready var main_menu_ui: Control = %MainMenuUI

func _ready() -> void:
	if main_menu_ui == null:
		return
	AudioManager.crossfade_to(menu_music)
	main_menu_ui.start_game.connect(func(): start_game.emit())
	Global.mainScene.free_entities_and_effects()
	Global.mainScene.free_hud()
