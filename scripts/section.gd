extends Node3D

@export var sectionType: GameState.Stage = GameState.Stage.SURFACE
@export var water: MeshInstance3D

var depth: int = 0

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
	
