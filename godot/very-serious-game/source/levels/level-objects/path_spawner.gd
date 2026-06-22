extends Node2D

@export var scene_to_spawn : PackedScene
@export var path : Path2D
@export var path_follow : PathFollow2D  
@export_range(1, 15, 0.1) var base_time_to_spawn : float = 2
@export_range(0.0, 1.0, 0.1) var randomness :  float = 0

var actual_time_to_spawn : float = 0.0
var time_since_last_spawn : float = 0.0
var active : bool = false

func _ready() -> void:
	actual_time_to_spawn = base_time_to_spawn
	actual_time_to_spawn += randf_range(-randomness, randomness)

func _process(delta: float) -> void:
	time_since_last_spawn += delta
	
	
	if time_since_last_spawn > actual_time_to_spawn:
		time_since_last_spawn -= actual_time_to_spawn
		spawn_scene()
	
func spawn_scene():
	if scene_to_spawn == null : return
	if Global.mainScene == null : return
	
	var path_progress_ratio_target = randf()
	path_follow.progress_ratio = path_progress_ratio_target
	var glo_pos = path_follow.global_position
	
	var new_scene = scene_to_spawn.instantiate() as Node2D
	if new_scene == null:
		return
	new_scene.global_position = glo_pos
	Global.mainScene.entity_root.add_child(new_scene)
