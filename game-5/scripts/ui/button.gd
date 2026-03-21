extends TextureButton

func _ready():
	button_down.connect(buttonDown)
	button_up.connect(buttonUp)
	
func buttonDown():
	if is_instance_valid($Text):
		$Text.position.y = 20
	
func buttonUp():
	if is_instance_valid($Text):
		$Text.position.y = 16
