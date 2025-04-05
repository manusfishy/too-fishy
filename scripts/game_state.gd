extends Node

var depth = 0
var maxDepthReached = 0
var money = 0
var upgrades = []

func setDepth(d: int):
	depth = d
	if (maxDepthReached < d):
		maxDepthReached = d
