class_name Level extends Node2D


@onready var camera_2d: ConstrainedCamera = $Camera2D
@onready var character_player: CharacterBody2D = $CharacterPlayer
@onready var level_animations: AnimationPlayer = %LevelAnimations

#func _ready() -> void:
	#start_level()

#debug test
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("left"):
		#restart_level()
#end test

	

func start_level():
	if level_animations == null:
		return
	
	level_animations.play("enter_player")
	
func setup_camera() -> void:
	if not camera_2d == null and not character_player == null:
		camera_2d.set_target(character_player.camera_target)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reload_current_level"):
		reload_level()

func reload_level():
	SceneManager.swap_level_to(self.scene_file_path)
