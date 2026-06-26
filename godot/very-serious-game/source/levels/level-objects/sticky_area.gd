class_name StickyArea extends Area2D
## Slows player when inside, spawns in an assortment of random sizes

@onready var sticky_area_collision: CollisionShape2D = $StickyAreaCollision
@onready var sprite_2d: Sprite2D = $Sprite2D

var entered_screen : bool = false

enum SIZE {
	SMALL,			# 250x250
	WIDE,			# 500x250
	EXTRA_WIDE,		# 750x250
	TALL,			# 250x500
	EXTRA_TALL,		# 250x750
	LARGE,			# 500x500
}

const SIGN_DICT : Dictionary[SIZE, Vector2] = {
	SIZE.SMALL: Vector2(250,250),
	SIZE.WIDE: Vector2(500,250),
	SIZE.EXTRA_WIDE: Vector2(750,250),
	SIZE.TALL: Vector2(250,500),
	SIZE.EXTRA_TALL: Vector2(250,750),
	SIZE.LARGE: Vector2(500,500),
}

@export var sprites_dict : Dictionary[SIZE, Texture2D]

func _ready() -> void:
	if sticky_area_collision == null : return
	var shape = RectangleShape2D.new()
	var shape_size_index : int = SIZE.values().pick_random()
	var shape_size = SIGN_DICT[shape_size_index]
	shape.size = shape_size
	
	
	sticky_area_collision.shape = shape
	
	#var size_random_add_x = randf_range(0, 400)
	#var size_random_add_y = randf_range(0, 200)
	#sticky_area_collision.shape.size.x += size_random_add_x
	#sticky_area_collision.shape.size.y += size_random_add_y
	
	
	# get correct size sprite
	sprite_2d.texture = sprites_dict[shape_size_index]
	
	# randomize scale
	var random_scale_factor : float = randf_range(0.9,1.5)
	scale *= random_scale_factor


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterPlayer:
		body.enter_sticky()
func _on_body_exited(body: Node2D) -> void:
	if body is CharacterPlayer:
		body.exit_sticky()


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	entered_screen = true


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if not entered_screen: return
	print_debug("Freed Honey Patch: %s" %name)
	queue_free()
