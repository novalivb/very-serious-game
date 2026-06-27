class_name IntroSequence extends Control

@export var music : AudioStream
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var can_skip : bool = false

func _ready() -> void:
	AudioManager.crossfade_to(music)
	animation_player.play("scroll_text")
	animation_player.animation_finished.connect(queue_free.unbind(1))

func _input(event: InputEvent) -> void:
	if not can_skip:
		return
	if event is InputEventAction or event is InputEventKey or event is InputEventJoypadButton or event is InputEventMouseButton:
		animation_player.advance(100)
