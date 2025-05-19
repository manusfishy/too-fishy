extends Node


enum FishType {
	FISH_A,
	FISH_B,
	ANGLER_FISH,
	DUMMY_FISH,
	SPIKEY_FISH
}

var fishConfigMap = {
	FishType.FISH_A: {
		weight_min = 1,
		weight_max = 10,
		price_weight_multiplier = 1,
		speed_min = 1,
		speed_max = 2.5,
		difficulty = 1,
		scene = preload("res://scenes/mobs/BasicFishA.tscn"),
		icon = preload("res://textures/icons/fish_a.png")
	},
	FishType.FISH_B: {
		weight_min = 1,
		weight_max = 5,
		price_weight_multiplier = 1.2,
		speed_min = 2,
		speed_max = 5,
		difficulty = 1,
		scene = preload("res://scenes/mobs/BasicFishB.tscn"),
		icon = preload("res://textures/icons/fish_b.png")
	},
	FishType.ANGLER_FISH: {
		weight_min = 5,
		weight_max = 10,
		price_weight_multiplier = 3,
		speed_min = 0.1,
		speed_max = 1,
		difficulty = 5,
		scene = preload("res://scenes/mobs/AnglerFish.tscn"),
		icon = preload("res://textures/icons/angler_fish.png")
	},
	FishType.DUMMY_FISH: {
		weight_min = 5,
		weight_max = 10,
		price_weight_multiplier = 10,
		speed_min = 3,
		speed_max = 7,
		difficulty = 10,
		scene = preload("res://scenes/mobs/dummy_fish.tscn"),
		icon = preload("res://textures/icons/dummy_fish.png")
	},
	FishType.SPIKEY_FISH: {
		weight_min = 5,
		weight_max = 10,
		price_weight_multiplier = 3,
		speed_min = 0.5,
		speed_max = 1.5,
		difficulty = 5,
		scene = preload("res://scenes/mobs/spikey_fish.tscn"),
		icon = preload("res://textures/icons/spikey_fish.png")
	}
}

var fishSectionMap = {
	GameState.Stage.SURFACE: {
		max_fish_amount = 15,
		shiny_rate = .02,
		weight_multiplier = .8,
		spawnRates = {
			FishType.FISH_A: .9,
			FishType.FISH_B: .1,
		}
	},
	GameState.Stage.DEEP: {
		max_fish_amount = 10,
		shiny_rate = .02,
		weight_multiplier = .9,
		spawnRates = {
			FishType.FISH_A: .7,
			FishType.FISH_B: .3,
		}
	},
	GameState.Stage.DEEPER: {
		max_fish_amount = 10,
		shiny_rate = .04,
		weight_multiplier = 1,
		spawnRates = {
			FishType.FISH_A: .5,
			FishType.FISH_B: .4,
			FishType.SPIKEY_FISH: .1
		}
	},
	GameState.Stage.SUPERDEEP: {
		max_fish_amount = 8,
		shiny_rate = .04,
		weight_multiplier = 1.1,
		spawnRates = {
			FishType.FISH_A: .2,
			FishType.FISH_B: .45,
			FishType.ANGLER_FISH: .14,
			FishType.DUMMY_FISH: .01,
			FishType.SPIKEY_FISH: .2
		}
	},
	GameState.Stage.HOT: {
		max_fish_amount = 5,
		shiny_rate = .05,
		weight_multiplier = 1.15,
		spawnRates = {
			FishType.FISH_B: .2,
			FishType.ANGLER_FISH: .55,
			FishType.DUMMY_FISH: .05,
			FishType.SPIKEY_FISH: .2
		}
	},
	GameState.Stage.LAVA: {
		max_fish_amount = 4,
		shiny_rate = .06,
		weight_multiplier = 1.15,
		spawnRates = {
			FishType.ANGLER_FISH: .7,
			FishType.DUMMY_FISH: .2,
			FishType.SPIKEY_FISH: .1
		}
	},
	GameState.Stage.VOID: {
		max_fish_amount = 1,
		shiny_rate = .08,
		weight_multiplier = 1.2,
		spawnRates = {
			FishType.DUMMY_FISH: .1,
			FishType.ANGLER_FISH: .1,
			FishType.FISH_A: .8,
		}
	}
}
