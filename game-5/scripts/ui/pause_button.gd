extends TextureButton

func _ready():
	pressed.connect(pausePressed)
	
func pausePressed():
	event_bus.emit_signal("togglePause")
