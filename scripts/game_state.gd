extends Node

#DEFINITIONS
enum Stage {SURFACE, DEEP, DEEPER, SUPERDEEP, HOT, LAVA, VOID}
var depthStageMap = {
	0: Stage.SURFACE,
	100: Stage.DEEP,
	200: Stage.DEEPER,
	300: Stage.SUPERDEEP,
	400: Stage.HOT,
	500: Stage.LAVA,
	600: Stage.VOID
}

enum Upgrade {CARGO_SIZE, DEPTH_RESISTANCE, PICKAXE_UNLOCKED, VERT_SPEED, HOR_SPEED, LAMP_UNLOCKED, AK47, DUALAK47, HARPOON, HARPOON_ROTATION, INVENTORY_MANAGEMENT, SURFACE_BUOY, INVENTORY_SAVE, DRONE_SELLING}
var upgradeCosts = {
	Upgrade.CARGO_SIZE: 25,
	Upgrade.DEPTH_RESISTANCE: 50,
	Upgrade.PICKAXE_UNLOCKED: 200,
	Upgrade.VERT_SPEED: 25,
	Upgrade.HOR_SPEED: 25,
	Upgrade.LAMP_UNLOCKED: 50,
	Upgrade.AK47: 500,
	Upgrade.DUALAK47: 500,
	Upgrade.HARPOON: 100,
	Upgrade.HARPOON_ROTATION: 150,
	Upgrade.INVENTORY_MANAGEMENT: 200,
	Upgrade.SURFACE_BUOY: 100,
	Upgrade.INVENTORY_SAVE: 250,
	Upgrade.DRONE_SELLING: 300
}

var maxUpgrades = {
	Upgrade.CARGO_SIZE: 5,
	Upgrade.DEPTH_RESISTANCE: 5,
	Upgrade.PICKAXE_UNLOCKED: 1,
	Upgrade.VERT_SPEED: 2,
	Upgrade.HOR_SPEED: 3,
	Upgrade.LAMP_UNLOCKED: 1,
	Upgrade.AK47: 1,
	Upgrade.DUALAK47: 1,
	Upgrade.HARPOON: 1,
	Upgrade.HARPOON_ROTATION: 1,
	Upgrade.INVENTORY_MANAGEMENT: 1,
	Upgrade.SURFACE_BUOY: 1,
	Upgrade.INVENTORY_SAVE: 1,
	Upgrade.DRONE_SELLING: 1
}

#STATE
var upgrades = {
	Upgrade.CARGO_SIZE: 0,
	Upgrade.DEPTH_RESISTANCE: 0,
	Upgrade.PICKAXE_UNLOCKED: 0,
	Upgrade.VERT_SPEED: 0,
	Upgrade.HOR_SPEED: 0,
	Upgrade.LAMP_UNLOCKED: 0,
	Upgrade.AK47: 0,
	Upgrade.DUALAK47: 0,
	Upgrade.HARPOON: 0,
	Upgrade.HARPOON_ROTATION: 0,
	Upgrade.INVENTORY_MANAGEMENT: 0,
	Upgrade.SURFACE_BUOY: 0,
	Upgrade.INVENTORY_SAVE: 0,
	Upgrade.DRONE_SELLING: 0
}
var depth = 0
var maxDepthReached = 0
var money = 25
var isDocked = false
var fishes_lower_boarder = -15 - 12

var player_node: CharacterBody3D = null
var god_mode = false
var health = 100.0
var headroom = 0
var death_screen = false
var paused = true

var inventory: Inv = Inv.new()

var playerInStage: Stage = Stage.SURFACE

func setDepth(d: int):
	depth = d
	if (maxDepthReached < d):
		maxDepthReached = d
	if snapped(d, 100) <= depthStageMap.keys()[len(depthStageMap.keys())-1]:
		GameState.playerInStage = depthStageMap[snapped(d, 100)]
	else:
		GameState.playerInStage = Stage.VOID
	
func getUpgradeCost(mUpgrade: Upgrade) -> float:
	return (upgrades[mUpgrade] + 1) * upgradeCosts[mUpgrade]

func upgrade(mUpgrade: Upgrade) -> bool:
	var cost = getUpgradeCost(mUpgrade)
	if money >= cost && upgrades[mUpgrade] < maxUpgrades[mUpgrade]:
		money -= cost
		upgrades[mUpgrade] += 1
		return true
	else:
		return false
