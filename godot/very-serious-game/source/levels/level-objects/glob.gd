class_name Glob extends RigidBody2D

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = %VisibleOnScreenNotifier2D


func _ready() -> void:
	linear_velocity.x = randf_range(0, 400)
	angular_velocity = linear_velocity.x / (TAU * 2)
	if position.x > 0: # always point toward world center (level center) NOT CAMERA CENTER
		angular_velocity *= -1
		linear_velocity.x *= -1

func _physics_process(_delta: float) -> void:
	visible_on_screen_notifier_2d.global_position = global_position

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	gravity_scale = 0.5


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
