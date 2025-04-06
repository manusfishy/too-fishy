extends CharacterBody3D

@export var speed_vertical = 1.0
@export var speed_horizontal = 3.0

@onready var camera = $Camera3D
var throw_strength = 15.0 # Adjust for distance
var is_holding_hook = true
var target_velocity = Vector3.ZERO

@onready var pickaxe_scene = preload("res://scenes/pickaxe.tscn")
@onready var rope = $rope # A MeshInstance3D with CylinderMesh
var is_hook_thrown = false

var colorMap = {
	GameState.Stage.SURFACE: Color.AQUAMARINE,
	GameState.Stage.DEEP: Color.AQUA,
	GameState.Stage.DEEPER: Color.CADET_BLUE,
	GameState.Stage.SUPERDEEP: Color.DARK_CYAN,
	GameState.Stage.HOT: Color.CORNFLOWER_BLUE,
	GameState.Stage.LAVA: Color.ORANGE_RED,
	GameState.Stage.VOID: Color.BLACK
}

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
		
	target_velocity.x = direction.x * (speed_horizontal + ( GameState.upgrades[GameState.Upgrade.HOR_SPEED] * 1.5))
	target_velocity.y = direction.y * (speed_vertical  + ( GameState.upgrades[GameState.Upgrade.VERT_SPEED] * 1.5))
	
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
	
	$Camera3D.environment.fog_light_color = colorMap[sectionType]
	process_death()
	
	
	
	

	

func _process(delta):
	process_dock(delta)
	process_depth_effects(delta)
	

func onDock():
	GameState.inventory.sellItems()
	print("docked")

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
