extends CharacterBody3D

@export var speed_vertical = 1.0
@export var speed_horizontal = 3.0

var target_velocity = Vector3.ZERO

func _physics_process(delta: float) -> void:
	var direction = Vector3.ZERO
	
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_up"):
		direction.y += 1
	if Input.is_action_pressed("move_down"):
		direction.y -= 1
	
	target_velocity.x = direction.x * speed_horizontal
	target_velocity.y = direction.y * speed_vertical
	target_velocity.z = 0
	
	velocity = target_velocity
	move_and_slide()
