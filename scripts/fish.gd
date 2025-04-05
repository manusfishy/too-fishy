extends CharacterBody3D

@export var min_speed = 1
@export var max_speed = 2.5
@export var min_angle = -30
@export var max_angle = 30
@export var difficulty = 0
@export var rotation_cooldown = .1

var rotation_cooldown_left = 0
var speed = 0

func _physics_process(delta: float) -> void:
	if rotation_cooldown_left > 0:
		rotation_cooldown_left -= delta
	
	if get_slide_collision_count() > 0 && rotation_cooldown_left <= 0:
		rotation_cooldown_left = rotation_cooldown
		var random_rotation = randf_range(min_angle, max_angle)
		rotate_y(deg_to_rad(180))
		
		rotation[2] = 0
		rotate_z(deg_to_rad(randf_range(min_angle, max_angle)))
		
		if rotation[1] < 0:
			velocity = Vector3.MODEL_RIGHT * speed
			velocity = velocity.rotated(Vector3.FORWARD, rotation.z)
		else:
			velocity = Vector3.MODEL_LEFT * speed
			velocity = velocity.rotated(Vector3.BACK, rotation.z)
		
	move_and_slide()
	
func initialize(start_position):
	speed = randf_range(min_speed, max_speed)
	position = start_position
	
	rotate_z(deg_to_rad(randf_range(min_angle, max_angle)))
	
	velocity = Vector3.MODEL_LEFT * speed
	velocity = velocity.rotated(Vector3.BACK, rotation.z)
	
