extends Area2D


func _on_area_entered(area):
	if area.speed != level_stats.getStats(level_stats.ghostTunnelSpeed):
		area.speed = level_stats.getStats(level_stats.ghostTunnelSpeed)


func _on_area_exited(area):
	if area.state == area.States.FRIGHTENED:
		area.speed = level_stats.getStats(level_stats.scareGhostSpeed)
	elif area.state == area.States.SCATTER or area.state == area.States.CHASE:
		area.speed = level_stats.getStats(level_stats.ghostSpeed)
