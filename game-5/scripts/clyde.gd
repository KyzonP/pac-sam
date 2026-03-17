extends Node2D

@export var scatterTile : Vector2i
@export var player : Area2D
@export var pelletsEaten : int = -1
@export var releasePellets : int
@export var released : bool = false

enum States {CHASE, SCATTER, FRIGHTENED}
enum Direction {UP, DOWN, LEFT, RIGHT, VOID}

func _ready():
	scatterTile = get_parent().helper.maze.local_to_map(Vector2(40,568))
	
	get_parent().connect("calculateTarget", clydeTarget)
	get_parent().add_to_group("Clyde")
	
	event_bus.pelletConsumed.connect(checkRelease)
	event_bus.restart.connect(reset)
	event_bus.startLevel.connect(start)
	
func start():
	checkRelease()
	
func reset(death, level):
	pelletsEaten = -1
	released = false
	
func clydeTarget(state : States):
	# if more than 8 tiles away from Sam, go towards him - otherwise, go to scatter tile
	if state == States.CHASE:
		if self.global_position.distance_to(player.global_position) > 128:
			get_parent().targetTile = get_parent().helper.maze.local_to_map(player.global_position)
		else:
			get_parent().targetTile = scatterTile
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
