extends PanelContainer

func _process(delta: float) -> void:
	$HUDContainer/DepthLabel.text = "Depth: %sm" % GameState.depth
	$HUDContainer/MaxDepthLabel.text = "Depth Reached: %sm" % GameState.maxDepthReached
	$HUDContainer/MoneyLabel.text = "Money: %s" % GameState.money
	$HUDContainer/CurrentStageLabel.text = "%s" % Strings.stageNames[GameState.playerInStage]
