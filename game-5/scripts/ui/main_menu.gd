extends Control

func _on_classic_pressed():
	get_tree().change_scene_to_file("res://levels/Level1.tscn")


func _on_temple_pressed():
	get_tree().change_scene_to_file("res://levels/Level2.tscn")


func _on_tomb_pressed():
	get_tree().change_scene_to_file("res://levels/Level3.tscn")
