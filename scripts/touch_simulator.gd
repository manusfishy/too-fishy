extends Node

# This script simulates touch events for testing touch controls in desktop environment

func _ready():
	print("Touch simulator ready")
	
func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			# Simulate touch press
			var touch_event = InputEventScreenTouch.new()
			touch_event.pressed = true
			touch_event.position = event.position
			touch_event.index = 0
			Input.parse_input_event(touch_event)
		elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			# Simulate touch release
			var touch_event = InputEventScreenTouch.new()
			touch_event.pressed = false
			touch_event.position = event.position
			touch_event.index = 0
			Input.parse_input_event(touch_event)
	
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# Simulate touch drag
		var drag_event = InputEventScreenDrag.new()
		drag_event.position = event.position
		drag_event.relative = event.relative
		drag_event.index = 0
		Input.parse_input_event(drag_event)
