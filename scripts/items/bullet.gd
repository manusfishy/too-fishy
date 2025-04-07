extends Area3D

var speed = 50.0 # Meters per second
var velocity = Vector3.ZERO
var lifetime = 2.0 # Seconds before despawn
var direction = Vector3.LEFT # Default direction
var submarine = null # Reference to submarine that shot this bullet

func _ready():
	submarine = GameState.player_node
	# Connect collision signal
	connect("body_entered", _on_body_entered)
	# Start a timer to despawn
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	# Move bullet in its forward direction
	# print("bullet process!")
	translate(direction * speed * delta)
	
	# Check for collisions with fish
	#for body in $Area3D.get_overlapping_bodies():
	#	if body.is_in_group("fishes"):
	#		if submarine:
	#			submarine.catch_fish(body) # Call catch_fish on submarine
	#		queue_free()
	#		break # Only catch one fish per harpoon
	#	if body.is_in_group("boss"):
	#		Boss.attackBoss() # Remove bullet on impact

func _on_body_entered(body):
	# Handle collision 
	if body.is_in_group("fishes"):
		if submarine:
			submarine.catch_fish(body) # Call catch_fish on submarine
		
	if body.is_in_group("boss"):
			Boss.attackBoss() # Remove bullet on impact
	queue_free()
