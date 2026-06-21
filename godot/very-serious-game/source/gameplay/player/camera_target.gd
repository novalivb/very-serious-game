extends Marker2D
## Target for a camera that sits Height pixels above the exported Body node

@export var height : float = 300
@export var body : Node2D

func _process(_delta: float) -> void:
	if body == null: return
	var body_pos = body.global_position
	var target_pos = Vector2(body_pos.x, body_pos.y - height)
	global_position = target_pos
