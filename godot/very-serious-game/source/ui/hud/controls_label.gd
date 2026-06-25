extends Label

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var left: TextureRect = $Control/HBoxContainer/Panel2/Left
@onready var right: TextureRect = $Control/HBoxContainer/Panel/Right

const ICON_BASE_MODULATE : Color = Color(1.0, 1.0, 1.0, 1.0)
const ICON_PRESSED_MODULATE := Color(0.053, 1.0, 0.02)

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#await get_tree().create_timer(2).timeout
	#animation_player.play("fade_in_out")



func _process(_delta: float) -> void:
	if Input.is_action_pressed("left"):
		left.modulate = ICON_PRESSED_MODULATE
	else:
		left.modulate = ICON_BASE_MODULATE

	
	if Input.is_action_pressed("right"):
		right.modulate = ICON_PRESSED_MODULATE
	else:
		right.modulate = ICON_BASE_MODULATE
