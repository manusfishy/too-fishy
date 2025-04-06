extends PanelContainer

func _ready() -> void:
	$VBoxContainer/ContinueButton.pressed.connect(func (): 
		if Boss.boss_dialog_index < len(Strings.boss_dialog_lines[Boss.boss_dialog_section]) -1:
			Boss.boss_dialog_index += 1
		else:
			Boss.boss_dialog_displayed = false
			Boss.boss_dialog_section += 1
			Boss.boss_dialog_index = 0
			GameState.paused = false
		)

func _process(delta: float) -> void:
	if Boss.boss_dialog_displayed:
		$VBoxContainer/MessageLabel.text = Strings.boss_dialog_lines[Boss.boss_dialog_section][Boss.boss_dialog_index]
		$VBoxContainer/NameLabel.text = Boss.boss_dialog_from[Boss.boss_dialog_section]
		visible = true
	else:
		visible = false
