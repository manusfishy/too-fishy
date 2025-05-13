extends Panel

var achievement = null

@onready var icon = $Icon
@onready var shiny_indicator = $ShinyIndicator
@onready var air_indicator = $AirIndicator
@onready var question_mark = $QuestionMark

func set_achievement(new_achievement):
	achievement = new_achievement
	icon.texture = load(achievement.texture_path)
	icon.show()
	question_mark.hide()
	
func set_undiscovered():
	achievement = null
	icon.hide()
	shiny_indicator.hide()
	air_indicator.hide()
	question_mark.show()
	
func show_shiny_indicator():
	shiny_indicator.show()
	
func show_air_indicator():
	air_indicator.show()
	
func _ready():
	shiny_indicator.hide()
	air_indicator.hide()
	set_undiscovered()