class_name WarningLabel extends RichTextLabel
## Rich text label scene prepacked with a colored warning symbol font character
## and BBCode to make it wave. Tracks a target node within the margins of the HUD.

@export var target_node : Node2D

@export var x_margin : float = 0
@export var y_level : float = 60

const X_CENTER_OFFSET : float = 39

func _process(_delta: float) -> void:
	if target_node == null:
		return
	var target_canvas_position : Vector2 = target_node.get_global_transform_with_canvas().get_origin()
	var canvas_position = Vector2(
		clampf(target_canvas_position.x, x_margin, get_viewport_rect().size.x + x_margin),
		y_level
	)
	canvas_position.x -= X_CENTER_OFFSET
	position = canvas_position
