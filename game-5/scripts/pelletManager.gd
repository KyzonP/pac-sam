extends Node2D

# Honestly this could be two scripts - one for pellet managing and the other for releasing inky and clyde. Ruh roh

var pellets : int

var pelletGroup : Array
var powerupGroup : Array

var releaseTimer : float = 0.0
var releaseTimerMax : float = 4.0

var inky : bool = false
var clyde : bool = false

signal scoreChanged

func _ready():
	pellets = _countPellets()
	_createGroups()
	
	event_bus.restart.connect(reset)
	event_bus.inkyReleased.connect(inkyReleased)
	event_bus.clydeReleased.connect(clydeReleased)
	
func _physics_process(delta):
	# If less than 100 (to stop it checking once all ghosts are released)
	if !inky or !clyde:
		releaseTimer += delta
		if releaseTimer >= releaseTimerMax:
			if !inky:
				event_bus.emit_signal("checkInky")
			elif !clyde:
				event_bus.emit_signal("checkClyde")

func inkyReleased():
	inky = true
	releaseTimer = 0
	
func clydeReleased():
	clyde = true
	releaseTimer = 0
	
func removePellet(pellet):
	# If less than 100 (to stop it checking once all ghosts are released)
	if releaseTimer < 100:
		releaseTimer = 0
	
	pellet.visible = false
	
	scoreChanged.emit(10)
	
	event_bus.emit_signal("pelletConsumed")
	
func removePowerUp(powerUp):
	# If less than 100 (to stop it checking once all ghosts are released)
	if releaseTimer < 100:
		releaseTimer = 0
	
	powerUp.visible = false
	
	scoreChanged.emit(50)
	
	event_bus.emit_signal("pelletConsumed")
	
func _countPellets():
	var pelletCount = 0
	
	for i in self.get_children():
		if i.is_in_group("pellet"):
			i.connect("pelletCrossed", removePellet)
			
			if i.eaten == false:
				pelletCount += 1
	
	return pelletCount
	
func _createGroups():
	for i in self.get_children():
		if i.is_in_group("powerup"):
			powerupGroup.append(i)
			i.connect("powerUpCrossed", removePowerUp)
		elif i.is_in_group("pellet"):
			pelletGroup.append(i)
	
func reset(death, _level):
	inky = false
	clyde = false
	
	# If a restart is happening due to a death
	if death:
		pass
		
	# If a restart is happening due to completion of the level
	else:
		for i in pelletGroup:
			i.visible = true
			i.eaten = false
		for i in powerupGroup:
			i.visible = true
			i.eaten = false
			
		pellets = _countPellets()
