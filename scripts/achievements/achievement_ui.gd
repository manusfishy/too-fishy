extends Control

@onready var grid_container = $GridContainer
@onready var achievement_manager = $"/root/AchievementManager"

var achievement_slot_scene = preload("res://scenes/ui/achievement_slot.tscn")

func _ready():
	achievement_manager.achievement_unlocked.connect(_on_achievement_unlocked)
	achievement_manager.achievement_updated.connect(_on_achievement_updated)
	_initialize_slots()
	
func _initialize_slots():
	for achievement in achievement_manager.achievements.values():
		var slot = achievement_slot_scene.instantiate()
		grid_container.add_child(slot)
		
		if achievement.is_discovered:
			_update_slot(slot, achievement)
		else:
			slot.set_undiscovered()
			
func _on_achievement_unlocked(achievement):
	for slot in grid_container.get_children():
		if slot.achievement == null or slot.achievement == achievement:
			_update_slot(slot, achievement)
			break
			
func _on_achievement_updated(achievement):
	for slot in grid_container.get_children():
		if slot.achievement == achievement:
			_update_slot(slot, achievement)
			break
			
func _update_slot(slot, achievement):
	slot.set_achievement(achievement)
	if achievement.caught_shiny:
		slot.show_shiny_indicator()
	if achievement.caught_in_air:
		slot.show_air_indicator()