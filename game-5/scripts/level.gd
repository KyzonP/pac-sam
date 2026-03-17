extends Node2D

var score : int = 0
var level = 1
var lives : int = 3

var pelletsEaten : int = 0
var won : bool = false
var levelStart : bool = false
var freeze : bool = false
var ghostFrightened : bool = false
var ghostsEaten : int = 0


### TIMERS ###
var stateTimer = 0.0
var frightenedTimer = 0.0
var frightenedTimerMax = 6.0

var state : States = States.SCATTER

var stateTimes = [7,20,7,20,5,20,5]

enum States {CHASE, SCATTER, FRIGHTENED}



func _ready():
	$HighScore.text = "[center]" + str(level_stats.highScore)
	$Pellets.connect("scoreChanged", ScoreChanged)
	
	event_bus.pelletConsumed.connect(checkWin)
	event_bus.endGame.connect(endGame)
	event_bus.ghostState.connect(ghostFrightenedToggle)
	event_bus.restart.connect(reset)
	
	event_bus.emit_signal("startLevel")
		
func reset(death, level):
	# If a restart is happening due to a death
	if death:
		stateTimer = 0

		stateTimes = level_stats.setStats(level_stats.stateTimes)
		
	# If a restart is happening due to completion of the level
	else:
		stateTimer = 0
		
		level = level + 1
		
		if level > 1 and level < 5:
			stateTimes = [7,20,7,20,5,1033,0.016666]
		elif level >= 5:
			stateTimes = [5,20,5,20,5,1037,0.016666]
			
		stateTimes = level_stats.setStats(level_stats.stateTimes)
			
	state = States.SCATTER
	freeze = false
	event_bus.emit_signal("startLevel")
		
func checkWin():
	pelletsEaten += 1
	
	if pelletsEaten >= 244 and !won:
		won = true
		endGame(false)
		
		
func endGame(death):
	if !freeze:
		freeze = true
		event_bus.emit_signal("freeze")
		
		# Do a few things #
		await get_tree().create_timer(2.0).timeout
		
		if death:
			lives = lives - 1
			$Lives.text = "[center]" + str(lives)
			if lives > 0:
				event_bus.emit_signal("restart", true, level)
			else:
				print("Game Over!")
				if score > level_stats.highScore:
					level_stats.highScore = score
					get_tree().reload_current_scene()
		else:
			event_bus.emit_signal("restart", false, level + 1)
			level_stats.level = level+1
	
func _physics_process(delta):
	if !ghostFrightened and !won:
		stateTimer += delta
		if stateTimes.size() > 0 and stateTimer >= stateTimes[0]:
			stateTimer = 0
			stateTimes.pop_front()

			if state == States.SCATTER:
				event_bus.emit_signal("ghostState", "chase")
				state = States.CHASE
			elif state == States.CHASE:
				event_bus.emit_signal("ghostState", "scatter")
				state = States.SCATTER
	elif !won:
		frightenedTimer += delta
		if frightenedTimer >= frightenedTimerMax:
			frightenedTimer = 0
			ghostFrightened = false
			ghostsEaten = 0
			if state == States.SCATTER:
				event_bus.emit_signal("ghostState", "scatter")
			elif state == States.CHASE:
				event_bus.emit_signal("ghostState", "chase")
		
func ghostFrightenedToggle(state):
	if state == "frightened":
		ghostFrightened = true

func ghostEaten():
	if ghostsEaten == 0:
		ScoreChanged(200)
		ghostsEaten = 1
	elif ghostsEaten == 1:
		ScoreChanged(400)
		ghostsEaten = 2
	elif ghostsEaten == 2:
		ScoreChanged(600)
		ghostsEaten = 3
	elif ghostsEaten == 3:
		ScoreChanged(800)
		ghostsEaten = 4


func ScoreChanged(amount):
	score += amount
	$Score.text = "[center]" + str(score)
