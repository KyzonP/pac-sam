extends TouchScreenButton

signal joystick_moved
signal joystick_released

var radiusJoyStick
var radiusJoyBase
var maxLength
var doubleLength

var touchInsideJoyStick = false

var held = false
var posOffset = Vector2.ZERO
var lastMousePos = Vector2.ZERO

@onready var parent = get_parent()

func _ready():
	radiusJoyStick = 38
	radiusJoyBase = 60
	
	maxLength = radiusJoyBase - radiusJoyStick
	doubleLength = maxLength * 2
	
	posOffset = get_parent().position + Vector2(-60,-60)
	
	### NEW ###
	parent.modulate.a = 0
		
func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed and not held:
			parent.global_position = event.position
			#parent.modulate.a = 1
			
			held = true
		elif not event.pressed:
			if held:
				_on_released()
		

func _physics_process(delta):
	if held:
		var center = parent.global_position
		var mouse_pos = get_global_mouse_position()
		
		var diff = mouse_pos - center
		if diff.length() > maxLength:
			diff = diff.normalized() * maxLength
			
		position = diff
		emit_signal("joystick_moved", position / maxLength)
	else:
		position = Vector2.ZERO
		
func _on_released():
	held = false
	get_parent().modulate.a = 0
	emit_signal("joystick_released")
