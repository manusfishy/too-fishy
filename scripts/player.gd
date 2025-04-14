extends CharacterBody3D

@export var speed_vertical = 1.0
@export var speed_horizontal = 1.0

@onready var camera = $Camera3D
var throw_strength = 15.0 # Adjust for distance
var is_holding_hook = true
var target_velocity = Vector3.ZERO

@onready var sound_player = $SoundPlayer
@onready var pickaxe_scene = preload("res://scenes/pickaxe.tscn")
@export var inventory: Inv
@export var traumaShakeMode = 1
@onready var cooldown_timer = $HarpoonCD # Timer node, set to one-shot, 2s wait time

var harpoon_scene = preload("res://scenes/harpoon.tscn") # Path to harpoon scene
var bullet_scene = preload("res://scenes/bullet.tscn")
var ak_scene = preload("res://scenes/ak47.tscn")
var touch_controls_scene = preload("res://scenes/ui/touch_controls.tscn")
var can_shoot = true
var touch_controls = null
var touch_direction = Vector2.ZERO

signal section_changed(sectionType)

func _ready():
	GameState.player_node = self
	print("player ready")
	
	# Initialize touch controls if on mobile
	if OS.has_feature("mobile") or OS.has_feature("web"):
		touch_controls = touch_controls_scene.instantiate()
		get_tree().root.add_child(touch_controls)
		touch_controls.joystick_input.connect(_on_joystick_input)
		touch_controls.shoot_pressed.connect(_on_shoot_pressed)

func _on_joystick_input(direction):
	touch_direction = direction

func _on_shoot_pressed():
	if can_shoot and !GameState.paused and !is_mouse_over_ui():
		shoot_harpoon()

func collision():
	var _collision = move_and_slide()
	
	# Check for collisions after movement
	for i in get_slide_collision_count():
		var collision_info = get_slide_collision(i)
		var collider = collision_info.get_collider()
		if collider is CharacterBody3D:
			if "type" in collider:
				if collider.type == FishesConfig.FishType.SPIKEY_FISH:
					hurtPlayer(5)

var can_be_hurt = true

func hurtPlayer(damage: int):
	add_trauma(1)
	if can_be_hurt:
		GameState.health -= damage
		sound_player.play_sound("ughhh")
		can_be_hurt = false
		get_tree().create_timer(1.0).timeout.connect(reset_hurt_cooldown)

func reset_hurt_cooldown():
	can_be_hurt = true

var acceleration_x := 2.0
var max_speed_x := 5.0
var velocity_x := 0.0
func movement(_delta: float):
	var direction = Vector3.ZERO

	# Handle keyboard input
	if Input.is_action_pressed("move_right"):
		velocity_x = min(velocity_x + acceleration_x * _delta, max_speed_x)
		if $Pivot.rotation[1] < 0:
			$Pivot.rotate_y(deg_to_rad(180))
	elif Input.is_action_pressed("move_left"):
		velocity_x = max(velocity_x - acceleration_x * _delta, -max_speed_x)
		if $Pivot.rotation[1] >= 0:
			$Pivot.rotate_y(deg_to_rad(180))
	# Handle touch input for horizontal movement
	elif touch_direction.x != 0:
		velocity_x = touch_direction.x * max_speed_x
		if touch_direction.x > 0 and $Pivot.rotation[1] < 0:
			$Pivot.rotate_y(deg_to_rad(180))
		elif touch_direction.x < 0 and $Pivot.rotation[1] >= 0:
			$Pivot.rotate_y(deg_to_rad(180))
	else:
		if velocity_x > 0:
			velocity_x = max(velocity_x - acceleration_x * _delta, 0)
		elif velocity_x < 0:
			velocity_x = min(velocity_x + acceleration_x * _delta, 0)

	direction.x = velocity_x
	
	# Handle keyboard input for vertical movement
	if Input.is_action_pressed("move_up"):
		direction.y += 1
		if position.y >= 0:
			direction.y = 0
	elif Input.is_action_pressed("move_down"):
		direction.y -= 1
	# Handle touch input for vertical movement
	elif touch_direction.y != 0:
		direction.y = touch_direction.y
		if touch_direction.y > 0 and position.y >= 0:
			direction.y = 0
		
	target_velocity.x = direction.x * (speed_horizontal + (GameState.upgrades[GameState.Upgrade.HOR_SPEED] * 1.5))
	target_velocity.y = direction.y * (speed_vertical + (GameState.upgrades[GameState.Upgrade.VERT_SPEED] * 1.5))
	
	if direction.y >= 1:
		target_velocity.y = target_velocity.y * 2
	
	target_velocity.z = 0
	velocity = target_velocity
	if GameState.paused:
		velocity = Vector3.ZERO
	move_and_slide()
	position.z = 0.33


