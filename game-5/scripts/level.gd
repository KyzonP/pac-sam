extends Node2D

var score : int = 0

func _ready():
	$Pellets.connect("scoreChanged", ScoreChanged)

func ScoreChanged(amount):
	score += amount
	$Score.text = "[center]" + str(score)
