extends Node2D

enum Direction {UP, DOWN, LEFT, RIGHT}
@export var maze : TileMapLayer

func is_tile_free(dir, pos) -> bool:
	# Get current cell
	var current_cell = maze.local_to_map(pos)
	
	# Calculate next cell based on direction
	var next_cell = current_cell
	match dir:
		Direction.UP: next_cell.y -= 1
		Direction.DOWN: next_cell.y += 1
		Direction.LEFT: next_cell.x -= 1
		Direction.RIGHT: next_cell.x += 1
		
	# Check if it's free - if so, return true
	var tile_data = maze.get_cell_tile_data(next_cell)
	
	if tile_data == null:
		return true
	else:
		return false

func snap_to_grid(body, pos):
	var current_cell = maze.local_to_map(pos)
	
	body.global_position = maze.map_to_local(current_cell)
