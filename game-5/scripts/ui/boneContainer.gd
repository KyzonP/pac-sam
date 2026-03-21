extends HBoxContainer

@export var bone_scene: PackedScene 

func _ready():
	event_bus.fruitEaten.connect(add_acquired_bone)
	print("Connected: ", event_bus.fruitEaten.is_connected(add_acquired_bone))

func add_acquired_bone(anim_name):
	print("now")
	var new_bone = bone_scene.instantiate()
	add_child(new_bone)
	
	var anim = level_stats.getStats(level_stats.fruitName)
	var sprite = new_bone.get_node("AnimatedSprite2D")
	sprite.play(anim)
	
	new_bone.modulate.a = 0     # Start invisible
	new_bone.scale = Vector2.ZERO # Start tiny
	
	var tween = create_tween().set_parallel(true)
	
	tween.tween_property(new_bone, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(new_bone, "modulate:a", 1.0, 0.3)

	if get_child_count() > 7:
		var oldest = get_child(0)
		_tween_out_bone(oldest)
		
func _tween_out_bone(bone_node: Control):
	var tween_out = create_tween().set_parallel(true)
	
	tween_out.tween_property(bone_node, "modulate:a", 0.0, 0.3)
	tween_out.tween_property(bone_node, "scale", Vector2.ZERO, 0.3)
	
	tween_out.tween_property(bone_node, "custom_minimum_size:x", 0, 0.4).set_trans(Tween.TRANS_SINE)
	
	tween_out.chain().kill() # Stop the tween
	tween_out.chain().callback(bone_node.queue_free)
