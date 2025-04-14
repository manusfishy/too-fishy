extends Control

# Virtual joystick variables
var joystick_active = false
var joystick_origin = Vector2.ZERO
var joystick_position = Vector2.ZERO
var joystick_direction = Vector2.ZERO
var joystick_radius = 100.0

# Shoot button variables
var shoot_button_rect = Rect2(0, 0, 150, 150)
var shoot_button_pressed = false

# Signals
signal joystick_input(direction)
signal shoot_pressed()

func _ready():
	# Position the shoot button in the bottom right corner
	var screen_size = get_viewport().get_visible_rect().size
	shoot_button_rect.position = Vector2(screen_size.x - shoot_button_rect.size.x - 20,
										screen_size.y - shoot_button_rect.size.y - 20)

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			# Check if touch is within shoot button
			if shoot_button_rect.has_point(event.position):
				shoot_button_pressed = true
				emit_signal("shoot_pressed")
			else:
				# Start joystick
				joystick_active = true
				joystick_origin = event.position
				joystick_position = event.position
		else:
			# End touch
			if shoot_button_rect.has_point(event.position) and shoot_button_pressed:
				shoot_button_pressed = false
			
			if joystick_active:
				joystick_active = false
				joystick_direction = Vector2.ZERO
				emit_signal("joystick_input", Vector2.ZERO)
	
	elif event is InputEventScreenDrag and joystick_active:
		joystick_position = event.position
		
		# Calculate joystick direction and limit to radius
		var direction = joystick_position - joystick_origin
		if direction.length() > joystick_radius:
			direction = direction.normalized() * joystick_radius
			joystick_position = joystick_origin + direction
		
		# Normalize for input
		joystick_direction = direction / joystick_radius
		emit_signal("joystick_input", joystick_direction)

func _draw():
	if OS.has_feature("mobile") or OS.has_feature("web"):
		# Draw joystick if active
		if joystick_active:
			# Draw joystick base
			draw_circle(joystick_origin, joystick_radius, Color(0.5, 0.5, 0.5, 0.5))
			# Draw joystick handle
			draw_circle(joystick_position, 50, Color(0.7, 0.7, 0.7, 0.7))
		
		# Draw shoot button
		var button_color = Color(1.0, 0.3, 0.3, 0.7)
		if shoot_button_pressed:
			button_color = Color(1.0, 0.5, 0.5, 0.8)
		
		draw_circle(shoot_button_rect.position + shoot_button_rect.size / 2, shoot_button_rect.size.x / 2, button_color)
		
		# Draw shoot icon (simple crosshair)
		var center = shoot_button_rect.position + shoot_button_rect.size / 2
		var line_length = 30
		draw_line(center - Vector2(line_length, 0), center + Vector2(line_length, 0), Color.WHITE, 5)
		draw_line(center - Vector2(0, line_length), center + Vector2(0, line_length), Color.WHITE, 5)

func _process(_delta):
	# Redraw the controls every frame to handle movement
	queue_redraw()
