extends Node2D

@export var scatterTile : Vector2i
@export var player : Area2D
@export var pelletsEaten : int = -1
@export var releasePellets : int
@export var released : bool = false

enum States {CHASE, SCATTER, FRIGHTENED}
enum Direction {UP, DOWN, LEFT, RIGHT, VOID}

func _ready():
	scatterTile = get_parent().helper.maze.local_to_map(Vector2(40,8))
	
	get_parent().connect("calculateTarget", pinkyTarget)
	get_parent().add_to_group("Pinky")
	
	event_bus.pelletConsumed.connect(checkRelease)
	event_bus.restart.connect(reset)
	event_bus.startLevel.connect(start)
	event_bus.disableShadows.connect(disableShadows)
	
func start():
	checkRelease()
	
func reset(_death, _level):
	pelletsEaten = -1
	released = false
	
func pinkyTarget(state : States):
	# Go 4 tiles in the direction Sam is heading - unless going up, when it becomes diagonal
	if state == States.CHASE:
		var targetPos : Vector2
		if player.moveDir == player.Direction.UP:
			targetPos = player.global_position + Vector2(-64,-64)
		elif player.moveDir == player.Direction.LEFT:
			targetPos = player.global_position + Vector2(-64,0)
		elif player.moveDir == player.Direction.RIGHT:
			targetPos = player.global_position + Vector2(64,0)
		elif player.moveDir == player.Direction.DOWN:
			targetPos = player.global_position + Vector2(0,64)
		
		get_parent().targetTile = get_parent().helper.maze.local_to_map(targetPos)
	elif state == States.SCATTER:
		get_parent().targetTile = scatterTile
		
### CRUISE ELROY CODE HERE ###
func checkRelease():
	pelletsEaten += 1
	
	if pelletsEaten >= releasePellets and !released:
		release()
	
func release():
	get_parent().release()
	
	released = true

func disableShadows():
	$PointLight2D.shadow_enabled = false
