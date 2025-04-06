extends Node3D

@export var section: PackedScene
@export var level_wrapper: Node3D
@export var player: CharacterBody3D
@export var boss: PackedScene

@export var sectionHeight: float
@export var preloadSectionsCount: int

var lastSpawned = -35
var snappedDepth = 0
func _process(delta: float) -> void:
	GameState.setDepth(player.position.y * -1)
	snappedDepth = snapped(player.position.y, 1) * -1
	if player.position.y < (lastSpawned):
		spawnNewSection(lastSpawned - sectionHeight)
	if GameState.maxDepthReached > Boss.boss_spawn_height && Boss.boss_spawned == false:
		var boss_spawn_loc = (GameState.maxDepthReached * -1) - 25
		spawnBoss(boss_spawn_loc)

func spawnNewSection(position: float):
	var newSection = section.instantiate()
	newSection.position.y = position
	lastSpawned = position
	GameState.fishes_lower_boarder = lastSpawned - sectionHeight/2 - 1
	if position <= -50:
		newSection.setDepth(position * -1)
	add_child(newSection)

func spawnBoss(position: float):
	print("Spawn boss", position)
	var spawned_boss = boss.instantiate()
	spawned_boss.position.y = position
	spawned_boss.position.z = 0.33
	spawned_boss.position.x = -5
	add_child(spawned_boss)
	Boss.setBossSpawned()
	
