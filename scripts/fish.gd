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

@export var mesh_instance_path: NodePath
var mesh_instance: MeshInstance3D

var rotation_cooldown_left = 0
var speed = 0
var home: int
var type: int
var accumulated_shader_time: float = 0.0 # Custom time accumulator for shader

# --- Shader Animation Speed Control (names describe rate of accumulation) ---
@export var base_anim_rate: float = 0.5 # Base rate for accumulated_shader_time
@export var speed_to_anim_rate_factor: float = 1.25 # Increased from 0.75
@export var min_effective_anim_rate: float = 0.2 # Min rate at which accumulated_shader_time advances
@export var max_effective_anim_rate: float = 4.0 # Max rate at which accumulated_shader_time advances
# --- End Shader Animation Speed Control ---

# WebGL Performance optimizations
var shader_update_timer: float = 0.0
var shader_update_interval: float = 0.033 # Update shader ~30fps instead of every frame
var is_webgl_build: bool = false

func _ready():
	# Detect WebGL build for performance optimizations
	is_webgl_build = OS.get_name() == "Web"
	
	# Reduce shader update frequency on WebGL
	if is_webgl_build:
		shader_update_interval = 0.05 # 20fps for shader updates on WebGL
	
	if mesh_instance_path:
		mesh_instance = get_node_or_null(mesh_instance_path)
		if !mesh_instance:
			printerr("  ERROR: Fish script could not find MeshInstance3D at path: ", mesh_instance_path, " for node: ", name)
	else:
		printerr("  ERROR: mesh_instance_path is not set for node: ", name)
	
	accumulated_shader_time = randf() * 2.0 * PI
	
	# Disable shiny particles on WebGL for performance
	if is_webgl_build and shiny_particles:
		shiny_particles.visible = false
		shiny_particles.emitting = false

func removeFish():
	var fish_data = {
		"price": price,
		"weight": weight,
		"id": get_instance_id()
	}
	var my_fish = InvItem.new()
	my_fish.type = str(self.type)
	my_fish.weight = fish_data.weight
	my_fish.price = fish_data.price
	my_fish.id = fish_data.id
	my_fish.shiny = self.is_shiny
	queue_free()
	return my_fish
	
func _physics_process(delta: float) -> void:
	# print("Fish ", name, ": _physics_process, delta: ", delta) # Uncomment for very verbose logging
	if rotation_cooldown_left > 0:
		rotation_cooldown_left -= delta
	
	if get_slide_collision_count() > 0 && rotation_cooldown_left <= 0:
		rotation_cooldown_left = rotation_cooldown
		rotate_y(deg_to_rad(180))
		var deg = randf_range(min_angle, max_angle)
		set_z_rotation_and_velocity(deg)
	
	if global_position.y >= -0.5:
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
	
	# Update shader animation with timer-based optimization
	shader_update_timer += delta
	if shader_update_timer >= shader_update_interval:
		update_shader_animation(shader_update_timer)
		shader_update_timer = 0.0

func update_shader_animation(delta_time: float):
	#if !mesh_instance:
		# print("Fish ", name, ": mesh_instance is null in _physics_process. Skipping animation update.") # Uncomment for verbose logging
		#return
	var material_override = mesh_instance.get_surface_override_material(0)
	#if !material_override:
		# print("Fish ", name, ": material_override is null. Skipping animation update.") # Uncomment for verbose logging
	#	return

	#if !(material_override is ShaderMaterial):
		# print("Fish ", name, ": material_override is not ShaderMaterial (Type: ", typeof(material_override), "). Skipping animation update.") # Uncomment for verbose logging
		#return

	# If we reach here, mesh_instance and material are valid
	var material: ShaderMaterial = material_override
	
	var current_speed: float = velocity.length()
	var effective_anim_rate = base_anim_rate + (current_speed * speed_to_anim_rate_factor)
	effective_anim_rate = clamp(effective_anim_rate, min_effective_anim_rate, max_effective_anim_rate)
	
	accumulated_shader_time += delta_time * effective_anim_rate
	
	# print("Fish ", name, ": current_speed: ", current_speed, ", effective_anim_rate: ", effective_anim_rate, ", new_accum_time: ", accumulated_shader_time) # Uncomment for verbose logging
	material.set_shader_parameter("animation_time_input", accumulated_shader_time)

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
			achievement_system.record_fish_surface(self.type)
