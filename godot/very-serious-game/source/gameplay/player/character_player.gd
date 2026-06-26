class_name CharacterPlayer extends CharacterBody2D

enum DIRECTION {
	LEFT = -1, # ccw
	RIGHT = 1, # cw
}

signal first_movement_taken
signal globbed(glob : Glob)
signal screen_exited

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export_range(0.1, 360, 0.1, "radians_as_degrees") var default_rotational_speed : float = PI / 2
@export var enabled : bool = true

@onready var climb_input_component: ClimbInputComponent = %ClimbInputComponent
@onready var camera_target: Marker2D = %CameraTarget
@onready var glob_target: Marker2D = %GlobTarget
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = %VisibleOnScreenNotifier2D

# body nodes
@onready var body: CollisionShape2D = %Body
@onready var l_hand: ShapeCast2D = %LHand
@onready var r_hand: ShapeCast2D = %RHand
@onready var hazard_detector: ShapeCast2D = %HazardDetector


var is_god_mode : bool = false:
	set(value):
		is_god_mode = value
		body.disabled = is_god_mode

var is_grabbing_left : bool = false
var is_grabbing_right : bool = false
var current_angle : float = 0.0
var has_taken_first_movement : bool = false
var sticky_rotation_multiplier : float = 1.0

const STICKY_ROTATION_PENALTY : float = 0.5

func repivot_to(glo_pos : Vector2):
	if not enabled or body == null:
		return
	
	# store original body pos
	var body_pos = body.global_position
	# move character pos
	global_position = glo_pos
	# restore original body pos
	body.global_position = body_pos

func _init() -> void:
	Global.player = self

func _ready() -> void:
	if not climb_input_component == null:
		climb_input_component.climb_left_pressed.connect(grab_left)
		climb_input_component.climb_left_released.connect(release_left)
		climb_input_component.climb_right_pressed.connect(grab_right)
		climb_input_component.climb_right_released.connect(release_right)
	if not visible_on_screen_notifier_2d == null:
		visible_on_screen_notifier_2d.screen_exited.connect(_on_visible_on_screen_notifier_2d_screen_exited)


func _physics_process(delta: float) -> void:
	if not enabled :
		return
		
	#region godmode
	if OS.is_debug_build():
		if Input.is_action_pressed("god_mode_1"):
			if Input.is_action_just_pressed("god_mode_2"):
				is_god_mode = not is_god_mode
	
	if is_god_mode:
		var direction = Input.get_vector("left", "right", "up", "down").normalized()
		velocity = direction * 2000
		
		move_and_slide()
		return
	#endregion
	
	
	# check shapecast colliders for globs
	for collision_idx in hazard_detector.get_collision_count():
		var collider =hazard_detector.get_collider(collision_idx)
		if collider is Glob:
			enabled = false
			globbed.emit(collider)
			return
			
	# rotate and slide
	var rotational_velocity = get_angular_direction() * default_rotational_speed * delta
	rotational_velocity *= sticky_rotation_multiplier
	if not rotational_velocity == 0.0 and not has_taken_first_movement:
		has_taken_first_movement = true
		first_movement_taken.emit()
		
	rotate(rotational_velocity)
	
	move_and_slide()

func get_angular_direction():
	return int(is_grabbing_right) - int(is_grabbing_left)
	
	
func grab_right():
	if not enabled: return
	is_grabbing_right = true
	repivot_to(r_hand.global_position)
	
func release_right():
	if not enabled: return
	is_grabbing_right = false
	if is_grabbing_left:
		repivot_to(l_hand.global_position)
	
func grab_left():
	if not enabled: return
	is_grabbing_left = true
	repivot_to(l_hand.global_position)
	
func release_left():
	if not enabled: return
	is_grabbing_left = false
	if is_grabbing_right:
		repivot_to(r_hand.global_position)

func enter_sticky():
	sticky_rotation_multiplier = STICKY_ROTATION_PENALTY

func exit_sticky():
	sticky_rotation_multiplier = 1.0

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	#if not enabled: return
	screen_exited.emit()
