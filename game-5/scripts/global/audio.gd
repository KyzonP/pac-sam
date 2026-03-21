extends Node

func _ready():
	event_bus.toggleMute.connect(toggleMute)

func _input(event):
	if event.is_action_pressed("mute"):
		toggleMute()

func toggleMute():
	var master_bus = AudioServer.get_bus_index("Master")
	var is_muted = AudioServer.is_bus_mute(master_bus)
	AudioServer.set_bus_mute(0, !is_muted)
