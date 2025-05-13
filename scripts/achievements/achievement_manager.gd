class_name AchievementManager
extends Node

const FishAchievement = preload("res://scripts/achievements/achievement_data.gd")

signal achievement_unlocked(achievement: FishAchievement)
signal achievement_updated(achievement: FishAchievement)

var achievements: Dictionary = {}

func _ready():
	_initialize_achievements()
	
func _initialize_achievements():
	for achievement in FishAchievement.get_all_achievements():
		achievements[achievement.fish_type] = achievement
		
func record_fish_catch(fish_type: FishesConfig.FishType, is_shiny: bool, caught_in_air: bool):
	if not achievements.has(fish_type):
		return
		
	var achievement = achievements[fish_type]
	var was_discovered = achievement.is_discovered
	
	achievement.is_discovered = true
	if is_shiny:
		achievement.caught_shiny = true
	if caught_in_air:
		achievement.caught_in_air = true
		
	if !was_discovered:
		achievement_unlocked.emit(achievement)
	else:
		achievement_updated.emit(achievement)
		
	save_achievements()

func save_achievements():
	var save_data = {}
	for type in achievements:
		var achievement = achievements[type]
		save_data[type] = {
			"discovered": achievement.is_discovered,
			"shiny": achievement.caught_shiny,
			"air": achievement.caught_in_air
		}
	
	var save_game = FileAccess.open("user://achievements.save", FileAccess.WRITE)
	var json_string = JSON.stringify(save_data)
	save_game.store_line(json_string)
	
func load_achievements():
	if not FileAccess.file_exists("user://achievements.save"):
		return
		
	var save_game = FileAccess.open("user://achievements.save", FileAccess.READ)
	var json_string = save_game.get_line()
	var save_data = JSON.parse_string(json_string)
	
	if save_data:
		for type_str in save_data:
			var type = int(type_str)
			if achievements.has(type):
				var achievement = achievements[type]
				var data = save_data[type_str]
				achievement.is_discovered = data.discovered
				achievement.caught_shiny = data.shiny
				achievement.caught_in_air = data.air