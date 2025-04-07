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

enum Upgrade {ROD_STRENGTH, DEPTH_RESISTANCE, PICKAXE_UNLOCKED, VERT_SPEED, HOR_SPEED, LAMP_UNLOCKED}
var upgradeCosts = {
	Upgrade.ROD_STRENGTH: 25,
	Upgrade.DEPTH_RESISTANCE: 50,
	Upgrade.PICKAXE_UNLOCKED: 200,
	Upgrade.VERT_SPEED: 25,
	Upgrade.HOR_SPEED: 25,
	Upgrade.LAMP_UNLOCKED: 50,
}

var maxUpgrades = {
	Upgrade.ROD_STRENGTH: 5,
	Upgrade.DEPTH_RESISTANCE: 5,
	Upgrade.PICKAXE_UNLOCKED: 1,
	Upgrade.VERT_SPEED: 5,
	Upgrade.HOR_SPEED: 5,
	Upgrade.LAMP_UNLOCKED: 1,
}

#STATE
var upgrades = {
	Upgrade.ROD_STRENGTH: 0,
	Upgrade.DEPTH_RESISTANCE: 0,
	Upgrade.PICKAXE_UNLOCKED: 0,
	Upgrade.VERT_SPEED: 0,
	Upgrade.HOR_SPEED: 0,
	Upgrade.LAMP_UNLOCKED: 0,
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
	GameState.playerInStage = depthStageMap[snapped(d, 100)]
	
func getUpgradeCost(upgrade: Upgrade) -> float:
	return (upgrades[upgrade] + 1) * upgradeCosts[upgrade]

func upgrade(upgrade: Upgrade) -> bool:
	var cost = getUpgradeCost(upgrade)
	if money >= cost && upgrades[upgrade] < maxUpgrades[upgrade]:
		money -= cost
		upgrades[upgrade] += 1
		return true
	else:
		return false
