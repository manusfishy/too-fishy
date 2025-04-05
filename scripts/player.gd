extends CharacterBody3D

@export var speed_vertical = 1.0
@export var speed_horizontal = 3.0
@onready var hook = $hook
@onready var camera = $Camera3D
var throw_strength = 15.0 # Adjust for distance
var is_holding_hook = true
var target_velocity = Vector3.ZERO

@export var inventory: Inv


@onready var rope = $rope # A MeshInstance3D with CylinderMesh
var is_hook_thrown = false

func _ready():
	# Ensure hook starts as a child of the player
	hook.freeze = true # Prevents physics until thrown

func _input(event):
	if event.is_action_pressed("throw"): # Bind "throw" to a key (e.g., left mouse)
		if is_holding_hook:
			throw_hook()

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

func _process(_delta):
	if is_hook_thrown:
		var start = global_transform.origin
		var end = hook.global_transform.origin
		var distance = start.distance_to(end)
		rope.scale.y = distance # Stretch cylinder
		rope.global_transform.origin = (start + end) / 2 # Center it
		rope.look_at(end, Vector3.UP) # Orient toward hook
	if position.y >= 0 && position.x > -4:
		GameState.isDocked = true
	else:
		GameState.isDocked = false

func throw_hook():
	# Detach hook from player
	hook.reparent(get_tree().root.get_child(0)) # Move to world root
	hook.freeze = false # Enable physics
	is_holding_hook = false
	
	# Calculate throw direction (forward from camera)
	var throw_direction = camera.global_transform.basis.x.normalized()
	
	# Apply impulse to throw the hook
	hook.apply_central_impulse(throw_direction * throw_strength)
