extends Node2D

### ANIM VAR ###
@onready var anim : AnimatedSprite2D = get_parent().get_node("Anim")
@onready var scareAnim : AnimatedSprite2D = get_parent().get_node("ScareAnim")
@onready var eyes : AnimatedSprite2D = get_parent().get_node("Eyes")
@export var eaten : bool = false

enum Direction {UP, DOWN, LEFT, RIGHT, VOID}

func _ready():
	### ANIM SIGNALS ###
	get_parent().get_parent().connect("changeAnim", playAnim)
	get_parent().get_parent().connect("flashAnim", flashGhost)
	get_parent().get_parent().connect("scareGhost", scareGhost)
	get_parent().get_parent().connect("ghostEaten", ghostEaten)
	get_parent().get_parent().connect("ghostRespawned", ghostReleased)

### ANIM FUNC ###

func playAnim(direction):
	if direction == Direction.UP:
		anim.animation = "up"
		scareAnim.animation = "up"
	elif direction == Direction.LEFT:
		anim.animation = "left"
		scareAnim.animation = "left"
	elif direction == Direction.RIGHT:
		anim.animation = "right"
		scareAnim.animation = "right"
	elif direction == Direction.DOWN:
		anim.animation = "down"
		scareAnim.animation = "down"
	
func ghostEaten():
	eaten = true
	
	anim.visible = false
	scareAnim.visible = false
	eyes.visible = true
	
func ghostReleased():
	eyes.visible = false
	anim.visible = true
	scareAnim.visible = false
		
func scareGhost():
	anim.visible = false
	scareAnim.visible = true
		
func flashGhost(final : bool = false):
	if !final and !eaten:
		var current_state = anim.visible
		anim.visible = !current_state
		scareAnim.visible = current_state
	elif final:
		eaten = false
		eyes.visible = false
		anim.visible = true
		scareAnim.visible = false
