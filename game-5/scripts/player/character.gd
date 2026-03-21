extends Area2D

var lastDir : Direction = Direction.RIGHT
var moveDir : Direction = Direction.RIGHT
var speed : float = 80.00
var freeze : bool = false
var pelletFreeze : bool = false
var powerupFreeze : bool = false
var powerupFreezeCounter : int = 0
var powerupFreezeCounterMax : int = 3

# For joystick input
var joystick_vector = Vector2.ZERO
var mobile = false

@export var helper : Node2D

const SNAP_DISTANCE = 4

enum Direction {UP, DOWN, LEFT, RIGHT, VOID}

@export var startPos : Vector2 = Vector2(224, 424)

@onready var anim : AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	event_bus.restart.connect(reset)
	event_bus.freeze.connect(freezeSam)
	event_bus.ghostState.connect(ghostFrightenedToggle)
	event_bus.startLevel.connect(start)
	event_bus.disableShadows.connect(disableShadows)
	
	refreshMovement()
	
# Func to stop weird movement on resets/pauses
func refreshMovement():
	lastDir = Direction.UP
	moveDir = Direction.UP
	var cell = helper.maze.local_to_map(global_position)
	var centre = helper.maze.map_to_local(cell)
	global_position = centre
	
func get_joystick_input():
	# Ignore deadzone
	if joystick_vector.length() < 0.3:
		return
		
	# Bias for switching axis
	var bias = 1.2
	
	if abs(joystick_vector.x) > abs(joystick_vector.y) * bias:
		if joystick_vector.x < 0:
			lastDir = Direction.LEFT
		elif joystick_vector.x > 0:
			lastDir = Direction.RIGHT
	elif abs(joystick_vector.y) > abs(joystick_vector.x) * bias:
		if joystick_vector.y < 0:
			lastDir = Direction.UP
		elif joystick_vector.y > 0:
			lastDir = Direction.DOWN
	
func on_joystick_moved(v):
	joystick_vector = v
	
func on_joystick_released():
	joystick_vector = Vector2.ZERO

func _input(event):
	if event.is_action_pressed("move_up"):
		lastDir = Direction.UP
	if event.is_action_pressed("move_down"):
		lastDir = Direction.DOWN
	if event.is_action_pressed("move_left"):
		lastDir = Direction.LEFT
	if event.is_action_pressed("move_right"):
		lastDir = Direction.RIGHT
	
func _physics_process(delta):
	if mobile:
		get_joystick_input()
	
	var cell = helper.maze.local_to_map(global_position)
	var centre = helper.maze.map_to_local(cell)
	
	# If lastDir != moveDir, check the different directions. If that direction is free, change the moveDir
	if lastDir != moveDir and helper.is_tile_free(lastDir, global_position):

		if global_position.distance_to(centre) < SNAP_DISTANCE:
			global_position = centre
			moveDir = lastDir
			
			playAnim(moveDir)
			
	# Check if we can even keep moving forwards
	if global_position.distance_to(centre) < (speed * delta):
		
		if not helper.is_tile_free(moveDir, global_position):
			global_position = centre
			moveDir = Direction.VOID
			
			playAnim(moveDir, true)
	
	# Move in the direction currently set if not frozen, or slowed by pellets/powerups
	if !freeze and !pelletFreeze and !powerupFreeze:
		match moveDir:
			Direction.UP: global_position.y -= speed * delta
			Direction.DOWN: global_position.y += speed * delta
			Direction.LEFT: global_position.x -= speed * delta
			Direction.RIGHT: global_position.x += speed * delta
	elif pelletFreeze:
		pelletFreeze = false
	elif powerupFreeze:
		if powerupFreezeCounter < powerupFreezeCounterMax:
			powerupFreezeCounter += 1
		else:
			powerupFreezeCounter = 0
			powerupFreeze = false
		
	### CHECK FOR OVERLAPPING AREA ###
	var overlapping_areas = get_overlapping_areas()
	
	for area in overlapping_areas:
		if area.is_in_group("ghost"):
			
			var ghostCell = helper.maze.local_to_map(area.global_position)
			if cell == ghostCell:
				if !area.checkFrightened() and !area.beenEaten:
					event_bus.emit_signal("endGame", true)
				elif !area.beenEaten:
					area.eaten()
					event_bus.emit_signal("ghostEaten")
				
func freezeSam():
	freeze = true
		
func ghostFrightenedToggle(state):
	if state == "frightened":
		speed = level_stats.getStats(level_stats.scareSamSpeed)
	else:
		speed = level_stats.getStats(level_stats.samSpeed)
		
func start():
	freeze = false
		
func reset(_death, _level):
	global_position = startPos
	refreshMovement()
	
	speed = level_stats.getStats(level_stats.samSpeed)
	
func playAnim(direction, stop : bool = false):
	if direction == Direction.UP:
		anim.animation = "up"
	elif direction == Direction.LEFT:
		anim.animation = "left"
	elif direction == Direction.RIGHT:
		anim.animation = "right"
	elif direction == Direction.DOWN:
		anim.animation = "down"
	
	if !stop:
		anim.play()
	else:
		anim.stop()
	
func disableShadows():
	$PointLight2D.shadow_enabled = false
