extends RigidBody3D

func _on_body_entered(body):
	if body != get_parent(): # Ignore player collision
		# Stop the hook (e.g., stick to surface)
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		#freeze = true
		print("Hook hit: ", body.name)
