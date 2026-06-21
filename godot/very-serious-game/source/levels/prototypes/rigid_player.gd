extends RigidBody2D

@export var background_wall : PhysicsBody2D

@onready var l_hand_marker: Marker2D = %LHandMarker
@onready var r_hand_marker: Marker2D = %RHandMarker
@onready var climb_input_component: ClimbInputComponent = $ClimbInputComponent

enum DIRECTION {
	LEFT = -1, # ccw
	RIGHT = 1, # cw
}

#func _ready() -> void:
	#if not climb_input_component or not background_wall: return
	#climb_input_component.climb_left_pressed.connect(create_joint_on.bind(background_wall, DIRECTION.LEFT))

func create_joint_on(node_b : PhysicsBody2D, direction : DIRECTION):
	#test
	gravity_scale = 0
	
	var hand_marker : Marker2D
	match direction:
		DIRECTION.LEFT:
			hand_marker = l_hand_marker
		_:
			hand_marker = r_hand_marker
	var new_joint = PinJoint2D.new()
	new_joint.global_position = hand_marker.global_position
	hand_marker.add_child(new_joint)
	new_joint.bias = 0.9
	new_joint.motor_target_velocity = PI / 2
	new_joint.motor_enabled = true
	
	new_joint.node_a = new_joint.get_path_to(self)
	new_joint.node_b = new_joint.get_path_to(node_b)
	
