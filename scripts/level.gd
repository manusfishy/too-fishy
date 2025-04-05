extends Node3D
enum Stage {SURFACE, DEEP, DEEPER, SUPERDEEP, HOT, LAVA, VOID}

@export var section: PackedScene
@export var level_wrapper: Node3D
@export var player: CharacterBody3D

@export var sectionHeight: float
@export var preloadSectionsCount: int

var lastSpawned = -15
var depth = 0

func _process(delta: float) -> void:
	depth = snapped(player.position.y, 1) * -1
	if player.position.y < (lastSpawned):
		spawnNewSection(lastSpawned - sectionHeight)

func spawnNewSection(position):
	var newSection = section.instantiate()
	newSection.position.y = position
	lastSpawned = position
	if position <= -40:
		newSection.setDepth(position * -1)
	add_child(newSection)
