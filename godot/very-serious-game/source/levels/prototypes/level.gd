class_name Level extends Node2D

signal score_updated(new_score : int)

@export var enabled : bool = false

@onready var camera_2d: ConstrainedCamera = $Camera2D
@onready var character_player: CharacterPlayer = $CharacterPlayer
@onready var level_animations: AnimationPlayer = %LevelAnimations
@onready var path_spawner: PathSpawner = %PathSpawner

const SCORE_LABEL_SCENE_UID : String = "uid://cnwslaj5obs67"

var score : int = 0
var player_y_pos : float = 0.0

func _ready() -> void:
	if not character_player == null:
		character_player.first_movement_taken.connect(activate_spawner)
		character_player.globbed.connect(glob_player)
		character_player.screen_exited.connect(reload_level)
	
	var score_label = load(SCORE_LABEL_SCENE_UID).instantiate() as ScoreLabel
	if score_label == null: return
	score_label.set_score(0)
	Global.mainScene.get_hud_root().add_child(score_label)
	score_updated.connect(score_label.set_score)

#region systems
func _process(_delta: float) -> void:
	if not enabled: return
	
	var previous_y_pos = player_y_pos
	player_y_pos = min(player_y_pos, character_player.body.global_position.y)
	
	var height_gained_this_frame = min(0, player_y_pos - previous_y_pos)
	add_score(-height_gained_this_frame)
	

## initializes level activity
func start_level():
	# anything missing?
	if level_animations == null or character_player == null or camera_2d == null:
		return
	# sets up camera
	level_animations.play("enter_player")
	await level_animations.animation_finished
	player_y_pos = character_player.body.global_position.y
	enabled = true
	

## load the current level again
func reload_level():
	save_score_if_record()
	SceneManager.swap_level_to(self.scene_file_path)

## Called during "enter player" animation
func setup_camera() -> void:
	if not camera_2d == null and not character_player == null:
		camera_2d.set_target(character_player.camera_target)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reload_current_level"):
		reload_level()
#endregion

func activate_spawner():
	if path_spawner == null: return
	path_spawner.active = true

func glob_player(glob : Glob):
	# place glob on player head
	glob.freeze = true
	glob.set_collision_layer_value(3, false)
	glob.reparent(character_player.glob_target)
	glob.position = Vector2.ZERO
	
	# play impact animations and sound
	# TODO
	
	# tween player position down off-screen
	var tween = create_tween()
	var position_target = character_player.global_position.y + 600
	tween.tween_property(
		character_player,
		"global_position:y",
		position_target,
		2
		)

## Add score, minimum 0
func add_score(value : int):
	if value == 0: return
	
	score = max(0, score + value)
	score_updated.emit(score)
	
func save_score_if_record():
	var high_score = ConfigFileHandler.load_player_settings()["high_score"] as int
	if high_score == null: return
	if high_score >= score: return
	
	ConfigFileHandler.save_player_setting("high_score", score)
