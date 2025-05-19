extends CharacterBody3D

@export var min_speed = 1
@export var max_speed = 2.5
@export var min_angle = -30
@export var max_angle = 30
@export var difficulty = 0
@export var rotation_cooldown = .1
@export var weight = 1
@export var price = 1
@export var is_shiny = false
@export var shiny_particles: GPUParticles3D

var rotation_cooldown_left = 0
var speed = 0
var home: int
var type: int

func removeFish():
	var fish_data = {
		"price": price,
		"weight": weight,
		"id": get_instance_id()
	}
	var my_fish = InvItem.new()
	my_fish.type = str(self.type) # Convert the numeric type to a string
	my_fish.weight = fish_data.weight
	my_fish.price = fish_data.price
	my_fish.id = fish_data.id
	my_fish.shiny = self.is_shiny # Also make sure to copy the shiny property
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
	
	if global_position.y >= -0.5:
		# Record this fish type as having reached the surface before deleting
		record_surface_achievement()
		queue_free()
		return
	elif global_position.y >= -0.75:
		if is_looking_up():
			var deg = randf_range(min_angle, min_angle / 2.0)
			set_z_rotation_and_velocity(deg)
	elif global_position.y <= GameState.fishes_lower_boarder:
		if !is_looking_up():
			var deg = randf_range(max_angle / 2.0, max_angle)
			set_z_rotation_and_velocity(deg)
	elif randf() < .004:
		set_z_rotation_and_velocity(randf_range(min_angle, max_angle))
		
		
	move_and_slide()
	
func initialize(mStart_position, mHome, mMin_speed, mMax_speed,
mDifficulty, mMin_weight, mMax_weight, price_weight_multiplier, mType, weight_multiplier, mIs_shiny = false):
	self.home = mHome
	self.min_speed = mMin_speed
	self.max_speed = mMax_speed
	self.difficulty = mDifficulty
	self.weight = clamp(randf_range(mMin_weight, mMax_weight) * weight_multiplier,
							mMin_weight, mMax_weight)
	self.price = round(weight * price_weight_multiplier)
	self.type = mType
	self.is_shiny = mIs_shiny
	
	scale = get_scale_for_weight(mMax_weight, mMin_weight, weight)
	
	if self.is_shiny:
		price = price * 3
	speed = randf_range(min_speed, max_speed)
	position = mStart_position
	add_to_group("fishes")
	
	set_z_rotation_and_velocity(randf_range(min_angle, max_angle))
	
	if self.shiny_particles != null:
		# Create a new material instance to prevent shared material modifications
		var particles_material = self.shiny_particles.process_material.duplicate()
		self.shiny_particles.process_material = particles_material
		
		# Set color based on shiny status
		if self.is_shiny:
			particles_material.color = Color(1.0, 0.9, 0.2) # Gold color
		else:
			particles_material.color = Color(0.2, 0.7, 1.0) # Blue color
			
		# Enable particles if shiny
		shiny_particles.emitting = self.is_shiny
	
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

func get_scale_for_weight(max_weight, min_weight, mWeight) -> Vector3:
	var weight_range = (max_weight - min_weight)
	var normal_weight = weight_range / 2
	var weight_sanitized = mWeight - min_weight
	var weight_factor = weight_sanitized / normal_weight
	var scale_factor = 1 + weight_factor * .3
	return Vector3(scale_factor, scale_factor, 1)

# Record that this fish type has reached the surface for achievements
func record_surface_achievement():
	# Only record if we can find the achievement system
	var achievement_manager = get_node_or_null("/root/AchievementManager")
	if achievement_manager and achievement_manager.has_method("get_achievement_system"):
		var achievement_system = achievement_manager.get_achievement_system()
		if achievement_system:
			print("Fish reached surface! Recording achievement for type: ", self.type)
			achievement_system.record_fish_surface(self.type)
	else:
		print("Could not record surface achievement - achievement system not found")
