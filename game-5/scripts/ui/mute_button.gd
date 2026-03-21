extends TextureButton

func _ready():
	pressed.connect(mutePressed)
	
func mutePressed():
	event_bus.toggleMute
	
	var master_bus = AudioServer.get_bus_index("Master")
	if AudioServer.is_bus_mute(master_bus):
		texture_normal = load("res://assets/ui/MuteButtonDisabled.png")
	else:
		texture_normal = load("res://assets/ui/MuteButton.png")
