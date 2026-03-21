extends CanvasLayer

@onready var life1 = $Life1 #192, 544
@onready var life2 = $Life2 #216, 544
@onready var life3 = $Life3 #240, 592

var life1Tween : Tween
var life2Tween : Tween
var life3Tween : Tween

var lives : int = 2

func _ready():
	event_bus.lifeChanged.connect(lifeChanged)
	
	event_bus.restart.connect(reset)
	
func reset(death, _level):
	if not death:
		lives = 2
		
		killTweens()
	else:
		pass
		
func killTweens():
	if life1Tween:
		life1Tween.kill()
	if life2Tween:
		life2Tween.kill()
	if life3Tween:
		life3Tween.kill()
	
func lifeChanged(remaining):
	killTweens()
	
	# Create one tween that moves everything at once
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE)
	
	# Ternary logic: if 'remaining' is high enough, Y is 544, else it's 592 (off-screen)
	tween.tween_property(life1, "position:y", 552 if remaining >= 2 else 592, 0.5)
	tween.tween_property(life2, "position:y", 552 if remaining >= 3 else 592, 0.5)
	tween.tween_property(life3, "position:y", 552 if remaining >= 4 else 592, 0.5)
	
	#if remaining == 4:
		#life1Tween = get_tree().create_tween()
		#life1Tween.tween_property(life1, "position", Vector2(192,544), 0.5)
		#
		#life2Tween = get_tree().create_tween()
		#life2Tween.tween_property(life2, "position", Vector2(216,544), 0.5)
		#
		#life3Tween = get_tree().create_tween()
		#life3Tween.tween_property(life3, "position", Vector2(240,544), 0.5)
	#elif remaining == 3:
		#life1Tween = get_tree().create_tween()
		#life1Tween.tween_property(life1, "position", Vector2(192,544), 0.5)
		#
		#life2Tween = get_tree().create_tween()
		#life2Tween.tween_property(life2, "position", Vector2(216,544), 0.5)
		#
		#life3Tween = get_tree().create_tween()
		#life3Tween.tween_property(life3, "position", Vector2(240,592), 0.5)
	#elif remaining == 2:
		#life1Tween = get_tree().create_tween()
		#life1Tween.tween_property(life1, "position", Vector2(192,544), 0.5)
		#
		#life2Tween = get_tree().create_tween()
		#life2Tween.tween_property(life2, "position", Vector2(216,592), 0.5)
		#
		#life3Tween = get_tree().create_tween()
		#life3Tween.tween_property(life3, "position", Vector2(240,592), 0.5)
	#elif remaining == 1:
		#life1Tween = get_tree().create_tween()
		#life1Tween.tween_property(life1, "position", Vector2(192,592), 0.5)
		#
		#life2Tween = get_tree().create_tween()
		#life2Tween.tween_property(life2, "position", Vector2(216,592), 0.5)
		#
		#life3Tween = get_tree().create_tween()
		#life3Tween.tween_property(life3, "position", Vector2(240,592), 0.5)
