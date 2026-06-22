extends Node
## Scene Manager

var loading_screen : LoadingScreen
var mid_swap : bool = false

const MINIMUM_LOAD_TIME : float = 0.5

func swap_level_to(level_path : String):
	if mid_swap:
		return
	mid_swap = true
	
	
	# transition in
	loading_screen_transition_in(false, "shape_scale_circle")
	await loading_screen.animated_in
	
	# clear entities and effects
	var active_entities = Global.mainScene.entity_root.get_children(true)
	for entity in active_entities:
		entity.queue_free()
	var active_effects = Global.mainScene.effect_root.get_children(true)
	for effect in active_effects:
		effect.queue_free()
	
	# start minimum load time timer
	var load_minimum_timer : SceneTreeTimer = get_tree().create_timer(MINIMUM_LOAD_TIME)
	
	
	# load level
	var new_level_scene = await SceneLoader.load_scene(level_path) as PackedScene
	if new_level_scene == null:
		return
	
	var new_level = new_level_scene.instantiate()
	Global.mainScene.set_current_level(new_level)
	
	# no handoff, as there is only one level, anyway
	Global.mainScene.level_root.get_child(0).queue_free()
	await get_tree().process_frame
	
	# wait for at least minimum load time if it hasn't passed
	if not load_minimum_timer == null:
		if not load_minimum_timer.is_queued_for_deletion():
			if not load_minimum_timer.time_left == 0.0:
				await load_minimum_timer.timeout
	
	loading_screen_transition_out()
	if new_level is Level:
		new_level.start_level()
	await loading_screen.animated_out
	mid_swap = false

func loading_screen_transition_in(reverse : bool = false, transition_shader : String = "random"):
	if not loading_screen: return
	
	loading_screen.call_deferred("set_transition_material", transition_shader)
	await get_tree().process_frame
	var animation_name = "in_reverse" if reverse else "in"
	loading_screen.loading_animation_player.play(animation_name)

# currently does not change shader because it resets the screen and the fill param isn't set until the animation player
func loading_screen_transition_out(reverse : bool = true, transition_shader : String = "random"):
	if not loading_screen: return
	
	#loading_screen.call_deferred("set_transition_material", transition_shader)
	#await get_tree().create_timer(5).timeout
	var animation_name = "out_reverse" if reverse else "out"
	loading_screen.loading_animation_player.play(animation_name)

# loading a level
# activate loading screen, if needed
# await animation finished

# initialize scene loader with the requested scene path

# with both scenes active, hand off relevant data

# post-process the pr
