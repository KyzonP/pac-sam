extends Area2D

enum Direction {UP, DOWN, LEFT, RIGHT, VOID}
var lastDir : Direction = Direction.RIGHT
var moveDir : Direction = Direction.VOID

var speed : float = 59.88

const SNAP_DISTANCE = 4
@export var helper : Node2D


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
	
	# Move in the direction currently set
	match moveDir:
		Direction.UP: global_position.y -= speed * delta
		Direction.DOWN: global_position.y += speed * delta
		Direction.LEFT: global_position.x -= speed * delta
		Direction.RIGHT: global_position.x += speed * delta
