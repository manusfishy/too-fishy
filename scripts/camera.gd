extends Camera3D

var environment_color_map = {
	GameState.Stage.SURFACE: Color.AQUAMARINE * 0.4,
	GameState.Stage.DEEP: Color.AQUA,
	GameState.Stage.DEEPER: Color.CADET_BLUE,
	GameState.Stage.SUPERDEEP: Color.DARK_CYAN,
	GameState.Stage.HOT: Color.CORNFLOWER_BLUE,
	GameState.Stage.LAVA: Color.ORANGE_RED,
	GameState.Stage.VOID: Color.BLACK
}

func _ready():
	environment.fog_light_color = environment_color_map[0]

func change_section_environment(sectionType):
	var tween = self.create_tween()
	tween.tween_property(environment, "fog_light_color", environment_color_map[sectionType], 1)
