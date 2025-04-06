extends Node3D

var speed = 10.0 # Speed of harpoon movement
var lifetime = 3.0 # Seconds before despawn if no hit
var submarine = null # Reference to submarine to call catch_fish

func _ready():
	# Start a timer to despawn if it doesn't hit anything
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	var dir = -1
	if submarine and submarine.has_node("Pivot") and submarine.get_node("Pivot").rotation.y >= 0:
		dir = 1
  
	# Move harpoon
	translate(Vector3(dir * speed * delta, 0, 0))
	
	# Check for collisions with fish
	for body in $Area3D.get_overlapping_bodies():
		if body.is_in_group("fishes"):
			if submarine:
				submarine.catch_fish(body) # Call catch_fish on submarine
			body.queue_free() # Remove fish
			queue_free() # Remove harpoon after hit
			break # Only catch one fish per harpoon
