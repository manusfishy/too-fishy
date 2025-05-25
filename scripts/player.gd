extends CharacterBody3D

@export var speed_vertical = 1.0
@export var speed_horizontal = 1.0

@onready var camera = $Camera3D
var throw_strength = 15.0 # Adjust for distance
var is_holding_hook = true
var target_velocity = Vector3.ZERO

# Harpoon rotation variables
var harpoon_rotation_active = false
var harpoon_rotation_speed = 120.0 # Degrees per second
var harpoon_max_rotation = 90.0 # Maximum rotation in degrees
var harpoon_rotation_direction = 1 # 1 = clockwise, -1 = counterclockwise

@onready var harpoon_launch_point_node = $Pivot/HarpoonLaunchPoint # Adjust path if needed

@onready var sound_player = $SoundPlayer
@onready var pickaxe_scene = preload("res://scenes/pickaxe.tscn")
@export var inventory: Inv
@export var traumaShakeMode = 1

# Cooldown configurations
const COOLDOWN_HARPOON = 1.0 # Reduced from 2.0
const COOLDOWN_SURFACE_BUOY = 3.0
const COOLDOWN_SELLING_DRONE = 5.0

@onready var cooldown_timer_harpoon = $HarpoonCD # Timer node for harpoon
@onready var cooldown_timer_buoy = $BuoyCD # Timer node for surface buoy
@onready var cooldown_timer_drone = $DroneCD # Timer node for selling drone

var harpoon_scene = preload("res://scenes/harpoon.tscn") # Path to harpoon scene
var bullet_scene = preload("res://scenes/bullet.tscn")
var ak_scene = preload("res://scenes/ak47.tscn")
var catch_effect_scene = preload("res://scenes/catch_effect.tscn") # Preload catch effect
@onready var touch_controls_scene = preload("res://scenes/ui/touch_controls.tscn")
@onready var pause_menu_scene = preload("res://scenes/ui/pause_menu.tscn")
var can_shoot = true
var touch_controls = null
var touch_direction = Vector2.ZERO
var pause_menu = null
signal section_changed(sectionType)

# New inventory menu reference
var inventory_menu = null

# Track previous stage for section change detection
var previous_stage = GameState.Stage.SURFACE

# Lava damage tracking
var is_in_lava_area = false

var pickup_range := 1.5
var can_swing = true
var rotation_target = 0
var trauma = 0.0
var health = 100.0
var isDocked = false
var docked_timer = 0.0
var dock_countdown = 2.0

# Camera shake properties
var trauma_reduction_rate = 1.7 # How quickly trauma reduces over time
var shake_power = 2.0 # Exponent for screen shake based on trauma
var max_shake_offset = 1.0 # Maximum movement from origin
var max_shake_roll = 0.0 # Maximum rotation in radians (0 = disabled)

# Achievement system reference
var achievement_system = null

func _ready():
	GameState.player_node = self
	print("player ready")
	
	# Initialize cooldown timers
	setup_cooldown_timer("HarpoonCD", COOLDOWN_HARPOON)
	setup_cooldown_timer("BuoyCD", COOLDOWN_SURFACE_BUOY)
	setup_cooldown_timer("DroneCD", COOLDOWN_SELLING_DRONE)
	
	# Initialize touch controls if on mobile
	if OS.has_feature("mobile") or OS.has_feature("web"):
		touch_controls = touch_controls_scene.instantiate()
		get_tree().root.add_child(touch_controls)
		touch_controls.joystick_input.connect(_on_joystick_input)
		touch_controls.shoot_pressed.connect(_on_shoot_pressed)
	
	# Get reference to pause menu from UI
	var ui_node = get_node("/root/Node3D/UI")
	if ui_node and ui_node.has_node("PauseMenu"):
		pause_menu = ui_node.get_node("PauseMenu")

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
		
		# Show damage visual effects (screen crack and red flash)
		# Find the UI node to add the effects to
		var ui_node = get_node("/root/Node3D/UI")
		if ui_node:
			if ui_node.has_node("DamageEffects"):
				ui_node.get_node("DamageEffects").show_damage_effects()
			else:
				# Create damage effects instance if it doesn't exist
				var damage_effects = load("res://scenes/damage_effects.tscn").instantiate()
				ui_node.add_child(damage_effects)
				damage_effects.show_damage_effects()
		
		can_be_hurt = false
		get_tree().create_timer(1.0).timeout.connect(reset_hurt_cooldown)

