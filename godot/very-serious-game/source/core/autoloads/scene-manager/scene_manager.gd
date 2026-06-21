extends Node
## Scene Manager

var loading_screen : LoadingScreen



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
