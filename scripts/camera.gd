extends Camera3D

@export var directional_light: DirectionalLight3D

var environment_color_map = {
	GameState.Stage.SURFACE: Color.from_rgba8(30, 110, 163, 255),
	GameState.Stage.DEEP: Color.from_rgba8(30, 110, 163, 255),
	GameState.Stage.DEEPER: Color.from_rgba8(12, 59, 94, 255),
	GameState.Stage.SUPERDEEP: Color.from_rgba8(12, 59, 94, 255),
	GameState.Stage.HOT: Color.from_rgba8(217, 103, 4, 255),
	GameState.Stage.LAVA: Color.from_rgba8(217, 46, 4, 255),
	GameState.Stage.VOID: Color.from_rgba8(10, 10, 10, 255)
}

var environment_light_map = {
	GameState.Stage.SURFACE: 1.0,
	GameState.Stage.DEEP: 0.8,
	GameState.Stage.DEEPER: 0.5,
	GameState.Stage.SUPERDEEP: 0.1,
	GameState.Stage.HOT:  0.2,
	GameState.Stage.LAVA: 1.0,
	GameState.Stage.VOID: 0.1,
}

func _ready():
	environment.fog_light_color = environment_color_map[0]
	directional_light = get_node("/root/Node3D/DirectionalLight3D")

func change_section_environment(sectionType):
	var tween = self.create_tween()
	tween.tween_property(environment, "fog_light_color", environment_color_map[sectionType], 1)
	if (directional_light):
		tween.tween_property(directional_light, "light_energy", environment_light_map[sectionType], 3)
