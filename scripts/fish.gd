extends CharacterBody3D

@export var min_speed = 1
@export var max_speed = 2.5
@export var min_angle = -30
@export var max_angle = 30
@export var difficulty = 0
@export var rotation_cooldown = .1
@export var weight = 1
@export var price = 1

var rotation_cooldown_left = 0
var speed = 0
var home: int


func removeFish():
	var fish_data = {
		"price": price,
		"weight": weight,
		"id": get_instance_id()
	}
	var my_fish = InvItem.new()
	my_fish.type = "fish"
	my_fish.weight = fish_data.weight
	my_fish.price = fish_data.price
	my_fish.id = fish_data.id
	queue_free()
	return my_fish
	


func _physics_process(delta: float) -> void:
	if rotation_cooldown_left > 0:
		rotation_cooldown_left -= delta
	
	if get_slide_collision_count() > 0 && rotation_cooldown_left <= 0:
		rotation_cooldown_left = rotation_cooldown
		rotate_y(deg_to_rad(180))
		
		var deg = randf_range(min_angle, max_angle)
		
		set_z_rotation_and_velocity(deg)
		
	if global_position.y >= -0.75:
		if is_looking_up():
			var deg = randf_range(min_angle, min_angle / 2)
			set_z_rotation_and_velocity(deg)
	elif global_position.y <= GameState.fishes_lower_boarder:
		if !is_looking_up():
			var deg = randf_range(max_angle / 2, max_angle)
			set_z_rotation_and_velocity(deg)
	elif randf() < .004:
		set_z_rotation_and_velocity(randf_range(min_angle, max_angle))
		
		
	move_and_slide()
	
func initialize(start_position, home, min_speed, max_speed, difficulty, min_weight, max_weight, price_weight_multiplier):
	self.home = home
	self.min_speed = min_speed
	self.max_speed = max_speed
	self.difficulty = difficulty
	self.weight = randf_range(min_weight, max_weight)
	self.price = round(weight * price_weight_multiplier)
	speed = randf_range(min_speed, max_speed)
	position = start_position
	add_to_group("fishes")
	
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
	
func scatter(body: Node3D) -> void:
	if (body.global_position.x < global_position.x && is_facing_left() or 
		body.global_position.x > global_position.x && !is_facing_left()):
		rotate_y(deg_to_rad(180))
	if (body.global_position.y < global_position.y):
		set_z_rotation_and_velocity(randf_range(35, 55))
	else:
		set_z_rotation_and_velocity(randf_range(-35, -55))
	
		
	pass
