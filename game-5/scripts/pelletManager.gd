extends Node2D

var pellets : int

signal scoreChanged

func _ready():
	pellets = _countPellets()
	
func removePellet(pellet):
	pellet.queue_free()
	
	scoreChanged.emit(10)
	
func _countPellets():
	var pelletCount = 0
	
	for i in self.get_children():
		if i.is_in_group("pellet"):
			i.connect("pelletCrossed", removePellet)
			
			pelletCount += 1
	
	return pelletCount
