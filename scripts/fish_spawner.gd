extends Node3D

@export var fish_scene: PackedScene
@export var spawn_location: Vector3

func _ready() -> void:
	var fish = fish_scene.instantiate()
	fish.initialize(spawn_location)
	add_child(fish)
	
