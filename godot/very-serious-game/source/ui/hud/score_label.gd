class_name ScoreLabel extends Control

const BASE_TEXT : String = "[wave amp=16.0freq=16.0connected=1]SCORE:[/wave] "
@onready var score_text_label: RichTextLabel = %ScoreTextLabel
@onready var score_value_label: RichTextLabel = %ScoreValueLabel

func set_score(value : int):
	if score_value_label == null:
		await ready
	score_value_label.text = "%d" %value
