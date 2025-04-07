extends Node3D

@export var section: PackedScene
@export var level_wrapper: Node3D
@export var player: CharacterBody3D
@export var boss: PackedScene
@export var boss_section: PackedScene

@export var sectionHeight: float
@export var preloadSectionsCount: int

var last_section_type: GameState.Stage = GameState.Stage.SURFACE

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
	var i = snapped(-position, 100)
	i = min(i, GameState.depthStageMap.keys()[len(GameState.depthStageMap.keys())-1])
	newSection.sectionType = GameState.depthStageMap[i]
	newSection.lastSectionType = last_section_type
	lastSpawned = position
	GameState.fishes_lower_boarder = lastSpawned - sectionHeight/2 - 1
	if position <= -50:
		newSection.setDepth(position * -1)
	add_child(newSection)
	last_section_type = GameState.depthStageMap[i]

func spawnBoss(position: float):
	print("Spawn boss", position)
	var spawned_boss = boss.instantiate()
	spawned_boss.position.y = position
	spawned_boss.position.z = -0.33
	spawned_boss.position.x = -5
	spawned_boss.player = player
	add_child(spawned_boss)
	Boss.setBossSpawned()
	
	position = lastSpawned - sectionHeight
	var bossSection = boss_section.instantiate()
	bossSection.position.y = position
	var i = snapped(-position, 100)
	
	i = min(i, GameState.depthStageMap.keys()[len(GameState.depthStageMap.keys())-1])
	
	lastSpawned = position + 50
	GameState.fishes_lower_boarder = lastSpawned - sectionHeight/2 - 1

	add_child(bossSection)
	
#func process_dialog_options():
	
