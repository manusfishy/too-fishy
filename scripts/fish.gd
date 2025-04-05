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
		
		var deg = randf_range(min_angle, max_angle)
		
		set_z_rotation_and_velocity(deg)
			
	print(position.y)
	if position.y >= -0.75:
		if is_looking_up():
			var deg = randf_range(min_angle, min_angle/2)
			set_z_rotation_and_velocity(deg)
		
	move_and_slide()
	
func initialize(start_position):
	speed = randf_range(min_speed, max_speed)
	position = start_position
	
	set_z_rotation_and_velocity(randf_range(min_angle, max_angle))
	
func set_z_rotation_and_velocity(deg: float) -> void:
	rotation[2] = 0
	var rad = deg_to_rad(deg)
		
	if is_facing_left():
		rotate_z(-rad)
		velocity = Vector3.MODEL_RIGHT * speed
		velocity = velocity.rotated(Vector3.FORWARD, rotation.z)
	else:
		rotate_z(rad)
		velocity = Vector3.MODEL_LEFT * speed
		velocity = velocity.rotated(Vector3.BACK, rotation.z)
	
	
func is_facing_left() -> bool:
	return rotation[1] < 0
	
func is_looking_up() -> bool:
	return rotation[2] > 0
