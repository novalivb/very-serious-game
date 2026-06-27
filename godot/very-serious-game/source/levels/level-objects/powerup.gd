class_name Powerup extends Area2D

enum EFFECT {
	SPEED_BOOST,
}

@export var effect : EFFECT


var collected : bool = false
