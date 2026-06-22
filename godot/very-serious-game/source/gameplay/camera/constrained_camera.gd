class_name ConstrainedCamera extends Camera2D

@export var target : Node2D
@export var lock_x : bool = false
@export var lock_y : bool = false

@export var vertical_scroll_lock : bool = true

var max_y_value : float = 0


func set_target(new_target: Node2D):
	if new_target == null: return
	target = new_target
	global_position = target.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if target == null: return
	
	if not lock_x:
		global_position.x = lerp(global_position.x, target.global_position.x, 0.5)

	if not lock_y:
		var y_position = lerp(global_position.y, target.global_position.y, 0.5)
		if vertical_scroll_lock:
			y_position = min(max_y_value, y_position)
		
		global_position.y = y_position
		max_y_value = global_position.y
		
