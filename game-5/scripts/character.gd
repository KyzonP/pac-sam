extends Area2D

var lastDir : Direction = Direction.RIGHT
var moveDir : Direction = Direction.RIGHT
var speed : float = 80.00
var freeze : bool = false
var pelletFreeze : bool = false
var powerupFreeze : bool = false
var powerupFreezeCounter : int = 0
var powerupFreezeCounterMax : int = 3


@export var helper : Node2D

const SNAP_DISTANCE = 4

enum Direction {UP, DOWN, LEFT, RIGHT, VOID}

@export var startPos : Vector2 = Vector2(224, 424)

func _ready():
	event_bus.restart.connect(reset)
	event_bus.freeze.connect(freezeSam)
	event_bus.ghostState.connect(ghostFrightenedToggle)
	event_bus.startLevel.connect(start)
	
	refreshMovement()
	
# Func to stop weird movement on resets/pauses
func refreshMovement():
	lastDir = Direction.UP
	moveDir = Direction.UP
	var cell = helper.maze.local_to_map(global_position)
	var centre = helper.maze.map_to_local(cell)
	global_position = centre

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
	var cell = helper.maze.local_to_map(global_position)
	var centre = helper.maze.map_to_local(cell)
	
	# If lastDir != moveDir, check the different directions. If that direction is free, change the moveDir
	if lastDir != moveDir and helper.is_tile_free(lastDir, global_position):

		if global_position.distance_to(centre) < SNAP_DISTANCE:
			global_position = centre
			moveDir = lastDir
			
	# Check if we can even keep moving forwards
	if global_position.distance_to(centre) < (speed * delta):
		
		if not helper.is_tile_free(moveDir, global_position):
			global_position = centre
			moveDir = Direction.VOID
	
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
				if !area.checkFrightened():
					event_bus.emit_signal("endGame", true)
				elif !area.beenEaten:
					area.eaten()
					event_bus.emit_signal("ghostEaten")
				
func freezeSam():
	freeze = true
		
func ghostFrightenedToggle(state):
	if state == "frightened":
		speed = level_stats.setStats(level_stats.scareSamSpeed)
	else:
		speed = level_stats.setStats(level_stats.samSpeed)
		
func start():
	freeze = false
		
func reset(death, level):
	global_position = startPos
	refreshMovement()
	
	speed = level_stats.setStats(level_stats.samSpeed)
