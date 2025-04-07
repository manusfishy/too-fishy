extends Node3D

@export var sectionType: GameState.Stage = GameState.Stage.SURFACE
@export var lastSectionType: GameState.Stage = GameState.Stage.SURFACE

@export var water: MeshInstance3D
@export var spawn_marker_a: Marker3D
@export var spawn_marker_b: Marker3D
@export var background_mat: StandardMaterial3D
@export var lava_vine_mat: StandardMaterial3D = preload("res://materials/walls/veins_lava.tres")
@export var particles_enabled: bool = true

var sectionBackgroundMap: Dictionary = {
	GameState.Stage.SURFACE: preload("res://materials/backgrounds/bg_loop.tres"),
	GameState.Stage.DEEP: preload("res://materials/backgrounds/bg_loop.tres"),
	GameState.Stage.DEEPER: preload("res://materials/backgrounds/bg_loop.tres"),
	GameState.Stage.SUPERDEEP: preload("res://materials/backgrounds/bg_loop.tres"),
	GameState.Stage.HOT: preload("res://materials/backgrounds/bg_loop.tres"),
	GameState.Stage.LAVA: preload("res://materials/backgrounds/bg_lava.tres"),
	GameState.Stage.VOID: preload("res://materials/backgrounds/bg_lava.tres"),
}

var sectionTransitions: Dictionary = {
	GameState.Stage.HOT: preload("res://materials/backgrounds/bg_deep_to_lava.tres"),
	GameState.Stage.LAVA: preload("res://materials/backgrounds/bg_lava_to_void.tres"),
}

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
		var fishType = null
		for type in FishesConfig.fishSectionMap[sectionType].spawnRates:
			commulative_spawn_rate += FishesConfig.fishSectionMap[sectionType].spawnRates[type]
			if r <= commulative_spawn_rate:
				fishType = type
				spawn_fish_config = FishesConfig.fishConfigMap[type]
				break
		var fish = spawn_fish_config.scene.instantiate()
		
		var shiny = randf() < FishesConfig.fishSectionMap[sectionType].shiny_rate
	
		fish.initialize(spawn_pos, self.get_instance_id(), 
			spawn_fish_config.speed_min, spawn_fish_config.speed_max, 
			spawn_fish_config.difficulty, 
			spawn_fish_config.weight_min, spawn_fish_config.weight_max, 
			spawn_fish_config.price_weight_multiplier,
			fishType,
			shiny
			)
		add_child(fish)
		amount += 1
		if !spawn_all:
			break

func _ready() -> void:
	if not particles_enabled:
		$Debris.visible = false
		$Bubbles.visible = false
	spawn_fish(true)
	
	var shouldBeTransition = false
	var shouldTransitionTo: GameState.Stage = GameState.Stage.SURFACE
	if sectionTransitions.has(lastSectionType) and sectionTransitions.has(sectionType):
		if lastSectionType == GameState.Stage.HOT and sectionType == GameState.Stage.LAVA:
			shouldBeTransition = true
			shouldTransitionTo = GameState.Stage.HOT
	
	if shouldBeTransition:
		background_mat = sectionTransitions[shouldTransitionTo]
		$Background.set_surface_override_material(0, background_mat)
	else:
		if background_mat == null:
			if sectionBackgroundMap[sectionType] != null:
				background_mat = sectionBackgroundMap[sectionType]
			else:
				print("No background material found for ", GameState.Stage.keys()[sectionType])
				background_mat = sectionBackgroundMap[GameState.Stage.SURFACE]
	$Background.set_surface_override_material(0, background_mat)

	if sectionType == GameState.Stage.LAVA:
		$LeftWall/Node3D2/Veins.set_surface_override_material(0, lava_vine_mat)
		$LeftWall2/Node3D2/Veins.set_surface_override_material(0, lava_vine_mat)
	
func screen_entered() -> void:
	is_on_screen = true

func screen_exited() -> void:
	is_on_screen = false

func respawn_timer_expired() -> void:
	if !is_on_screen:
		spawn_fish()
