class_name StickyArea extends Area2D
@onready var sticky_area_collision: CollisionShape2D = $StickyAreaCollision

func _ready() -> void:
	if sticky_area_collision == null : return
	var shape = RectangleShape2D.new()
	#add_child(shape)
	shape.size = Vector2(200, 200)
	sticky_area_collision.shape = shape
	
	var size_random_add_x = randf_range(0, 400)
	var size_random_add_y = randf_range(0, 200)
	sticky_area_collision.shape.size.x += size_random_add_x
	sticky_area_collision.shape.size.y += size_random_add_y
	
	


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterPlayer:
		body.enter_sticky()
func _on_body_exited(body: Node2D) -> void:
	if body is CharacterPlayer:
		body.exit_sticky()
