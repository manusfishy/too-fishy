extends CharacterBody3D

@export var speed_vertical = 1.0
@export var speed_horizontal = 3.0
@onready var hook = $hook
@onready var camera = $Camera3D
var throw_strength = 15.0 # Adjust for distance
var is_holding_hook = true
var target_velocity = Vector3.ZERO

func _ready():
	# Ensure hook starts as a child of the player
	hook.freeze = true # Prevents physics until thrown

func _input(event):
	if event.is_action_pressed("throw"): # Bind "throw" to a key (e.g., left mouse)
		if is_holding_hook:
			throw_hook()

func _physics_process(delta: float) -> void:
	var direction = Vector3.ZERO
	
	if Input.is_action_pressed("move_right"):
		direction.x += 1
		
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_up"):
		direction.y += 1
		if position.y >= 0:
			direction.y = 0
	if Input.is_action_pressed("move_down"):
		direction.y -= 1
	
	target_velocity.x = direction.x * speed_horizontal
	target_velocity.y = direction.y * speed_vertical
	target_velocity.z = 0
	
	velocity = target_velocity
	move_and_slide()


func throw_hook():
	# Detach hook from player
	hook.reparent(get_tree().root.get_child(0)) # Move to world root
	hook.freeze = false # Enable physics
	is_holding_hook = false
	
	# Calculate throw direction (forward from camera)
	var throw_direction = - camera.global_transform.basis.x.normalized()
	
	# Apply impulse to throw the hook
	hook.apply_central_impulse(throw_direction * throw_strength)
