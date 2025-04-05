extends Node3D

@export var section: PackedScene
@export var level_wrapper: Node3D
@export var player: CharacterBody3D

@export var sectionHeight: float
@export var preloadSectionsCount: int

var lastSpawned = -15

func _process(delta: float) -> void:
	if player.position.y < (lastSpawned):
		spawnNewSection(lastSpawned - sectionHeight)

func spawnNewSection(position):
	var newSection = section.instantiate()
	newSection.position.y = position
	lastSpawned = position
	add_child(newSection)
