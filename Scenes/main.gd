extends Node2D

var score := 0
@onready var score_label = $CanvasLayer/MarginContainer/Label

func add_score(amount: int) -> void:
	score += amount
	score_label.text = "Score : " + str(score)