func _physics_process(delta: float) -> void:
	movement(delta)
	collision()
	
	var depthSnapped = snapped(GameState.depth, 100)
	if depthSnapped >= GameState.depthStageMap.keys()[len(GameState.depthStageMap.keys())-1]:
		depthSnapped = GameState.depthStageMap.keys()[len(GameState.depthStageMap.keys())-1]
	var sectionType = GameState.depthStageMap[depthSnapped]
	section_changed.emit(sectionType)
	
	process_death()

func _process(delta):
	process_dock(delta)
	process_depth_effects(delta)
	processTrauma(delta)


func _input(_event):
	if Input.is_action_just_pressed("throw"):
		if can_shoot and !GameState.paused and !is_mouse_over_ui():
			shoot_harpoon()
	
	# Surface buoy functionality - quickly return to surface when B key is pressed
	if Input.is_action_just_pressed("upgrade_surface_buoy") and GameState.upgrades[GameState.Upgrade.SURFACE_BUOY] > 0:
		if !GameState.isDocked and !GameState.paused:
			activate_surface_buoy()
			
	# Drone selling functionality - sell inventory remotely when Q key is pressed
	if Input.is_action_just_pressed("upgrade_drone_selling") and GameState.upgrades[GameState.Upgrade.DRONE_SELLING] > 0:
		if !GameState.isDocked and !GameState.paused and GameState.inventory.items.size() > 0:
			activate_selling_drone()

func activate_surface_buoy():
	# Only works if player is below the surface
	if position.y < -1:
		# Create visual effect
		var particles = CPUParticles3D.new()
		particles.emitting = true
		particles.one_shot = true
		particles.explosiveness = 1.0
		particles.amount = 30
		particles.lifetime = 1.0
		particles.mesh = SphereMesh.new()
		particles.mesh.radius = 0.1
		particles.mesh.height = 0.2
		particles.direction = Vector3(0, 1, 0)
		particles.spread = 45.0
		particles.gravity = Vector3(0, 0, 0)
		particles.initial_velocity_min = 2.0
		particles.initial_velocity_max = 5.0
		particles.color = Color(0.2, 0.7, 1.0, 0.8)
		add_child(particles)
		
		# Play sound effect
		sound_player.play_sound("bup")
		
		# Move player to surface
		position.y = -1
		
		# Add small cooldown to prevent spamming
		can_shoot = false
		cooldown_timer.start()

func is_mouse_over_ui() -> bool:
	return get_viewport().gui_get_focus_owner() != null
	
var sold = 0
func onDock():
	
	sold = GameState.inventory.sellItems()
	if sold != 0:
		sound_player.play_sound("coins")

	#if sold != 0:
		#var price_str = "Sold Items Value: $" + str(sold)
		#PopupManager.show_popup(price_str, $PopupSpawnPosition.global_position, Color.GREEN)
		#print("docked")
	

