extends RigidBody2D


func _ready() -> void:
	angular_velocity = randf_range(-1, 1)
	linear_velocity.x = randf_range(0, 200)
	if position.x > 0: # always point toward world center (level center) NOT CAMERA CENTER
		linear_velocity.x *= -1
