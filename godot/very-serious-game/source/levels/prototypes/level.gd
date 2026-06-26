class_name Level extends Node2D

signal score_updated(new_score : int)

@export var enabled : bool = false

@export var background_music : AudioStream
#@export var sticky_area_scene : PackedScene

@onready var camera_2d: ConstrainedCamera = $Camera2D
@onready var character_player: CharacterPlayer = $CharacterPlayer
@onready var level_animations: AnimationPlayer = %LevelAnimations
@onready var glob_spawner: PathSpawner = %GlobSpawner
@onready var sticky_area_spawner: PathSpawner = %StickyAreaSpawner

const SCORE_LABEL_SCENE_UID : String = "uid://cnwslaj5obs67"
const CONTROLS_LABEL_SCENE_UID : String = "uid://csja53kpc30oy"
const HEIGHT_SCORE_CONVERSION_RATE = 50

# [height, dynamic values]
# dynamic values: [glob spawning rate, sticky area spawning rate, powerup spawning rate
const HEIGHT_THRESHOLD_DATA : Dictionary[float, Vector3] = {
	0.0: 		Vector3(4, 1000, 0.0),
	10000.0: 	Vector3(3, 750, 0.0),
	20000.0: 	Vector3(2, 500, 0.0),
	50000.0: 	Vector3(1, 250, 0.0),
	100000.0: 	Vector3(0.5, 250, 0.0),
}

var score_label : ScoreLabel
var controls_label : Label

var player_y_pos : float = 0.0
var height_gained_since_start : float = 0.0
var current_height_threshold_index : float = 1
var score : int = 0
var height_since_last_score : float = 0.0
var height_since_last_sticky : float = 0.0
var sticky_spawn_height_threshold: float = HEIGHT_THRESHOLD_DATA[0.0].y

#region systems
func _ready() -> void:
	AudioManager.play_ambient()
	if not character_player == null:
		character_player.first_movement_taken.connect(first_movement_trigger)
		character_player.globbed.connect(glob_player)
		character_player.screen_exited.connect(reload_level)
	
	create_score_label()
	create_controls_label()
	
	# set default threshold values
	set_threshold_values(0.0)
	
func _process(_delta: float) -> void:
	if not enabled: return
	
	var previous_y_pos = player_y_pos
	player_y_pos = min(player_y_pos, character_player.body.global_position.y)
	
	var height_gained_this_frame = min(0, player_y_pos - previous_y_pos)
	add_height(-height_gained_this_frame)
	
func set_threshold_values(threshold : float):
	if not HEIGHT_THRESHOLD_DATA.has(threshold): return
	

	var height_threshold_vector = HEIGHT_THRESHOLD_DATA[threshold]
	glob_spawner.base_time_to_spawn = height_threshold_vector.x
	sticky_spawn_height_threshold = height_threshold_vector.y
	# TODO powerups get height_threshold_vector.z

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

## initializes level activity
func start_level():
	# anything missing?
	if level_animations == null or character_player == null or camera_2d == null or controls_label == null:
		return
	# sets up camera
	level_animations.play("enter_player")
	await level_animations.animation_finished
	fade_in_controls_label()
	controls_label.animation_player.play("fade_in_out")
	player_y_pos = character_player.body.global_position.y
	enabled = true
	
func fade_in_controls_label():
	if controls_label == null: return
	var tween = create_tween()
	tween.tween_property(controls_label, "modulate:a", 1, 2)

## Called during "enter player" animation
func setup_camera() -> void:
	if not camera_2d == null and not character_player == null:
		camera_2d.set_target(character_player.camera_target)
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		Global.mainScene.pause()

#endregion



#region start gameplay
func first_movement_trigger():
	AudioManager.crossfade_to(background_music)
	await get_tree().create_timer(3).timeout
	fade_out_controls_label()
	await get_tree().create_timer(7).timeout
	activate_spawners()
	fade_in_score_label()

func activate_spawners():
	if not glob_spawner == null:
		glob_spawner.active = true
	
	# sticky areas should be spawned by climb progress,
	# instead of on a timer
	#if not sticky_area_spawner == null:
		#sticky_area_spawner.active = true
	

func fade_in_score_label():
	if score_label == null: return
	var tween = create_tween()
	tween.tween_property(score_label, "modulate:a", 1.0, 1)

func fade_out_controls_label():
	if controls_label == null: return
	var tween = create_tween()
	tween.tween_property(controls_label, "modulate:a", 0.0, 1)
	tween.tween_callback(controls_label.queue_free)
#endregion


#region gameplay dynamics
## freeze glob, attach to player and kill player
func glob_player(glob : Glob):
	# play sound
	AudioManager.create_sound_effect(SoundEffectSettings.SOUND_EFFECT_TYPE.SQUELCH)
	
	# place glob on player head
	glob.freeze = true
	glob.set_collision_layer_value(3, false)
	glob.reparent(character_player.glob_target)
	glob.position = Vector2.ZERO
	
	
	# tween player position down off-screen
	var tween = create_tween()
	var position_target = character_player.global_position.y + 600
	tween.tween_property(
		character_player,
		"global_position:y",
		position_target,
		2
		)

## spawn sticky area on sticky area spawner path
func spawn_sticky_area():
	if sticky_area_spawner == null or character_player == null: return
	
	sticky_area_spawner.spawn_scene()
#endregion

#region utility functions
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reload_current_level"):
		reload_level()
		
## load the current level again
func reload_level():
	AudioManager.crossfade_to(null)
	save_score_if_record()
	SceneManager.swap_level_to(self.scene_file_path)

## Add height, convert to score
func add_height(value : float):
	if value == 0: return
	# add total height
	height_gained_since_start = max(0, height_gained_since_start + value)
	
	# check for height threshold criteria
	# manual for now
	if height_gained_since_start > 100000:
		set_threshold_values(100000)
	elif height_gained_since_start > 50000:
		set_threshold_values(50000)
	elif height_gained_since_start > 20000:
		set_threshold_values(20000)
	elif height_gained_since_start > 10000:
		set_threshold_values(10000)
	
	
	# add score if needed
	height_since_last_score = max(0, height_since_last_score + value)
	if height_since_last_score > HEIGHT_SCORE_CONVERSION_RATE:
		while height_since_last_score > HEIGHT_SCORE_CONVERSION_RATE:
			add_score(1)
			height_since_last_score -= HEIGHT_SCORE_CONVERSION_RATE
	
	# spawn sticky area if needed
	height_since_last_sticky = max(0, height_since_last_sticky + value)
	if height_since_last_sticky >= sticky_spawn_height_threshold:
		while height_since_last_sticky > sticky_spawn_height_threshold:
			spawn_sticky_area()
			height_since_last_sticky -= sticky_spawn_height_threshold

## Add score, minimum 0
func add_score(value : int):
	if value == 0: return
	
	score = max(0, score + value)
	save_score_if_record()
	score_updated.emit(score)
	
func save_score_if_record():
	var high_score = ConfigFileHandler.load_player_settings()["high_score"] as int
	if high_score == null: return
	if high_score >= score: return
	
	ConfigFileHandler.save_player_setting("high_score", score)
	
	if not score_label == null:
		score_label.set_high(score)
	#endregion
	
	
	