func shoot_harpoon():
	# Instance the harpoon
	var harpoon = harpoon_scene.instantiate()
	get_parent().add_child(harpoon)
	sound_player.play_sound("harp")
	var dir = 1
	if ($Pivot.rotation[1] >= 0):
		dir = -1
	
	harpoon.position = position + dir * global_transform.basis.x * -1 # move harpoon to correct side
	
	# If harpoon rotation upgrade is purchased, use mouse/touch position to determine direction
	if GameState.upgrades[GameState.Upgrade.HARPOON_ROTATION] > 0:
		var aim_position = Vector2.ZERO
		var viewport_center = get_viewport().get_visible_rect().size / 2
		
		# Handle both mouse and touch input
		if OS.has_feature("mobile") or OS.has_feature("web"):
			# For mobile, use the last touch position or joystick direction
			if touch_direction != Vector2.ZERO:
				# Use joystick direction if active
				aim_position = viewport_center + touch_direction * 100
			else:
				# Otherwise use center + offset to match default direction
				aim_position = viewport_center + Vector2(0, 50)
		else:
			# For desktop, use mouse position
			aim_position = get_viewport().get_mouse_position()
		
		var direction_vector = (aim_position - viewport_center).normalized()
		
		# Convert 2D direction to 3D (assuming Y is up in 3D space)
		harpoon.direction = Vector3(direction_vector.x, direction_vector.y, 0).normalized()
		
		# Calculate rotation angle based on direction vector
		var angle = atan2(direction_vector.y, direction_vector.x)
		
		# Apply rotation to the harpoon model
		# Rotate 90 degrees first to align with the direction vector
		harpoon.rotation = Vector3(0, 0, angle - PI/2)
		
		# Flip the harpoon if shooting to the left
		if dir < 0:
			harpoon.rotation.z += PI
	else:
		# Default behavior - shoot straight up/down
		harpoon.direction = global_transform.basis.y.normalized()
		
		# Apply default rotation based on submarine direction
		if dir < 0:
			harpoon.rotate_z(deg_to_rad(180))
	
	# Pass submarine reference to harpoon for catching fish
	harpoon.submarine = self
	can_shoot = false
	cooldown_timer.start()

func catch_fish(fish):
	print("Caught fish: ", fish.name) # Replace with inventory logic
	if fish.has_method("removeFish"):
		sound_player.play_sound("bup")
		var fish_details = fish.removeFish()
		if GameState.inventory.add(fish_details):
			var weight_str = "Weight added: " + str(fish_details.weight) + " kg"
			var price_str = "\nValue: $" + str(fish_details.price)
			PopupManager.show_popup(weight_str + price_str, $PopupSpawnPosition.global_position, Color.GREEN)
		else:
			var inv_full_str = "Inventory full!"
			PopupManager.show_popup(inv_full_str, $PopupSpawnPosition.global_position, Color.RED)

func _on_timer_timeout():
	can_shoot = true

func process_dock(delta):
	# print(position)
	if position.y >= -1 && position.x > -7:
		if (GameState.health < 100.0):
			GameState.health += 5 * delta
		# enable upgrade (doing this only when docked avoids checking every frame during the entire game)
		if GameState.upgrades[GameState.Upgrade.LAMP_UNLOCKED] == 1 \
				and $Pivot/SmFishSubmarine/UnlockableLamp.visible == false:
			$Pivot/SmFishSubmarine/UnlockableLamp.visible = true
		if GameState.upgrades[GameState.Upgrade.AK47] == 1 \
			and $Pivot/SmFishSubmarine/ak47_0406195124_texture.visible == false:
			$Pivot/SmFishSubmarine/ak47_0406195124_texture.visible = true
		if GameState.upgrades[GameState.Upgrade.DUALAK47] == 1 \
			and $Pivot/SmFishSubmarine/ak47_69420_texture2.visible == false:
			$Pivot/SmFishSubmarine/ak47_69420_texture2.visible = true
		if not GameState.isDocked:
			onDock()
			GameState.isDocked = true
	else:
		if GameState.isDocked:
			GameState.isDocked = false

func process_depth_effects(delta):
	GameState.headroom = ((GameState.upgrades[GameState.Upgrade.DEPTH_RESISTANCE] + 1) * 100 - GameState.depth)
	if GameState.headroom < 0:
		add_trauma(0.1)
		GameState.health += GameState.headroom * delta

func process_death():
	if GameState.health <= 0:
		sound_player.play_sound("ughhh")
		GameState.death_screen = true
		
		# If inventory save upgrade is purchased, keep inventory items
		if GameState.upgrades[GameState.Upgrade.INVENTORY_SAVE] == 0:
			GameState.inventory.clear()
		else:
			# Visual feedback that inventory was saved
			PopupManager.show_popup("Inventory saved by insurance!", $PopupSpawnPosition.global_position, Color.GREEN)
		
		GameState.paused = true
		GameState.health = 100
		position = Vector3(-8, 0, 0.33)


