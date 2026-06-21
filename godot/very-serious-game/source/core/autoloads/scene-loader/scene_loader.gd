extends Node
## Scene Manager. Contains functions related to loading scenes

signal scene_loaded
signal finished_loading


enum POST_PROCESS_MODE {
	DELETE,
	REMOVE,
	HIDE,
}

var path : String = ""
var load_progress_percentage : float = 0.0
var loading : bool = false


func _process(_delta: float) -> void:
	if path.is_empty():
		return
	
	# while there is a path, check its load status and react
	var load_progress : Array[float] = [] # progress from 0.0 to 1.0
	var status := ResourceLoader.load_threaded_get_status(path, load_progress)
	
	match status:
		# success
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
			load_progress_percentage = load_progress[0] * 100
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			scene_loaded.emit()
			
			
		# fail
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE:
			pass
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
			pass

## Loads the provided scene path over threads and returns the scene resource when complete
func load_scene(scene_path_or_uid : String) -> Resource:
	# do not interrupt loading
	if loading:
		return null
	
	# set
	loading = true
	path = scene_path_or_uid
	
	# initialize and wait for load
	ResourceLoader.load_threaded_request(path)
	await scene_loaded
	
	# collect the loaded scene
	var scene := ResourceLoader.load_threaded_get(path)
	if not scene:
		#error
		return null
	
	# reset
	path = ""
	loading = false
	load_progress_percentage = 0.0
	
	# finish
	finished_loading.emit()
	return scene