func reset_hurt_cooldown():
	can_be_hurt = true

var acceleration_x := 2.5 # Adjusted to feel less spongy but not too fast
var deceleration_x := 3.8 # For responsive stopping without being too quick
var max_speed_x := 5.0 # Keep original max speed
var velocity_x := 0.0
var velocity_y := 0.0
var acceleration_y := 2.2 # Slower vertical acceleration
var deceleration_y := 3.0 # Slower vertical deceleration
var max_speed_y := 4.0 # Reduced vertical speed

func movement(_delta: float):
	var direction = Vector3.ZERO
	var input_x = 0.0
	var input_y = 0.0

	# Get horizontal input
	if Input.is_action_pressed("move_right"):
		input_x = 1.0
		if $Pivot.rotation[1] < 0:
			$Pivot.rotate_y(deg_to_rad(180))
	elif Input.is_action_pressed("move_left"):
		input_x = -1.0
		if $Pivot.rotation[1] >= 0:
			$Pivot.rotate_y(deg_to_rad(180))
	# Handle touch input for horizontal movement
	elif touch_direction.x != 0:
		input_x = touch_direction.x
		if touch_direction.x > 0 and $Pivot.rotation[1] < 0:
			$Pivot.rotate_y(deg_to_rad(180))
		elif touch_direction.x < 0 and $Pivot.rotation[1] >= 0:
			$Pivot.rotate_y(deg_to_rad(180))
	
	# Apply horizontal acceleration/deceleration
	if input_x != 0:
		# Accelerate faster
		velocity_x = move_toward(velocity_x, input_x * max_speed_x, acceleration_x * _delta)
	else:
		# Decelerate faster when no input for less floaty feel
		velocity_x = move_toward(velocity_x, 0, deceleration_x * _delta)

	direction.x = velocity_x
	if position.y >= -0.2: # don't stick out too far from surface
			input_y = -0.2
	# Get vertical input
	if Input.is_action_pressed("move_up"):
		input_y = 1.0
		if position.y >= -0.2: # Surface limit
			input_y = -0.2
	elif Input.is_action_pressed("move_down"):
		input_y = -1.0
	# Handle touch input for vertical movement
	elif touch_direction.y != 0:
		input_y = touch_direction.y
		if touch_direction.y > 0 and position.y >= 0:
			input_y = 0
	
	# Apply vertical acceleration/deceleration like horizontal
	if input_y != 0:
		velocity_y = move_toward(velocity_y, input_y * max_speed_y, acceleration_y * _delta)
	else:
		velocity_y = move_toward(velocity_y, 0, deceleration_y * _delta)
		
	direction.y = velocity_y
	
	# Apply upgrades to speed (reduced multiplier for upgrades)
	var hor_speed_bonus = speed_horizontal + (GameState.upgrades[GameState.Upgrade.HOR_SPEED] * 0.5)
	var vert_speed_bonus = speed_vertical + (GameState.upgrades[GameState.Upgrade.VERT_SPEED] * 0.3)
	
	target_velocity.x = direction.x * hor_speed_bonus
	target_velocity.y = direction.y * vert_speed_bonus
	
	# Boost upward movement slightly for better control
	if direction.y > 0:
		target_velocity.y = target_velocity.y * 1.2
	
	target_velocity.z = 0
	
	# Set velocity directly without the lerp for more responsive control
	if GameState.paused:
		target_velocity = Vector3.ZERO
	
	velocity = target_velocity
	move_and_slide()
	position.z = 0.33


