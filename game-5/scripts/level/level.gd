extends Node2D

@export var levelNumber : int = 0

var score : int = 0
var level = 1
var lives : int = 3

var pelletsEaten : int = 0
var won : bool = false
var levelStart : bool = false
var freeze : bool = false
var ghostFrightened : bool = false
var ghostsEaten : int = 0
var ghostFlashes : int = 5
var fruit1 : int = 70
var fruit1Spawned : bool = false
var fruit2 : int = 170
var fruit2Spawned : bool = false
var lifeGained : bool = false

### TIMERS ###
var stateTimer = 0.0
var frightenedTimer = 0.0
var frightenedTimerMax = 6.0
@export var flashTimer = 0.0
@export var flashTimerMax = 0.5

var state : States = States.SCATTER

var stateTimes = [7,20,7,20,5,20,5]

enum States {CHASE, SCATTER, FRIGHTENED}

### AUDIO ###
var hurtSound = preload("res://audio/hurt_randomizer.tres")

var speed_milestones = [
	{"threshold": 50, "pitch": 1.1, "reached": false},
	{"threshold": 100, "pitch": 1.2, "reached": false},
	{"threshold": 150, "pitch": 1.3, "reached": false},
	{"threshold": 200, "pitch": 1.4, "reached": false}
]

func _ready():
	# Save data
	save_load.load_data()
	
	# Start audio
	AudioManager.play_music(AudioManager.soundtrack, 1.0)
	
	# Reset level stats
	level_stats.level = 1
	
	# Link up mobile controls
	checkMobile()
	
	if levelNumber == 1:
		$UI/HighScore.text = "[center]High Score[br][/center]" + str(int(level_stats.highScore1))
	elif levelNumber == 2:
		$UI/HighScore.text = "[center]High Score[br][/center]" + str(int(level_stats.highScore2))
	elif levelNumber == 3:
		$UI/HighScore.text = "[center]High Score[br][/center]" + str(int(level_stats.highScore3))
	$Pellets.connect("scoreChanged", ScoreChanged)
	
	event_bus.pelletConsumed.connect(checkWin)
	event_bus.endGame.connect(endGame)
	event_bus.ghostState.connect(ghostFrightenedToggle)
	event_bus.restart.connect(reset)
	event_bus.fruitEaten.connect(ScoreChanged)
	
	event_bus.emit_signal("startLevel")
	
	
func checkMobile():
	if OS.has_feature("web_android") or OS.has_feature("web_ios"):
		get_node_or_null("TouchJoystick/TouchScreenButton").connect("joystick_moved", Callable(get_node_or_null("Sam"), "on_joystick_moved"))
		get_node_or_null("TouchJoystick/TouchScreenButton").connect("joystick_released", Callable(get_node_or_null("Sam"), "on_joystick_released"))
		get_node_or_null("Sam").mobile = true
		
		event_bus.emit_signal("disableShadows")
		
		get_viewport().scaling_3d_scale = 0.75
		Engine.max_fps = 60
	else:
		get_node_or_null("TouchJoystick").queue_free()
		
func reset(death, _levelNo):
	# If a restart is happening due to a death
	if death:
		stateTimer = 0
		
	# If a restart is happening due to completion of the level
	else:
		# Audio
		AudioManager.music_player.pitch_scale = 1.0
		
		stateTimer = 0
		
		level = level + 1
			
		frightenedTimerMax = level_stats.getStats(level_stats.scareTime)
		ghostFlashes = level_stats.getStats(level_stats.scareFlashes)
		
		pelletsEaten = 0
		won = false
		
		fruit1Spawned = false
		fruit2Spawned = false
		
	ghostFrightened = false
	event_bus.emit_signal("ghostFlash", true)
	state = States.SCATTER
	freeze = false
	event_bus.emit_signal("startLevel")
	
	if stateTimes != level_stats.getStats(level_stats.stateTimes):
		stateTimes = level_stats.getStats(level_stats.stateTimes)
		
func checkWin():
	pelletsEaten += 1
	
	checkFruit()
	
	checkAudio()
	
	if pelletsEaten >= 244 and !won:
		won = true
		endGame(false)
		
func checkAudio():
	for milestone in speed_milestones:
		if pelletsEaten >= milestone.threshold and not milestone.reached:
			milestone.reached = true
			AudioManager.music_player.pitch_scale = milestone.pitch
		
func endGame(death):
	if !freeze:
		freeze = true
		event_bus.emit_signal("freeze")
		
		if death:
			AudioManager.play_sfx(hurtSound)
		
		# Do a few things #
		await get_tree().create_timer(2.0).timeout
		
		if death:
			lives = lives - 1
			event_bus.emit_signal("lifeChanged", lives)
			$UI/Lives.text = "[center]" + str(lives)
			if lives > 0:
				event_bus.emit_signal("restart", true, level)
			else:
				if levelNumber == 1:
					if score > level_stats.highScore1:
						level_stats.highScore1 = score
				elif levelNumber == 2:
					if score > level_stats.highScore2:
						level_stats.highScore2 = score
				elif levelNumber == 3:
					if score > level_stats.highScore3:
						level_stats.highScore3 = score
						
				save_load.save_game()
					
				get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
		else:
			
			level_stats.level = level_stats.level+1
			event_bus.emit_signal("restart", false, level + 1)
			
	
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
			event_bus.emit_signal("ghostFlash", true)
			
			frightenedTimer = 0
			ghostFrightened = false
			ghostsEaten = 0
			if state == States.SCATTER:
				event_bus.emit_signal("ghostState", "scatter")
			elif state == States.CHASE:
				event_bus.emit_signal("ghostState", "chase")
		elif frightenedTimer > (frightenedTimerMax - (flashTimerMax * (ghostFlashes + 1))):
			flashTimer += delta
			if flashTimer >= flashTimerMax/2:
				flashTimer = 0
				event_bus.emit_signal("ghostFlash", false)
		
func ghostFrightenedToggle(newState):
	if newState == "frightened":
		ghostFrightened = true
		frightenedTimer = 0

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
	
	if score >= 10000 and not lifeGained:
		lives = lives + 1
		lifeGained = true
		event_bus.emit_signal("lifeChanged", lives)
	
	$UI/Score.text = "[center]Score[br]" + str(score)
	
func checkFruit():
	if pelletsEaten >= fruit1 and !fruit1Spawned:
		fruit1Spawned = true
		event_bus.emit_signal("spawnFruit")
	elif pelletsEaten >= fruit2 and !fruit2Spawned:
		fruit2Spawned = true
		event_bus.emit_signal("spawnFruit")
