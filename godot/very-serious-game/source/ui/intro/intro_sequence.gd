class_name IntroSequence extends Control

@export var music : AudioStream
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	AudioManager.crossfade_to(music)
	animation_player.play("scroll_text")
	animation_player.animation_finished.connect(queue_free)
