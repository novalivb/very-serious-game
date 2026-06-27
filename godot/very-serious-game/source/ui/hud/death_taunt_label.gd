class_name DeathTauntLabel extends Label

@export_multiline var taunts_array : Array[String]

func _ready() -> void:
	if taunts_array == null:
		return
	if taunts_array.is_empty():
		text = ""
	else:
		text = taunts_array.pick_random()
