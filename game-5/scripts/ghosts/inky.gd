extends Node2D

@export var scatterTile : Vector2i
@export var player : Area2D
@export var blinky : Area2D
@export var pelletsEaten : int = -1
@export var releasePellets : int
@export var released : bool = false

enum States {CHASE, SCATTER, FRIGHTENED}
enum Direction {UP, DOWN, LEFT, RIGHT, VOID}

func _ready():
	scatterTile = get_parent().helper.maze.local_to_map(Vector2(408,568))
	
	get_parent().connect("calculateTarget", inkyTarget)
	get_parent().add_to_group("Inky")
	
	event_bus.pelletConsumed.connect(checkRelease)
	event_bus.restart.connect(reset)
	event_bus.startLevel.connect(start)
	event_bus.checkInky.connect(checkInky)
	
func start():
	checkRelease()
	
func reset(_death, level):
	pelletsEaten = -1
	released = false
	if level > 1:
		releasePellets = 0
	
func inkyTarget(state : States):
	# Go a few tiles in Sam's direction, then calculate distance between there and Blinky. Double that, and that's where Inky is headed
	if state == States.CHASE:
		var targetPos : Vector2
		if player.moveDir == player.Direction.UP:
			targetPos = player.global_position + Vector2(-32,-32)
		elif player.moveDir == player.Direction.LEFT:
			targetPos = player.global_position + Vector2(-32,0)
		elif player.moveDir == player.Direction.RIGHT:
			targetPos = player.global_position + Vector2(32,0)
		elif player.moveDir == player.Direction.DOWN:
			targetPos = player.global_position + Vector2(0,32)
		
		var offset = targetPos - blinky.global_position
		targetPos = targetPos + offset
		
		get_parent().targetTile = get_parent().helper.maze.local_to_map(targetPos)
	elif state == States.SCATTER:
		get_parent().targetTile = scatterTile
		
func checkRelease():
	pelletsEaten += 1
	
	if pelletsEaten >= releasePellets and !released:
		release()
	
func release():
	get_parent().release()
	
	released = true
	
func checkInky():
	if !released:
		release()
		event_bus.emit_signal("inkyReleased")
