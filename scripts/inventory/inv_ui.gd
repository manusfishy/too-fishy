extends Control

var is_open = false

func _ready():
	close()
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("inv_toggle"):
		if is_open:
			close()
		else :
			open()

	
func close():
	visible = false
	is_open = false
	
func open():
	visible = true
	is_open = true
	
