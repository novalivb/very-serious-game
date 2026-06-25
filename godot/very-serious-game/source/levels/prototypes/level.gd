class_name Level extends Node2D

signal score_updated(new_score : int)

@export var enabled : bool = false

@export var background_music : AudioStream

@onready var camera_2d: ConstrainedCamera = $Camera2D
@onready var character_player: CharacterPlayer = $CharacterPlayer
@onready var level_animations: AnimationPlayer = %LevelAnimations
@onready var path_spawner: PathSpawner = %PathSpawner

const SCORE_LABEL_SCENE_UID : String = "uid://cnwslaj5obs67"
const CONTROLS_LABEL_SCENE_UID : String = "uid://csja53kpc30oy"
const HEIGHT_SCORE_CONVERSION_RATE = 50

var height_gained : float = 0.0
var score : int = 0
var player_y_pos : float = 0.0
var score_label : ScoreLabel
var controls_label : Label

func _ready() -> void:
	AudioManager.play_ambient()
	if not character_player == null:
		character_player.first_movement_taken.connect(first_movement_trigger)
		character_player.globbed.connect(glob_player)
		character_player.screen_exited.connect(reload_level)
	
	create_score_label()
	create_controls_label()
	
func create_score_label():
	score_label = load(SCORE_LABEL_SCENE_UID).instantiate() as ScoreLabel
	if score_label == null: return
	score_label.modulate.a = 0.0
	score_label.set_score(0)
	Global.mainScene.get_hud_root().add_child(score_label)
	score_updated.connect(score_label.set_score)

func create_controls_label():
	controls_label = load(CONTROLS_LABEL_SCENE_UID).instantiate() as Label
	if controls_label == null: return
	Global.mainScene.hud_root.add_child(controls_label)
	

#region systems
func _process(_delta: float) -> void:
	if not enabled: return
	
	var previous_y_pos = player_y_pos
	player_y_pos = min(player_y_pos, character_player.body.global_position.y)
	
	var height_gained_this_frame = min(0, player_y_pos - previous_y_pos)
	add_height(-height_gained_this_frame)
	

## initializes level activity
func start_level():
	# anything missing?
	if level_animations == null or character_player == null or camera_2d == null:
		return
	# sets up camera
	level_animations.play("enter_player")
	await level_animations.animation_finished
	controls_label.animation_player.play("fade_in_out")
	player_y_pos = character_player.body.global_position.y
	enabled = true
	

## load the current level again
func reload_level():
	AudioManager.crossfade_to(null)
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

func first_movement_trigger():
	AudioManager.crossfade_to(background_music)
	await get_tree().create_timer(3).timeout
	fade_out_controls_label()
	await get_tree().create_timer(7).timeout
	activate_spawner()
	fade_in_score_label()

func activate_spawner():
	if path_spawner == null: return
	path_spawner.active = true

func fade_in_score_label():
	if score_label == null: return
	var tween = create_tween()
	tween.tween_property(score_label, "modulate:a", 1.0, 1)

func fade_out_controls_label():
	if controls_label == null: return
	var tween = create_tween()
	tween.tween_property(controls_label, "modulate:a", 0.0, 1)
	tween.tween_callback(controls_label.queue_free)




func glob_player(glob : Glob):
	# play sound
	AudioManager.create_sound_effect(SoundEffectSettings.SOUND_EFFECT_TYPE.SQUELCH)
	
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

## Add height, convert to score
func add_height(value : float):
	if value == 0: return
	
	height_gained = max(0, height_gained + value)
	if height_gained > HEIGHT_SCORE_CONVERSION_RATE:
		while height_gained > HEIGHT_SCORE_CONVERSION_RATE:
			add_score(1)
			height_gained -= HEIGHT_SCORE_CONVERSION_RATE

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
