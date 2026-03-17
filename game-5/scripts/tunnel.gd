extends Area2D

var enteredAreas = []

func _on_area_entered(area):
	print("teleport")
	
	if area.global_position.x < 0:
		area.global_position.x = 456
	elif area.global_position.x > 0:
		area.global_position.x = -8
	
