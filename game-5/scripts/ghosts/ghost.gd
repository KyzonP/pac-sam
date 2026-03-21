extends Area2D


var state : States = States.SCATTER
var lastState : States = States.SCATTER
var lastDir : Direction = Direction.VOID
var moveDir : Direction = Direction.VOID
var speed : float = 75.0
@export var helper : Node2D
var PRNG : int = 0

var freeze : bool = true
var beenEaten : bool = false

var respawnTween : Tween
var releaseTween : Tween

const SNAP_DISTANCE = 1

enum States {CHASE, SCATTER, FRIGHTENED}
enum Direction {UP, DOWN, LEFT, RIGHT, VOID}

var targetTile : Vector2i
@export var startPos : Vector2

signal calculateTarget
signal changeAnim(direction)
signal flashAnim(final)
signal scareGhost()
signal ghostEaten()
signal ghostRespawned()

func _ready():
	targetTile = helper.maze.local_to_map(Vector2.ZERO)
	
	event_bus.ghostState.connect(changeState)
	event_bus.restart.connect(reset)
	event_bus.freeze.connect(freezeGhost)
	event_bus.ghostFlash.connect(flashGhost)

func _physics_process(delta):
	var cell = helper.maze.local_to_map(global_position)
	var centre = helper.maze.map_to_local(cell)
	
	# If lastDir != moveDir, check the different directions. If that direction is free, change the moveDir
	if lastDir != moveDir and helper.is_tile_free(lastDir, global_position):

		if global_position.distance_to(centre) < SNAP_DISTANCE:
			global_position = centre
			moveDir = lastDir
			changeAnim.emit(moveDir)
			
	# Check if we can even keep moving forwards
	if global_position.distance_to(centre) < (speed/1.5 * delta):
		checkIntersection(cell, centre)
	
	# Move in the direction currently set
	if !freeze:
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

# Check each direction - except the direction the ghost is coming from. If those directions are free, choose between them. (Unless turn is set to true)
func checkIntersection(_cell, centre, turn : bool = false, spawn : bool = false):
	emit_signal("calculateTarget", state)
	
	var possDir: Array[PotentialTiles] = []
	var _possibleDirections = 0
	
	if moveDir != Direction.UP or turn:
		if helper.is_tile_free(Direction.DOWN, centre + nextTile()):
			var newPoss = PotentialTiles.new(Direction.DOWN, helper.get_tile(Direction.DOWN, centre + nextTile()))
			possDir.append(newPoss)
			
			_possibleDirections += 1
			
	if moveDir != Direction.DOWN or turn:
		if helper.is_tile_free(Direction.UP, centre + nextTile()):
			var newPoss = PotentialTiles.new(Direction.UP, helper.get_tile(Direction.UP, centre + nextTile()))
			possDir.append(newPoss)
			
			_possibleDirections += 1
	
	if moveDir != Direction.RIGHT or turn:
		if helper.is_tile_free(Direction.LEFT, centre + nextTile()):
			var newPoss = PotentialTiles.new(Direction.LEFT, helper.get_tile(Direction.LEFT, centre + nextTile()))
			possDir.append(newPoss)
			
			_possibleDirections += 1
			
	if moveDir != Direction.LEFT or turn:
		if helper.is_tile_free(Direction.RIGHT, centre + nextTile()):
			var newPoss = PotentialTiles.new(Direction.RIGHT, helper.get_tile(Direction.RIGHT, centre + nextTile()))
			possDir.append(newPoss)
			
			_possibleDirections += 1
		
	
	# If there's only one way to go, just go that way
	if possDir.size() == 1:
		lastDir = possDir[0].dir
	else:
		# Otherwise, calculate the closest tile to the target tile
		var winner : Direction
		
		# Unless frightened, in which case it's pesudo random!
		if state != States.FRIGHTENED:
			var bestDistance = 100000000
			
			for i in possDir:
				var distance = i.pos.distance_to(helper.maze.map_to_local(targetTile))
				if distance < bestDistance:
					bestDistance = distance
					winner = i.dir
		elif state == States.FRIGHTENED:
			# First, choose a random direction to try - if it's free, go that way (unless it's the direction they're going already
			var randDir = randi_range(0,3)
			var randFound = false
			if randDir == 0 and moveDir != Direction.DOWN:
				if helper.is_tile_free(Direction.UP, centre + nextTile()):
					winner = Direction.UP
					randFound = true
			elif randDir == 1 and moveDir != Direction.RIGHT:
				if helper.is_tile_free(Direction.LEFT, centre + nextTile()):
					winner = Direction.LEFT
					randFound = true
			elif randDir == 2 and moveDir != Direction.LEFT:
				if helper.is_tile_free(Direction.RIGHT, centre + nextTile()):
					winner = Direction.RIGHT
					randFound = true
			elif randDir == 3 and moveDir != Direction.UP:
				if helper.is_tile_free(Direction.DOWN, centre + nextTile()):
					winner = Direction.DOWN
					randFound = true
			
			if !randFound:
				# Otherwise, check up, left, right, then down
				if helper.is_tile_free(Direction.UP, centre + nextTile()) and moveDir != Direction.DOWN:
					winner = Direction.UP
				elif helper.is_tile_free(Direction.LEFT, centre + nextTile()) and moveDir != Direction.RIGHT:
					winner = Direction.LEFT
				elif helper.is_tile_free(Direction.RIGHT, centre + nextTile()) and moveDir != Direction.LEFT:
					winner = Direction.RIGHT
				elif helper.is_tile_free(Direction.DOWN, centre + nextTile()) and moveDir != Direction.UP:
					winner = Direction.DOWN
		lastDir = winner
		
	if spawn:
		#216, 232 OR 232,232
		var leftDistance = Vector2(216,232).distance_to(helper.maze.map_to_local(targetTile))
		var rightDistance = Vector2(232,232).distance_to(helper.maze.map_to_local(targetTile))
		
		if leftDistance > rightDistance:
			moveDir = Direction.RIGHT
			changeAnim.emit(moveDir)
		else:
			moveDir = Direction.LEFT
			changeAnim.emit(moveDir)
		
		#for i in possDir:
			#var distance = i.pos.distance_to(helper.maze.map_to_local(targetTile))
			#if distance < bestDistance:
				#bestDistance = distance
				#winner = i.dir
		