func _physics_process(delta: float) -> void:
	movement(delta)
	collision()
	rockingMotion(delta)
	
	# Check if the current stage has changed and emit signal if so
	var current_stage = GameState.playerInStage
	if current_stage != previous_stage:
		emit_signal("section_changed", current_stage)
		previous_stage = current_stage
	
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
		if !GameState.isDocked and !GameState.paused and cooldown_timer_buoy.time_left == 0:
			activate_surface_buoy()
	
	# Quick save functionality when enabled by upgrade
	if Input.is_action_just_pressed("inventory_save") and GameState.upgrades[GameState.Upgrade.INVENTORY_SAVE] > 0:
		if !GameState.isDocked and !GameState.paused:
			# Quick save without menu
			SaveSystem.save_game()
			# Add visual/audio feedback
			sound_player.play_sound("save")
			var popup_text = "Game Saved"
			PopupManager.show_popup(popup_text, $PopupSpawnPosition.global_position, Color.GREEN)
	
	# Drone selling functionality - sell inventory remotely when Q key is pressed
	if Input.is_action_just_pressed("upgrade_drone_selling") and GameState.upgrades[GameState.Upgrade.DRONE_SELLING] > 0:
		if !GameState.isDocked and !GameState.paused and GameState.inventory.items.size() > 0 and cooldown_timer_drone.time_left == 0:
			activate_selling_drone()
	
	# Toggle inventory menu
	if Input.is_action_just_pressed("inv_toggle"):
		if !GameState.paused:
			toggle_inventory_menu()

func setup_cooldown_timer(timer_name: String, wait_time: float) -> void:
	if !has_node(timer_name):
		var timer = Timer.new()
		timer.name = timer_name
		timer.one_shot = true
		timer.wait_time = wait_time
		add_child(timer)
	else:
		get_node(timer_name).wait_time = wait_time

func activate_surface_buoy():
	# Only works if player is below the surface
	if position.y < -1:
		print("Surface buoy activated - surfacing in place")
		
		# Move player to surface (keep x/z position, just change y)
		position.y = -1
		
		# Play sound effect
		sound_player.play_sound("bup")
		
		# Create visual effect at the submarine's actual surface position
		var particles = CPUParticles3D.new()
		particles.name = "SurfaceBuoyEffect"
		
		# Set position before adding to scene
		particles.position = position
		
		# Basic particle setup
		particles.emitting = true
		particles.one_shot = true
		particles.explosiveness = 1.0
		particles.amount = 50
		particles.lifetime = 2.0
		
		# Particle appearance
		var sphere_mesh = SphereMesh.new()
		sphere_mesh.radius = 0.05
		sphere_mesh.height = 0.1
		particles.mesh = sphere_mesh
		
		# Movement settings
		particles.direction = Vector3(0, 1, 0)
		particles.spread = 45.0
		particles.initial_velocity_min = 3.0
		particles.initial_velocity_max = 8.0
		particles.gravity = Vector3(0, -5, 0)
		
		# Color - light blue water splash
		particles.color = Color(0.6, 0.9, 1.0, 1.0)
		
		# Add to scene
		get_parent().add_child(particles)
		
		print("Submarine surfaced at: ", position)
		print("Particles at: ", particles.position)
		print("Particles emitting: ", particles.emitting)
		
		# Simple cleanup after 3 seconds
		get_tree().create_timer(3.0).timeout.connect(func():
			if is_instance_valid(particles):
				print("Cleaning up surface buoy particles")
				particles.queue_free()
		)
		
		# Start cooldown
		cooldown_timer_buoy.start()

func is_mouse_over_ui() -> bool:
	return get_viewport().gui_get_focus_owner() != null
	

func onDock():
	var sold = GameState.inventory.sellItems()
	if sold != 0:
		sound_player.play_sound("coins")
	# Show popup with amount sold
	var price_str = "Drone sold items for: $" + str(sold)
	if (GameState.upgrades[GameState.Upgrade.DRONE_SELLING] == 1):
		PopupManager.show_popup(price_str, $PopupSpawnPosition.global_position, Color.YELLOW)

