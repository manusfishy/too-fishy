extends PanelContainer

func _process(_delta: float) -> void:
	$MarginContainer/HUDContainer/DepthLabel.text = "Depth: %sm" % GameState.depth
	$MarginContainer/HUDContainer/MaxDepthLabel.text = "Depth Reached: %sm" % GameState.maxDepthReached
	# Money display moved to inventory UI
	$MarginContainer/HUDContainer/CurrentStageLabel.text = "%s" % Strings.stageNames[GameState.playerInStage]
	$MarginContainer/HUDContainer/HealthBar.value = GameState.health
	
	# Update pressure headroom bar value
	var headroom_value = GameState.headroom / (GameState.upgrades[GameState.Upgrade.DEPTH_RESISTANCE] + 1)
	$MarginContainer/HUDContainer/PressureHeadroomBar.value = headroom_value
	
	# Change color to red when near 0%
	if headroom_value <= 0.2:  # 20% or less is considered "near 0%"
		$MarginContainer/HUDContainer/PressureHeadroomBar.modulate = Color(1, 0, 0)  # Red
	else:
		$MarginContainer/HUDContainer/PressureHeadroomBar.modulate = Color(1, 1, 1)  # Default white