# Swap between states - for many state changes, reverse direction. Sorry for having a str input for this lmao
func changeState(newState : String):
	# Some really bad code just so this doesn't run if they're being set to their current state
	# Chase, Scatter, Frightened
	var newStateInt
	if newState == "chase":
		newStateInt = 0
	elif newState == "scatter":
		newStateInt = 1
	else:
		newStateInt = 2
	
	if state != newStateInt:
		if state == States.FRIGHTENED:
			if newState == "scatter":
				state = States.SCATTER
			elif newState == "chase":
				state = States.CHASE
			speed = level_stats.getStats(level_stats.ghostSpeed)
		else:
			if newState == "scatter":
				state = States.SCATTER
			elif newState == "chase":
				state = States.CHASE
			elif newState == "frightened":
				# Storing their previous state for when they're eaten
				lastState = state
				
				state = States.FRIGHTENED
				scareGhost.emit()
				speed = level_stats.getStats(level_stats.scareGhostSpeed)
				
			_reverseDirection()

# Instantly reverse direction for ghost. (If doing so won't clip through a wall, that is)
func _reverseDirection():
	var cell = helper.maze.local_to_map(global_position)
	var centre = helper.maze.map_to_local(cell)
	
	if moveDir == Direction.UP:
		if helper.is_tile_free(Direction.DOWN, centre):
			moveDir = Direction.DOWN
			changeAnim.emit(moveDir)
		checkIntersection(cell, centre)
		return
	elif moveDir == Direction.LEFT:
		if helper.is_tile_free(Direction.RIGHT, centre):
			moveDir = Direction.RIGHT
			changeAnim.emit(moveDir)
		checkIntersection(cell, centre)
		return
	elif moveDir == Direction.RIGHT:
		if helper.is_tile_free(Direction.LEFT, centre):
			moveDir = Direction.LEFT
			changeAnim.emit(moveDir)
		checkIntersection(cell, centre)
		return
	elif moveDir == Direction.DOWN:
		if helper.is_tile_free(Direction.UP, centre):
			moveDir = Direction.UP
			changeAnim.emit(moveDir)
		checkIntersection(cell, centre)
		return
		
func flashGhost(final : bool = false):
	flashAnim.emit(final)
		
func freezeGhost():
	freeze = true
	
	if releaseTween:
		releaseTween.kill()
	if respawnTween:
		respawnTween.kill()
		
func reset(_death, _level):
	# Tidying up death animations
	if releaseTween:
		releaseTween.kill()
	if respawnTween:
		respawnTween.kill()
	ghostRespawned.emit()
	
	speed = level_stats.getStats(level_stats.ghostSpeed)
	changeState("scatter")
	
	global_position = startPos
	freeze = true
	beenEaten = false
			
func release(blinkyStart : bool = false):
	if releaseTween:
		releaseTween.kill()
	
	if !blinkyStart:
		releaseTween = get_tree().create_tween()
		releaseTween.tween_property(self, "position", Vector2(224,280), self.position.distance_to(Vector2(216,280))/speed)
		releaseTween.chain().tween_property(self, "position", Vector2(224,232), self.position.distance_to(Vector2(216,248))/speed)
		releaseTween.finished.connect(releaseDone)
	else:
		releaseDone()
	
func releaseDone():
	freeze = false
	refreshMovement(true)
	
func eaten():
	# Signal for death anim
	ghostEaten.emit()
	
	beenEaten = true
	
	if respawnTween:
		respawnTween.kill()
		
	respawnTween = get_tree().create_tween()
	respawnTween.tween_property(self, "position", Vector2(224,280), self.position.distance_to(Vector2(224,280))/speed)
	respawnTween.finished.connect(_eatenDone)
	
func _eatenDone():
	# Signal for respawn anim
	ghostRespawned.emit()
	
	# Some really bad code to convert the last state to an int
	var lastStateStr
	if lastState == States.CHASE:
		lastStateStr = "chase"
	elif lastState == States.SCATTER:
		lastStateStr = "scatter"
	elif lastState == States.FRIGHTENED:
		lastStateStr = "frightened"
		
	changeState(lastStateStr)
	
	beenEaten = false
	
	release()
	
# Func to stop weird movement on resets/pauses
func refreshMovement( blinky: bool = false):	
	lastDir = Direction.VOID
	moveDir = Direction.VOID
	var cell = helper.maze.local_to_map(global_position)
	var centre = helper.maze.map_to_local(cell)
	checkIntersection(cell, centre, true, blinky)
	
	
func checkFrightened():
	if state == States.FRIGHTENED:
		return true
	else:
		return false
		
# Class to hold potential directions
class PotentialTiles:
	var dir : Direction
	var pos : Vector2
	
	func _init(_dir: Direction, _pos: Vector2):
		dir = _dir
		pos = _pos
