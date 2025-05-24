extends Node3D

# Script for lava areas that cause damage to the player

func _ready():
	# Initialization
	pass

func _on_lava_area_body_entered(body):
	# Check if the body that entered is the player
	if body.has_method("_on_lava_area_body_entered"):
		body._on_lava_area_body_entered(body)
	else:
		# Not the player
		pass

func _on_lava_area_body_exited(body):
	# Check if the body that exited is the player
	if body.has_method("_on_lava_area_body_exited"):
		body._on_lava_area_body_exited(body)
	else:
		# Not the player
		pass
