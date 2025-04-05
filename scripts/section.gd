extends Node3D
enum Stage {SURFACE, DEEP, DEEPER, SUPERDEEP, HOT, LAVA, VOID}

@export var sectionType: Stage = Stage.SURFACE
@export var water: MeshInstance3D

var depth: int = 0

var materialMap = {
	Stage.SURFACE: preload("res://materials/water/surface.tres"),
	Stage.DEEP: preload("res://materials/water/deep.tres"),
	Stage.DEEPER: preload("res://materials/water/deeper.tres"),
	Stage.SUPERDEEP: preload("res://materials/water/superdeep.tres"),
	Stage.HOT: preload("res://materials/water/hot.tres"),
	Stage.LAVA: preload("res://materials/water/lava.tres"),
	Stage.VOID: preload("res://materials/water/void.tres")
	}

var depthStageMap = {
	0: Stage.SURFACE,
	100: Stage.DEEP,
	200: Stage.DEEPER,
	300: Stage.SUPERDEEP,
	400: Stage.HOT,
	500: Stage.LAVA,
	600: Stage.VOID
}

func setDepth(d: int):
	depth = d
	var depthSnapped = snapped(depth, 100)
	sectionType = depthStageMap[depthSnapped]
	water.set_surface_override_material(0, materialMap[sectionType])
	print("set material to", materialMap[sectionType])
	
