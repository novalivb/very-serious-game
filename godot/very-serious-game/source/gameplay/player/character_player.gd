extends CharacterBody2D

enum DIRECTION {
	LEFT = -1, # ccw
	RIGHT = 1, # cw
}

@export_range(0.1, 360, 0.1, "radians_as_degrees") var default_rotational_speed : float = PI / 2

@onready var pivot: Node2D = %Pivot
@onready var climb_input_component: ClimbInputComponent = $ClimbInputComponent


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var is_grabbing_left : bool = false
var is_grabbing_right : bool = false
var current_angle : float = 0.0

func _ready() -> void:
	if not climb_input_component == null:
		climb_input_component.climb_left_pressed.connect(grab_left)
		climb_input_component.climb_left_released.connect(release_left)
		climb_input_component.climb_right_pressed.connect(grab_right)
		climb_input_component.climb_right_released.connect(release_right)

func _physics_process(delta: float) -> void:
	#region builtin
	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	#endregion
	
	
	move_and_slide()

func get_angular_direction():
	return int(is_grabbing_right) - int(is_grabbing_left)
	
	
func grab_right():
	is_grabbing_right = true
	
func release_right():
	is_grabbing_right = false
	
func grab_left():
	is_grabbing_left = true
	
func release_left():
	is_grabbing_left = false
