class_name HazardWarningArea extends Area2D
## Hazard Warning Area.
## For each hazard in area, tries to place a
## hazard warning where each hazard is in the area,
## but constrained to the bounds of the HUD



var hazard_warning_dict : Dictionary[RigidBody2D, WarningLabel] = {}


# When a hazard enters the body (collision layer filter), create a matching
# warning label on the HUD, tracking the hazard
func _on_body_entered(body: RigidBody2D) -> void:
	_attach_warning_label_to_hazard(body)

# creates a warning label node and links it to the hazard in the dict
func _attach_warning_label_to_hazard(hazard : RigidBody2D):
	hazard_warning_dict[hazard] = _create_warning_label(hazard)

# creates and returns a warning label targetting the hazard
func _create_warning_label(target_hazard : RigidBody2D) -> WarningLabel:
	return Global.mainScene.create_warning_label(target_hazard)


# free the label matching the body in the dict
func _on_body_exited(body: RigidBody2D) -> void:
	if hazard_warning_dict.has(body):
		hazard_warning_dict[body].queue_free()
