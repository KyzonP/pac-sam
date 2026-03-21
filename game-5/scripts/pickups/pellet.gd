extends Area2D

signal pelletCrossed(pellet)

var eaten = false

func _on_area_entered(area):
	if !eaten:
		if area.is_in_group("player") or area.is_in_group("elroy"):
			area.pelletFreeze = true
		
		eaten = true
		pelletCrossed.emit(self)