func shoot_harpoon():
	if cooldown_timer_harpoon.time_left > 0:
		return
		
	var dir = 1
	if ($Pivot.rotation[1] >= 0): # check submarine rotation
		dir = -1
	if not harpoon_launch_point_node or not harpoon_scene: return # Add camera check if needed
	# Instance the harpoon
	var harpoon = harpoon_scene.instantiate()
	get_parent().add_child(harpoon)
	sound_player.play_sound("harp")

	var launch_position = harpoon_launch_point_node.global_position
	harpoon.global_position = launch_position # Set global position correctly

	var final_shoot_direction = Vector3.ZERO
	var final_angle_radians = 0.0

	# --- Upgraded Aiming ---
	if GameState.upgrades[GameState.Upgrade.HARPOON_ROTATION] > 0:
		var cursor_pos = get_viewport().get_mouse_position()
		var launch_screen_pos = camera.unproject_position(launch_position)
		var screen_direction = cursor_pos - launch_screen_pos

		if screen_direction.length_squared() > 0.1:
			final_angle_radians = screen_direction.angle()
		else:
			final_angle_radians = 0.0 # Default right if cursor on launch point

		harpoon.global_rotation.z = - final_angle_radians
	# --- Default Aiming ---
	else:
		if ($Pivot.rotation[1] < 0):
			harpoon.rotate_z(deg_to_rad(180))
		harpoon.position = position + dir * global_transform.basis.x * -1 # move harpoon to correct side
		harpoon.direction = global_transform.basis.y.normalized() # set correct direction for the movement in harpoon

	# Set the submarine reference before any physics processing occurs
	harpoon.submarine = self
	cooldown_timer_harpoon.start()

func catch_fish(fish):
	# Replace with inventory logic
	if fish.has_method("removeFish"):
		# Store fish properties before removing it
		var is_shiny = "is_shiny" in fish and fish.is_shiny
		var fish_weight = fish.weight if "weight" in fish else 1
		var fish_position = fish.global_position
		var fish_type = fish.type if "type" in fish else 0 # Make sure to get the fish type
		
		# Get the fish details and remove it from the scene
		var fish_details = fish.removeFish()
		
		# Spawn the catch effect at the fish's position using preloaded scene
		var catch_effect = catch_effect_scene.instantiate()
		get_parent().add_child(catch_effect)
		catch_effect.global_position = fish_position
		
		# Set effect properties based on stored fish properties
		if is_shiny:
			catch_effect.set_shiny(true)
		
		# Add camera shake proportional to fish's weight or value
		var trauma_amount = clamp(fish_weight / 50.0, 0.2, 0.6)
		# Increase shake for shiny fish
		if is_shiny:
			trauma_amount *= 1.5
		
		add_trauma(trauma_amount)
		
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
				$Pivot/SmFishSubmarine/ak47_69420_texture2.visible = true # Check if dual AK47 was just enabled
				$Pivot/SmFishSubmarine/ak47_0406195124_texture.shared_ammo = $Pivot/SmFishSubmarine/ak47_0406195124_texture.get_max_ammo();
		if not GameState.isDocked:
			onDock()
			GameState.isDocked = true
	else:
		if GameState.isDocked:
			GameState.isDocked = false

func process_depth_effects(delta):
	GameState.headroom = ((GameState.upgrades[GameState.Upgrade.DEPTH_RESISTANCE] + 1) * 100 - GameState.depth)
	
	# Get reference to damage effects
	var ui_node = get_node("/root/Node3D/UI")
	var damage_effects = null
	if ui_node:
		if ui_node.has_node("DamageEffects"):
			damage_effects = ui_node.get_node("DamageEffects")
		else:
			# Create damage effects instance if it doesn't exist
			damage_effects = load("res://scenes/damage_effects.tscn").instantiate()
			ui_node.add_child(damage_effects)
	
	if GameState.headroom < 0:
		add_trauma(0.1)
		GameState.health += GameState.headroom * delta
		
		# Trigger pressure crack effects
		if damage_effects:
			damage_effects.process_pressure_damage(delta)
	else:
		# Safe depth - allow pressure cracks to start fading
		if damage_effects:
			damage_effects.end_pressure_damage()
	
	# Lava damage only when actually in lava area (not just lava stage)
	if is_in_lava_area:
		process_lava_damage(delta)

func process_lava_damage(delta):
	# Lava damage: 10 damage per second when in lava stage
	var lava_damage_per_second = 10.0
	GameState.health -= lava_damage_per_second * delta
	
	# Add trauma for being in lava (screen shake)
	add_trauma(0.05)
	
	# Play damage sound occasionally
	if randf() < 0.1: # 10% chance per frame to play sound
		sound_player.play_sound("ughhh")
	
	# Visual feedback - add red tint effect when taking lava damage
	var ui_node = get_node("/root/Node3D/UI")
	if ui_node:
		if ui_node.has_node("DamageEffects"):
			# Trigger subtle damage effects more frequently in lava
			if randf() < 0.02: # 2% chance per frame
				ui_node.get_node("DamageEffects").show_damage_effects()
		else:
			# Create damage effects instance if it doesn't exist
			if randf() < 0.02:
				var damage_effects = load("res://scenes/damage_effects.tscn").instantiate()
				ui_node.add_child(damage_effects)
				damage_effects.show_damage_effects()

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


