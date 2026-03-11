extends Area2D

signal pelletCrossed(pellet)

func _on_area_entered(area):
	pelletCrossed.emit(self)
