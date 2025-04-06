extends Node3D

@export var section: PackedScene
@export var level_wrapper: Node3D
@export var player: CharacterBody3D

@export var sectionHeight: float
@export var preloadSectionsCount: int

var lastSpawned = -15
var snappedDepth = 0
func _process(delta: float) -> void:
	GameState.setDepth(player.position.y * -1)
	snappedDepth = snapped(player.position.y, 1) * -1
	if player.position.y < (lastSpawned):
		spawnNewSection(lastSpawned - sectionHeight)

func spawnNewSection(position):
	var newSection = section.instantiate()
	newSection.position.y = position
	lastSpawned = position
	GameState.fishes_lower_boarder = lastSpawned - sectionHeight/2 - 1
	if position <= -40:
		newSection.setDepth(position * -1)
	add_child(newSection)
