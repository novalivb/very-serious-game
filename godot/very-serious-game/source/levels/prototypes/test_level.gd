extends Node2D
@onready var camera_2d: ConstrainedCamera = $Camera2D
@onready var character_player: CharacterBody2D = $CharacterPlayer


func _ready() -> void:
	if not camera_2d == null and not character_player == null:
		camera_2d.set_target(character_player.camera_target)
