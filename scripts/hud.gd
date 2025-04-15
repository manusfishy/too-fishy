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
	
	# Change bar color based on headroom percentage
	if headroom_value <= 0.15:  # 15% or less - red
		# Change both the bar color and the modulate property for full effect
		var style_box = $MarginContainer/HUDContainer/PressureHeadroomBar.get("theme_override_styles/fill")
		if style_box == null:
			style_box = StyleBoxFlat.new()
			$MarginContainer/HUDContainer/PressureHeadroomBar.set("theme_override_styles/fill", style_box)
		style_box.bg_color = Color(1, 0, 0)  # Red
	elif headroom_value <= 0.3:  # Between 15% and 30% - orange
		var style_box = $MarginContainer/HUDContainer/PressureHeadroomBar.get("theme_override_styles/fill")
		if style_box == null:
			style_box = StyleBoxFlat.new()
			$MarginContainer/HUDContainer/PressureHeadroomBar.set("theme_override_styles/fill", style_box)
		style_box.bg_color = Color(1, 0.5, 0)  # Orange
	else:  # Above 30% - default blue
		var style_box = $MarginContainer/HUDContainer/PressureHeadroomBar.get("theme_override_styles/fill")
		if style_box == null:
			style_box = StyleBoxFlat.new()
			$MarginContainer/HUDContainer/PressureHeadroomBar.set("theme_override_styles/fill", style_box)
		style_box.bg_color = Color(0, 0.36, 0.83)  # Default blue from the theme
