class_name Main extends Node

@export_category("Debug Settings")
@export var debug : bool = false
@export var autostart : bool = false

@export_category("Scenes")
@export var warning_label_scene : PackedScene

# world root nodes
@onready var level_root: Node2D = %LevelRoot
@onready var entity_root: Node2D = %EntityRoot
@onready var effect_root: Node2D = %EffectRoot

# canvas layer root nodes
@onready var hud_root: Control = %HUDRoot
@onready var pause_root: Control = %PauseRoot
@onready var transitions_root: Control = %TransitionsRoot
@onready var debug_root: Control = %DebugRoot

@onready var pause_screen: PauseScreen = %PauseScreen


const MAIN_MENU_SCENE_UID : String = "uid://cegnn4fyiak8c"
const TEST_LEVEL_SCENE_UID : String = "uid://0p0ifxkhcgrr"
const INTRO_SEQUENCE = preload("uid://c0otwbavsld83")

var _current_level : Node


func _init() -> void:
	Global.mainScene = self

func _ready() -> void:
	var seen_intro = ConfigFileHandler.load_player_settings()["seen_intro"]
	if not seen_intro:
		await play_intro()
	
	start_menu_or_game()
	if not pause_screen == null:
		pause_screen.unpause_requested.connect(unpause)
		pause_screen.menu_requested.connect(start_menu_or_game)

func play_intro():
	AudioManager.stop_ambient()
	
	var intro = INTRO_SEQUENCE.instantiate() as IntroSequence
	if intro == null:
		pass
	hud_root.add_child(intro)
	await intro.animation_player.animation_finished
	ConfigFileHandler.save_player_setting("seen_intro", true)

func get_hud_root() -> Control:
	return hud_root
func get_level_root() -> Node2D:
	return level_root
func get_entity_root() -> Node2D:
	return entity_root
func get_effect_root() -> Node2D:
	return effect_root

func free_entities_and_effects():
	for child in entity_root.get_children():
		child.queue_free()
	for child in effect_root.get_children():
		child.queue_free()

func free_hud():
	for child in hud_root.get_children():
		child.queue_free()

func pause():
	get_tree().paused = true
	if not pause_screen.visible:
		pause_screen.show()

func unpause():
	get_tree().paused = false
	if pause_screen.visible:
		pause_screen.hide()
	

#region levels
## Loads main menu if auto start is off, otherwides loads the level
## sans loading screen
func start_menu_or_game():
	unpause()
	AudioManager.crossfade_to(null)
	
	var level_scene : PackedScene
	
	if autostart:
		level_scene = load_level_by_path(TEST_LEVEL_SCENE_UID)
	else:
		# load splash screen, intro if needed, and then menu
		# TODO
		level_scene = load_main_menu()
	
	if level_scene == null: return
	
	var new_level : Node = level_scene.instantiate() as Node
	if not new_level:
		return
	
	if new_level is MainMenu:
		new_level.start_game.connect(start_game)
	
	await free_current_level()
	set_current_level(new_level)

func start_game():
	SceneManager.swap_level_to(TEST_LEVEL_SCENE_UID)
	

func return_to_main_menu():
	pass

## loads main menu without threading
func load_main_menu() -> PackedScene:
	return load(MAIN_MENU_SCENE_UID) as PackedScene

## calls upon scene loader to load over threads
func load_level_by_path(path : String) -> PackedScene:
	return load(path) as PackedScene

## Delete current level
func free_current_level():
	if _current_level == null:
		return
		
	_current_level.queue_free()
	await get_tree().process_frame

## Set the level and run its start functions
func set_current_level(level : Node):
	_current_level = level
	level_root.add_child(_current_level)
	if _current_level is MainMenu:
		if not _current_level.start_game.is_connected(start_game):
			_current_level.start_game.connect(start_game)
	elif _current_level is Level:
		_current_level.start_level()
#endregion

#region HUD
const WARNING_LABEL_TOP_MARGIN : float = 60

func create_warning_label(target_node : Node2D) -> WarningLabel:
	var new_warning_label = warning_label_scene.instantiate() as WarningLabel
	new_warning_label.target_node = target_node
	if target_node is Glob:
		new_warning_label.scale = Vector2.ONE * target_node.random_scale_factor
		if target_node.random_scale_factor == Glob.GIGA_GLOB_SCALE:
			new_warning_label.play_giga_warning()
			AudioManager.create_sound_effect(SoundEffectSettings.SOUND_EFFECT_TYPE.GIGA_HAZARD_WARNING)
		else:
			AudioManager.create_sound_effect(SoundEffectSettings.SOUND_EFFECT_TYPE.HAZARD_WARNING)

	hud_root.add_child(new_warning_label)
	new_warning_label.position = Vector2(1000, 30)
	return new_warning_label

#endregion
