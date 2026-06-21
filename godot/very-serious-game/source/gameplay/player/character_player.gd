extends CharacterBody2D

enum DIRECTION {
	LEFT = -1, # ccw
	RIGHT = 1, # cw
}

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export_range(0.1, 360, 0.1, "radians_as_degrees") var default_rotational_speed : float = PI / 2

@onready var climb_input_component: ClimbInputComponent = $ClimbInputComponent
@onready var camera_target: Marker2D = %CameraTarget

# body nodes
@onready var body: CollisionShape2D = %Body
@onready var l_hand: ShapeCast2D = %LHand
@onready var r_hand: ShapeCast2D = %RHand


var is_god_mode : bool = false:
	set(value):
		is_god_mode = value
		body.disabled = is_god_mode

var is_grabbing_left : bool = false
var is_grabbing_right : bool = false
var current_angle : float = 0.0

func repivot_to(glo_pos : Vector2):
	if body == null: return
	
	# store original body pos
	var body_pos = body.global_position
	# move character pos
	global_position = glo_pos
	# restore original body pos
	body.global_position = body_pos

func _ready() -> void:
	if not climb_input_component == null:
		climb_input_component.climb_left_pressed.connect(grab_left)
		climb_input_component.climb_left_released.connect(release_left)
		climb_input_component.climb_right_pressed.connect(grab_right)
		climb_input_component.climb_right_released.connect(release_right)


func _physics_process(delta: float) -> void:
	#region godmode
	if OS.is_debug_build():
		if Input.is_action_pressed("god_mode_1"):
			if Input.is_action_just_pressed("god_mode_2"):
				is_god_mode = not is_god_mode
	
	if is_god_mode:
		var direction = Input.get_vector("left", "right", "up", "down").normalized()
		velocity = direction * 500
		
		move_and_slide()
		return
	#endregion
	
	#region builtin
	# Add the gravity.
	#

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
	#endregion
	
	var rotational_velocity = get_angular_direction() * default_rotational_speed * delta
	rotate(rotational_velocity)
	
	move_and_slide()

func get_angular_direction():
	return int(is_grabbing_right) - int(is_grabbing_left)
	
	
func grab_right():
	is_grabbing_right = true
	repivot_to(r_hand.global_position)
	
func release_right():
	is_grabbing_right = false
	if is_grabbing_left:
		repivot_to(l_hand.global_position)
	
func grab_left():
	is_grabbing_left = true
	repivot_to(l_hand.global_position)
	
func release_left():
	is_grabbing_left = false
	if is_grabbing_right:
		repivot_to(r_hand.global_position)
