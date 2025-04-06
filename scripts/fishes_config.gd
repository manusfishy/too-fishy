extends Node


enum FishType {
	GOLD_FISH,
	CLOWN_FISH,
	RARE_FISH
}

var fishConfigMap = {
	FishType.GOLD_FISH: {
		weight_min = 1,
		weight_max = 10,
		price_weight_multiplier = 1,
		speed_min = 1,
		speed_max = 2.5,
		difficulty = 1,
		scene = preload("res://scenes/mobs/gold_fish.tscn")
	},
	FishType.CLOWN_FISH: {
		weight_min = 1,
		weight_max = 5,
		price_weight_multiplier = 1.2,
		speed_min = 2,
		speed_max = 5,
		difficulty = 1,
		scene = preload("res://scenes/mobs/clown_fish.tscn")
	},
	FishType.RARE_FISH: {
		weight_min = 5,
		weight_max = 10,
		price_weight_multiplier = 3,
		speed_min = 0.5,
		speed_max = 1.5,
		difficulty = 5,
		scene = preload("res://scenes/mobs/rare_fish.tscn")
	}
}

var fishSectionMap = {
	GameState.Stage.SURFACE: {
		max_fish_amount = 4,
		spawnRates = {
			FishType.RARE_FISH: 1
		}
	},
	GameState.Stage.DEEP: {
		max_fish_amount = 6,
		spawnRates = {
			FishType.GOLD_FISH: .5,
			FishType.CLOWN_FISH: .5
		}
	},
	GameState.Stage.DEEPER: {
		max_fish_amount = 4,
		spawnRates = {
			FishType.CLOWN_FISH: .9,
			FishType.RARE_FISH: .1
		}
	}
}
