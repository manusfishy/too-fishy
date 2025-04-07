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
var can_shoot = true

signal section_changed(sectionType)

func _ready():
	GameState.player_node = self
	print("player ready")
	

func collision():
	var collision = move_and_slide()
	
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

func movement(_delta: float):
	var direction = Vector3.ZERO
	if Input.is_action_pressed("move_right"):
		direction.x += 1
		if $Pivot.rotation[1] < 0:
			$Pivot.rotate_y(deg_to_rad(180))
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
		if $Pivot.rotation[1] >= 0:
			$Pivot.rotate_y(deg_to_rad(180))
	if Input.is_action_pressed("move_up"):
		direction.y += 1
		if position.y >= 0:
			direction.y = 0
	if Input.is_action_pressed("move_down"):
		direction.y -= 1
		
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
	var sectionType = GameState.depthStageMap[depthSnapped]
	section_changed.emit(sectionType)
	
	process_death()

func _process(delta):
	process_dock(delta)
	process_depth_effects(delta)
	processTrauma(delta)		


func _input(event):
	if Input.is_action_just_pressed("throw"):
		if can_shoot and !GameState.paused and !is_mouse_over_ui():
			shoot_harpoon()

func is_mouse_over_ui() -> bool:
	return get_viewport().gui_get_focus_owner() != null
	
func onDock():
	GameState.inventory.sellItems()
	
	print("docked")
	
func shoot_harpoon():
	# Instance the harpoon
	var harpoon = harpoon_scene.instantiate()
	get_parent().add_child(harpoon)
	sound_player.play_sound("harp")
	var dir = 1
	if ($Pivot.rotation[1] >= 0):
		dir = -1
		# harpoon.rotation = global_transform.basis.z.normalized() # rotate only on the correct side
		harpoon.rotate_z(deg_to_rad(180))

	harpoon.position = position + dir * global_transform.basis.x * -1 # move harpoon to correct side
	harpoon.direction = global_transform.basis.y.normalized() # set correct direction for the movement in harpoon
	
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
			var price_str = "Value: $" + str(fish_details.price)
			PopupManager.show_popup(weight_str, $PopupSpawnPosition.global_position, Color.GREEN)
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
		if GameState.upgrades[GameState.Upgrade.DualAK47] == 1 \
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
		GameState.health += GameState.headroom * delta

func process_death():
	if GameState.health <= 0:
		sound_player.play_sound("ughhh")
		GameState.death_screen = true
		GameState.inventory.clear()
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
			var intensity = 0.1  # Adjust shake strength
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
			var intensity = 0.1  # Adjust shake strength
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
			var intensity = 0.1  # Adjust shake strength (0.1-1.0)
			var shake = trauma * trauma * intensity
			camera.rotation_degrees.x = initial_rotation.x + pseudo_random(time) * max_x * shake
			camera.rotation_degrees.y = initial_rotation.y + pseudo_random(time + 100.0) * max_y * shake
			camera.rotation_degrees.z = initial_rotation.z + pseudo_random(time + 200.0) * max_z * shake
		else:
			camera.rotation_degrees = initial_rotation
		

func pseudo_random(seed: float) -> float:
	return (fmod(sin(seed * 12.9898) * 43758.5453, 1.0)) * 2.0 - 1.0  # Returns -1 to 1

func add_trauma(trauma_amount : float):
	trauma = clamp(trauma + trauma_amount, 0.0, 1.0)
