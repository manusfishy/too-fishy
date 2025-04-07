extends CharacterBody3D

@export var speed_vertical = 1.0
@export var speed_horizontal = 1.0

@onready var camera = $Camera3D
var throw_strength = 15.0 # Adjust for distance
var is_holding_hook = true
var target_velocity = Vector3.ZERO


@onready var pickaxe_scene = preload("res://scenes/pickaxe.tscn")
@export var inventory: Inv
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
	if can_be_hurt:
		GameState.health -= damage
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

	
func _input(event):
	if Input.is_action_just_pressed("throw") and can_shoot and !GameState.paused:
		shoot_harpoon()
	
func onDock():
	GameState.inventory.sellItems()
	
	print("docked")
	
func shoot_harpoon():
	# Instance the harpoon
	var harpoon = harpoon_scene.instantiate()
	get_parent().add_child(harpoon)
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
		var fish_details = fish.removeFish()
		GameState.inventory.add(fish_details)

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
		GameState.death_screen = true
		GameState.inventory.items.clear()
		GameState.paused = true
		GameState.health = 100
		position = Vector3(-8, 0, 0.33)


func scatter_area_entered(body: Node3D) -> void:
	if body.is_in_group("fishes"):
		body.scatter(self)
