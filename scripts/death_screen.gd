extends PanelContainer

func _process(_delta: float) -> void:
	if GameState.death_screen:
		visible = true
	else:
		visible = false

func _ready() -> void:
	$VBoxContainer/Button.pressed.connect(func (): 
		GameState.death_screen = false
		GameState.paused = false
	)
