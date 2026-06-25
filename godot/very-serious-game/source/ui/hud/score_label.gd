class_name ScoreLabel extends Control

#const BASE_TEXT : String = "[wave amp=16.0freq=16.0connected=1]SCORE:[/wave] "
#@onready var score_text_label: RichTextLabel = %ScoreTextLabel

# score value labels

@onready var score_value_label: RichTextLabel = %ScoreValueLabel
@onready var high_value_label: RichTextLabel = %HighValueLabel

func _ready() -> void:
	set_high(get_high_score())

func set_score(value : int):
	if score_value_label == null:
		await ready
	score_value_label.text = "%d00" %value
	
func get_high_score() -> int:
	var player_settings = ConfigFileHandler.load_player_settings()
	var high_score = player_settings["high_score"] as int
	return high_score
	
func set_high(value : int):
	if high_value_label == null:
		await ready
	high_value_label.text = "%d00" %value
