extends PanelContainer

func _process(_delta: float) -> void:
	$MarginContainer/HUDContainer/DepthLabel.text = "Depth: %sm" % GameState.depth
	$MarginContainer/HUDContainer/MaxDepthLabel.text = "Depth Reached: %sm" % GameState.maxDepthReached
	# Money display moved to inventory UI
	$MarginContainer/HUDContainer/CurrentStageLabel.text = "%s" % Strings.stageNames[GameState.playerInStage]
	$MarginContainer/HUDContainer/HealthBar.value = GameState.health
	$MarginContainer/HUDContainer/PressureHeadroomBar.value = GameState.headroom / (GameState.upgrades[GameState.Upgrade.DEPTH_RESISTANCE] + 1)
