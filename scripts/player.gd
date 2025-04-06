extends CharacterBody3D

@export var speed_vertical = 1.0
@export var speed_horizontal = 3.0

@onready var camera = $Camera3D
var throw_strength = 15.0 # Adjust for distance
var is_holding_hook = true
var target_velocity = Vector3.ZERO

@export var inventory: Inv

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


func _physics_process(_delta: float) -> void:
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
	
	var depthSnapped = snapped(GameState.depth, 100)
	var sectionType = GameState.depthStageMap[depthSnapped]
	
	$Camera3D.environment.fog_light_color = colorMap[sectionType]
	

func _process(delta):
	process_dock(delta)
	process_depth_effects(delta)
	

func process_dock(delta):
	if position.y >= 0 && position.x > -4:
		if (GameState.health < 100.0):
			GameState.health += 5 * delta
		GameState.isDocked = true
	else:
		GameState.isDocked = false

func process_depth_effects(delta):
	GameState.headroom = ((GameState.upgrades[GameState.Upgrade.DEPTH_RESISTANCE] + 1) * 100 - GameState.depth)
	if GameState.headroom < 0:
		GameState.health += GameState.headroom * delta
