extends CharacterBody3D

@export var speed_vertical = 1.0
@export var speed_horizontal = 3.0

@onready var camera = $Camera3D
var throw_strength = 15.0 # Adjust for distance
var is_holding_hook = true
var target_velocity = Vector3.ZERO


@onready var pickaxe_scene = preload("res://scenes/pickaxe.tscn")
@export var inventory: Inv
@onready var cooldown_timer = $HarpoonCD # Timer node, set to one-shot, 2s wait time

var harpoon_scene = preload("res://scenes/harpoon.tscn") # Path to harpoon scene
var can_shoot = true

signal section_changed(sectionType)

func _ready():
	print("player ready")


func addFishToInv(data):
	for item in GameState.inventory.items:
		if item.id == data.id:
			print("Duplicate fish ID detected: ", data.id)
			return false

	var my_fish = InvItem.new()
	my_fish.type = "fish"
	my_fish.weight = data.weight
	my_fish.price = data.price
	my_fish.id = data.id
	GameState.inventory.add(my_fish)
	return true

func collision():
	var collision = move_and_slide()
	
	# Check for collisions after movement
	for i in get_slide_collision_count():
		var collision_info = get_slide_collision(i)
		var collider = collision_info.get_collider()
		if collider is CharacterBody3D:
			if collider.has_method("removeFish"):
				var fish_details = collider.removeFish()
				addFishToInv(fish_details)


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
	move_and_slide()


func _physics_process(delta: float) -> void:
	movement(delta)
	# Check colision
	collision()
	
	var depthSnapped = snapped(GameState.depth, 100)
	var sectionType = GameState.depthStageMap[depthSnapped]
	section_changed.emit(sectionType)
	
	process_death()


func _process(delta):
	process_dock(delta)
	process_depth_effects(delta)
	if Input.is_action_just_pressed("throw") and can_shoot:
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
	harpoon.position = position + dir * global_transform.basis.x * -2
	harpoon.rotation = global_transform.basis.get_euler() # Align with submarine

	harpoon.direction = global_transform.basis.x.normalized() * -dir
	
	# Pass submarine reference to harpoon for catching fish
	harpoon.submarine = self
	can_shoot = false
	cooldown_timer.start()

func catch_fish(fish):
	print("Caught fish: ", fish.name) # Replace with inventory logic

func _on_timer_timeout():
	can_shoot = true

func process_dock(delta):
	if position.y >= 0 && position.x > -4:
		if (GameState.health < 100.0):
			GameState.health += 5 * delta
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
		GameState.health = 100
		position = Vector3(-8, 0, 0.33)
