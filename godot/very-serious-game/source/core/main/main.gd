class_name Main extends Node

@export_category("Debug Settings")
@export var debug : bool = false
@export var autostart : bool = false

@export_category("Other")

# world root nodes
@onready var level_root: Node2D = %LevelRoot
@onready var entity_root: Node2D = %EntityRoot
@onready var effect_root: Node2D = %EffectRoot

# canvas layer root nodes
@onready var hud_root: Control = %HUDRoot
@onready var pause_root: Control = %PauseRoot
@onready var transitions_root: Control = %TransitionsRoot
@onready var debug_root: Control = %DebugRoot


const MAIN_MENU_SCENE_UID : String = "uid://cegnn4fyiak8c"
const TEST_LEVEL_SCENE_UID : String = "uid://0p0ifxkhcgrr"

var _current_level : Node
	#set(value):
		#_current_level = value
		#if _current_level:
			#level_root.add_child(_current_level)

func _init() -> void:
	Global.mainScene = self

func _ready() -> void:
	start_menu_or_game()

func start_menu_or_game():
	var level_scene : PackedScene
	
	if autostart:
		level_scene = load_level_by_path(TEST_LEVEL_SCENE_UID)
	else:
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
	#var new_level_scene = load_level_by_path(TEST_LEVEL_SCENE_UID)
	#var new_level = new_level_scene.instantiate() as Level
	#if new_level == null: return
	#
	#var _previous_level = _current_level
	#set_current_level(new_level)
	#
	#
	## post process prev level
	#level_root.get_child(0).queue_free()
	#_previous_level = null
	#
	#new_level.start_level()

func return_to_main_menu():
	pass

## loads main menu without threading
func load_main_menu() -> PackedScene:
	return load(MAIN_MENU_SCENE_UID) as PackedScene

## calls upon scene loader to load over threads
func load_level_by_path(path : String) -> PackedScene:
	return load(path) as PackedScene

func load_level_by_index(index : int):
	pass
	
func free_current_level():
	if _current_level == null:
		return
		
	_current_level.queue_free()
	await get_tree().process_frame

func set_current_level(level : Node):
	_current_level = level
	level_root.add_child(_current_level)
	if _current_level is MainMenu:
		if not _current_level.start_game.is_connected(start_game):
			_current_level.start_game.connect(start_game)
	elif _current_level is Level:
		_current_level.start_level()
