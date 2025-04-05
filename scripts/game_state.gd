extends Node
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

var depth = 0
var maxDepthReached = 0
var money = 0
var upgrades = []
var playerInStage: Stage = Stage.SURFACE

func setDepth(d: int):
	depth = d
	if (maxDepthReached < d):
		maxDepthReached = d
	GameState.playerInStage = depthStageMap[snapped(d, 100)]
