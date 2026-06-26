class_name Glob extends RigidBody2D

@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = %VisibleOnScreenNotifier2D
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D

var shape: CircleShape2D
var random_scale_factor : float = 1.0

const DEFAULT_SHAPE_RADIUS : float = 60.0
const GIGA_GLOB_SCALE : float = 3.45
const GIGA_GLOB_EXTRA_HEIGHT : float = 1000



func _ready() -> void:
	linear_velocity.x = randf_range(0, 400)
	angular_velocity = linear_velocity.x / (TAU * 2)
	if position.x > 0: # always point toward world center (level center) NOT CAMERA CENTER
		angular_velocity *= -1
		linear_velocity.x *= -1
	
	# get random sprite size
	random_scale_factor = randf_range(0.9, 2)
	if randi_range(0, 100) == 100:	# 1% chance of spawning giga glob
	#if randi_range(0,1) == 1: 		# 50% chance
		random_scale_factor = GIGA_GLOB_SCALE
		freeze = true
		global_position.y -= GIGA_GLOB_EXTRA_HEIGHT
		freeze = false
	sprite_2d.scale = Vector2(random_scale_factor, random_scale_factor)
	
	# spawn a unique shape matching the glob size and assign to collision
	shape = CircleShape2D.new()
	shape.radius = DEFAULT_SHAPE_RADIUS * random_scale_factor
	collision_shape_2d.shape = shape
	

func _physics_process(_delta: float) -> void:
	visible_on_screen_notifier_2d.global_position = global_position

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	gravity_scale = 0.5


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
