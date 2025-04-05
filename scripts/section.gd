extends Node3D

@export var sectionType: GameState.Stage = GameState.Stage.SURFACE
@export var water: MeshInstance3D
@export var spawn_area: MeshInstance3D

var depth: int = 0
var is_on_screen: bool = false

var materialMap = {
	GameState.Stage.SURFACE: preload("res://materials/water/surface.tres"),
	GameState.Stage.DEEP: preload("res://materials/water/deep.tres"),
	GameState.Stage.DEEPER: preload("res://materials/water/deeper.tres"),
	GameState.Stage.SUPERDEEP: preload("res://materials/water/superdeep.tres"),
	GameState.Stage.HOT: preload("res://materials/water/hot.tres"),
	GameState.Stage.LAVA: preload("res://materials/water/lava.tres"),
	GameState.Stage.VOID: preload("res://materials/water/void.tres")
	}


func setDepth(d: int):
	depth = d
	var depthSnapped = snapped(depth, 100)
	sectionType = GameState.depthStageMap[depthSnapped]
	water.set_surface_override_material(0, materialMap[sectionType])
	print("set material to", materialMap[sectionType])
	


func spawn_fish(spawn_all: bool = false):
	if !FishesConfig.fishSectionMap.has(sectionType):
		print("No fish spawns defined for ", GameState.Stage.keys()[sectionType])
		return
	var amount = len(get_tree().get_nodes_in_group("fishes").filter(func(x): return x.home_stage == sectionType))
	var spawn_aabb = spawn_area.get_aabb()
	var start_pos = (spawn_aabb.position)
	var end_pos = (spawn_aabb.position + spawn_aabb.size)
	while amount < FishesConfig.fishSectionMap[sectionType].max_fish_amount:
		var r = randf()
		var spawn_pos = Vector3(randf_range(start_pos.x, end_pos.x), randf_range(start_pos.y, end_pos.y), 1)
		spawn_pos = to_global(spawn_pos)
		spawn_pos.z = -0.3
		var commulative_spawn_rate = 0
		var spawn_fish_config = null
		for type in FishesConfig.fishSectionMap[sectionType].spawnRates:
			commulative_spawn_rate += FishesConfig.fishSectionMap[sectionType].spawnRates[type]
			if r <= commulative_spawn_rate:
				spawn_fish_config = FishesConfig.fishConfigMap[type]
				break
		var fish = spawn_fish_config.scene.instantiate()
		fish.initialize(spawn_pos, sectionType, 
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