func rockingMotion(delta): # Apply a submarine-like rocking motion
	if abs(velocity.x) < 0.1 and abs(velocity.y) < 0.1:
		# Apply a slow submarine-like rocking motion when stationary
		var rocking_angle = sin(time * 0.5) * 1.3
		$Pivot.rotation.z = lerp($Pivot.rotation.z, deg_to_rad(rocking_angle), delta * 0.8)
	else:
		# Make the submarine tilt slightly based on movement
		var tilt = - velocity.x * 0.01 # Small tilt for movement
		$Pivot.rotation.z = lerp($Pivot.rotation.z, tilt, delta * 2.0)
	
	# Clamp rotation to prevent extreme angles
	$Pivot.rotation.z = clamp($Pivot.rotation.z, deg_to_rad(-8), deg_to_rad(8))


@export var max_x := 10.0
@export var max_y := 10.0
@export var max_z := 5.0

@export var noise_speed := 50.0


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
	# Load the dummy fish model to use as a drone
	var drone_scene = preload("res://scenes/mobs/drone.tscn")
	var drone = drone_scene.instantiate()
	
	# Set up the drone
	drone.position = position
	drone.position.y += 0.6 # above the submarine
	drone.scale = Vector3(0.5, 0.5, 0.5) # Make it a bit smaller than regular fish
	get_parent().add_child(drone)
	
	# Create visual effect for the drone
	var particles = $dronefart.duplicate()
	particles.color = Color(0.8, 0.8, 0.2) # Give it a golden color
	drone.add_child(particles)
	particles.emitting = true
	
	# Define dock position (based on process_dock logic: y >= -1 && x > -7)
	var dock_position = Vector3(-5, -0.5, position.z) # Slightly above surface, within dock area
	
	# Calculate durations for smooth movement
	var distance_to_dock = drone.position.distance_to(dock_position)
	var swim_duration = distance_to_dock / 3.0 # Drone moves at ~3 units per second
	
	# Create animation sequence
	var tween = get_tree().create_tween()
	
	# First: swim toward dock
	tween.tween_property(drone, "position", dock_position, swim_duration)
	
	# Then: fade out and remove (using tween_callback to start fade after movement)
	tween.tween_callback(func():
		var fade_tween = get_tree().create_tween()
		fade_tween.tween_property(drone, "modulate:a", 0.0, 0.5)
		fade_tween.tween_callback(func():
			if is_instance_valid(drone):
				drone.queue_free()
		)
	)
	
	# Sell items immediately when drone is deployed
	onDock()
	
	# Start cooldown
	cooldown_timer_drone.start()

func toggle_inventory_menu():
	# Get the inventory menu
	if inventory_menu == null:
		# Find the menu in the scene
		var ui_parent = get_tree().get_root().find_child("UI", true, false)
		if ui_parent and ui_parent.has_node("CenterContainer/InventoryMenu"):
			inventory_menu = ui_parent.get_node("CenterContainer/InventoryMenu")
	
	# Toggle the menu
	if inventory_menu:
		if inventory_menu.visible:
			inventory_menu.close()
		else:
			inventory_menu.open()

func connect_achievement_system(system):
	achievement_system = system

# Called when player enters a lava area (connect this to lava Area3D nodes)
func _on_lava_area_entered(area):
	is_in_lava_area = true

# Called when player exits a lava area (connect this to lava Area3D nodes)  
func _on_lava_area_exited(area):
	is_in_lava_area = false

# Alternative method using body detection for Area3D
func _on_lava_area_body_entered(body):
	if body == self: # Make sure it's the player entering
		is_in_lava_area = true

func _on_lava_area_body_exited(body):
	if body == self: # Make sure it's the player exiting
		is_in_lava_area = false