func scatter_area_entered(body: Node3D) -> void:
	if body.is_in_group("fishes"):
		body.scatter(self)


@export var trauma_reduction_rate := 1.0

@export var max_x := 10.0
@export var max_y := 10.0
@export var max_z := 5.0

@export var noise_speed := 50.0

var trauma := 0.0

var time := 0.0


@onready var initial_rotation := camera.rotation_degrees as Vector3


# yes get traumatized <3 :3 test
# 1. Random Jitter Version (commented out)
func processTrauma(delta):
	if traumaShakeMode == 1:
		time += delta
		trauma = max(trauma - delta * trauma_reduction_rate, 0.0)

		if trauma > 0:
			var intensity = 0.1 # Adjust shake strength
			var shake = trauma * trauma * intensity
			camera.rotation_degrees.x = initial_rotation.x + randf_range(-max_x, max_x) * shake
			camera.rotation_degrees.y = initial_rotation.y + randf_range(-max_y, max_y) * shake
			camera.rotation_degrees.z = initial_rotation.z + randf_range(-max_z, max_z) * shake
		else:
			camera.rotation_degrees = initial_rotation
		
	if traumaShakeMode == 2:
		# 2. Sine Wave Version (commented out)
		time += delta
		trauma = max(trauma - delta * trauma_reduction_rate, 0.0)
		
		if trauma > 0:
			var intensity = 0.1 # Adjust shake strength
			var shake = trauma * trauma * intensity
			var shake_x = sin(time * 20.0) * max_x * shake
			var shake_y = cos(time * 15.0) * max_y * shake
			var shake_z = sin(time * 10.0) * max_z * shake
			
			camera.rotation_degrees.x = initial_rotation.x + shake_x
			camera.rotation_degrees.y = initial_rotation.y + shake_y
			camera.rotation_degrees.z = initial_rotation.z + shake_z
		else:
			camera.rotation_degrees = initial_rotation
	
	if traumaShakeMode == 3:
		# 3. Pseudo-Random Version (active)
		time += delta
		trauma = max(trauma - delta * trauma_reduction_rate, 0.0)
		
		if trauma > 0:
			var intensity = 0.1 # Adjust shake strength (0.1-1.0)
			var shake = trauma * trauma * intensity
			camera.rotation_degrees.x = initial_rotation.x + pseudo_random(time) * max_x * shake
			camera.rotation_degrees.y = initial_rotation.y + pseudo_random(time + 100.0) * max_y * shake
			camera.rotation_degrees.z = initial_rotation.z + pseudo_random(time + 200.0) * max_z * shake
		else:
			camera.rotation_degrees = initial_rotation
		

func pseudo_random(mSeed: float) -> float:
	return (fmod(sin(mSeed * 12.9898) * 43758.5453, 1.0)) * 2.0 - 1.0 # Returns -1 to 1

func add_trauma(trauma_amount: float):
	trauma = clamp(trauma + trauma_amount, 0.0, 1.0)

func activate_selling_drone():
	# Create visual effect for the drone
	var particles = CPUParticles3D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 0.8
	particles.amount = 20
	particles.lifetime = 1.5
	particles.mesh = SphereMesh.new()
	particles.mesh.radius = 0.05
	particles.mesh.height = 0.1
	particles.direction = Vector3(0, 1, 0)
	particles.spread = 30.0
	particles.gravity = Vector3(0, 0, 0)
	particles.initial_velocity_min = 1.0
	particles.initial_velocity_max = 3.0
	particles.color = Color(0.8, 0.8, 0.2, 0.7)
	add_child(particles)
	
	# Play sound effect
	sound_player.play_sound("coins")
	
	# Sell all items in inventory
	var sold = GameState.inventory.sellItems()
	
	# Show popup with amount sold
	var price_str = "Drone sold items for: $" + str(sold)
	PopupManager.show_popup(price_str, $PopupSpawnPosition.global_position, Color.YELLOW)
	
	# Add small cooldown to prevent spamming
	can_shoot = false
	cooldown_timer.start()
