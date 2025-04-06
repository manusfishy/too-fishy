extends RigidBody3D

# Rotation sensitivity (only for y-axis now)
@export var rotation_sensitivity: float = 0.11
var is_hooked: bool = false

func _ready():
	# Disable physics initially
	freeze = true
	# Disable gravity
	gravity_scale = 0.0
	print("Parent is: ", get_parent().name)

func _input(event):
	if event is InputEventMouseButton:
		var rotation_amount = 0
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			print("Scrolled Up")
			rotation_amount = rotation_sensitivity
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			print("Scrolled Down")
			rotation_amount = -rotation_sensitivity
		
		if rotation_amount != 0:
			rotate_z(rotation_amount)

func launch():
	# Enable physics when launched
	freeze = false
	gravity_scale = 1.0  # Re-enable gravity for launching
	is_hooked = false

func _on_body_entered(body):
	print("Hook hit: ", body.name)
	if body == get_parent().get_parent(): # When hitting player
		$CollisionShape3D.disabled = true
		freeze = true
		# Reparent to maintain position
		var new_parent = get_parent().get_node("Pivot")
		reparent(new_parent)
		global_transform = new_parent.global_transform
		
