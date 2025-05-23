extends Node3D

# Script for lava areas that cause damage to the player

func _ready():
	print("Lava area initialized at position: ", global_position)

func _on_lava_area_body_entered(body):
	print("Something entered lava area: ", body.name, " at position: ", body.global_position)
	# Check if the body that entered is the player
	if body.has_method("_on_lava_area_body_entered"):
		body._on_lava_area_body_entered(body)
		print("Lava area detected PLAYER entry - damage starting!")
	else:
		print("Not the player, ignoring: ", body.name)

func _on_lava_area_body_exited(body):
	print("Something exited lava area: ", body.name)
	# Check if the body that exited is the player
	if body.has_method("_on_lava_area_body_exited"):
		body._on_lava_area_body_exited(body)
		print("Lava area detected PLAYER exit - damage stopped!")
	else:
		print("Not the player, ignoring: ", body.name)
