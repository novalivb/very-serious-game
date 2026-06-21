class_name LoadingScreen extends Control

signal animated_in
signal animated_out

@export var debug : bool = false

@onready var loading_texture: ColorRect = $LoadingTexture
@onready var loading_animation_player: AnimationPlayer = $LoadingAnimations

#[Shader Name, ShaderMaterial UID]
var transitions : Dictionary[String, String] = {
	"fade_in" : "uid://dko8taocf13ok",
	"wipe_right" : "uid://tqi2jjk8fi78",
	"wipe_down" : "uid://ctchqkg1fdiu5",
	"diamond_sweep_right" : "uid://ca75uolvq75pc",
	"diamond_sweep_down" : "uid://ce4g3twvkhwuk",
	"shape_scale_star" : "uid://bxgmxhrl6qgei",
	"shape_scale_circle" : "uid://eaoykg61k5yr",
}
var trans_idx : int = 1

var animations : Array[String] = [
	"in",
	"out",
	"in_reverse",
	"out_reverse",
	]
#var anim_idx : int = 0

func _ready() -> void:
	SceneManager.loading_screen = self
	#SceneManager.loading_screen_transition_in()
	#await loading_animation_player.animation_finished
	#SceneManager.loading_screen_transition_out()
	
	if not loading_animation_player == null:
		#loading_texture.material = load(transitions.values()[0])
		loading_animation_player.animation_finished.connect(_on_loading_animation_finished)

#func _process(_delta: float) -> void:
	#if Input.is_action_just_pressed("move_forward"):
		#var trans_arr = transitions.values()
		#loading_texture.material = load(trans_arr[trans_idx])
		#trans_idx = (trans_idx + 1) % trans_arr.size()
		#
		#
	#if Input.is_action_just_pressed("jump"):
		#loading_animation_player.play(animations[anim_idx])
		#anim_idx = (anim_idx + 1) % animations.size()

func set_transition_material(trans_name : String = "shape_scale_circle"):
	if trans_name == "random":
		set_transition_material_random()
		return
		
	loading_texture.material = load(transitions[trans_name])

func set_transition_material_random():
	loading_texture.material = load(transitions.values().pick_random())
	

func _on_loading_animation_finished(anim_name : String):
	if anim_name == "in" or anim_name == "in_reverse":
		if debug: print_debug("Transitioned in")
		animated_in.emit()
	elif anim_name == "out" or anim_name == "out_reverse":
		if debug: print_debug("Transitioned out")
		animated_out.emit()
