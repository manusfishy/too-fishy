extends Node3D

@export var sectionType: GameState.Stage = GameState.Stage.SURFACE
@export var water: MeshInstance3D
@export var spawn_marker_a: Marker3D
@export var spawn_marker_b: Marker3D

var depth: int = 0
var is_on_screen: bool = false

func setDepth(d: int):
	depth = d
	var depthSnapped = snapped(depth, 100)

func spawn_fish(spawn_all: bool = false):
	var stage_name = GameState.Stage.keys()[sectionType]
	if !FishesConfig.fishSectionMap.has(sectionType):
		print("No fish spawns defined for ", GameState.Stage.keys()[sectionType])
		return
	var amount = len(get_tree().get_nodes_in_group("fishes").filter(func(x): return x.home == self.get_instance_id()))
	while amount < FishesConfig.fishSectionMap[sectionType].max_fish_amount:
		var r = randf()
		var spawn_pos = Vector3(randf_range(spawn_marker_a.position.x, spawn_marker_b.position.x), 
							randf_range(spawn_marker_a.position.y, spawn_marker_b.position.y), 1)
		spawn_pos.z = -0.3
		var commulative_spawn_rate = 0
		var spawn_fish_config = null
		for type in FishesConfig.fishSectionMap[sectionType].spawnRates:
			commulative_spawn_rate += FishesConfig.fishSectionMap[sectionType].spawnRates[type]
			if r <= commulative_spawn_rate:
				spawn_fish_config = FishesConfig.fishConfigMap[type]
				break
		var fish = spawn_fish_config.scene.instantiate()
		fish.initialize(spawn_pos, self.get_instance_id(), 
			spawn_fish_config.speed_min, spawn_fish_config.speed_max, 
			spawn_fish_config.difficulty, 
			spawn_fish_config.weight_min, spawn_fish_config.weight_max, 
			spawn_fish_config.price_weight_multiplier)
		add_child(fish)
		amount += 1
		if !spawn_all:
			break

func _ready() -> void:
	spawn_fish(true)

func screen_entered() -> void:
	is_on_screen = true

func screen_exited() -> void:
	is_on_screen = false
