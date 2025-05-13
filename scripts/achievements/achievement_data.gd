extends Node

class_name FishAchievement

var fish_type: FishesConfig.FishType
var is_discovered: bool = false
var caught_shiny: bool = false
var caught_in_air: bool = false
var display_name: String
var texture_path: String

func _init(type: FishesConfig.FishType, name: String, texture: String):
	fish_type = type
	display_name = name
	texture_path = texture

static func get_all_achievements() -> Array[FishAchievement]:
	var achievements: Array[FishAchievement] = []
	
	achievements.append(FishAchievement.new(FishesConfig.FishType.FISH_A, "Common Fish", "res://textures/fish_a_icon.png"))
	achievements.append(FishAchievement.new(FishesConfig.FishType.FISH_B, "Swift Fish", "res://textures/fish_b_icon.png"))
	achievements.append(FishAchievement.new(FishesConfig.FishType.ANGLER_FISH, "Angler Fish", "res://textures/angler_fish_icon.png"))
	achievements.append(FishAchievement.new(FishesConfig.FishType.DUMMY_FISH, "Dummy Fish", "res://textures/dummy_fish_icon.png"))
	achievements.append(FishAchievement.new(FishesConfig.FishType.SPIKEY_FISH, "Spikey Fish", "res://textures/spikey_fish_icon.png"))
	
	return achievements