extends Area2D

var eaten : bool = true

var timer : float = 0.0
var timerMax : float = 10.0

@onready var anim = $Sprite

func _ready():
	anim.animation = level_stats.getStats(level_stats.fruitName)
	
	event_bus.spawnFruit.connect(spawnBone)
	event_bus.restart.connect(reset)
		
func reset(_death, _level):
	despawnBone()
	print(anim.animation)
	anim.animation = level_stats.getStats(level_stats.fruitName)
	print(level_stats.level)

func _physics_process(delta):
	if !eaten:
		timer += delta
		
		if timer >= timerMax:
			timer = 0.0
			
			despawnBone()

func _on_area_entered(area):
	if !eaten and area.is_in_group("player"):
		despawnBone()
		print("emit")
		
		
		event_bus.fruitEaten.emit(level_stats.getStats(level_stats.bonusPoints))

func spawnBone():
	if eaten:
		visible = true
		eaten = false
		
		timerMax = randf_range(9.0,10.0)
	
func despawnBone():
	visible = false
	eaten = true
	
