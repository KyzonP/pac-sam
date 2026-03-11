extends Area2D

enum Direction {UP, DOWN, LEFT, RIGHT, VOID}
var lastDir : Direction = Direction.LEFT
var moveDir : Direction = Direction.LEFT

var speed : float = 44.91

const SNAP_DISTANCE = 1

@export var helper : Node2D

var targetTile : Vector2i

# Class to hold potential directions
class PotentialTiles:
	var dir : Direction
	var pos : Vector2
	
	func _init(_dir: Direction, _pos: Vector2):
		dir = _dir
		pos = _pos

func _ready():
	targetTile = helper.maze.local_to_map(Vector2.ZERO)
	print(targetTile)
	print(helper.maze.map_to_local(targetTile))

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
		checkIntersection(cell, centre)
	
	# Move in the direction currently set
	match moveDir:
		Direction.UP: global_position.y -= speed * delta
		Direction.DOWN: global_position.y += speed * delta
		Direction.LEFT: global_position.x -= speed * delta
		Direction.RIGHT: global_position.x += speed * delta
		
#Have a target tile - usually Pac-Man
# When moving into a tile, check the tile ahead. Check in all directions (except the direction they're coming from)
# If there's only one viable one, that's the way to go
# If there are multiple, compare distance to the target tile

func nextTile():
	if moveDir == Direction.UP:
		return Vector2(0,-16)
	if moveDir == Direction.DOWN:
		return Vector2(0,16)
	if moveDir == Direction.RIGHT:
		return Vector2(16,0)
	if moveDir == Direction.LEFT:
		return Vector2(-16,0)
	
	return Vector2.ZERO

func checkIntersection(cell, centre):
	var possDir: Array[PotentialTiles] = []
	var possibleDirections = 0
	
	if moveDir != Direction.UP:
		if helper.is_tile_free(Direction.DOWN, centre + nextTile()):
			var newPoss = PotentialTiles.new(Direction.DOWN, helper.get_tile(Direction.DOWN, centre + nextTile()))
			possDir.append(newPoss)
			
			possibleDirections += 1
			
	if moveDir != Direction.DOWN:
		if helper.is_tile_free(Direction.UP, centre + nextTile()):
			var newPoss = PotentialTiles.new(Direction.UP, helper.get_tile(Direction.UP, centre + nextTile()))
			possDir.append(newPoss)
			
			possibleDirections += 1
	
	if moveDir != Direction.RIGHT:
		if helper.is_tile_free(Direction.LEFT, centre + nextTile()):
			var newPoss = PotentialTiles.new(Direction.LEFT, helper.get_tile(Direction.LEFT, centre + nextTile()))
			possDir.append(newPoss)
			
			possibleDirections += 1
			
	if moveDir != Direction.LEFT:
		if helper.is_tile_free(Direction.RIGHT, centre + nextTile()):
			var newPoss = PotentialTiles.new(Direction.RIGHT, helper.get_tile(Direction.RIGHT, centre + nextTile()))
			possDir.append(newPoss)
			
			possibleDirections += 1
		
	
	# If there's only one way to go, just go that way
	if possDir.size() == 1:
		lastDir = possDir[0].dir
	else:
		# Otherwise, calculate the closest tile to the target tile
		var winner : Direction
		var bestDistance = 100000000
		
		for i in possDir:
			var distance = i.pos.distance_to(helper.maze.map_to_local(targetTile))
			if distance < bestDistance:
				bestDistance = distance
				winner = i.dir
		
		lastDir = winner
