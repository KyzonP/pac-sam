extends Node2D

@export var scatterTile : Vector2i
@export var player : Area2D
@export var pelletsEaten : int = -1
@export var releasePellets : int
@export var elroy1 : int
@export var elroy2: int
@export var released : bool = false

enum States {CHASE, SCATTER, FRIGHTENED}
enum Direction {UP, DOWN, LEFT, RIGHT, VOID}

func _ready():
	scatterTile = get_parent().helper.maze.local_to_map(Vector2(408,8))
	
	get_parent().connect("calculateTarget", blinkyTarget)
	get_parent().add_to_group("Blinky")
	
	event_bus.pelletConsumed.connect(checkRelease)
	event_bus.restart.connect(reset)
	event_bus.startLevel.connect(start)
	
	elroy1 = level_stats.getStats(level_stats.elroyDots)
	elroy2 = level_stats.getStats(level_stats.elroyDots2)
	
func start():
	checkRelease()
	
func reset(_death, _level):
	pelletsEaten = -1
	released = false
	
	elroy1 = level_stats.getStats(level_stats.elroyDots)
	elroy2 = level_stats.getStats(level_stats.elroyDots2)
	
func blinkyTarget(state : States):
	if state == States.CHASE:
		get_parent().targetTile = get_parent().helper.maze.local_to_map(player.global_position)
	elif state == States.SCATTER:
		get_parent().targetTile = scatterTile
		
### CRUISE ELROY CODE HERE ###
func checkRelease():
	pelletsEaten += 1
	
	if pelletsEaten >= releasePellets and !released:
		release(true)
	elif (244 - pelletsEaten) < elroy1:
		get_parent().speed = level_stats.getStats(level_stats.elroySpeed)
	elif (244 - pelletsEaten) < elroy2:
		get_parent().speed = level_stats.getStats(level_stats.elroySpeed2)
	
func release(blinkyStart: bool = false):
	get_parent().release(blinkyStart)
	
	released = true
