extends Node

		
##### SAVE FUNCTIONS #####
func save():
	var save_dict = {
		"highScore1": level_stats.highScore1,
		"highScore2": level_stats.highScore2,
		"highScore3": level_stats.highScore3
	}
	return save_dict
	
func save_game():
	var save_game = FileAccess.open("user://pacSam.save", FileAccess.WRITE)
	
	var json_string = JSON.stringify(save())
	
	save_game.store_line(json_string)
	
func load_data():
	if not FileAccess.file_exists("user://pacSam.save"):
		return
	
	var save_game = FileAccess.open("user://pacSam.save", FileAccess.READ)
	
	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()
		var json=JSON.new()
		var parse_result = json.parse(json_string)
		var node_data = json.get_data()
		
		for i in node_data.keys():
			if i=="highScore1":
				level_stats.highScore1 = node_data[i]
			elif i == "highScore2":
				level_stats.highScore2 = node_data[i]
			elif i == "highScore3":
				level_stats.highScore3 = node_data[i]
